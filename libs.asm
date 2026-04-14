section .text
    global write
    global exit

    extern sys_write
    extern sys_exit

; --------------------------------
; write(fd=1, buf=rdi, len=rsi)
; --------------------------------
write:
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1                  ; stdout
    call sys_write
    ret

; --------------------------------
; exit(code=rdi)
; --------------------------------
exit:
    call sys_exit
