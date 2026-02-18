.intel_syntax noprefix
.global _start
_start:
	// Server exit syscall
	mov rdi, 0	# code 0 (success) 
	mov rax, 60	# sys_exit
	syscall
