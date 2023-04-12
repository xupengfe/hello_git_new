#include <time.h>
#include <errno.h>
#include <sys/syscall.h>

long main(void) {
    struct timespec req;
    req.tv_sec = 1;
    req.tv_nsec = 1000;
    long result;

    asm volatile(
        "syscall"
        : "=a" (result)
        : "0" (__NR_nanosleep), "D" (&req)
        : "rcx", "r11", "memory"
    );
    if (result == -1 && errno != EINTR) {
        return -errno;
    }
    return result;
}
