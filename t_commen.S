.section .rodata

.section .text

.global _start

_start:
	push    $0x21       # '!'
	mov     $1, %rax    # sys_write call number 
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	mov     $1, %rdx    # write 1 char
	syscall   
	add     $8, %rsp    # restore sp

	# Call SYS_EXIT
	movl $1, %eax
	# push arguments
	movl $0, %ebx
	# initiate
	int $0x80
