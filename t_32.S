.section .rodata

.section .text

.global _start

_start:
	push    $0x48       # 'H'
	mov     $4, %eax    # sys_write call number
	mov     $1, %ebx    # write to stdout (fd=1)
	mov     %esp, %ecx  # use char on stack
	mov     $1, %edx    # write 1 char
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x65       # 'e'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x6C       # 'l'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x6C       # 'l'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x6F       # 'o'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x20       # ' '
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x57       # 'W'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x6F       # 'o'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x72       # 'r'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x6C       # 'l'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x64       # 'd'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	push    $0x0A       # '\n'
	mov     $4, %eax    # sys_write call number
	int     $0x80
	add     $4, %esp    # restore sp

	movl $1, %eax
	movl $0, %ebx
	int $0x80
