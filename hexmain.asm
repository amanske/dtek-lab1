  # hexmain.asm
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

	.text
main:
	li	$a0, 18		# change this to test different values

	jal	hexasc		# call hexasc
	nop			# delay slot filler (just in case)	

	move	$a0,$v0		# copy return value to argument register

	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window
	
stop:	j	stop		# stop after one run
	nop			# delay slot filler (just in case)

hexasc:
	andi 	$a1,$a0, 0xf 	# removes everything but the 4 least significant bits
	slti 	$a3, $a1, 10 	# checks if input is < 9 
	beq 	$a3, $0, then	# if input is > 9, go to then
	addi 	$v0, $a1, 0x30 	# else, add input to 0x30 to achieve ascii-number for 0-9
	jr 	$ra		# return to jal call
then:	addi 	$v0, $a1, 0x37 	# add input to 0x37 to achieve ascii-number for A-F
	jr 	$ra		# return to jal call

