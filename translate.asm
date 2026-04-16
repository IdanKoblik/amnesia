section .data
    asm_prologue db "section .bss", 10, "    tape resb 30000", 10, 10
                 db "section .text", 10, "    global _start", 10, 10
                 db "_start:", 10, "    mov r12, tape", 10
    asm_prologue_len equ $ - asm_prologue

    asm_add_r12 db "    add r12, "
    asm_add_r12_len equ $ - asm_add_r12

    asm_sub_r12 db "    sub r12, "
    asm_sub_r12_len equ $ - asm_sub_r12

    asm_add_byte db "    add byte [r12], "
    asm_add_byte_len equ $ - asm_add_byte

    asm_sub_byte db "    sub byte [r12], "
    asm_sub_byte_len equ $ - asm_sub_byte

    asm_dot db "    mov rdi, 1", 10, "    mov rsi, r12", 10
            db "    mov rdx, 1", 10, "    mov rax, 1", 10
            db "    syscall", 10
    asm_dot_len equ $ - asm_dot

    asm_comma db "    mov rdi, 0", 10, "    mov rsi, r12", 10
              db "    mov rdx, 1", 10, "    mov rax, 0", 10
              db "    syscall", 10
    asm_comma_len equ $ - asm_comma

    asm_loop_prefix db "loop_"
    asm_loop_prefix_len equ $ - asm_loop_prefix

    asm_colon_nl db ":", 10
    asm_colon_nl_len equ $ - asm_colon_nl

    asm_loop_cmp db "    cmp byte [r12], 0", 10
    asm_loop_cmp_len equ $ - asm_loop_cmp

    asm_je db "    je loop_"
    asm_je_len equ $ - asm_je

    asm_jne db "    jne loop_"
    asm_jne_len equ $ - asm_jne

    asm_end_suffix db "_end"
    asm_end_suffix_len equ $ - asm_end_suffix

    asm_nl db 10

    asm_epilogue db "    mov rdi, 0", 10, "    mov rax, 60", 10
                 db "    syscall", 10
    asm_epilogue_len equ $ - asm_epilogue

section .bss
    loop_stack resq 256          ; bracket matching stack
    num_buf resb 20              ; itoa buffer

section .text
    global translate

    extern write

;; --------------------------------
;; translate(buf=rdi, len=rsi)
;; Converts brainfuck source to x86-64 NASM assembly on stdout
;; --------------------------------
translate:
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rbp

    mov r12, rdi                 ; r12 = source buffer
    mov r13, rsi                 ; r13 = source length
    xor r14, r14                 ; r14 = current index
    xor r15, r15                 ; r15 = loop counter
    xor ebp, ebp                 ; rbp = loop stack pointer

    mov rdi, asm_prologue
    mov rsi, asm_prologue_len
    call write

.loop:
    cmp r14, r13
    jge .done

    movzx eax, byte [r12 + r14]

    cmp al, '>'
    je .right
    cmp al, '<'
    je .left
    cmp al, '+'
    je .inc_bf
    cmp al, '-'
    je .dec_bf
    cmp al, '.'
    je .dot
    cmp al, ','
    je .comma
    cmp al, '['
    je .open
    cmp al, ']'
    je .close
    jmp .next

.right:
    mov bl, '>'
    mov rdi, asm_add_r12
    mov rsi, asm_add_r12_len
    jmp .collapse

.left:
    mov bl, '<'
    mov rdi, asm_sub_r12
    mov rsi, asm_sub_r12_len
    jmp .collapse

.inc_bf:
    mov bl, '+'
    mov rdi, asm_add_byte
    mov rsi, asm_add_byte_len
    jmp .collapse

.dec_bf:
    mov bl, '-'
    mov rdi, asm_sub_byte
    mov rsi, asm_sub_byte_len
    jmp .collapse

.collapse:
    ;; bl = char to count, rdi = prefix ptr, rsi = prefix len
    push rsi                     ; save prefix len
    push rdi                     ; save prefix ptr

    mov rcx, 1
.count_loop:
    lea rdx, [r14 + rcx]
    cmp rdx, r13
    jge .count_done
    cmp byte [r12 + rdx], bl
    jne .count_done
    inc rcx
    jmp .count_loop
.count_done:
    add r14, rcx
    dec r14                      ; .next will inc

    push rcx                     ; save count

    ;; emit prefix
    mov rdi, [rsp + 8]          ; prefix ptr
    mov rsi, [rsp + 16]         ; prefix len
    call write

    ;; emit count
    pop rdi                      ; count
    add rsp, 16                  ; discard saved prefix
    call emit_number

    ;; emit newline
    mov rdi, asm_nl
    mov rsi, 1
    call write
    jmp .next

.dot:
    mov rdi, asm_dot
    mov rsi, asm_dot_len
    call write
    jmp .next

.comma:
    mov rdi, asm_comma
    mov rsi, asm_comma_len
    call write
    jmp .next

.open:
    ;; push loop counter onto bracket stack
    mov [loop_stack + rbp * 8], r15
    inc rbp

    ;; emit "loop_N:\n"
    mov rdi, asm_loop_prefix
    mov rsi, asm_loop_prefix_len
    call write
    mov rdi, r15
    call emit_number
    mov rdi, asm_colon_nl
    mov rsi, asm_colon_nl_len
    call write

    ;; emit "    cmp byte [r12], 0\n"
    mov rdi, asm_loop_cmp
    mov rsi, asm_loop_cmp_len
    call write

    ;; emit "    je loop_N_end\n"
    mov rdi, asm_je
    mov rsi, asm_je_len
    call write
    mov rdi, r15
    call emit_number
    mov rdi, asm_end_suffix
    mov rsi, asm_end_suffix_len
    call write
    mov rdi, asm_nl
    mov rsi, 1
    call write

    inc r15
    jmp .next

.close:
    ;; pop loop counter from bracket stack
    dec rbp
    mov rbx, [loop_stack + rbp * 8]

    ;; emit "    cmp byte [r12], 0\n"
    mov rdi, asm_loop_cmp
    mov rsi, asm_loop_cmp_len
    call write

    ;; emit "    jne loop_N\n"
    mov rdi, asm_jne
    mov rsi, asm_jne_len
    call write
    mov rdi, rbx
    call emit_number
    mov rdi, asm_nl
    mov rsi, 1
    call write

    ;; emit "loop_N_end:\n"
    mov rdi, asm_loop_prefix
    mov rsi, asm_loop_prefix_len
    call write
    mov rdi, rbx
    call emit_number
    mov rdi, asm_end_suffix
    mov rsi, asm_end_suffix_len
    call write
    mov rdi, asm_colon_nl
    mov rsi, asm_colon_nl_len
    call write

    jmp .next

.next:
    inc r14
    jmp .loop

.done:
    mov rdi, asm_epilogue
    mov rsi, asm_epilogue_len
    call write

    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

;; --------------------------------
;; emit_number(n=rdi)
;; Converts integer to decimal string and writes to stdout
;; --------------------------------
emit_number:
    push r12

    mov rax, rdi
    lea r12, [rel num_buf + 19]

    test rax, rax
    jnz .convert
    dec r12
    mov byte [r12], '0'
    jmp .write_num

.convert:
    mov rcx, 10
.digit_loop:
    test rax, rax
    jz .write_num
    xor edx, edx
    div rcx
    add dl, '0'
    dec r12
    mov [r12], dl
    jmp .digit_loop

.write_num:
    mov rdi, r12
    lea rsi, [rel num_buf + 19]
    sub rsi, r12
    call write

    pop r12
    ret
