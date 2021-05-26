#;	Author: Cicelia Siu
#;	Section 1003
#;	Date: 30 Nov 2020
#;	Assignment #14: Compare and constrast different approaches 
#;  to solving a problem recursively.

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_READ_INTEGER = 5

#; Max n numbers
    minimum = 1
    maximum = 46

#; Strings
    nPrompt: .asciiz "Calculate the Fibonacci sequence number (1-46): "
    nInputError: .asciiz "Number must be between 1 and 46.\n\n"
    topDownPart1: .asciiz "\nTopDown Fibonacci("
    bottomUpPart1: .asciiz "\nBottom Up Fibbonacci ("
    endPart2: .asciiz ") : "
    endPart3: .asciiz " function calls required.\n"

    endLine: .asciiz "\n"

.text
.globl main
.ent main
main:

#; prompt for n
    prompt:
        li $v0, SYSTEM_PRINT_STRING
        la $a0, nPrompt
        syscall

        li $v0, SYSTEM_READ_INTEGER
        syscall

        move $s0, $v0               #; s0 = n
        

#;      check for n error
        blt $s0, minimum, printError
        bgt $s0, maximum, printError
    b calculate
    
    printError:
        li $v0, SYSTEM_PRINT_STRING
        la $a0, nInputError
        syscall
    b prompt

#; calulate 
    calculate:

#; top Down
    move $a0, $s0
    li $a1, 0
    jal topDown

    move $t1, $v0   #; f(n)
    move $t2, $a1   #; final count
    
    li $v0, SYSTEM_PRINT_STRING
    la $a0, topDownPart1
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $s0
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endPart2
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $t1
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endLine
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $t2
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endPart3
    syscall

#; Bottom Up
    move $a0, $s0
    li $a1, 1
    li $a2, 1
    li $a3, 0
    jal bottomUp

    move $t1, $v0

    sub $sp, $sp, 4    
    sw $fp,($sp)
    addu $fp, $sp, 4
        lw $t2, ($fp)
    lw $fp, ($sp)
    add $sp, $sp, 4

    li $v0, SYSTEM_PRINT_STRING
    la $a0, bottomUpPart1
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $s0
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endPart2
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $t1
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endLine
    syscall

    li $v0, SYSTEM_PRINT_INTEGER
    move $a0, $t2
    syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, endPart3
    syscall
    endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main





#; Naive Top-Down function         
#; Argument 1 (a0): Integer value n 
#; Argument 2 (a1): Number of function calls made by reference
.globl topDown
.ent topDown
topDown:
    #; push $ra
    sub $sp, $sp, 4    
    sw $ra,($sp)

    #; push $s0
    sub $sp, $sp, 4    
    sw $s0,($sp)

    #; push $s1
    sub $sp, $sp, 4    
    sw $s1,($sp)

    #; push $s2
    sub $sp, $sp, 4    
    sw $s2,($sp)

    #; push $ra
    sub $sp, $sp, 4    
    sw $s3,($sp)

    #; inc count
    addu $a1, $a1, 1 

    #; save a0 into s1
    move $s1, $a0

    #; if 0 or 1
    beq $a0, 0, returnZero
    beq $a0, 1, returnOne
        b continue
    returnZero:
        li $v0, 0
        b endfunction
    returnOne:
        li $v0, 1
        b endfunction
    
    #; if not 0 or 1
    continue:
        #; n-1
        sub $a0, $s1, 1
        move $a1, $a1
        jal topDown
        move $s2, $v0       #; s2 = topDown(n-1)

        #; n-2
        sub  $a0, $s1, 2
        jal topDown
        move $s3, $v0       #; s3 = topDown(n-2)

        #; add topDown(n-1) and topDown(n-2)
        add $v0, $s2, $s3

    endfunction:
    #; pop $s3
    lw $s3, ($sp)
    add $sp, $sp, 4
    #; pop $s2
    lw $s2, ($sp)
    add $sp, $sp, 4
    #; pop $s1
    lw $s1, ($sp)
    add $sp, $sp, 4
    #; pop $s0
    lw $s0, ($sp)
    add $sp, $sp, 4
    #; pop $ra
    lw $ra, ($sp)
    add $sp, $sp, 4
    jr $ra 
.end topDown


#; Bottom-Up Function
#; Argument 1: Integer of the final value n
#; Argument 2: Integer of the Current Value of n
#; Argument 3: Integer value generated previously f(n-1)
#; Argument 4: Integer value generated previously f(n-2)
#; Argument 5: Number of function calls by-reference
.globl bottomUp
.ent bottomUp
bottomUp:

    #; push $fp for by-reference
    sub $sp, $sp, 4    
    sw $fp,($sp)
    addu $fp, $sp, 4

    move $t0, $a0       #; t0 = final n
    move $t1, $a1       #; t1 = current
    move $t2, $a2       #; t2 = f(n-1)
    move $t3, $a3       #; t3 = f(n-2)
    li $t5, 1           #;t5 = count
    
    #; if 0 or 1
    beq $t0, 0, returnZero1
    beq $t0, 1, returnOne1
        b calculateLoop
    returnZero1:
        li $v0, 0
        b endBottomFunction
    returnOne1:
        li $v0, 1
        b endBottomFunction

    #; if not 0 or 1
    calculateLoop:
        add $t4, $t3, $t2       #; t4 = f(n-1)+f(n-2)
    
        move $t3, $t2          #; update f(n-2)
        move $t2, $t4           #; update f(n-1)

        addu $t1 $t1, 1
        addu $t5,$t5, 1
        bltu $t1, $t0, calculateLoop

        move $v0, $t4   #; final f(n)
        sw $t5, ($fp)   #; copy 5th argument into stack using fp

    endBottomFunction:
    #; pop $fp
    lw $fp, ($sp)
    add $sp, $sp, 4

    jr $ra
.end buttomUp