#include <stdio.h>

#define max(a,b) ((a) > (b) ? (a) : (b))

static int test(int x) 
{
	return x ? x : 0;
}

static int test1(int x)
{
	return x ? : 0;
}

void main(void)
{
	int x = 2, y;

	y = test(x);
	printf("x=%d, x ? x : 0, return:%d\n", x, y);

	x = 0;
	y = test(x);
	printf("x=%d, x ? x : 0, return:%d\n", x, y);

	x = 2;
	y = test1(x);
	printf("x=%d, x ? : 0, return:%d\n", x, y);

	x = 0;
	y = test1(x);
	printf("x=%d, x ? : 0, return:%d\n", x, y);

	int a=1, b=2;
	printf("a:%d, b:%d, max:%d\n", a, b, max(a,b));

}

