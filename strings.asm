section .text
    global strlen
    global newline

    ;; libs.asm
    extern write

;; --------------------------------
;; strlen(str=rdi)
;; --------------------------------
strlen:
    mov rax, 0
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

;; --------------------------------
;; newline()
;; --------------------------------
newline:
    sub rsp, 8                  ; allocate space below the return address
    mov byte [rsp], 10          ; newline character
    mov rdi, rsp
    mov rsi, 1
    call write
    add rsp, 8                  ; restore stack
    ret
