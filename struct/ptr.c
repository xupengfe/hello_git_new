#include <stdio.h>

void main(void)
{
    int a = 7;
    unsigned long *p;

    p = (unsigned long *)&a; 
    printf("p:%p, *p:%lx\n", p, *p);
    printf("*(unsigned long*)*p: will point one space segment fault\n");
    printf("1[3870200]: segfault at 0 ip 000000000040114d sp 00007ffd71cfce00 error 6 in 1[401000+1000]\n");
    printf("&a:%p, (unsigned long *)a:%lx\n", &a, (unsigned long *)a);
    printf("*(unsigned long *)a:%lx\n", *(unsigned long *)a);
    //printf("p:%p, *p:%lx, *(unsigned long*)*p:%lx\n", p, *p, *(unsigned long*)*p);
}
