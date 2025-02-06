#include <stdio.h>

int hack(void) {
    printf("If it's printed, this app has been hacked!\n");

    return 2;
}
int func2() {
    int func2_ret = 0x13;

    return func2_ret;
}

int func1()
{
    int func1_ret = 0x12;
    unsigned long *stack_pointer;

    printf("Before get stack pointer, sp: %p\n", (void*)stack_pointer);
    __asm__ volatile ("mov %0, sp" : "=r"(stack_pointer));
    printf("After get stack pointer, sp: %p, *(sp + 8bytes): %x\n",
           (void*)stack_pointer, *(stack_pointer + 1));
    *(stack_pointer + 1) = (unsigned long)hack;
    printf("After hack, sp: %p, *(sp + 8bytes): %x\n",
           (void*)stack_pointer, *(stack_pointer + 1));
    func2();

    return func1_ret;
}


int main(void)
{
    int main_ret = 0x11;

    func1();

    return main_ret;
}

