; Author: Cicelia Siu
; Section: 1003
; Date Last Modified: Oct 9th, 2020
; Program Description: Random Numbers using LCG and CombSort


section .data
	; 	System Service Call Constants
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0

	;	ASCII Values
	NULL equ 0
	LINEFEED equ 10

    	;	Labels/Prompts / Useful Strings
	labelHeader db "Sorted Random Number Generator", LINEFEED, LINEFEED, NULL
    LabelResultHeader db "Sorted Random Numbers", LINEFEED, LINEFEED, NULL
	promptQuantity db "Enter number of values to generate (2-10,000):", NULL
	promptMaxValue db "Maximum Value (1-100,000):", NULL
	endOfLine db LINEFEED, NULL
	space db " "

	errorStringUnexpected db "Error - Unexpected Character found in input.", LINEFEED, LINEFEED, NULL
	errorStringNoDigits db "Error - Value must contain at least one digit.", LINEFEED, LINEFEED, NULL
	errorNotInRange db "Error - Inputed Value is not within range.", LINEFEED, LINEFEED, NULL

	; 	Useful variables
	quantity dd 0		; note i changed these two from dq
	maxValue dd 0
	VALUES_PER_LINE equ 5
	OUTPUT_LENGTH equ 11
	m equ 2147483647
	a equ 48271

section .bss
	quantityString resd 1000
	maxValueString resd 1000
	lcgArray resd 10000
	randomNumbersArray resd 10000
	hexArray resd 10000


section .text

global _start
_start:

;	Output Header
	mov rdi, labelHeader
	call findLength	; rdx set by macro findLength
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, labelHeader
	syscall

;	Ouput Quantity Prompt
	mov rdi, promptQuantity
	call findLength	; rdx set by macro findLength
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, promptQuantity
	syscall

; 	Input Quantity
	mov rdi, quantityString
	call readString
	mov rdi, quantityString
	call convertDecimalToInteger
	mov dword[quantity], eax 
	; check if quantity is in range
	cmp dword[quantity], 2
	jb rangeError1
	cmp dword[quantity],10000
	jbe continue1
	rangeError1:
	mov rdi, errorNotInRange
	call endOnError

	continue1:
;	Output Max Value Prompt
	mov rdi, promptMaxValue
	call findLength	; rdx set by macro findLength
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, promptMaxValue
	syscall
; 	Input Max Value 
	mov rdi, maxValueString
	call readString
	mov rdi, maxValueString
	call convertDecimalToInteger
	mov dword[maxValue], eax
	; check if maxValye is in range
	cmp dword[maxValue], 1
	jb rangeError2
	cmp dword[maxValue],100000
	jbe continue2
	rangeError2:
	mov rdi, errorNotInRange
	call endOnError

	continue2:


; Get random numbers into array
	mov rdi, lcgArray
	mov rsi, randomNumbersArray
	call randomNumbersGenerator

; EVERYTHING ABOVE THIS WORKS

; sort random numbers
	mov rdi, randomNumbersArray
	call combSort


; EVERYTHING BELOW THIS WORKS
; Switch random numbers to hex and print
; print head
	mov rdi, LabelResultHeader
	call findLength	; rdx set by macro findLength
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, LabelResultHeader
	syscall
; start conversion
mov ebx, 0	; count loop
mov r12, randomNumbersArray
mov r13, hexArray
randomNumbersToHex:
	mov rdi, r12
	mov rsi, r13
	call convertIntegerToHexadecimal
	; print out hex
	mov rsi, r13
	mov rdx, OUTPUT_LENGTH
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	syscall
	inc ebx
	add r12, 4
	add r13, 4
; check to see if its the 5th one
	mov ecx, VALUES_PER_LINE
	mov eax, ebx
	mov edx, 0
	div ecx
	cmp edx, 0
	je addLinefeed 
	; if not add space and loop
	mov rax, SYSTEM_WRITE	; write out
	mov rdi, STANDARD_OUT	; standard out -> terminal
	mov rsi, space
	mov rdx, 1
	syscall
	cmp ebx, dword[quantity]
	je addLinefeed		; when array index = length, done converting
	jmp randomNumbersToHex
	addLinefeed:
		mov rax, SYSTEM_WRITE	; write out
		mov rdi, STANDARD_OUT	; standard out -> terminal
		mov rsi, endOfLine	; message
		mov rdx, 2	
		syscall
		cmp ebx, dword[quantity]
		je printDone		; when array index = length, done converting
		jmp randomNumbersToHex
printDone:


endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall

; FUNCTION #1 (works except the numbers are not the same)
; linear congruential generator for random numbers
; rdi = address of lcgs array
; rsi = address for random numbers array
global randomNumbersGenerator
randomNumbersGenerator:
	mov r8, 0	; loop count
	mov dword[rdi], 1 ; put seed in first
;	mov dword[rsi], 1	; in both arrays

	generate:
		mov eax, dword[rdi +r8*4]	; set previous lcg to eax - pass by reference
		movsxd rax, eax
		mov rcx, a
		mul rcx		; seed * a
		mov rcx, m
		mov rdx, 0
		div rcx		; (seed *a) / m to get remainder in edx
		mov rax, rdx	; put remainder into eax
		mov dword[rdi + r8*4 +4], edx	; remainder will be set into the lcg(n)
; make remainder less than max Value
		mov ecx, dword[maxValue]	; lcg % range+1
		inc ecx			; range + 1
		mov edx, 0
		div ecx		; divide remainder by max value to get the remainder less than maxVAlue
		mov dword[rsi + r8*4], edx	; remainder will be set into the array(n)
		inc r8		; inc loop count
		mov ecx, dword[quantity]
		dec ecx
		cmp r8d, dword[quantity]	; if loopcount != quantity, keep looping
		jne generate
ret
	


; FUNCTION # 2
; Comb Sort
; rdi = address of the integer numbers

global combSort
combSort:
	push rbx
	push r12
;	mov r12, 0
;	mov ecx, dword[rdi]
	mov eax, dword[quantity] 	; gapsize
	combSortLoop:
		; gapsize = gapsize *10 /13
		 mov ecx, 10
		 mul ecx
		 mov ecx, 13
		 mov edx, 0
		 div ecx
		 cmp eax, 0		; if gapsize == 0
		 jne continueLoop
		mov eax, 1	; gapsize = 1
		cmp r12, 0	; if swapsDone == 0
		je exitSortLoop	; exit sort Loop
		; if not keep going
		 continueLoop:
			mov r12, 0		; swapsDone = 0
			mov r8d , 0 	; i
			; for loop
			startForLoop:
			mov r9d, dword[quantity]
			sub r9d, eax ; n-gapsize
			cmp r8d, r9d	; check if i<n-gapsize
			jae combSortLoop
;			movsxd rbx, r8d
			movsxd r8, r8d
			movsxd rax, eax
			add r8, rax	; i+gapsize
			mov ecx, dword[rdi+r8*4] ; array[i+gapsize]
			sub r8, rax
			;mov ebx, dword[rdi+r8*4]	; array[i]
			; if 
			cmp dword[rdi+r8*4], ecx		; if array[i] > array[i+gapsize]
			jbe skipSwap
			; swap
				mov ebx, dword[rdi +r8*4]	; temp = array[i]
				mov dword[rdi+ r8*4], ecx	; array [i] = array[i+gapsize]
				add r8, rax	; i+gapsize
				mov dword[rdi +r8*4], ebx	; array[i+gapsize]= temp
				sub r8, rax
				inc r12		; swapsdone = 1
			skipSwap:
			inc r8d		; i++
			jmp startForLoop
	exitSortLoop:
	pop r12
	pop rbx
ret


; FUNCTION # 3
; Convert a decmal String to Integer (signed dword)
; rdi = null terminated string (byte array)
; rsi = dword integer variable

global convertDecimalToInteger
convertDecimalToInteger:
    push rbx
	mov eax, 0
	mov rbx, rdi
	mov r9d, 1	; sign
	mov r8d, 10 ; base
	mov r10, 0 ; digits processed
	checkForSpaces1:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck1
		inc rbx
	jmp checkForSpaces1
	nextCheck1:
	cmp cl, "+"
	je checkForSpaces2Adjust
	cmp cl, "-"
	jne checkNumerals
	mov r9d, -1
	checkForSpaces2Adjust:
		inc rbx
	checkForSpaces2:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck2	
		inc rbx
	jmp checkForSpaces2
	nextCheck2:
	checkNumerals:
		movzx ecx, byte[rbx]
		cmp cl, NULL
		je finishConversion
		cmp cl, " "
		je checkForSpaces3	
		cmp cl, "0"
		jb errorUnexpectedCharacter
		cmp cl, "9"
		ja errorUnexpectedCharacter
		jmp convertCharacter
		errorUnexpectedCharacter:
			mov rdi, errorStringUnexpected
			call endOnError 	
		convertCharacter:
		sub cl, "0"
		mul r8d
		add eax, ecx
		inc r10
		inc rbx
	jmp checkNumerals
	checkForSpaces3:
		mov cl, byte[rbx]
		cmp cl, " "
		jne checkNull
		inc rbx
	jmp checkForSpaces3
	checkNull:
		cmp cl, NULL
		je finishConversion
            ; put errorStringUnexpected in a register (rdi?), and call endonerror
            mov rdi, errorStringUnexpected
			call endOnError 
	finishConversion:
		cmp r10, 0
		jne applySign
            ; put errorStringNoDigits in a register (rdi?), and call endonerror
			mov rdi, errorStringNoDigits
			call endOnError 
	applySign:
		mul r9d
		mov dword[rsi], eax
    pop rbx
ret

; FUNCTION #4
; convert integer to hexadecimal string
; rdi = dword integer variable
; rsi = string(11 byte array)

global convertIntegerToHexadecimal
convertIntegerToHexadecimal:
    push rbx
	mov byte[rsi], "0"
	mov byte[rsi+1], "x"
	mov byte[rsi+10], NULL	
	mov rbx, rsi
	add rbx, 9	
	mov r8d, 16 ;base
	mov rcx, 8
	mov eax, dword[rdi]
	convertHexLoop:
		mov edx, 0
		div r8d	
		cmp dl, 10 
		jae addA
			add dl, "0" ; Convert 0-9 to "0"-"9"
		jmp nextDigit
		addA:
			add dl, 55 ; 65 - 10 = 55 to convert 10 to "A"	
		nextDigit:
			mov byte[rbx], dl
			dec rbx
			dec rcx
	cmp eax, 0
	jne convertHexLoop

	addZeroes:
		cmp rcx, 0
		je endConversion
		mov byte[rbx], "0"
		dec rbx
		dec rcx
	jmp addZeroes
	endConversion:
    pop rbx
	mov rax, rsi
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


; reads in String from STD-IN
; rdi = address of location to place string
; rcx = max length of string

global readString
readString:
	push rbp
	push rbx
	mov rbx, 0
	mov rbp, rdi	; argument 1, rdi = rbp
	readLengthLoop:
		lea rsi, byte[rbp + rbx]
		mov rdx, 1
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		syscall
				
		inc rbx
		cmp byte[rbp + rbx - 1], LINEFEED
		je readLengthDone
	
	mov r8, rcx
	inc r8
	cmp rbx, r8	; rcx = argument 2
	jb readLengthLoop
		call clearInputBuffer
;		mov rdx, errorStringTooLong
;		call endOnError 
	readLengthDone:
	mov byte[rbp + rbx - 1], NULL
	pop rbx
	pop rbp
ret

global clearInputBuffer
clearInputBuffer:
	clearBufferLoop:
		lea rsi, byte[rdx]
		mov rdx, 1
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		syscall
	cmp byte[rdx], LINEFEED
	jne clearBufferLoop
ret