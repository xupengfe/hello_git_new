#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <errno.h>
#include <linux/types.h>
#include <sys/stat.h>

struct ustat {
	__kernel_daddr_t f_tfree;
	ino_t f_tinode;
	char f_fname[6];
	char f_fpack[6];
};

static dev_t dev_num;

int main(void)
{
	struct ustat ubuf;
	int ret = 0;
	struct stat buf;

	stat("/", &buf);
	dev_num = buf.st_dev;

	ret = syscall(__NR_ustat, (unsigned int)dev_num, &ubuf);

	printf("ustat ret:%d, errno:%d\n", ret, errno);

	return 0;
}
