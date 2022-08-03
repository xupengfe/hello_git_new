#include <stdio.h>
#include <stdint.h>

struct doe_header {
	uint32_t vid:16;
	uint32_t type:8;
	uint32_t rsvd0:8;
	uint32_t len:18;
	uint32_t rsvd1:14;
};

void main(void)
{
	struct doe_header *doe;
	int i = 0;

	doe->vid = 0x123;
	doe->type = 0x4;
	doe->rsvd0 = 0x5;
	doe->len = 0x666;
	doe->rsvd1 = 0x777;

	for (i = 0; i < sizeof(doe); i++)
		printf("doe[%d]:%x\n", i, *((unsigned char *)doe + i));

	printf("Why 1ddc end in doe->rsvd1\n");
	printf("\tuint32_t len:18;\n\tuint32_t rsvd1:14;\n");
	printf("doe->rsvd1 = 0x777;\n");
	printf("1ddc:0001 1101 1101 1100 for rsvd1:14\n");
}