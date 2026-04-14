section .text
    global _start

_start:
    mov rdi, [rsp]               ; argc
    cmp rdi, 2
    jl exit                      ; no argument — exit instead of segfault

    mov rdi, [rsp + 16]          ; argv[1]

    call strlen
    call write

    mov byte [rsp], 10
    mov rdi, rsp
    mov rax, 1
    call write

    call exit

write:
    mov rdx, rax
    mov rsi, rdi

    mov rax, 1
    mov rdi, 1
    syscall

    ret

strlen:
    mov rax, 0
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

exit:
    mov rax, 60
    mov rdi, 0
    syscall
