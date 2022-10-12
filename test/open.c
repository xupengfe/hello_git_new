#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#define  A  0100

int main()
{
    char *name1 = "testfile.txt";
    char *name2 ="1.txt";
    int filedesc = open(name1, O_WRONLY | O_CREAT | O_TRUNC,
               S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if(filedesc < 0) {
        printf("open testfile.txt failed:%d\n", filedesc);
        return 1;
    }
    printf("Open %s successfully:%d\n", name1, filedesc);
     close(filedesc);

    printf("O_CREAT:0x%x, A(define with 0100):0x%x\n", O_CREAT, A);
    int fd = open(name2, O_RDONLY, 0xffffffff);  //O_RDONLY | O_CREAT  should successfully
        if (fd < 0) {
             printf("open 1.txt failed:%d\n", fd);
             return 1;
        }
    printf("Open 1.txt successfully:%d\n", fd);
    sleep(100);
    close(fd);
    //if(write(filedesc,"This will be output to testfile.txt\n", 36) != 36)
    //{
    //    write(2,"There was an error writing to testfile.txt\n");    // strictly not an error, it is allowable for fewer characters than requested to be written.
    //    return 1;
    //}

    return 0;
}
