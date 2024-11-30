.global _start

.data
    msg:    .ascii      "Hello, World!\n"

.text
_start:
    mov     x0, #1              // fd 1 = stdout
    ldr     x1, =msg            // msg addr
    mov     x2, #14             // msg len 14
    mov     x8, #64             // syscall num 64 = write
    svc     #0                  // syscall

    // exit syscall
    mov     x0, #6              // ret with 6
    mov     x8, #93             // syscall num 93 = exit
    svc     #0                  // syscall
