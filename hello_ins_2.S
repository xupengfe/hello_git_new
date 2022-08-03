.data
msg:
    .ascii  "Hello world\n"
    len = . - msg
.text
    .global _start
_start:
    # call SYS_WRITE
    movl $len,%edx
    movl $msg,%ecx
    movl $1,%ebx
    movl $4,%eax

    int $0x80
    # Call SYS_EXIT
    movl $0,%ebx
    movl $1,%eax
    int $0x80
