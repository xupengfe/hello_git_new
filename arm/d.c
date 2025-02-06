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

int err_num = 0;

double get_elapsed_time(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

void *thread_func(void *arg) {
    cpu_set_t cpuset;
    struct timespec start, end;
    double elapsed;

    CPU_ZERO(&cpuset);
    CPU_SET(0, &cpuset);
    pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);

    clock_gettime(CLOCK_REALTIME, &start);
    usleep(1000);

    CPU_ZERO(&cpuset);
    int num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
    int target_cpu = num_cpus - 1;
    CPU_SET(target_cpu, &cpuset);
    
    pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
    usleep(1000);
    clock_gettime(CLOCK_REALTIME, &end);

    elapsed = (end.tv_sec - start.tv_sec);
    elapsed += (end.tv_nsec - start.tv_nsec) / 1e9;
    printf("Elapsed time for switching from CPU 0 to CPU %d: %lf seconds\n", target_cpu, elapsed);

    return NULL;
}

int main(int argc, char *argv[]) {
    size_t mb_size = DEFAULT_MB_SIZE;
    pthread_t thread;
    void* buffer_node1;

    if (argc > 1) {
        mb_size = strtol(argv[1], NULL, 10);
        if (mb_size <= 0) {
            printf("Invalid size specified. Using default size %d MB.\n", DEFAULT_MB_SIZE);
            mb_size = DEFAULT_MB_SIZE;
        }
    }
    printf("Testing mem size %d MB.\n", mb_size);

    size_t buffer_size = mb_size * 1024 * 1024;

    struct timespec start, end;
    double node01_time = 0, node00_time = 0;

    // Check for at least two NUMA nodes
    if (numa_num_configured_nodes() < 2) {
        printf("Platform NUMA nodes < 2, node1 is also the node0!\n");
        buffer_node1 = numa_alloc_onnode(buffer_size, 0);
    } else {
        buffer_node1 = numa_alloc_onnode(buffer_size, 1);
    }

    // Check for at least two NUMA nodes
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

    if (pthread_create(&thread, NULL, thread_func, NULL)) {
        fprintf(stderr, "Error creating thread\n");
        return 1;
    }

    if (pthread_join(thread, NULL)) {
        fprintf(stderr, "Error joining thread\n");
        return 2;
    }

    return err_num;
}
