;   Author: Cicelia Siu
;   Section: 1003
;   Date Last Modified: Oct 20th, 2020
;   Program Description: Assignment #9: Circular Buffer

section .data
    ; helpful numbers
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

    ; outsputs
    fileAddError db "Characters could not be added.", LINEFEED, NULL
    readFileOpenError db "Read file could not be opened.", LINEFEED, NULL
    writeFileOpenError db "Write file could not be opened.", LINEFEED, NULL
    stringLegnthError db "String is longer than 20 characters.", LINEFEED, NULL
    fileWriteError db "File could not be written in.", LINEFEED, NULL
    noLineArgumentError db "The right amount of command line arguments.", LINEFEED, NULL
    hexLineOutputs db "Line: ", NULL
    hexColumnOutputs db " Column: ", NULL
    writeFile db "results.txt", NULL

    READ_ONLY equ 0
    WRITE_ONLY equ 1
    READ_AND_WRITE equ 2


    BUFFER_SIZE equ 100
    charactersBufferedToCircular dq 0
    charactersBufferedToFile dq 0
    charactersRead db 0
    
    STRING_LENGTH equ 20
    matched db 0
    readPointer dq 0
    writePointer dq 0
    lineNumber dq 1
    columnNumber dq 1

; unitialized
section .bss
    fileBuffer resb 100
    circularBuffer resq 20
    searchString resq 20
    readFile resq 1000
    readFileDescriptor dq 0
    writeFileDescriptor dq 0
    stringLength dq 0
    charactersInFileBuffer db 0
    hexOutputs resb 11
    endOfFileReached db 0
    
    
	
extern atof, printf
section .text

global main
main:
    ; check if there are 3 line arguments - works
    mov r12, rdi
    mov r13, rsi
    ; if not the right amount of tags
    mov rdi, noLineArgumentError
    cmp r12, 3
    je read 
        call endOnError
    read:
    ; mov read file and search string files from argv
    mov rbx, qword[r13+8]
    mov qword[readFile], rbx
    mov rbx, qword[r13+16]
    mov rdx, qword[rbx]
    mov qword[searchString], rdx
    
    ; find length of searchString
    mov rdi, searchString
    call findLength
    dec rdx ; subtract the NULL
    mov qword[stringLength], rdx
    cmp rdx, STRING_LENGTH
    jbe openFile
        mov rdi, stringLegnthError
        call endOnError

    openFile:

   

    ;initalize fileBuffer
    call addToFileBuffer

    ; open write file
        mov rax, 85
        mov rdi, writeFile
        mov rsi, 00200q | 00400q
        syscall

        mov rdi, writeFileOpenError      ; if RAX returns negative give error
        cmp rax, 0
        jge skipError2
        call endOnError
        skipError2:
        mov qword[writeFileDescriptor], rax

    ; Circular Buffer
    circularBufferStart:
        ; fill circularBuffer 
        call getCharFunction   
        mov rdx, qword[stringLength]
        cmp qword[charactersBufferedToCircular], rdx
        jb circularBufferStart
        ; when done initalizing fileBuffer, start circularBuffer

        
        circularBufferLoop:

        mov rdi, searchString
        mov rsi, circularBuffer
        call compareStrToBuffer
        
        cmp byte[matched], 1
        je match            ; if matched write in file

        inc qword[columnNumber]
        call getCharFunction ; if not, getChar another character to circular look and loop
        jmp circularBufferLoop
        
        match:              
            

        ; write in file the hex outputs
            mov rdi, hexLineOutputs
            call findLength
            dec rdx
            mov rax, 1
            mov rdi, qword[writeFileDescriptor]
            mov rsi, hexLineOutputs
            syscall

            mov rdi, fileWriteError
            cmp rax, 0
            jl endOnError

            ; convert line # to hex
            mov rdi, lineNumber
            mov rsi, hexOutputs
            call convertIntegerToHexadecimal
            ; print put hex line #
            mov rdi, hexOutputs
            call findLength
            dec rdx
            mov rax, 1
            mov rdi, qword[writeFileDescriptor]
            mov rsi, hexOutputs
            syscall

            mov rdi, fileWriteError
            cmp rax, 0
            jl endOnError

           ; print hex columnNumber
            mov rdi, hexColumnOutputs
            call findLength
            dec rdx
            mov rax, 1
            mov rdi, qword[writeFileDescriptor]
            mov rsi, hexColumnOutputs
            syscall

            mov rdi, fileWriteError
            cmp rax, 0
            jl endOnError

            ; convert line # to hex
            mov rdi, columnNumber
            mov rsi, hexOutputs
            call convertIntegerToHexadecimal
            ; print put hex line #
            mov rdi, hexOutputs
            call findLength
            dec rdx
            mov rax, 1
            mov rdi, qword[writeFileDescriptor]
            mov rsi, hexOutputs
            syscall

            mov rdi, fileWriteError
            cmp rax, 0
            jl endOnError
            
            
            mov rdx, 2
            dec rdx
            mov rax, 1
            mov rdi, qword[writeFileDescriptor]
            mov rsi, endOfLine
            syscall

            mov rdi, fileWriteError
            cmp rax, 0
            jl endOnError

             
        ; loop again
        mov byte[matched], 0
        call getCharFunction
        jmp circularBufferLoop
    
    endLoop:
        
    ; close the write file
            mov rax, 3
            mov rdi, qword[writeFileDescriptor]
            syscall

    endProgram:
        mov rax, SYSTEM_EXIT
        mov rdi, SUCCESS
        syscall

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
	mov rax, qword[rdi]
	convertHexLoop:
		mov rdx, 0
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
	cmp rax, 0
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




; get one character from the file buffer -works
global getCharFunction
getCharFunction:
    ; if (characterBufferedToFile>charactersBufferedToCircular)
    mov rdx, qword[charactersBufferedToCircular]
    cmp qword[charactersBufferedToFile], rdx
    jl else1
    ; { 
        ; &circularBuffer+writePinter = buffer[charactersBufferedToCircular]
        ; charactersBufferedToCircular++
        ; writePointer++
    ;}
    mov cl, byte[fileBuffer+rdx]
    mov rdx, qword[writePointer]
    mov byte[circularBuffer+rdx], cl
    ; writePointer = (writePointer+1) % stringLength
    mov rax, qword[writePointer]
    mov rbx, qword[stringLength]
    inc rax
    mov rdx, 0
    div rbx
    mov qword[writePointer], rdx
    inc qword[charactersBufferedToCircular]
    jmp return
    ; else { 
        ; if (endOfFilRreached ==1)
    else1:
        cmp qword[endOfFileReached], 1
        jne else2
            jmp endProgram
        ; else {
            ;fileRead syscall
            ; if rax< 0 error
        ;}
        else2:
            call addToFileBuffer
            jmp getCharFunction

    return:
ret

; compare a string to the buffer - works
; rdi = address to searchString
; rsi = address to circularBuffer
global compareStrToBuffer
compareStrToBuffer:
    mov r8, 0 ; index for string
    mov rax, qword[readPointer] ; index for circular
    loopTillNULL:
        cmp r8, qword[stringLength]  ; if index>string Length end
        ja compareDone
        mov cl, byte[rdi+r8]   ; searchString
        mov dl, byte[rsi+rax]
        cmp dl, LINEFEED
        jne continue1
            mov qword[columnNumber], 0
            inc qword[lineNumber]
            jmp end
        continue1:
        cmp cl, byte[rsi+rax]   ; compare to circular Buffer
        je nextLetter
        jmp end
    nextLetter:  
        inc r8
        inc rax
        mov rbx, stringLength
        mov rdx, 0
        div rbx
        mov rax, rdx
        jmp loopTillNULL
    compareDone:
        mov byte[matched], 1
    end:
        ; inc readPointer
        inc qword[charactersRead]
        mov rax, qword[readPointer]
        mov rbx, qword[stringLength]
        inc rax 
        mov rdx, 0
        div rbx
        mov qword[readPointer], rdx
ret

; add characters into File I/O Buffer - works
global addToFileBuffer
addToFileBuffer:
     ; open the requested file to read
    ; readFile = null terminated string of the file name/destination
    mov rax, 2
    mov rdi, qword[readFile]
    mov rsi, READ_ONLY
    syscall
    mov rdi, readFileOpenError      ; if RAX returns negative give error
    cmp rax, 0
    jge skipError1
        call endOnError
    skipError1:
    mov qword[readFileDescriptor], rax

    ;get characters from readFile
    mov rax, 0
    mov rdi, qword[readFileDescriptor]  
    mov rsi, fileBuffer ; write in file buffer
    mov rdx, BUFFER_SIZE
    syscall
    ; check
    add qword[charactersInFileBuffer], rax
    mov rdi, fileAddError
    cmp rax, 0
    jg skipError3
    call endOnError

    skipError3:
    cmp rax, BUFFER_SIZE
    jge skipError4
        mov byte[endOfFileReached], 1

    skipError4:
    mov qword[charactersBufferedToFile], rax
    mov qword[charactersBufferedToCircular], 0
    
    ; close the read file
    mov rax, 3
    mov rdi, qword[readFileDescriptor]
    syscall
ret