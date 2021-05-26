#;	Author: Cicelia Siu
#;	Section 1003
#;	Date: 19 Nov 2020
#;	Assignment #12: Working with MIPS Arrays and Arithmetic. 

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_FLOAT = 2
	SYSTEM_PRINT_STRING = 4
	
#;	Function Input Data
	squareRootValue1: .word 1742
	squareRootValue2: .word 4566
	floatSquareRootValue1: .float 15135.0
	floatSquareRootValue2: .float 911560.50
	floatTolerance1: .float 0.01
	floatTolerance2: .float 0.001
	
	printArray: .word 1, 1, 1, 1, 1, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 1, 1, 1, 1, 1
				.word 1, 1
	PRINT_ARRAY_LENGTH = 38
	
	arrayValues: .word	377, 148, 641, -486, 828, 456, 192, -742, -658, -139 
				 .word	801, -946, 325, 916, 982, 902, -809, 858, -510, -713
				 .word	-309, 515, 587, 320, 994, 528, -617, -515, -123, 294
				 .word	644, -339, 842, -441, -557, 58, 773, 694, 78, -744
				 .word	-350, -424, -514, -679, 402, -924, -178, 315, 509, 173
				 .word	44, -80, -340, 905, -840, -210, 671, -755, -809, 731
				 .word	-936, -414, 627, -565, -749, -804, -456, -236, 933, 961
				 .word	-675, -9, 653, 581, -567, 916, 738, 343, 684, -184
				 .word	-789, -400, -941, 145, 933, 230, -236, 880, 646, -926
				 .word	982, 221, -451, -783, 331, -157, 193, 940, -818, 270
	ARRAY_LENGTH = 100
	
#;	Labels
	endLabel: .asciiz ".\n"
	newLine: .asciiz "\n"
	space: .asciiz " "
	squareRootLabel1: .asciiz "The square root of 1742 is "
	squareRootLabel2: .asciiz "The square root of 4566 is "
	squareRootFloatLabel1: .asciiz "The square root of 15135.0 is "
	squareRootFloatLabel2: .asciiz "The square root of 911560.50 is "
	printArrayLabel: .asciiz "\nPrint Array Test:\n"
	unsortedLabel: .asciiz "\nUnsorted List:\n"
	sortedLabelAscending: .asciiz "\nSorted List (Ascending):\n"

.text
#;	Function 1: Integer Square Root Estimation
#;	Estimates the square root using Newton's Method
#;	Argument 1: Integer value to find the square root of
#;	Returns: The estimated square root as an integer
.globl estimateIntegerSquareRoot
.ent estimateIntegerSquareRoot
estimateIntegerSquareRoot:
#;	New Estimate = (Old + Value/Old)/2
	move $t0, $a0 #; Old Estimate
	
	estimationLoop:
		divu $t1, $a0, $t0	#; value/old
		add $t1, $t1, $t0	#; value/old + old
		div $t1, $t1, 2	#; (value/old+old)/2
		
		sub $t2, $t0, $t1 #; difference
		move $t0, $t1	#; old = new
	#; Exit loop if |difference| <= 1
	blt $t2, -1, estimationLoop
	bgt $t2, 1, estimationLoop
	
	move $v0, $t0
	jr $ra
.end estimateIntegerSquareRoot

#; Function 2: Float Square Root Estimation
#;	Estimates the square root using Netwon's Method
#;	Argument 1: Float value to find the square root of
#;	Argument 2: Float value representing the tolerance level to stop at
#;	Returns: The estimated square root as a float

#;	Floating Point Comparison
#;	Use c.lt.s FRsrc1, FRsrc2 to set the comparison flag
#;	Use bc1t label to branch if the comparison was true	
#;	Example:
#;		c.lt.s $f0, $f1
#;		bc1t estimateLoop #; Branch if $f0 < $f1
#;	In this version of MIPS, there is no greater than comparisons


.globl estimateFloatSquareRoot
.ent estimateFloatSquareRoot
estimateFloatSquareRoot:
#;	New Estimate = (Old + Value/Old)/2
	mov.s $f0, $f12		#; $f0 = Old Estimate
	mov.s $f6, $f14		#; $f6 = Tolerance
	li $t0, -1
	mtc1 $t0, $f8
	cvt.s.w $f8, $f8		# $f8 = -1
	mul.s $f10, $f6, $f8	#; $f10 = -Tolerance

	floatEstimationLoop:
		div.s $f2, $f12, $f0 	#; value/old
		add.s $f2, $f2, $f0		#; value/old + old
		li $t0, 2
		mtc1 $t0, $f8
		cvt.s.w $f8, $f8		# $f8 = 2
		div.s $f2, $f2, $f8		#; (value/old + old)/2

		sub.s $f4, $f0, $f2		#; difference
		mov.s $f0, $f2 			#; old = new
		#; Exit loop if |difference| <= tolerance level
		c.lt.s $f6, $f4			
		bc1t floatEstimationLoop #; Branch if tolerance < difference
		c.lt.s $f4, $f10
		bc1t floatEstimationLoop #; Branch if difference < -tolerance

		#; move $v0, $t0 but $f0 is returning register
	jr $ra
.end estimateFloatSquareRoot

#;	Function 3: Print Integer Array
#;	Prints the elements of the array to the terminal
#;	On each line, output a number of values equal to the square root of the total number of elements
#;	Use estimateIntegerSquareRoot to determine how many elements should be printed on each line
#;	Argument 1: Address of array to print
#;	Argument 2: Integer count of the number of elements in the array
.globl printIntegerArray
.ent printIntegerArray
printIntegerArray:
#;	Remember to push and pop $ra for non-leaf functions
	#; push ra
	subu $sp, $sp, 4
	sw $ra, ($sp)

	move $a3, $a0

	#; find number of integers on each line
	move $a0, $a1
	jal estimateIntegerSquareRoot
	move $t2, $v0 	#; $t2 =  number of intgers on each line


	#; print integer loop
	li $t0, 1

	printIntegerLoop:
		lw $t1, ($a3)

		li $v0, SYSTEM_PRINT_INTEGER
		move $a0, $t1
		syscall

		li $v0, SYSTEM_PRINT_STRING
		la $a0, space
		syscall
		
		#; check for new line
		beq $t0, $a1, printNewLine
		rem $t3, $t0, $t2
		bne $t3, 0, nextInteger
		printNewLine:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, newLine
			syscall


		nextInteger:
		addu $t0, $t0, 1
		addu $a3, $a3, 4
		ble $t0, $a1, printIntegerLoop
		

	#; pop ra
	lw $ra, ($sp)
	addu $sp, $sp, 4

	jr $ra
.end printIntegerArray

#; Function 4: Integer Comb Sort (Ascending)
#;	Uses the comb sort algorithm to sort a list of integer values in ascending order
#; Argument 1: Address of array to sort
#;	Argument 2: Integer count of the number of elements in the array
#;	Returns: Nothing
.globl sortList
.ent sortList
sortList:
	move $t0, $a0
	move $t1, $a1 	#; gapsize = length

	gapLoop:
		#; Adjust Gap Size:  gap * 10 / 13
		mulou $t1, $t1, 10
		divu $t1, $t1, 13
		#; Ensure gap size does not go below 1
		bgt $t1, 0, skipFloor
			li $t1, 1
		skipFloor:

		move $t2, $a1	#; n
		sub $t2, $t2, $t1	#; n - gapsize
		li $t3, 0	#; i
		li $t4, 0	#; swaps Done

		combsortLoop:	#; while i < n - gapsize
			move $t0, $a0
			bge $t3, $t2, exitInnerLoop
			mulou $t6, $t3, 4		#; $t6 = i*4
			addu $t0, $t0, $t6
			lw $t7, ($t0)		#:$t7 = dword[rdi + i * 4]
			move $t0, $a0

			addu $t5, $t3, $t1 	#; $t5 = i+gapsize
			mulou $t5, $t5, 4		#; $t5 = i+gapsize*4
			add $t0, $t0, $t5	
			lw $t8, ($t0)		#; t8 = dword[rdi + i+gapsize * 4]
			move $t0, $a0

			ble $t7, $t8, swapDone	#;$t7>t8, then swap

			swap:
				move $t0, $a0
				addu $t0, $t0, $t6
				lw $t7, ($t0)		#:$t7 = dword[rdi + i * 4]

				move $t0, $a0
				addu $t0, $t0, $t5	
				lw $t8, ($t0)		#; t8 = dword[rdi + i+gapsize * 4]
				sw $t7, ($t0)	#; t7 -> dword[rdi + i+gapsize * 4]

				move $t0, $a0
				addu $t0, $t0, $t6
				sw $t8, ($t0)	#; t8 -> dword[rdi + i * 4]

				addu $t4, $t4, 1	#; increase swapsDone

			swapDone:
			addu $t3, $t3, 1	#; increase i
			b combsortLoop
		exitInnerLoop:
		#; Only check for swaps done when gap size is 1
		bne $t1, 1, gapLoop
		beq $t4, 0, combSortDone
		b gapLoop
		combSortDone:

	jr $ra
.end sortList


#; ----------------------------------------------------------------------------------------
#;	------------------------------------DO NOT CHANGE MAIN----------------------------------
#; ----------------------------------------------------------------------------------------
.globl main
.ent main
main:
#;	Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel1
	syscall

	lw $a0, squareRootValue1
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel2
	syscall

	lw $a0, squareRootValue2
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Float Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel1
	syscall

	l.s $f12, floatSquareRootValue1
	l.s $f14, floatTolerance1
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Float Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel2
	syscall

	l.s $f12, floatSquareRootValue2
	l.s $f14, floatTolerance2
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Print Array Test
	li $v0, SYSTEM_PRINT_STRING
	la $a0, printArrayLabel
	syscall

	la $a0, printArray
	li $a1, PRINT_ARRAY_LENGTH
	jal printIntegerArray

#;	Print Unsorted Array
	li $v0, SYSTEM_PRINT_STRING
	la $a0, unsortedLabel
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	Print Sorted Array (Ascending)
	li $v0, SYSTEM_PRINT_STRING
	la $a0, sortedLabelAscending
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal sortList

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	End Program
	li $v0, SYSTEM_EXIT
	syscall
.end main
