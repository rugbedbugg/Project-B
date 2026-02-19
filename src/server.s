.intel_syntax noprefix
.global _start
_start:
	// Socket call
	// socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
	mov 	rdi, 2		# AF_INET 	= 2 (defined)
	mov 	rsi, 1		# SOCK_STREAM 	= 1 (widely used default)
	mov 	rdx, 0		# IPPROTO_IP 	= 0 (common default)
	mov 	rax, 41		# syscall ID for socket call
	syscall

	// Server exit syscall
	mov 	rdi, 0		# code 0 (success) 
	mov 	rax, 60		# sys_exit
	syscall
