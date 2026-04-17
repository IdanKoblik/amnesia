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
    err_madvise db "error: madvise failed", 10
    err_madvise_len equ $ - err_madvise
    err_fork db "error: fork failed", 10
    err_fork_len equ $ - err_fork
    err_pipe db "error: pipe failed", 10
    err_pipe_len equ $ - err_pipe
    err_dup2 db "error: dup2 failed", 10
    err_dup2_len equ $ - err_dup2
    err_execve db "error: execve failed", 10
    err_execve_len equ $ - err_execve

section .text
    global write
    global exit
    global open
    global close
    global read
    global fstat
    global mmap
    global munmap
    global madvise
    global fork
    global pipe
    global dup2
    global execve
    global wait4

    extern sys_write
    extern sys_exit
    extern sys_open
    extern sys_close
    extern sys_read
    extern sys_fstat
    extern sys_mmap
    extern sys_munmap
    extern sys_madvise
    extern sys_fork
    extern sys_pipe
    extern sys_dup2
    extern sys_execve
    extern sys_wait4

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

;; --------------------------------
;; madvise(addr=rdi, len=rsi, advice=rdx)
;; --------------------------------
madvise:
    call sys_madvise
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_madvise
    mov rdx, err_madvise_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; fork() -> pid
;; --------------------------------
fork:
    call sys_fork
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_fork
    mov rdx, err_fork_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; pipe(pipefd=rdi)
;; --------------------------------
pipe:
    call sys_pipe
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_pipe
    mov rdx, err_pipe_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; dup2(oldfd=rdi, newfd=rsi)
;; --------------------------------
dup2:
    call sys_dup2
    cmp rax, 0
    jl .error
    ret

.error:
    mov rdi, 2
    mov rsi, err_dup2
    mov rdx, err_dup2_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; execve(path=rdi, argv=rsi, envp=rdx)
;; only returns on failure
;; --------------------------------
execve:
    call sys_execve
    mov rdi, 2
    mov rsi, err_execve
    mov rdx, err_execve_len
    call sys_write
    mov rdi, 1
    call sys_exit

;; --------------------------------
;; wait4(pid=rdi, status=rsi, options=rdx, rusage=r10)
;; --------------------------------
wait4:
    call sys_wait4
    ret

