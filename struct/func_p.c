#include <stdio.h>

struct DEMO
{
	// int x, y;
	// int (*func)(int, int);
	int (*func)(int x, int y);
};


int multi(int x, int y)
{
	return x*y;
}


int add(int x, int y)
{
	return x+y;
}

void main(void)
{
	struct DEMO demo;

	demo.func=add;
	printf("func=add; func(3,4)=%d\n", demo.func(3,4));

	demo.func=multi;
	printf("func=multi; func(4,5)=%d\n", demo.func(4,5));
}
