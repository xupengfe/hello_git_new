#include <stdio.h>
#include <unistd.h>
#include <stdlib.h> 
#include <stdint.h>
#include <time.h>
#include <cpuid.h>
#include <sys/time.h>
#include <err.h>

#define XSAVE_HDR_OFFSET	512
#define XSAVE_HDR_SIZE		64

#define CPUID_LEAF_XSTATE		0xd
#define CPUID_SUBLEAF_XSTATE_USER	0x0

#define LOOP_TIMES 100

/* err() exits and will not return. */
#define fatal_error(msg, ...)	err(1, "[FAIL]\t" msg, ##__VA_ARGS__)

struct xsave_buffer *valid_xbuf;
static uint32_t xstate_size;

struct xsave_buffer {
	union {
		struct {
			char legacy[XSAVE_HDR_OFFSET];
			char header[XSAVE_HDR_SIZE];
			char extended[0];
		};
		char bytes[0];
	};
};

static inline uint64_t get_tsc()
{
    uint64_t a, d;
    __asm__ volatile("rdtsc" : "=a"(a), "=d"(d));
    return (d << 32) | a;
}

static inline uint64_t get_tscp()
{
    uint64_t a, d;
    __asm__ volatile("rdtscp" : "=a"(a), "=d"(d));
    return (d << 32) | a;
}

static inline void __xsave(struct xsave_buffer *xbuf, uint64_t rfbm)
{
	uint32_t rfbm_lo = rfbm;
	uint32_t rfbm_hi = rfbm >> 32;

	asm volatile("xsave (%%rdi)"
		     : : "D" (xbuf), "a" (rfbm_lo), "d" (rfbm_hi)
		     : "memory");
}

static inline void __xrstor(struct xsave_buffer *xbuf, uint64_t rfbm)
{
	uint32_t rfbm_lo = rfbm;
	uint32_t rfbm_hi = rfbm >> 32;

	asm volatile("xrstor (%%rdi)"
		     : : "D" (xbuf), "a" (rfbm_lo), "d" (rfbm_hi));
}

static uint32_t get_xstate_size(void)
{
	uint32_t eax, ebx, ecx, edx;

	__cpuid_count(CPUID_LEAF_XSTATE, CPUID_SUBLEAF_XSTATE_USER, eax, ebx,
		      ecx, edx);
	/*
	 * EBX enumerates the size (in bytes) required by the XSAVE
	 * instruction for an XSAVE area containing all the user state
	 * components corresponding to bits currently set in XCR0.
	 */
	return ebx;
}

static struct xsave_buffer *alloc_xbuf(uint32_t buf_size)
{
	struct xsave_buffer *xbuf;

	/* XSAVE buffer should be 64B-aligned. */
	xbuf = aligned_alloc(64, buf_size);
	if (!xbuf)
		fatal_error("aligned_alloc()");

	return xbuf;
}

int main(int argc, char **argv)
{
    uint64_t beg_tsc, end_tsc, mask = 0xe7;
    long loop;
    long sum;

    printf("LOOP_TIMES:%d\n", LOOP_TIMES);
    printf("-------------rdtsc-------------\n");
    loop = LOOP_TIMES;
    sum = 0;
    while(loop--)
    {
        beg_tsc = get_tsc();
        end_tsc = get_tsc();
        sum += (end_tsc - beg_tsc);
    }
    printf("AVG_CYCLE : %ld\n", sum / LOOP_TIMES);

    sleep(1);

    printf("-------------rdtscp-------------\n");
    loop = LOOP_TIMES;
    sum = 0;
    while(loop--)
    {
        beg_tsc = get_tscp(); 
        end_tsc = get_tscp();
        sum += (end_tsc - beg_tsc);
    }
    printf("AVG_CYCLE : %ld\n", sum / LOOP_TIMES);

    beg_tsc = get_tsc();
    sleep(1);
    end_tsc = get_tsc();
    printf("\nsleep 1 and rdtsc: %ld, beg: %ld, end: %ld\n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    beg_tsc = get_tscp();
    sleep(1);
    end_tsc = get_tscp();
    printf("sleep 1 and rdtscp: %ld, beg: %ld, end: %ld\n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    printf("\n# cat /proc/cpuinfo | grep -i 'CPU MHz' | head -n 1\n");
    system("cat /proc/cpuinfo | grep -i 'CPU MHz' | head -n 1");
    printf("\n# dmesg | grep MHz\n");
    system("dmesg | grep MHz");

    xstate_size = get_xstate_size();
    valid_xbuf = alloc_xbuf(xstate_size);

    beg_tsc = get_tscp();
    __xsave(valid_xbuf, xstate_size);
    end_tsc = get_tscp();
    printf("xsave tscp time: %ld, beg:%ld, end:%ld \n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    beg_tsc = get_tscp();
    __xrstor(valid_xbuf, xstate_size);
    end_tsc = get_tscp();
    printf("xrstor tscp time: %ld, beg:%ld, end:%ld \n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    beg_tsc = get_tsc();
    __xsave(valid_xbuf, xstate_size);
    end_tsc = get_tsc();
    printf("xsave tsc time: %ld, beg:%ld, end:%ld \n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    beg_tsc = get_tsc();
    __xrstor(valid_xbuf, xstate_size);
    end_tsc = get_tsc();
    printf("xrstor tsc time: %ld, beg:%ld, end:%ld \n", end_tsc - beg_tsc,
        beg_tsc, end_tsc);

    return 0;
}
