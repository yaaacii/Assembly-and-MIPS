; Author: Cicelia Siu
; Section: 1003
; Date Last Modified: September 20th, 2020
; Program Description:Convert multiple numbers into hex



; Macros

;	Determines the number of characters (including null) of the provided string
;	Argument 1: Address of string
;	Returns length in rdx
%macro findLength 1
	push rcx
	
	mov rdx, 1
	%%countLettersLoop:
		mov cl, byte[%1 + rdx - 1]
		cmp cl, NULL
		je %%countLettersDone
		
		inc rdx
	loop %%countLettersLoop
	%%countLettersDone:
	
	pop rcx
%endmacro

;	Outputs error message and stops program execution
;	Argument 1: Address of error message
%macro endOnError 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, %1
	findLength %1	; rdx set by macro findLength
	syscall
	
	jmp endProgram
%endMacro


; Convert a Decimal String to Integer (signed dword)
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
; Argument 3: dword offset for array
%macro convertDecimalToInteger 3
	mov rbx, %1		; set rbx to string
	mov rax, 0		;set rax to variable
	mov r8, 1	; default sign
	mov r10b, -1	; no digit
	%%toInteger:
		mov cl, byte[rbx] 	; set character to cl reg
		cmp cl, NULL		;check to see if Null
		je %%convertToIntDone	; if so, done
		cmp cl, LINEFEED
		je %%convertToIntDone
		%%skipSpace:	; check for spaces or zeros
			cmp cl, " "		; check if itis a space
			je %%nextChara		; if so, go to next chara
		cmp cl, "+"		; check if its + or -
		je %%nextChara	; if +, go to next caharater
		cmp cl, "-"
		jne %%checkUnexpected	; if not negative or positive jump to check unexpected
		mov r8, -1		; if negative, change sign
		jmp %%nextChara		; go to nect chara
		%%checkUnexpected:
			cmp cl, "0"
			jb unexpectedChara
			cmp cl, "9"
			ja unexpectedChara
		%%convertToInt:
			sub cl, "0"		; convert cl to integer
			movzx ecx, cl
			mov edx, 10	
			mul edx 	; eax * 10
			add eax, ecx 	; add c reg
			mov r10b, 1	; there is at least one digit 
			; check spaces inbetween
			cmp byte[rbx+1], " "	; if theres is a space
			jne %%nextChara
			cmp byte[rbx+2], " "	; check if next is a space or null
			je %%nextChara		;if so, next chara
			cmp cl, NULL
			je %%nextChara		; if not, there are either numerals or another unexpected chara
			jmp unexpectedChara

		%%nextChara:
			inc rbx		; next character in string
			jmp %%toInteger	; loop to check again
	%%convertToIntDone:
	cmp r10b, -1		; if has no digits
	je noDigit	; jmp to unexpected chara
	mul r8		; multiply final (eax) by 1 if + or -1 if -
	mov r9d, dword[%3]
	mov dword[%2+ r9d*4], eax ;into %2
%endmacro


;Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
; Argument 3: dword offset for array
%macro convertIntegerToHexadecimal 3
	mov r9d, dword[%3]
	mov eax, dword[%1+ r9*4]
    mov r8d, 16     ; divisor
	mov rbx, %2		; set rbx to %2
	mov rcx, 10     ; set index to 10 bc 11 byte arrayssssss
	mov byte[rbx+rcx], NULL		; last character in string to NULL [%2 + index + array index]
	%%toHex:
		dec rcx     ; dec index
		cmp rcx, 1	; when rbx is at 1, the hex is done
		je %%finishHex
        ; division process
		mov edx, 0
		div r8d		; div rax by 16 for hex
		cmp edx, 10	; check remainder
		jae %%covertLetter ; convert to letter if remainder is >=10
		add edx, 48		; convert to number if remainder is <10
		mov byte[rbx+rcx], dl
		jmp %%toHex
		%%covertLetter:		; convert to letter
			add edx, 55
			mov byte[rbx+rcx], dl
			jmp %%toHex
	%%finishHex:
		mov byte[rbx+rcx], "x"	; doing 0x
		dec rbx
		mov byte[rbx+rcx], "0"
%endmacro



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
	
	;	Program Constraints
	MINIMUM_ARRAY_SIZE equ 1
	MAXIMUM_ARRAY_SIZE equ 1000
	INPUT_LENGTH equ 20
	OUTPUT_LENGTH equ 11
	VALUES_PER_LINE equ 5
	
	;	Labels / Useful Strings
	labelHeader db "Number Converter (Decimal to Hexadecimal)", LINEFEED, LINEFEED, NULL
	labelConverted db "Converted Values", LINEFEED, NULL
	endOfLine db LINEFEED, NULL
	space db " "
	
	;	Prompts
	promptCount db "Enter number of values to convert (1-1000):", LINEFEED, NULL
	promptDataEntry db "Enter decimal value:", LINEFEED, NULL
	
	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - Program can only convert at least 1 value.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - Program can only convert at most 1,000 values.", LINEFEED, LINEFEED, NULL
							 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL
	
	; 	extra credit error
	errorIntegerRange db LINEFEED, "Error - Value not within double word integer range.", LINEFEED, LINEFEED, NULL
	
	;	Other
	arrayLength dd 0
	arrayIndex dd 0
	


section .bss
	;	Array of integer values, not all will necessarily be used
	array resd 1000
	inputString resb 21
	outputString resb 11
	hex1 resd 11
	hexArray resd 1000

section .text
global _start
_start:

	;	Output Header	- Works
	mov rax, SYSTEM_WRITE	; write out
	mov rdi, STANDARD_OUT	; standard out -> terminal
	mov rsi, labelHeader	; message
	findLength labelHeader		; finds length and puts into rdx, don't know if i need mov rdx
	syscall
	
	;	Output Array Length Prompt	-works
	mov rax,SYSTEM_WRITE	; write out
	mov rdi, STANDARD_OUT	; standard out -> terminal
	mov rsi, promptCount	; message
	findLength promptCount	; finds length and puts into rdx, don't know if i need mov rdx
	syscall

	;	Read in Array Length - one character at a time	-works
	mov rbx, 0		; index
	readLengthLoop:
		mov rax, SYSTEM_READ	; read in
		mov rdi, STANDARD_IN	; standard in <- terminal
		mov rsi, inputString		; begin at address of input string
		add rsi, rbx	; beginning plus index
		mov rdx, 1		; reading one character at a time
		syscall			; execute
		inc rbx		; increase index
		cmp byte[inputString+rbx -1], LINEFEED	; trying to find linefeed
		je readLengthDone		; if so, done
		cmp rbx, 21
		ja errorLength
		jmp readLengthLoop		; keep going if not linefeed
		errorLength:
			endOnError errorStringTooLong
	readLengthDone:

	;	Convert Array Length							- works EXCEPT spaces between numerals and noDigit
	
	convertDecimalToInteger inputString, arrayLength, arrayIndex
	

	;	Check that Array Length is Valid - output error message and end program if not	-works so far 
	mov rax, qword[arrayLength]
	mov rbx, MINIMUM_ARRAY_SIZE
	mov rcx, MAXIMUM_ARRAY_SIZE
	cmp rax, rbx
	jae checkArrayMax
		endOnError errorArrayMinimum	; this will end program if array lenth is below min array size
	checkArrayMax:
	cmp rax, rcx
	jbe checkLengthDone
	endOnError errorArrayMaximum	; this will end program if array length is above max array size
	checkLengthDone:
	
	jmp charaCorrect	

	; do unexpected Character errors
	unexpectedChara:
		endOnError errorStringUnexpected
	noDigit:
		endOnError errorStringNoDigits
	charaCorrect:


	;	Read in Array Values
		mov r15w, 1  ; loop times	
	ReadDataLoop:
		; Prompt For New Value		
		mov rax,SYSTEM_WRITE	; write out
		mov rdi, STANDARD_OUT	; standard out -> terminal
		mov rsi, promptDataEntry	; message
		findLength promptDataEntry	; finds length and puts into rdx
		syscall	

		;	Read in Value - one character at a time
		mov rbx, 0		; index
		readValueLoop:
			mov rax, SYSTEM_READ	; read in
			mov rdi, STANDARD_IN	; standard in <- terminal
			mov rsi, inputString		; begin at address of input string
			add rsi, rbx	; beginning plus index
			mov rdx, 1		; reading one character at a time
			syscall			; execute
			inc rbx		; increase index
			cmp byte[inputString+rbx -1], LINEFEED	; trying to find linefeed
			je readValueDone		; if so, done
			cmp rbx, 21				; check if more than 21 characters
			ja errorLength1		; if so, error
			jmp readValueLoop		; keep going if not linefeed
			errorLength1:
				endOnError errorStringTooLong
		readValueDone:

		;	Convert Value
		convertDecimalToInteger inputString, array, arrayIndex

		; extra credit
;		movzx r8, byte[arrayIndex]
;		lea r14, [array + r8*4]		
;		mov r8, qword[r14]
;		cmp qword[r14], 2147483647	; check if integer is greater than dword int range
;		ja integerRangeError	
;		cmp qword[r14], -2147483647		; or less than dword int range
;		jl integerRangeError		;	if so, error
;		jmp continue1				; if not, continue
;		integerRangeError:
;			endOnError errorIntegerRange
		; end of extra credit
;		continue1:			
		inc byte[arrayIndex]	; increase array address for next value	
		cmp r15w, word[arrayLength]		; if the array index= arrayLength  		
		je ReadDataDone		; the array is done
		inc r15w	; if has more space, increment array
		jmp ReadDataLoop	; and do loop until 0 space left
	ReadDataDone:
		



	;	Output Array Values in Hex - (5 Per Line)
	; 		Print Header
	printOut:
		mov rax,SYSTEM_WRITE	; write out
		mov rdi, STANDARD_OUT	; standard out -> terminal
		mov rsi, labelConverted	; message
		findLength labelConverted	; finds length and puts into rdx
		syscall

	; Convert Values
	mov r9w, 0		; times looped
	mov byte[arrayIndex], 0		; array index
	
	convertToHexLoop:
		convertIntegerToHexadecimal array, outputString, arrayIndex	; convert
		inc byte[arrayIndex]	; inc array index

	; 		Print Array Values in Hex 
		hexOutput:
			mov rax, SYSTEM_WRITE	; write out
			mov rdi, STANDARD_OUT	; standard out -> terminal
			mov rsi, outputString	; message
			mov rdx, OUTPUT_LENGTH	; only outputs 11
			syscall
			inc r9w		; inc looped times

			; check to see if its the 5th one
			mov bx, VALUES_PER_LINE
			mov ax, r9w
			mov dx, 0
			div bx
			cmp dx, 0
			je addLinefeed 
			; if not add space and loop
			mov rax, SYSTEM_WRITE	; write out
			mov rdi, STANDARD_OUT	; standard out -> terminal
			mov rsi, space
			mov rdx, 1
			syscall
			cmp r9w, word[arrayLength]
			je addLinefeed		; when array index = length, done converting
			jmp convertToHexLoop
			addLinefeed:
				mov rax, SYSTEM_WRITE	; write out
				mov rdi, STANDARD_OUT	; standard out -> terminal
				mov rsi, endOfLine	; message
				mov rdx, 2	; only outputs 1 character
				syscall
				cmp r9w, word[arrayLength]
				je printDone		; when array index = length, done converting
				jmp convertToHexLoop
	printDone:

endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall
