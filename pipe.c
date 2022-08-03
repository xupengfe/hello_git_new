#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
 
int main(void)
{
	int n,fd[2];
	pid_t pid;
	char line[1024];
	
	if (pipe(fd) < 0)
		return 1;
	if ((pid=fork()) < 0)
		return 1;
	else if (pid > 0)	//parent
	{
		close(fd[0]);	//close parent's read-port
		write(fd[1],"I am from parent!\n",19);	//write to pipe
	}
	else	//child
	{
		close(fd[1]);	//close child's write-port
		n = read(fd[0],line,1024);	//read from pipe
		printf("%s%d\n",line,n);
	}
	printf("I am public!\n");
	return 1;
}
