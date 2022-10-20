#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <asm/ldt.h>
#include <errno.h>
#include <stdint.h>

int main() {
	unsigned long addr = 0;
	struct user_desc u_info;
	int ret = 0;

	u_info.entry_number = (uint32_t)-1;
	u_info.read_exec_only = 0x1;
	u_info.seg_not_present = 0x1;
	printf("read_exec_only:%d, seg_not_present:%d\n", u_info.read_exec_only,
		u_info.seg_not_present);
	//ret = syscall(SYS_set_thread_area, addr);
	ret = syscall(SYS_set_thread_area, &u_info);

	printf("ret:%d, addr:%lx, errno:%d\n", ret, addr, errno);
	printf("entry_number is %d\n",u_info.entry_number);

	return 0;

}
