#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <asm/ldt.h>
#include <errno.h>

int main() {
	unsigned long addr = 0;
	struct user_desc u_info;
	int ret = 0;

	u_info.entry_number = -1; 
	//ret = syscall(SYS_set_thread_area, addr);
	ret = syscall(SYS_set_thread_area, &u_info);

	printf("ret:%d, addr:%lx, errno:%d\n", ret, addr, errno);
	printf("entry_number is %d\n",u_info.entry_number);

	return 0;

}
