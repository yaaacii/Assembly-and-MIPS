; Author: Cicelia Siu
; Section: 1003
; Date Last Modified: September 4th, 2020
; Program Description: Learning to use Macros. Finding length of string, convering to uppercase, converting decimal string to integer, and converting integer to hex string

; Macro 1 - Returns the length of a given string in rax
; Argument 1: null terminated string
%macro stringLength 1
	mov rbx, %1		; set rbx to string
	%%countLoop:
		inc rax		; increase count
		mov cl, byte[rbx]	; set character to cl reg
		cmp cl, NULL	; comparing character to null
		je %%stringDone		;if equals, go to stringdone
		inc rbx		; go to next character
		jmp %%countLoop
	%%stringDone:
%endmacro

; Macro 2 - Convert letters in a string to uppercase
; Argument 1: null terminated string
%macro toUppercase 1
	mov rbx, %1		; set rbx to string
	%%toUppercaseLoop:
		mov cl, byte[rbx] 	; set character to cl reg
		cmp cl, NULL		;check to see if Null
		je %%uppercaseDone	; if so, done
		cmp cl, "a"
		jb %%nextCharacter	; if below a, next character
		cmp cl, "z"
		ja %%nextCharacter	; if above z, next character
		sub byte[rbx], 32	;convert to uppercase
		%%nextCharacter:
			inc rbx
			jmp %%toUppercaseLoop
	%%uppercaseDone:
%endmacro

; Macro 3 - Convert a Decimal String to Integer (signed dword)
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	mov rbx, %1		; set rbx to string
	mov rax, 0		;set rax to variable
	mov r8, 1	; default sign
	%%toInteger:
		mov cl, byte[rbx] 	; set character to cl reg
		cmp cl, NULL		;check to see if Npull
		je %%convertToIntDone	; if so, done
		%%skipSpace:	; check for spaces or zeros
			cmp cl, " "		; check if itis a space
			je %%nextChara		; if so, go to next chara
			cmp cl, "0"		;check if its a 0
			je %%nextChara		; if so,next chara
		cmp cl, "+"		; check if its + or -
		je %%nextChara	; if +, go to next caharater
		cmp cl, "-"
		jne %%convertToInt	; if not negative or positive jump to convert
		mov r8, -1		; if negative, change sign
		jmp %%nextChara		; go to nect chara
		%%convertToInt:
			sub cl, "0"		; convert cl to integer
			movzx ecx, cl
			mov edx, 10	
			mul edx 	; eax * 10
			add eax, ecx 	; add c reg
		%%nextChara:
			inc rbx		; next character in string
			jmp %%toInteger	; loop to check again
	%%convertToIntDone:
	mul r8		; multiply final (eax) by 1 if + or -1 if -
	mov dword[%2], eax	; set eax into %2

%endmacro

; Macro 4 - Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
%macro convertIntegerToHexadecimal 2
	mov eax, dword[%1]
    mov r8d, 16     ; divisor
	mov rbx, %2		; set rbx to %2
	mov rcx, 10     ; set index to 10 bc 11 byte arrayssssss
	mov byte[rbx+rcx], NULL		; last character in string to NULL
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
; System Service Call Constants
SYSTEM_WRITE equ 1
SYSTEM_EXIT equ 60
SUCCESS equ 0
STANDARD_OUT equ 1

; Special Characters
LINEFEED equ 10
NULL equ 0

; Macro 1 Variable
macro1Message db "This is the string that never ends, it goes on and on my friends.", LINEFEED, NULL

; Macro 1 Test Variables
macro1Label db "Macro 1: "
macro1Pass db "Pass", LINEFEED
macro1Fail db "Fail", LINEFEED
macro1Expected dq 67

; Macro 2 Variables
macro2Message db "Did you read Chapters 8, 9, and 11 yet?", LINEFEED, NULL

; Macro 2 Test Variable
macro2Label db "Macro 2: "

; Macro 3 Variables
macro3Number1 db "12345", NULL
macro3Number2 db "      +19", NULL
macro3Number3 db " -    1468     ", NULL
macro3Integer1 dd 0
macro3Integer2 dd 0
macro3Integer3 dd 0

; Macro 3 Test Variables
macro3Label1 db "Macro 3-1: "
macro3Label2 db "Macro 3-2: "
macro3Label3 db "Macro 3-3: "
macro3Pass db "Pass", LINEFEED
macro3Fail db "Fail", LINEFEED
macro3Expected1 dd 12345
macro3Expected2 dd 19
macro3Expected3 dd -1468

; Macro 4 Variables
macro4Integer1 dd 255
macro4Integer2 dd 1988650
macro4Integer3 dd -7

; Macro 4 Test Variables
macro4Label1 db "Macro 4-1: "
macro4Label2 db "Macro 4-2: "
macro4Label3 db "Macro 4-3: "
macro4NewLine db LINEFEED

section .bss
; Macro 4 Strings
macro4String1 resb 11
macro4String2 resb 11
macro4String3 resb 11

section .text
global _start
_start:

	; DO NOT ALTER _start in any way.

	mov rax, 0
	
	; Macro 1 - Do not alter
	; Invokes the macro using macro1Message as the argument
	stringLength macro1Message

	; Macro 1 Test - Do not alter
	push rax
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro1Label
	mov rdx, 9
	syscall
	
	mov rdi, STANDARD_OUT
	mov rsi, macro1Fail
	mov rdx, 5
	pop rax
	cmp rax, qword[macro1Expected]
	jne macro1_Fail
		mov rsi, macro1Pass
	macro1_Fail:
	mov rax, SYSTEM_WRITE
	syscall
	
	; Macro 2 - Do not alter
	; Invokes the macro using macro2message as the argument
	toUppercase macro2Message
	
	; Macro 2 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Message
	mov rdx, 41
	syscall
	
	; Macro 3 - 1 - Do not alter
	; Invokes the macro with macro3Number1 and macro3Integer1
	convertDecimalToInteger macro3Number1, macro3Integer1

	; Macro 3 - 2 - Do not alter
	; Invokes the macro with macro3Number2 and macro3Integer2
	convertDecimalToInteger macro3Number2, macro3Integer2
	
	; Macro 3 - 3 - Do not alter
	; Invokes the macro with macro3Number3 and macro3Integer3
	convertDecimalToInteger macro3Number3, macro3Integer3

	; Macro 3 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer1]
	cmp ebx, dword[macro3Expected1]
	jne macro3_1_Fail
		mov rsi, macro3Pass
	macro3_1_Fail:
	syscall

	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label2
	mov rdx, 11
	syscall

	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer2]
	cmp ebx, dword[macro3Expected2]
	jne macro3_2_Fail
		mov rsi, macro3Pass
	macro3_2_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer3]
	cmp ebx, dword[macro3Expected3]
	jne macro3_3_Fail
		mov rsi, macro3Pass
	macro3_3_Fail:
	syscall
	
	; Macro 4 - 1 - Do not alter
	convertIntegerToHexadecimal macro4Integer1, macro4String1
	
	; Macro 4 - 2 - Do not alter
	convertIntegerToHexadecimal macro4Integer2, macro4String2
	
	; Macro 4 - 3 - Do not alter
	convertIntegerToHexadecimal macro4Integer3, macro4String3

	; Macro 4 Test - Do not alter	
	; Test 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String1
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 2
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String2
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 3
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String3
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall