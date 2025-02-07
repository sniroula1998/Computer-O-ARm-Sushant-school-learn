.global _start

.section .data
msg:    .asciz "Hello, World!\n"

.section .text
_start:
    mov r0, #1          @ File descriptor 1 (stdout)
    ldr r1, =msg        @ Load address of msg
    mov r2, #14         @ Length of msg
    mov r7, #4          @ System call number for sys_write
    svc 0               @ Make system call

    mov r0, #0          @ Exit status 0
    mov r7, #1          @ System call number for sys_exit
    svc 0               @ Make system call

