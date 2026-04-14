section .data
    err_write db "error: write failed", 10
    err_write_len equ $ - err_write
    err_open db "error: failed to open file", 10
    err_open_len equ $ - err_open
    err_close db "error: failed to close file", 10
    err_close_len equ $ - err_close
    err_usage db "usage: amenasia <file>", 10
    err_usage_len equ $ - err_usage

section .text
    global write
    global exit
    global open
    global close
    global error_usage

    extern sys_write
    extern sys_exit
    extern sys_open
    extern sys_close

;; --------------------------------
;; write(fd=1, buf=rdi, len=rsi)
;; --------------------------------
write:
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1                  ; stdout
    call sys_write
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2                  ; stderr
    mov rsi, err_write
    mov rdx, err_write_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; exit(code=rdi)
;; --------------------------------
exit:
    call sys_exit

;; --------------------------------
;; open(filename=rdi, flags=rsi, mode=rdx)
;; --------------------------------
open:
    call sys_open
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2                  ; stderr
    mov rsi, err_open
    mov rdx, err_open_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; close(fd=rdi)
;; --------------------------------
close:
    call sys_close
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2                  ; stderr
    mov rsi, err_close
    mov rdx, err_close_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; error_usage()
;; --------------------------------
error_usage:
    mov rdi, 2                  ; stderr
    mov rsi, err_usage
    mov rdx, err_usage_len
    call sys_write
    mov rdi, 1
    call sys_exit
