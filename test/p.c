#include <stdio.h>

void main(void)
{
	int a = 1;

	printf("&a:%p, a:%d\n", &a, a);

	printf("(unsigned long *)(&a):%p , *(unsigned long *)(&a):%lx\n", (unsigned long *)(&a), *(unsigned long *)(&a));

	printf("((unsigned long *)(&a) + 1):%p, *((unsigned long *)(&a) + 1):%lx\n", ((unsigned long *)(&a) + 1), *((unsigned long *)(&a) + 1));

}
