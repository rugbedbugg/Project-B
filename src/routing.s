.intel_syntax noprefix

.global	ROUTE

.extern	PATH_EQ_SPACE

.extern	RESP_OK
.extern	RESP_BAD_REQUEST
.extern	RESP_NOT_FOUND
.extern	RESP_METHOD_NOT_ALLOWED
.extern	RESP_NOT_IMPLEMENTED

.section .rodata
### Currently configured endpoints
#==================
PATH_HEALTH:	.ascii	"/health"
PATH_LOGIN:	.ascii	"/login"
PATH_FILES:	.ascii	"/files"
PATH_LOGOUT:	.ascii	"/logout"
###################

### Endpoints' path lengths
#==================
.set 	PATH_HEALTH_LEN,	7
.set 	PATH_LOGIN_LEN,		6
.set 	PATH_FILES_LEN,		6
.set 	PATH_LOGOUT_LEN,	7
###################

.section .text
#===============================================#
#		   Routing			#
#===============================================#
ROUTE:
	// /health => GET only
	mov		rdi,	r14
	lea		rsi,	[rip+PATH_HEALTH]
	mov		rdx,	PATH_HEALTH_LEN
	call		PATH_EQ_SPACE
	cmp		rax,	1
	jne		CHECK_LOGIN
	cmp		r15,	1
	jne		RESP_METHOD_NOT_ALLOWED
	jmp		RESP_OK

CHECK_LOGIN:
	mov		rdi,	r14
	lea		rsi,	[rip+PATH_LOGIN]
	mov		rdx,	PATH_LOGIN_LEN
	call		PATH_EQ_SPACE
	cmp		rax,	1
	jne		CHECK_FILES
	cmp		r15,	2
	jne		RESP_METHOD_NOT_ALLOWED	# /login currently supports POST only
	cmp		r11,	0
	jl		RESP_BAD_REQUEST		# POST /login requires valid Content-Length
	jmp		RESP_NOT_IMPLEMENTED

CHECK_FILES:
	mov		rdi,	r14
	lea		rsi,	[rip+PATH_FILES]
	mov		rdx,	PATH_FILES_LEN
	call		PATH_EQ_SPACE
	cmp		rax,	1
	jne		CHECK_LOGOUT
	jmp		RESP_NOT_IMPLEMENTED

CHECK_LOGOUT:
	mov		rdi,	r14
	lea		rsi,	[rip+PATH_LOGOUT]
	mov		rdx,	PATH_LOGOUT_LEN
	call		PATH_EQ_SPACE
	cmp		rax,	1
	jne		RESP_NOT_FOUND
	jmp		RESP_NOT_IMPLEMENTED
