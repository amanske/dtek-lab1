  # analyze.asm
  # This file written 2015 by F Lundevall
  # Copyright abandoned - this file is in the public domain.

	.text
main:
	li	$s0,0x30
	
loop:
	move	$a0,$s0		# copy from s0 to a0
	
	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window

	addi	$s0,$s0,3	# what happens if the constant is changed? changed constant to 3, for adding 3 to index
	li	$t0,0x5b
	slt 	$t1, $s0, $t0 	# if index is smaller than goal, set t1 to 1 else 0 
	bne	$t1,$0,loop	# if t1 == 0, do not loop else loop
	nop			# delay slot filler (just in case)

stop:	j	stop		# loop forever here
	nop			# delay slot filler (just in case)

#question 1 = 43 iterations
#question 2 = 2 lines changed (14 and 17) , one added (16)