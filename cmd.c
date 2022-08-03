#include <stdlib.h>
#include <stdio.h>

int main(void)
{
	system("cat /proc/cpuinfo | grep processor | wc -l");

	return 0;
}
