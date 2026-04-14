section .bss
    buffer resb 1

section .text
    global process_file

    ;; libs.asm
    extern write
    extern read


;; TODO use mmap

process_file:
    push r13
    mov r13, rdi
.loop:
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 1
    call read

    cmp rax, 0
    je .done

    mov rdi, buffer
    mov rsi, 1
    call write

    jmp .loop
.done:
    pop r13
    ret
