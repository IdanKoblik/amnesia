section .data
    err_write db "error: write failed", 10
    err_write_len equ $ - err_write
    err_open db "error: failed to open file", 10
    err_open_len equ $ - err_open
    err_close db "error: failed to close file", 10
    err_close_len equ $ - err_close
    err_fstat db "error: fstat failed", 10
    err_fstat_len equ $ - err_fstat
    err_mmap db "error: mmap failed", 10
    err_mmap_len equ $ - err_mmap

section .text
    global write
    global exit
    global open
    global close
    global read
    global fstat
    global mmap
    global munmap

    extern sys_write
    extern sys_exit
    extern sys_open
    extern sys_close
    extern sys_read
    extern sys_fstat
    extern sys_mmap
    extern sys_munmap

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
;; read(fd=rdi, buffer=rsi, size=rdx)
;; --------------------------------
read:
    call sys_read
    ret

;; --------------------------------
;; fstat(fd=rdi, statbuf=rsi)
;; --------------------------------
fstat:
    call sys_fstat
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_fstat
    mov rdx, err_fstat_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; mmap(addr=rdi, len=rsi, prot=rdx, flags=r10, fd=r8, offset=r9)
;; --------------------------------
mmap:
    call sys_mmap
    cmp rax, -1
    je .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_mmap
    mov rdx, err_mmap_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; munmap(addr=rdi, len=rsi)
;; --------------------------------
munmap:
    call sys_munmap
    ret

