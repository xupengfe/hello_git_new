.section .rodata

msg:
	.ascii "Hello syscall instruction.\n"

.section .text

.global _start

_start:
	mov     $1, %rax    # sys_write syscall number in 64bit
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     $msg, %rsi  # Set msg start point on stack
	mov     $27, %rdx   # write 27 char
	syscall

	mov     $60, %rax   # syscall sys_exit num:60
	mov     $1,  %rdi   # fd with 1, standard output
	syscall             # syscall instruction is the new way for 64bit OS

#	movl $1, %eax
#	movl $0, %ebx
#	int $0x80         # int $0x80 is old interrupt way to call syscall
