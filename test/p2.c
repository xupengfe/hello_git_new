// SPDX-License-Identifier: GPL-2.0-only

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(void)
{
	uint32_t *buf;
	uint64_t *buf2;

	buf = aligned_alloc(32, 32);
	buf2 = aligned_alloc(64, 64);
	buf[5] = -1;
	printf("int buf[5]:%x, long buf[5]:%016lx, buf[4]:%x, buf[6]:%x\n",
	       buf[5], (long)buf[5], buf[4], buf[6]);

	printf("long buf2[5]:%016lx, buf2[4]:%lx, buf2[6]:%lx\n",
	       buf2[5], buf2[4], buf2[6]);

	buf2[5] = -1;

	printf("after: long buf2[5]:%016lx, buf2[4]:%lx, buf2[6]:%lx\n",
	       buf2[5], buf2[4], buf2[6]);
	free(buf);
	free(buf2);
}
