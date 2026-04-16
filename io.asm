section .bss
    statbuf resb 144             ; struct stat on x86_64

section .text
    global process_file

    ;; libs.asm
    extern fstat
    extern mmap
    extern munmap
    extern madvise

    ;; translate.asm
    extern translate

process_file:
    push r12
    push r13

    mov r12, rdi                 ; r12 = fd

    ;; fstat(fd, statbuf) to get file size
    mov rdi, r12
    mov rsi, statbuf
    call fstat

    ;; st_size is at offset 48
    mov r13, [abs statbuf + 48]  ; r13 = file size

    mov rdi, 0                   ; addr = NULL
    mov rsi, r13                 ; length = file size
    mov rdx, 1                   ; PROT_READ
    mov r10, 2                   ; MAP_PRIVATE
    mov r8, r12                  ; fd
    mov r9, 0                    ; offset = 0
    call mmap

    mov r12, rax

    mov rdi, r12
    mov rsi, r13
    mov rdx, 2                   ; MADV_SEQUENTIAL
    call madvise

    mov rdi, r12
    mov rsi, r13
    call translate

    mov rdi, r12
    mov rsi, r13
    call munmap

    pop r13
    pop r12
    ret
