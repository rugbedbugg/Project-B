.intel_syntax noprefix
.global _start
_start:
SOCK:	// Socket call
	// socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
	mov 	rdi, 2		# AF_INET 	= 2 (defined)
	mov 	rsi, 1		# SOCK_STREAM 	= 1 (widely used default)
	mov 	rdx, 0		# IPPROTO_IP 	= 0 (common default)
	mov 	rax, 41		# syscall ID for socket call
	syscall
	mov	r12, rax	# Listening socket 	(r12, r13 => callee-saved register)


BIND:	// Bind call
	// bind(FD, *SOCKADDR_IN, sizeof(SOCKADDR_IN))
	// where,
	// struct SOCKADDR_IN {sa_family, sin_port, sin_addr, sin_zero}
SK_FD:	mov	rdi, r12	# set listening socket [FD (File descriptor) from socket call]
SK_ADR:	sub 	rsp, 16		# Reserve 16 bytes for SOCKADDR_IN struct
	mov word ptr [rsp], 2			# sa_family = AF_INET = 2		(2 bytes)
	mov word ptr [rsp+2], 0x901f		# sin_port = 8080			(2 bytes)
	mov dword ptr [rsp+4], 0x0100007f	# sin_addr = INADDR_ANY = 127.0.0.1	(4 bytes)
	mov qword ptr [rsp+8], 0		# sin_zero (padding bytes)		(8 bytes)
	mov 	rsi, rsp	# input SOCKADDR_IN struct			Total = 16 bytes
SK_SIZ:	mov	rdx, 16		# struct SOCKADDR_IN size is fixed 16 bytes
	mov	rax, 49		# syscall ID for bind call
	syscall


LISTEN: // Listen call
	// listen(SOCKFD, BACKLOG)
	// rdi (SOCKFD) uses FD value from socket call
	mov 	rdi, r12	# Use listening socket
	mov	rsi, 4096	# BACKLOG value (old linux => 128, new linux => 4096)
				# No. of fully est. conns. waiting to be accepted
				# Excessive no. of conns. => Dropping of connections
	mov	rax, 50		# syscall ID for listen call
	syscall


EXIT:	// Server exit syscall
	mov	rdi, 0		# code 0 (success)
	mov 	rax, 60		# sys_exit
	syscall
