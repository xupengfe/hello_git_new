#include<stdio.h>
#include <unistd.h>
#include <string.h>

void main(void)
{
	char *msg = "Hello world\n";
	write(1, msg, strlen(msg));
}
