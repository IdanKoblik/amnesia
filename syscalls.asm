section .text
    global sys_write
    global sys_exit
    global sys_open
    global sys_close
    global sys_read
    global sys_fstat
    global sys_mmap
    global sys_munmap

;; -------------------------
;; sys_write(fd, buf, len)
;; rdi = fd
;; rsi = buffer
;; rdx = length
;; -------------------------
sys_write:
    mov rax, 1
    syscall
    ret

;; -------------------------
;; sys_exit(code)
;; rdi = exit code
;; -------------------------
sys_exit:
    mov rax, 60
    syscall

;; -------------------------
;; sys_open(filename, flags, mode)
;; rdi = filename
;; rsi = flags
;; rdx = mode
;; -------------------------
sys_open:
    mov rax, 2
    syscall
    ret

;; -------------------------
;; sys_close(fd)
;; rdi = fd
;; -------------------------
sys_close:
    mov rax, 3
    syscall
    ret

;; -------------------------
;; sys_read(fd, buffer, size)
;; rdi = fd
;; rsi = buffer
;; size = rdx
;; -------------------------
sys_read:
    mov rax, 0
    syscall
    ret

;; -------------------------
;; sys_fstat(fd, statbuf)
;; rdi = fd
;; rsi = statbuf
;; -------------------------
sys_fstat:
    mov rax, 5
    syscall
    ret

;; -------------------------
;; sys_mmap(addr, length, prot, flags, fd, offset)
;; rdi = addr
;; rsi = length
;; rdx = prot
;; r10 = flags
;; r8  = fd
;; r9  = offset
;; -------------------------
sys_mmap:
    mov rax, 9
    syscall
    ret

;; -------------------------
;; sys_munmap(addr, length)
;; rdi = addr
;; rsi = length
;; -------------------------
sys_munmap:
    mov rax, 11
    syscall
    ret
