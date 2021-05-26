#;	Author: Cicelia Siu
#;	Section 1003
#;	Date: 30 Nov 2020
#;	Assignment #13: Implements Conway's Game of Life on a wraparound board

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_READ_INTEGER = 5
	
#;	Board Parameters
	MAXIMUM_WIDTH = 80
	MINIMUM_WIDTH = 5
	MAXIMUM_HEIGHT = 40
	MINIMUM_HEIGHT = 5
	MINIMUM_GENERATIONS = 1
	WORD_SIZE = 4
	gameBoard: .space MAXIMUM_WIDTH * MAXIMUM_HEIGHT * WORD_SIZE
	
#;	Strings
	heightPrompt: .asciiz "Board Height: "
	widthPrompt: .asciiz "Board Width: "
	generationsPrompt: .asciiz "Generations to Simulate: "
	errorWidth: .asciiz "Board width must be between 5 and 80.\n"
	errorHeight: .asciiz "Board height must be between 5 and 40.\n"
	errorGenerations: .asciiz "Generation count must be at least 1.\n"
	initialGenerationLabel: .asciiz "\nInitial Generation\n"
	generationLabel: .asciiz "Generation #"
	newLine: .asciiz "\n"
	livingCell: .asciiz "¤"
	deadCell: .asciiz "•"
	
.text
.globl main
.ent main
main:
#;	Ask for width of gameboard
	askForWidth:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, widthPrompt
		syscall

		li $v0, SYSTEM_READ_INTEGER
		syscall

		move $s0, $v0												#; s0 = width of gameboard
#;	Check that width is within specified bounds
		blt $s0, 5, printWidthError
		bgt $s0, 80, printWidthError
		b askForHeight
	
	printWidthError:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, errorWidth
		syscall
		b askForWidth

	
#;	Ask for height of gameboard
	askForHeight:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, heightPrompt
		syscall

		li $v0, SYSTEM_READ_INTEGER
		syscall

		move $s1, $v0												#; s1 = height of gameboard

#;	Check that height is within specified bounds
		blt $s1, 5, printHeightError
		bgt $s1, 40, printHeightError
		b startInitalization

	printHeightError:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, errorHeight
		syscall
		b askForHeight

#;	Initialize Board Elements to 0
	startInitalization:
		la $t0, gameBoard										#; t0 = addy of gameBoard DONT CHANGE
		li $t1, 0												#; t1 = index of array
	
		mulou $t4, $s0, $s1		#; total number	of indexes	
		li $t5, 0			
		innerLoop:
			move $t3, $t0				#;reset $t3 to gameboard
			mulou $t9, $t1, WORD_SIZE	#; arrayIndex*dataSize
			addu $t3, $t3, $t9 		#; t3 = base + arrayIndex*dataSize 

			sw $t5, ($t3)		#; store 0 into board
			addu $t1, $t1, 1		#; arrayIndex++
			blt $t1, $t4, innerLoop	#; if arrayIndex < totalIndexes , stay in inner loop, exit


#;	Insert Glider at 2,2
	la $a0, gameBoard
	move $a1, $s0
	li $a2, 2
	li $a3, 2
	jal insertGlider
	
#;	Ask for generations to calculate
	askForGenerations:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, generationsPrompt
		syscall

		li $v0, SYSTEM_READ_INTEGER
		syscall

		move $s2, $v0									#; s2 = generations

#;	Ensure # of generations is positive
		bgt $s2, 0, printInitalBoard
		#print error:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, errorGenerations
			syscall
			b askForGenerations

	printInitalBoard:
#;	Print Initial Board
	li $v0, SYSTEM_PRINT_STRING
	la $a0, initialGenerationLabel
	syscall

	la $a0, gameBoard
	move $a1, $s0
	move $a2, $s1
	jal printGameBoard	

#; ----------------------anything above this is done------------------------------				
#;	For each generation:
	li $s3, 1
	eachGeneration:
#;		Play 1 Turn
		la $a0, gameBoard
		move $a1, $s0
		move $a2, $s1
		jal playTurn
#;		Print Generation Label
		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall

		li $v0, SYSTEM_PRINT_STRING
		la $a0, generationLabel
		syscall

		li $v0, SYSTEM_PRINT_INTEGER
		move $a0, $s3
		syscall

		li $v0, SYSTEM_PRINT_STRING
		la $a0, newLine
		syscall

#;		Print Board
		la $a0, gameBoard
		move $a1, $s0
		move $a2, $s1
		jal printGameBoard

		addu $s3, $s3, 1			#; generation#++
		ble $s3, $s2, eachGeneration	#; if generation # <= # of generations wanted, do another

	
	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main

#;  Insert Glider Pattern			-done
#;	••¤
#;	¤•¤
#;	•¤¤
#;	0,0 is in the top left of the gameboard
#;	Assume all cells are dead in the 3x3 space to start with.
#;	Argument 1: Address of Game Board
#;	Argument 2: Width of Game Board
#;	Argument 3: X Position of Top Left Square of Glider "•"
#;	Argument 4: Y Position of Top Left Square of Glider "•"
.globl insertGlider
.ent insertGlider
insertGlider:
	move $t0, $a0											#; t0 = addy of gameBoard DONT CHANGE
	move $t4, $a1											#; width of gameboard
	move $t1, $a2											#; t1 = arrayIndex of "0,0" (for now)
	mulou $t1, $t1, $t4
	addu $t1, $t1, $a3
	
	li $t5, 1
	
	#; get to "2,0"
	move $t3, $t0						#;reset $t3 to addy
	addu $t6, $t1, 2					#; add 2 to arrayIndex of "0,0"
	mulou $t2, $t6, WORD_SIZE			#; t2 = arrayIndex * Word Size
	addu $t3, $t3, $t2					#; base + arrayIndex * Word Size

	sw $t5, ($t3)						#; store 1 into "2,0"

	#; get to "0,1"
	move $t3, $t0						#;reset $t3 to addy
	addu $t6, $t1, $t4					#; add Width to arrayIndex of "0,0" to get one down
	mulou $t2, $t6, WORD_SIZE			#; t2 = arrayIndex * Word Size
	addu $t3, $t3, $t2					#; base + arrayIndex * Word Size

	sw $t5, ($t3)		#; store 1 into "0,1"
	

									
	#; get to "2,1"
	move $t3, $t0						#;reset $t3 to addy
	addu $t6, $t1, $t4					#; add Width to arrayIndex of "0,0" to get one down
	addu $t6, $t6, 2					#; add 2 to arrayIndex of "0,0"
	mulou $t2, $t6, WORD_SIZE			#; t2 = arrayIndex * Word Size
	addu $t3, $t3, $t2					#; base + arrayIndex * Word Size

	sw $t5, ($t3)		#; store 1 into "2,1"

	#; get to "1,2"
	move $t3, $t0						#;reset $t3 to addy
	addu $t6, $t1, $t4					#; add Width to arrayIndex of "0,0" to get one down
	addu $t6, $t6, $t4					#; add Width to arrayIndex of "0,0" to get second down
	addu $t6, $t6, 1					#; add 1 to arrayIndex of "0,0"
	mulou $t2, $t6, WORD_SIZE			#; t2 = arrayIndex * Word Size
	addu $t3, $t3, $t2					#; base + arrayIndex * Word Size

	sw $t5, ($t3)		#; store 1 into "1,2"

	#; get to "2,2"
	move $t3, $t0						#;reset $t3 to addy
	addu $t6, $t1, $t4					#; add Width to arrayIndex of "0,0" to get one down
	addu $t6, $t6, $t4					#; add Width to arrayIndex of "0,0" to get second down
	addu $t6, $t6, 2					#; add 2 to arrayIndex of "0,0"
	mulou $t2, $t6, WORD_SIZE			#; t2 = arrayIndex * Word Size
	addu $t3, $t3, $t2					#; base + arrayIndex * Word Size

	sw $t5, ($t3)		#; store 1 into "2,2"
	
	jr $ra
.end insertGlider

#;	Updates the state of the gameboard
#;	For each Cell:
#;	Living: 2-3 Living Neighbors -> Stay Alive, otherwise Change to Dead
#;	Dead: Exactly 3 Living Neighbors -> Change to Alive 
#;	Cell States:
#;		0: Currently Dead, Stay Dead (00b)
#;		1: Currently Living, Change to Dead (01b)
#;		2: Currently Dead, Change to Living (10b)
#;		3: Currently Living, Stay Living (11b)
#;	Right Bit: Current State
#;	Left Bit: Next State
#;	All cells must maintain their current state until all next states have been determined.
#;	Argument 1: Address of Game Board
#;	Argument 2: Width of Game Board
#;	Argument 3: Height of Game Board
.globl playTurn
.ent playTurn
playTurn:
	move $t0, $a0		#; t0 = addy of gameboard
	move $t4, $a1		#; t4 = width/columnSize of gameboard
	move $t5, $a2		#; t5 = height/rowSize of gameboard

	li $t1, 0			#; t1 = rowIndex
	li $t2, 0			#; t2 = columnIndex

	li $t6, 0			#; t6 = count
	
#;	For each cell on the gameboard:          ----------------- left off here
	countLoop:
		
#;		Count the number of living neighbors (including diagonals)
#;			The board wraps around, use remainder to find wrapped indice
#;			Start each width/height register value offset by the size of the board
#;				i.e. currentWidth = width instead of 0
#;		Use the remainder instruction to extract current state
	#; find top
		move $t8, $t2		#; reset adjusted columnIndex or x
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width
		move $t7, $t1		#; reset adjusted rowIndex or y
		addu $t7, $t7, 1	#; yIndex++ to find above cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size

		lw $t9, ($t3)	# t9 = top cell
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount1	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount1:


	#; find top-left
		move $t8, $t2		#; reset adjusted columnIndex or x
		subu $t8, $t8, 1	#; xIndex-- to find left cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		addu $t7, $t7, 1	#; yIndex++ to find above cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size

		lw $t9, ($t3)	# t9 = top-left cell
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount2	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount2:


		#; find top-right
		move $t8, $t2		#; reset adjusted columnIndex or x
		addu $t8, $t8, 1	#; xIndex++ to find right cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		addu $t7, $t7, 1	#; yIndex++ to find above cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = top-right cell
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount3	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount3:

		#; find left
		move $t8, $t2		#; reset adjusted columnIndex or x
		subu $t8, $t8, 1	#; xIndex-- to find left cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = left cell 
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount4	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount4:

		#; find right
		move $t8, $t2		#; reset adjusted columnIndex or x
		addu $t8, $t8, 1	#; xIndex++ to find right cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = right cell 
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount5	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount5:

		#; find bottom
		move $t8, $t2		#; reset adjusted columnIndex or x
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		subu $t7, $t7, 1	#; yIndex-- to find bottom cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = bottom cell 
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount6	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount6:

		#; find bottom-left
		move $t8, $t2		#; reset adjusted columnIndex or x
		subu $t8, $t8, 1	#; xIndex-- to find left cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		subu $t7, $t7, 1	#; yIndex-- to find bottom cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = bottom-left cell 
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount7	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount7:
		
		#; find bottom-right
		move $t8, $t2		#; reset adjusted columnIndex or x
		addu $t8, $t8, 1	#; xIndex++ to find right cell
		addu $t8, $t8, $t4	#; xIndex + width
		remu $t8, $t8, $t4	#; (xIndex + width) % width

		move $t7, $t1		#; reset adjusted rowIndex or y
		subu $t7, $t7, 1	#; yIndex-- to find bottom cell
		addu $t7, $t7, $t5	#; yIndex + height
		remu $t7, $t7, $t5	#; (yIndex + height) % height

		li $t3, 0				#;reset $t3
		mulou $t3, $t7, $t4		#; adjustedX*width
		addu $t3, $t3, $t8		#; adjustedY+(adjustedX*width)
		mulou $t3, $t3, WORD_SIZE	#;  [adjustedY+(adjustedX*width)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[adjustedY+(adjustedX*width)] * data size
		
		lw $t9, ($t3)	# t9 = bottom-right cell 
		remu $t9, $t9, 2	#; find the current state
		beq $t9, 0, skipCount8	#; if dead, dont inc count
			addu $t6, $t6, 1
		skipCount8:


#;		Update cell state
		#; go to current Cell
		li $t3, 0				#;reset $t3 
		mulou $t3, $t1, $t4 	#; rowIndex*width
		addu $t3, $t3, $t2		#; columnIndex+(rowIndex*with)
		mulou $t3, $t3, WORD_SIZE	#;  [columnIndex+(rowIndex*height)] * data size
		addu $t3, $t3, $t0									#; t3 = baseAddy + [[columnIndex+(rowIndex*height)] * data size

#;			if cell is currently alive with 2-3 neighbors, change next bit to alive
#;			if cell is currently dead with exactly 3 neighbors, change next bit to alive
		lw $t9, ($t3)	# t9 = current cell
		remu $t9, $t9, 2
		beq $t9, 1, checkLiving
		checkDead:
			beq $t6, 3, deadToAlive
			#; if not next bit will be dead
			li $t9, 0
			sw $t9, ($t3)
			b nextCell
		checkLiving:
		beq $t6, 3, aliveToAlive
		beq $t6, 2, aliveToAlive
			#; if not next bit will be dead
			li $t9, 1
			sw $t9, ($t3)
			b nextCell

		deadToAlive:
			li $t9, 2
			sw $t9, ($t3)
			b nextCell
		aliveToAlive:
			li $t9, 3
			sw $t9, ($t3)
			b nextCell

	nextCell:
		li $t6, 0 		#;reset count
		addu $t1, $t1, 1	#; inc rowIndex
		blt $t1, $t5, countLoop	#; if rowIndex < height, then go back to count loop, if not, go to outer loop

		#; outer Loop
		li $t1, 0		#; reset rowIndex
		addu $t2, $t2, 1	#; inc columnIndex
		blt $t2, $t4, countLoop	#: if columnIndex < width, then go back to count loop, if not, exit loop

#;	For each cell on the gameboard:
	li $t1, 0			#; t1 = reset arrayIndex
	mulou $t2, $t4, $t5		#; t2 = total # of indexesheight*width

	updateLoop:

		move $t6, $t0				#; base addy
		mulou $t9, $t1, WORD_SIZE	#; arrayIndex*dataSize
		addu $t6, $t6, $t9 		#; t6 = base + arrayIndex*dataSize 

#;		Update each cell to its new state by dividing by 2
		lw $t9, ($t6)
		divu $t9, $t9, 2
		sw $t9, ($t6)

	nextCell1:
		addu $t1, $t1, 1	#; inc arrayIndex
		blt $t1, $t2, updateLoop	#; if arrayIndex < totalIndexes, then go back to update loop,

	jr $ra
.end playTurn

#;	Prints the array using the specified dimensions				-DONE
#;	For values of 1, print as a livingCell "¤"
#;	For values of 0, print as a deadCell "•"
#;	Argument 1: Address of Array
#;	Argument 2: Width of Array
#;	Argument 3: Height of Array
.globl printGameBoard
.ent printGameBoard
printGameBoard:
	move $t0, $a0										#; t0 = addy of gameBoard
	move $t5, $a1				#; t5 = width
	move $t6, $t0
	li $t1, 0										#; t1 = index of array
	li $t3, 0										#; t3 = height count
	printInnerLoop:

		lw $t4, ($t6)								#; t4 = value 
		beqz $t4, printDead		#; if value = 0, print dead, else print living
		#; printLiving
			li $v0, SYSTEM_PRINT_STRING
			la $a0, livingCell
			syscall
			b next
		#; printDead
		printDead:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, deadCell
			syscall

		next:
		move $t6, $t0
		addu $t1, $t1, 1
		mulou $t9, $t1, WORD_SIZE	#; arrayIndex*dataSize
		addu $t6, $t6, $t9 		#; t6 = base + arrayIndex*dataSize 
		remu $t2, $t1, $t5		#; t2 = arrayIndex % width
		bne $t2, 0, printInnerLoop	#; if %arrayIndex < width , go to inner loop, if not, exit loop

		#; outer loop
		#; printNewLine
			li $v0, SYSTEM_PRINT_STRING
			la $a0, newLine
			syscall
		
		addu $t3, $t3, 1	#; heighCount++
		blt $t3, $a2, printInnerLoop	#; if heightCount < height , stay in inner loop, if not go to outer

	jr $ra
.end printGameBoard
