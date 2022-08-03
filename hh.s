# $ ./hh "Hello World"

.global _start
_start:
	popl %ecx
	popl %ecx
	popl %ecx
	movb $10,12(%ecx)
	xorl %edx, %edx
	movb $13, %dl
	xorl %eax, %eax
	movb $4, %al
	xorl %ebx, %ebx
	int $0x80
	xorl %eax, %eax
	incl %eax
	int $0x80
