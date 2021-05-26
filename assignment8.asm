;   Author: Cicelia Siu
;   Section: 1003
;   Date Last Modified: Oct 20th, 2020
;   Program Description: Assignment #8
;	This program will explore the use of accessing functions 
;	from a library and processing command line arguments.
; EXTRA CREDIT DONE

section .data
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0
    
    LINEFEED equ 10
    NULL equ 0
    endOfLine db LINEFEED, NULL
	space db " "

    diameterTagError db "Invalid diameter tag.", LINEFEED, NULL
    noTagError db "Enter -d <number. after the program name.", LINEFEED, NULL
    formatError db "Invalid numeric format for diameter.", LINEFEED, NULL
    VolumeAnswer db "Halfsphere Volume: %f", LINEFEED, NULL
	
    PI dq 3.14159
    two dq 2.00000
    three dq 3.00000
    atofError dq 0.00000

section .bss
    diameter dq 0.00000
    radius dq 0.00000
    volume dq 0.00000
	
extern atof, printf
section .text

global main
main:
    ;mov qword[argv], rsi
    ; check if there are 3 line arguments - works
    mov r12, rdi
    mov r13, rsi
    ; if not the right amount of tags
    mov rdi, noTagError
    cmp r12, 3
    jne error

    ; check for -d or r tag - words (havent tried r)
    mov rdi, diameterTagError   ; in case of error
	mov rbx, qword[r13+8]       ; note: i am chechked NULL before i check d or r tag
	cmp byte[rbx], "-"
	jne error
    cmp byte[rbx+2], NULL
	jne error
    cmp byte[rbx+1], "d"    ;   or check if its d or r tage
	je next

    ; with r tag
    cmp byte[rbx+1], "r"        ; if not d or r, error
    jne error
    ; input float after -r tag into radius variable
    mov rdi, qword[r13+16]
    call atof
    mov rdi, formatError    ; if atof doesnt work
    ucomisd xmm0, qword[atofError]
    je error
    movsd qword[radius], xmm0
    jmp calculate

    next:
    ; input float after -d tag into diameter variable 
    mov rdi, qword[r13+16]
    call atof
    mov rdi, formatError    ; if atof doesnt work
    ucomisd xmm0, qword[atofError]
    je error
    movsd qword[diameter], xmm0



    
    calculate:
    ; calc volume
    call calculateHalfSphereVolume
    mov rdi, VolumeAnswer
    mov rsi, qword[volume]
    mov rax, 1
    sub rsp, 8
    call printf
    add rsp, 8


    endProgram:
        mov rax, SYSTEM_EXIT
        mov rdi, SUCCESS
        syscall
    
    error:
    call endOnError
ret

; find the length of a string (including NULL)
; rdi = address of the string
; rdx = returns length

global findLength 
findLength:
	push rcx
	
	mov rdx, 1
	countLettersLoop:
		mov cl, byte[rdi + rdx - 1]
		cmp cl, NULL
		je countLettersDone
		
		inc rdx
	loop countLettersLoop
	countLettersDone:
	
	pop rcx
ret

; outputs error message and stops program
; rdi = address of error message

global endOnError
endOnError:
	mov rsi, rdi
	call findLength	; rdx set by macro findLength
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	syscall
	
	jmp endProgram
ret

global calculateHalfSphereVolume
calculateHalfSphereVolume:
    cmp qword[diameter], 0
    je continueWithRadius
    movsd xmm0, qword[diameter]
    divsd xmm0, qword[two]
    movsd qword[radius], xmm0
    ; for ec, do movsd radius, to xmm0
    continueWithRadius:
    movsd xmm0, qword[radius]
    mulsd xmm0, xmm0
    mulsd xmm0, qword[radius]   ; radius ^3
    mulsd xmm0, qword[PI]       ; PI*r^3
    mulsd xmm0, qword[two]    ; 2*PI*r^3
    divsd xmm0, qword[three]
    movsd qword[volume], xmm0

ret
