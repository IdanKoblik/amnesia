section .text
    global sys_write
    global sys_exit

; -------------------------
; sys_write(fd, buf, len)
; rdi = fd
; rsi = buffer
; rdx = length
; -------------------------
sys_write:
    mov rax, 1
    syscall
    ret

; -------------------------
; sys_exit(code)
; rdi = exit code
; -------------------------
sys_exit:
    mov rax, 60
    syscall
