default rel

section .data
    err_usage db "usage: amenasia <file>", 10
    err_usage_len equ $ - err_usage

    gcc_path db "/usr/bin/gcc", 0
    gcc_a0   db "gcc", 0
    gcc_a1   db "-x", 0
    gcc_a2   db "assembler", 0
    gcc_a3   db "-nostdlib", 0
    gcc_a4   db "-fno-use-linker-plugin", 0
    gcc_a5   db "-o", 0
    gcc_a6   db "out.bin", 0
    gcc_a7   db "-", 0

    gcc_argv dq gcc_a0, gcc_a1, gcc_a2, gcc_a3, gcc_a4, gcc_a5, gcc_a6, gcc_a7, 0
    gcc_envp dq 0

section .bss
    pipefd  resd 2
    wstatus resd 1

section .text
    global _start

    ;; libs.asm
    extern exit
    extern open
    extern close
    extern pipe
    extern fork
    extern dup2
    extern execve
    extern wait4

    ;; io.asm
    extern process_file

_start:
    mov rdi, [rsp]               ; argc
    cmp rdi, 2
    jl .exit                      ; no argument — exit instead of segfault

    mov r12, [rsp + 16]          ; argv[1]

    ;; pipe(pipefd)
    mov rdi, pipefd
    call pipe

    ;; fork()
    call fork
    test rax, rax
    jnz .parent

    ;; ---- child: exec gcc with stdin = pipe read end ----
    mov edi, dword [pipefd]      ; read end
    mov rsi, 0                   ; stdin
    call dup2

    mov edi, dword [pipefd]
    call close
    mov edi, dword [pipefd + 4]
    call close

    mov rdi, gcc_path
    mov rsi, gcc_argv
    mov rdx, gcc_envp
    call execve
    ;; execve only returns on error (handled inside)

.parent:
    mov r13, rax                  ; child pid

    ;; redirect stdout -> pipe write end
    mov edi, dword [pipefd + 4]
    mov rsi, 1                    ; stdout
    call dup2

    mov edi, dword [pipefd]
    call close
    mov edi, dword [pipefd + 4]
    call close

    ;; open(argv[1], O_RDONLY)
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    call open
    mov r14, rax

    mov rdi, r14
    call process_file

    mov rdi, r14
    call close

    ;; close stdout so child sees EOF on its stdin
    mov rdi, 1
    call close

    ;; wait4(pid, &status, 0, NULL)
    mov rdi, r13
    mov rsi, wstatus
    mov rdx, 0
    mov r10, 0
    call wait4

    mov rdi, 0
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
