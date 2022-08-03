.section .rodata

.section .text

.global _start

_start:
	push    $0x48
	mov     $1, %rax
	mov     $1, %rdi
	mov     %rsp, %rsi
	mov     $2, %rdx
	syscall
	add     $8, %rsp

	movl $1, %eax
	movl $0, %ebx
	int $0x80
