  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,1000
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

hexasc:
	andi 	$t5,$a0, 0xf 	# removes everything but the 4 least significant bits
	slti 	$a3, $t5, 10 	# checks if input is < 9 
	beq 	$a3, $0, then	# if input is > 9, go to then
	nop
	addi 	$v0, $t5, 0x30 	# else, add input to 0x30 to achieve ascii-number for 0-9
	jr 	$ra		# return to jal call
	nop
then:	addi 	$v0, $t5, 0x37 	# add input to 0x37 to achieve ascii-number for A-F
	jr 	$ra		# return to jal call
	nop
	
delay:
	PUSH	($ra)
	move	$t0, $a0	# ms
	li 	$t1, 0		# i
	li 	$t3, 100	# change this constant for changing the delay time

while:	ble 	$t0, $0, jump	# if t0 is less or equal to 0, then branch to jump
	nop
	move 	$t5, $t0
	addi	$t0, $t5, -1	# subtract 1 from t0


for:	ble 	$t3, $t1, endfor# for loop until t1 > t3
	nop
	move	$t5, $t1
	addi 	$t1, $t5, 1	# increment i with 1
	j for			# jump to for
	nop
	
endfor:	li	$t1, 0		# reset i
	j	while		# jump to while
	nop

jump:	POP 	($ra)		
 	jr 	$ra
 	nop
time2string:
	PUSH	($ra) 		# saving return value
	andi 	$a1, $a1, 0xffff# ignoring anything but the 16 least significant bits
	
	srl 	$t1, $a1, 12	# shift right 12 steps to aquire the 4 most significant digits in the NBCD
	PUSH($a0)
	move 	$a0, $t1	# move the 4 digits to a0
	jal 	hexasc		# jump to hexasc
	nop
	POP($a0)
	sb	$v0,0($a0)	# store byte in address of a0
	
	srl 	$t2, $a1, 8	# shift right 8 steps to aquire the next 4 in the NBCD
	PUSH($a0)
	move 	$a0, $t2	# move the 4 digits to a2
	jal 	hexasc		# jump to hexasc
	nop
	POP($a0)
	sb	$v0,1($a0)	# store byte in address of a0
	
	addi 	$t4, $t4, 0x3A	# adds ascii-code for ':'
	sb	$t4,2($a0)	# store byte in address of a0
			
	srl 	$t3, $a1, 4 	# shift right 4 steps to aquire the next 4 in the NBCD
	PUSH($a0)
	move 	$a0, $t3	# move the 4 digits to a2
	jal 	hexasc		# jump to hexasc
	nop
	POP($a0)
	sb	$v0,3($a0)	# store byte in address of a0
	
	PUSH($a0)
	move 	$a0, $a1	# move the 4 digits to a2
	jal 	hexasc		# jump to hexasc
	nop
	POP($a0)
	sb	$v0,4($a0)	# store byte in address of a0
	
	li 	$t4, 0x00	# load null byte to t4
	sb	$t4,5($a0)	# store byte in address of a0
	
	POP($ra)
	jr	$ra
	nop
