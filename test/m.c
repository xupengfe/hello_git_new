#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	int *p = NULL;

	p=(int *)malloc(sizeof(int)*10);
	*p=100;
	printf("%d\n",*p);
	free(p);
	p=NULL;

	return 0;
}
