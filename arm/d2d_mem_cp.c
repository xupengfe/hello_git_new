#define _GNU_SOURCE
#include <numa.h>
#include <numaif.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sched.h>
#include <unistd.h>
#include <pthread.h>
#define DEFAULT_MB_SIZE 1024
#define NUM_RUNS 10
int err_num = 0;

double get_elapsed_time(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

void *thread_func(void *arg) {
    cpu_set_t cpuset;
    struct timespec start, end;
    double elapsed;
    double total_elapsed = 0;

    int num_runs = *(int *)arg;

    for (int run = 0; run < num_runs; run++) {
        CPU_ZERO(&cpuset);
        CPU_SET(0, &cpuset);
        pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);

        clock_gettime(CLOCK_REALTIME, &start);
        usleep(1000);

        CPU_ZERO(&cpuset);
        int num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
        int target_cpu = num_cpus - 1;
        CPU_SET(target_cpu, &cpuset);

        if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
            perror("pthread_setaffinity_np");
            pthread_exit(NULL);
        }
        usleep(1000);
        clock_gettime(CLOCK_REALTIME, &end);

        elapsed = get_elapsed_time(start, end);
        printf("Elapsed time for switching from CPU 0 to CPU %d (%d round): %lf seconds\n",
               target_cpu, run + 1, elapsed);
        total_elapsed += elapsed;

        if (run > 0 && (total_elapsed / run) > 0.1) {  // Example stop condition
            printf("Stopping early due to high elapsed time.\n");
            break;
        }
    }

    double average_elapsed = total_elapsed / num_runs;
    printf("Average elapsed time across %d runs: %lf seconds\n", num_runs, average_elapsed);

    return NULL;
}

int main(int argc, char *argv[]) {
    size_t mb_size = DEFAULT_MB_SIZE;
    pthread_t thread;
    void* buffer_node1;
    int num_runs = NUM_RUNS;

    if (argc > 1) {
        mb_size = strtol(argv[1], NULL, 10);
        if (mb_size <= 0) {
            printf("Invalid size specified. Using default size %d MB.\n", DEFAULT_MB_SIZE);
            mb_size = DEFAULT_MB_SIZE;
        }
    }
    printf("Testing mem size %ld MB.\n", mb_size);

    size_t buffer_size = mb_size * 1024 * 1024;

    struct timespec start, end;
    double node01_time = 0, node00_time = 0;

    if (numa_num_configured_nodes() < 2) {
        printf("Platform NUMA nodes < 2, node1 is also the node0!\n");
        buffer_node1 = numa_alloc_onnode(buffer_size, 0);
    } else {
        buffer_node1 = numa_alloc_onnode(buffer_size, 1);
    }

    if (numa_available() < 0) {
        printf("System does not have necessary number of NUMA nodes\n");
        return -1;
    }

    void* buffer = numa_alloc_onnode(buffer_size, 0);
    void* buffer_node0 = numa_alloc_onnode(buffer_size, 0);

    if (!buffer || !buffer_node0 || !buffer_node1) {
        perror("numa_alloc_onnode");
        numa_free(buffer, buffer_size);
        numa_free(buffer_node0, buffer_size);
        numa_free(buffer_node1, buffer_size);
        return -1;
    }

    for (size_t i = 0; i < buffer_size / sizeof(int); i++) {
        ((int*)buffer)[i] = buffer_size - i;
        ((int*)buffer_node1)[i] = 0;
    }

    clock_gettime(CLOCK_MONOTONIC, &start);
    memcpy(buffer_node1, buffer, buffer_size);
    clock_gettime(CLOCK_MONOTONIC, &end);
    node01_time = get_elapsed_time(start, end);

    for (size_t i = 0; i < buffer_size / sizeof(int); i++) {
        if (((int*)buffer_node1)[i] != ((int*)buffer)[i]) {
            err_num++;
            printf("[ERROR] buffer_node1[%zu]:%d != buffer[%zu]:%d\n",
                   i, ((int*)buffer_node1)[i], i, ((int*)buffer)[i]);
        }
    }

    printf("Copy %zu MB memory from node 0 to 1, time taken: %.6f seconds\n",
           mb_size, node01_time);

    for (size_t i = 0; i < buffer_size / sizeof(int); i++) {
        ((int*)buffer)[i] = i;
        ((int*)buffer_node0)[i] = 0;
    }

    clock_gettime(CLOCK_MONOTONIC, &start);
    memcpy(buffer_node0, buffer, buffer_size);
    clock_gettime(CLOCK_MONOTONIC, &end);
    node00_time = get_elapsed_time(start, end);

    for (size_t i = 0; i < buffer_size / sizeof(int); i++) {
        if (((int*)buffer_node0)[i] != ((int*)buffer)[i]) {
            err_num++;
            printf("[ERROR] buffer_node0[%zu]:%d != buffer[%zu]:%d\n",
                   i, ((int*)buffer_node0)[i], i, ((int*)buffer)[i]);
        }
    }

    printf("Copy %zu MB memory from node 0 to 0, time taken: %.6f seconds\n",
           mb_size, node00_time);

    numa_free(buffer, buffer_size);
    numa_free(buffer_node0, buffer_size);
    numa_free(buffer_node1, buffer_size);

    if (pthread_create(&thread, NULL, thread_func, &num_runs)) {
        fprintf(stderr, "Error creating thread\n");
        return 1;
    }

    if (pthread_join(thread, NULL)) {
        fprintf(stderr, "Error joining thread\n");
        return 2;
    }

    return err_num;
}
