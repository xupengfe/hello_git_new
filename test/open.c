#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
 
int main()
{
    int filedesc = open("testfile.txt", O_WRONLY | O_CREAT | O_TRUNC,
               S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if(filedesc < 0) {
        printf("open testfile.txt failed\n");
        return 1;
    }
    printf("Open successfully\n");
 
    //if(write(filedesc,"This will be output to testfile.txt\n", 36) != 36)
    //{
    //    write(2,"There was an error writing to testfile.txt\n");    // strictly not an error, it is allowable for fewer characters than requested to be written.
    //    return 1;
    //}
    close(filedesc);

    return 0;
}
