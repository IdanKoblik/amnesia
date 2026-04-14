section .text
    global _start
    extern write
    extern exit
    extern open
    extern close
    extern error_usage

_start:
    mov rdi, [rsp]               ; argc
    cmp rdi, 2
    jl .exit                      ; no argument — exit instead of segfault

    mov rdi, [rsp + 16]          ; argv[1]

    call strlen
    mov rsi, rax
    call write

    mov byte [rsp], 10          ; newline
    mov rdi, rsp
    mov rsi, 1
    call write

    mov rdi, rsp
    mov rsi, 0          ; O_RDONLY
    mov rdx, 0          ; mode is ignored
    call open

    call close
    call exit

.exit:
    call error_usage

strlen:
    mov rax, 0
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

