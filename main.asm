section .text
    global _start
    extern write
    extern exit

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

    call exit

.exit:
    mov rdi, 0
    call exit

strlen:
    mov rax, 0
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

