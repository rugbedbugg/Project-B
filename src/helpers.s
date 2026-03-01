.intel_syntax noprefix

.global	REQ_BUF
.global	FIND_HDR_END
.global	PARSE_CONTENT_LENGTH
.global	PATH_EQ_SPACE

.section .rodata
CONTENT_LENGTH_KEY:	.ascii	"Content-Length:"

.section .bss
#===============================================#
#		Request Buffer (.bss)		#
#===============================================#
	.lcomm	REQ_BUF, 4096

.section .text
#===============================================#
#		     HELPERS			#
#===============================================#
# 1. FIND_HDR_END(buf_ptr=rdi, bytes_read=rsi)
#
# Scans request bytes for "\r\n\r\n" and returns offset to body start
# Returns: rax = offset after boundary OR -1 if not found
FIND_HDR_END:
	xor		rcx,	rcx
.FHE_LOOP:
	cmp		rcx,	rsi
	jge		.FHE_FAIL
	cmp		rcx,	rsi
	jae		.FHE_FAIL
	cmp byte ptr [rdi+rcx], 13
	jne		.FHE_NEXT
	lea		r8,	[rcx+3]
	cmp		r8,	rsi
	jae		.FHE_FAIL
	cmp byte ptr [rdi+rcx+1], 10
	jne		.FHE_NEXT
	cmp byte ptr [rdi+rcx+2], 13
	jne		.FHE_NEXT
	cmp byte ptr [rdi+rcx+3], 10
	jne		.FHE_NEXT
	lea		rax,	[rcx+4]
	ret

.FHE_NEXT:
	inc		rcx
	jmp		.FHE_LOOP

.FHE_FAIL:
	mov		rax,	-1
	ret

# 2. PARSE_CONTENT_LENGTH(req_start=rdi, hdr_end_ptr=rsi)
#
# Returns parsed Content-Length value in rax
# Returns -1 if header is absent OR malformed
PARSE_CONTENT_LENGTH:
	mov		r8,	rdi		# scan pointer
.PCL_SCAN:
	cmp		r8,	rsi
	jae		.PCL_FAIL
	mov		rdi,	r8
	mov		rdx,	rsi
	sub		rdx,	r8
	lea		rbx,	[rip+CONTENT_LENGTH_KEY]
	mov		r9,	15		# CONTENT_LENGTH_KEY_LEN
	cmp		rdx,	r9
	jb		.PCL_NEXT_LINE

	# compare "Content-Length:"
	xor		rcx,	rcx
.PCL_CMP:
	cmp		rcx,	r9
	je		.PCL_FOUND
	mov		al,	byte ptr [r8+rcx]
	cmp		al,	byte ptr [rbx+rcx]
	jne		.PCL_NEXT_LINE
	inc		rcx
	jmp		.PCL_CMP

.PCL_FOUND:
	# parse decimal digits after optional spaces
	lea		r8,	[r8+r9]
.PCL_SKIP_SP:
	cmp		r8,	rsi
	jae		.PCL_FAIL
	cmp byte ptr [r8], ' '
	jne		.PCL_DIGITS
	inc		r8
	jmp		.PCL_SKIP_SP

.PCL_DIGITS:
	xor		rax,	rax
	xor		r11,	r11		# digit count
.PCL_NUM_LOOP:
	cmp		r8,	rsi
	jae		.PCL_DONE
	mov		bl,	byte ptr [r8]
	cmp		bl, 13
	je		.PCL_DONE
	cmp		bl, '0'
	jb		.PCL_FAIL
	cmp		bl, '9'
	ja		.PCL_FAIL
	imul		rax,	rax,	10
	sub		bl,	'0'
	movzx		rbx,	bl
	add		rax,	rbx
	inc		r8
	inc		r11
	jmp		.PCL_NUM_LOOP

.PCL_DONE:
	cmp		r11,	0
	je		.PCL_FAIL
	ret

.PCL_NEXT_LINE:
	# advance to next line by searching '\n'
.PCL_EOL:
	cmp		r8,	rsi
	jae		.PCL_FAIL
	cmp byte ptr [r8], 10
	je		.PCL_ADVANCE
	inc		r8
	jmp		.PCL_EOL

.PCL_ADVANCE:
	inc		r8
	jmp		.PCL_SCAN

.PCL_FAIL:
	mov		rax,	-1
	ret

# 3. PATH_EQ_SPACE(path_ptr=rdi, literal_ptr=rsi, len=rdx)
#
# Checks whether the request path starts with a specific character
# and that it is immediately followed by a space
#
# Returns: rax = 1 (match) OR 0 (no match)
PATH_EQ_SPACE:
	xor		rcx,	rcx
.PEQ_LOOP:
	cmp		rcx,	rdx
	je		.PEQ_TERM
	mov		r8b,	byte ptr [rdi+rcx]
	mov		r9b,	byte ptr [rsi+rcx]
	cmp		r8b,	r9b
	jne		.PEQ_NO
	inc		rcx
	jmp		.PEQ_LOOP

.PEQ_TERM:
	cmp byte ptr [rdi+rdx], ' '
	jne		.PEQ_NO
	mov		rax,	1
	ret

.PEQ_NO:
	xor		rax,	rax
	ret
