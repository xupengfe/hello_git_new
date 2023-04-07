.section .rodata

msg:
    .ascii "Hello World\n"

.section .text

.global _start

_start:
    movl $4, %eax    # call SYS_WRITE:4 in 32bit
    movl $1, %ebx    # push arguments
    movl $msg, %ecx
    movl $12, %edx
    int $0x80
    movl $1, %eax    # Call SYS_EXIT:1 in 32bit
    movl $0, %ebx    # push arguments
    int $0x80        # initiate
