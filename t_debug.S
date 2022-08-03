.section .rodata

.section .text

.global _start

_start:
	push    $0x48       # 'H'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	mov     $2, %rdx    # write 1 char
	syscall
	add     $8, %rsp    # restore sp

	push    $0x65       # 'e'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x6C       # 'l'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x6C       # 'l'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x6F       # 'o'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x20       # ' '
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x57       # 'W'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x6F       # 'o'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x72       # 'r'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x6C       # 'l'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x64       # 'd'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	push    $0x0A       # '\n'
	mov     $1, %rax    # sys_write call number
	mov     $1, %rdi    # write to stdout (fd=1)
	mov     %rsp, %rsi  # use char on stack
	syscall
	add     $8, %rsp    # restore sp

	movl $1, %eax
	movl $0, %ebx
	int $0x80
