section .data
    err_usage db "usage: amenasia <file>", 10
    err_usage_len equ $ - err_usage

section .text
    global _start

    ;; libs.asm
    extern write
    extern exit
    extern open
    extern close
    extern read

    ;; strings.asm
    extern strlen
    extern newline

    ;; io.asm
    extern process_file

_start:
    mov rdi, [rsp]               ; argc
    cmp rdi, 2
    jl .exit                      ; no argument — exit instead of segfault

    mov r12, [rsp + 16]          ; argv[1]

    mov rdi, r12
    call strlen
    mov rsi, rax
    call write

    call newline
    call newline

    mov rdi, r12
    mov rsi, 0          ; O_RDONLY
    mov rdx, 0          ; mode is ignored
    call open
    mov r13, rax

    mov rdi, r13
    call process_file

    mov rdi, r13
    call close
    call exit

.exit:
    call error_usage

error_usage:
    mov rdi, 2                  ; stderr
    mov rsi, err_usage
    mov rdx, err_usage_len
    mov rax, 1
    syscall

    mov rdi, 1
    mov rax, 60
    syscall
