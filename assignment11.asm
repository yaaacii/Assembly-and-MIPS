#;	Author: Cicelia Siu
#;	Section 1003
#;	Date: 09 Nov 2020
#;	Assignment 11
#;	This program determines which widgets are within acceptable tolerances and outputs the results
.data
	widgetMeasurements: .word	706, 672, 658, 548, 570, 439, 648, 563, 790, 442
						.word	982, 904, 615, 718, 841, 827, 594, 673, 839, 762
						.word	547, 611, 620, 747, 858, 915, 509, 968, 774, 778
						.word	526, 934, 453, 910, 921, 766, 753, 849, 718, 479
						.word	910, 914, 481, 639, 614, 1049, 517, 501, 777, 860

	widgetTargetSizes:	.word	717, 662, 742, 502, 622, 511, 651, 645, 868, 517
						.word	895, 881, 539, 701, 779, 857, 653, 724, 907, 830
						.word	585, 574, 649, 750, 986, 930, 543, 932, 891, 760
						.word	603, 836, 509, 942, 864, 879, 668, 790, 806, 516
						.word	820, 834, 555, 588, 620, 926, 524, 517, 802, 988

	widgetStatus: .space 200

	lowerThreshold: .float 0.92
	upperThreshold: .float 1.08
	acceptInt: .word 0
	reworkInt: .word 1
	rejectInt: .word -1

	WIDGET_COUNT = 50

	messageWidgetHeader: 	.asciiz "Widget #"
	messageWidgetAccepted:	.asciiz ": Accepted\n"
	messageWidgetRejected:	.asciiz ": Rejected\n"
	messageWidgetRework:	.asciiz ": Rework\n"

	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	
.text
.globl main
.ent main
main:
	#; Your Code Here
	li $t7, WIDGET_COUNT
	la $s0, widgetMeasurements		#; address of widgetMeasurements
	la $s1, widgetTargetSizes		#; address of widgetTargetSizes
	la $s2, widgetStatus			#; address of widgetStatus
	#; Check Each Widget
	checkWidget:
		
		lw $t0, ($s0)			#; t0 = widgetMeasurements
		lw $t1, ($s1)			#; t1 = widgetTargetSizes
		#; Find Difference (Not needed)
		#; subu $t2, $t0, $t1 		#; difference will go into $t2 = t0-t1

		#; Find 8% Thresholds
		mul $t3, $t1, 92		#; findLowerThreshold(t3) = widgetTargetSizes * 92/100
		div $t3, $t3, 100
		mul $t4, $t1, 108		#; findUpperThreshold(t4) = widgetTargetSizes * 108/100
		div $t4, $t4, 100

		#; Determine Widget Status
			bltu $t0, $t3, reject	#; compare to thresholds
			bgtu $t0, $t4, rework
			b accept
			#; Reject (< 92%)
			reject:
				lw $t5, rejectInt
				sw $t5, ($s2)
				b next
			#; Rework (> 108%)
			rework:
				lw $t5, reworkInt
				sw $t5, ($s2)
				b next
			#; Accept (92% <= Difference <= 108%)
			accept:
				lw $t5, acceptInt
				sw $t5, ($s2)
				b next
		next: 
			beq $t7,1 ,outputStatus	#; if done converting, print outputs
			subu $t7, $t7, 1		#; if not, go to next index 
			addu $s0, $s0, 4
			addu $s1, $s1, 4
			addu $s2, $s2, 4
			b checkWidget

	#; Output Widget Statuses
	outputStatus:
	la $t0, widgetStatus
	li $t1, 1
	outputLoop:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, messageWidgetHeader
		syscall

		li $v0, SYSTEM_PRINT_INTEGER
		move $a0, $t1
		syscall

		lw $t3, ($t0)
		beq $t3, -1, rejectPrint
		beq $t3, 1, reworkPrint
		b acceptPrint

		rejectPrint:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, messageWidgetRejected
			syscall
			b nextPrint
		reworkPrint:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, messageWidgetRework
			syscall
			b nextPrint
		acceptPrint:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, messageWidgetAccepted
			syscall
			b nextPrint
		nextPrint:
			beq $t1, WIDGET_COUNT, endProgram 	#; print until index = widget count
			addu $t1, $t1, 1
			addu $t0, $t0, 4
			b outputLoop

	#; Ends Program
	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main