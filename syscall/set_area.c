#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <asm/ldt.h>
#include <errno.h>

int main() {
	unsigned long addr = 0;
	int ret = 0;

	ret = syscall(SYS_set_thread_area, addr);

	printf("ret:%d, addr:%lx, errno:%d\n", ret, addr, errno);

	return 0;

}
