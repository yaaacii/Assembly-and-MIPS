; Author: Cicelia Siu
; Section: 1003
; Date Last Modified: September 4th, 2020
; Program Description: Find the average of each index in a list. Find the sum,
; average, minimum, maximum, number of even numbers, and number of odd numbers of one list. 

section .data
; System service call values
SERVICE_EXIT equ 60
SERVICE_WRITE equ 1
EXIT_SUCCESS equ 0
STANDARD_OUT equ 1
NEWLINE equ 10

programDone db "Program Done.", NEWLINE 
stringLength dq 14

; Initalized Variables and Arrays

list1 dd 2078, 3854, 6593, 947, 5252, 1190, 716, 3587, 8014, 9563
	dd 9821, 3195, 1051, 6454, 5752, 980, 9015, 2478, 5624, 7251
	dd 2936, 1073, 1731, 5376, 4452, 792, 2375, 2542, 5666, 2228
	dd 454, 2379, 6066, 3340, 2631, 9138, 3530, 7528, 7152, 1551
	dd 9537, 9590, 2168, 9647, 5362, 2728, 5939, 4620, 1828, 5736

list2 dd 5087, 6614, 6035, 6573, 6287, 5624, 4240, 3198, 5162, 6972
	dd 6219, 1331, 1039, 23, 4540, 2950, 2758, 3243,1229, 8402
	dd 8522, 4559, 1704, 4160, 6746, 5289, 2430, 9660, 702, 9609
	dd 8673, 5012, 2340, 1477, 2878, 2331,3652, 2623, 4679, 6041
	dd 4160, 2310, 5232, 4158, 5419, 2158, 380, 5383, 4140, 1874

evenCount db 0		; # of evens
oddCount db 0			; # of odds

LIST_LENGTH equ 50

section .bss

; Uninitalized Variables and Arrays

list3 resd 50     ; this list 3 has 50 * 32 addresses
sumAnswer resq 1	; sum of all the numbers in list 3
averageAnswer resq 1	; average of numbers in list 3
minimumAnswer resd 1	; minimum of numbers in list 3
maximumAnswer resd 1	; maximum of numbers in list 3


section .text
; Start of the code





global _start
_start:

; ======Calculating List3========
    mov rbx, 0  ; set index to 0
	mov rcx, 2
    findAverage:
        mov eax, 0  ; set sum to 0 each loop
        add eax, dword [list1 + rbx*4]   ; add list 1[i] to eax
        add eax, dword [list2 + rbx*4]   ; add lsit 2[i] to eax
        mov rdx, 0	; set upper values to 0
        div rcx     ; eax = ecx/2
        mov dword[list3 + rbx*4], eax   ; set value in eax to list3[i] 
        inc rbx     ; increase index by 1
        cmp rbx,  LIST_LENGTH	; compare rbx and 50
 		jb findAverage		; loop to find average if rbx <= 50

; ======Calculating Sum========
	mov eax, 0	; set sum register to 0
	mov ebx, 0  ; set index to 0
	findSum:
		add eax, dword [list3 + rbx*4]  	;add list3 to rax
		inc ebx		; increase index by 1
		cmp ebx, LIST_LENGTH	; compare rbx and 50
 		jb findSum	; loop to find average if rbx <= 50
 	movsxd rax, eax
	mov qword[sumAnswer], rax	; after loop, set sumAnswer to rax

; ======Calculating Average========
	mov rax, qword[sumAnswer]		; set rax with sumAnswer
	mov rbx, 50		; set rbx with 50 # of values in list 3
	div rbx		; rax = rax/rbx
	mov qword[averageAnswer], rax		; set averageAnswer to rax

; ======Calculating Minimum========
	mov eax, dword[list3]		; set eax to list 3
	mov rbx, 1
	mov rcx, LIST_LENGTH-1
	minimumLoop:
		cmp eax, dword[list3 + rbx*4]
		jbe skipMin		; jumpif <= new value
		mov eax, dword[list3 + rbx*4]
		skipMin:
			inc rbx
			cmp rbx, rcx
			jbe minimumLoop
	mov dword[minimumAnswer], eax

; ======Calculating Maximum========
	mov eax, dword[list3]		; set eax to list 3
	mov rbx, 1
	mov rcx, LIST_LENGTH-1
	maximumLoop:
		cmp eax, dword[list3 + rbx*4]
		jae skipMax		; jumpif >= new value
		mov eax, dword[list3 + rbx*4]
		skipMax:
			inc rbx
			cmp rbx, rcx
			jbe maximumLoop
	mov dword[maximumAnswer], eax

; ======Calculating Even Values========	
	mov rbx, 0		; index
	mov ecx, 2		; divsor
	countEven:
		mov eax, dword[list3 + rbx*4]		; dividend
		mov edx, 0
		div ecx
		cmp edx, 0
		jne skipEven		; jump if remainder != 0
		inc byte[evenCount]
		skipEven:
			inc rbx
			cmp rbx, LIST_LENGTH
			jb countEven

; ======Calculating Odd Values========	
	mov rbx, 0		; index
	mov ecx, 2		; divisor
	countOdd:
		mov eax, dword[list3 + rbx*4]		; dividend
		mov edx, 0
		div ecx
		cmp edx, 0
		je skipOdd		; jump if remainder = 0
		inc byte[oddCount]
		skipOdd:
			inc rbx
			cmp rbx, LIST_LENGTH
			jb countOdd


endProgram:
; 	Outputs "Program Done." to the console
	mov rax, SERVICE_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, programDone
	mov rdx, qword[stringLength]
	syscall

; 	Ends program with success return value
	mov rax, SERVICE_EXIT
	mov rdi, EXIT_SUCCESS
	syscall
