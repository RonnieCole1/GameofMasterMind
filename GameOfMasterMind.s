	      .data
        .align  2
message:.asciiz "Hello. This is a game of Mastermind. To win, correctly guess the computer's randomly generated 4 digit number.\nTo begin, enter your 4 digit number: "
victory:.asciiz "\nYou guessed Correctly!"
guesses:.asciiz "\nTo reach the correct awnser, you guessed this many times: "
fermi:	.asciiz "Fermi "
pico:	.asciiz "Pico "
bagel:	.asciiz "Bagel "
target: .asciiz	"\nThe Computer's number was: "
lose:	.asciiz "\nYou Lose! "
ask:	.asciiz "\nGive another guess: "
ofb:    .asciiz "\nOut of bounds"
#--------------- Usual stuff at beginning of main -----------------
        .text
        .globl main
main:  
	li	$s5, 0		# Number of guesses
	
	# Generate 4 random integers from 0-9 and store them for later when we compare. 
	jal GenerateNumber
	move	$s0, $a0	# Our first random number which will soon represent our thousands place
	jal GenerateNumber
	move	$s1, $a0	# Our second random number which will soon represent our hundreds place
	jal GenerateNumber
	move	$s2, $a0	# Our third random number which will soon represent our tens place
	jal GenerateNumber
	move	$s3, $a0	# Our third random number which will soon represent our ones place
	
	# Prepare to build random number
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3
        
        # Build random number
        jal NumberBuilder
 	move	$s4, $v0	# This is our 4 digit number
 	
 	# Display results (For texting purposes)
        #move    $a1, $s4 
        #la      $a0, target        
        #li      $v0, 56
        #syscall

	# Our whole 4 digit random number is stored in s4.
        # This number's individual digits are stored in s0-3.
        # s0 s1 s2 s3	where the registers position corresponds to its place in the number   
	
	# Introduct the game and prompt the user to enter an integer.
	li	$v0, 4
	la, 	$a0, message
	syscall
guessagain:	
	beq	$s5, $0, skip
	
	
	# Tell user to guess again
     	li	$v0, 4
	la, 	$a0, ask
	syscall
	
skip:	# Have user input an integer.
     	li 	$v0, 5
     	syscall
     		
     	move 	$t0, $v0		# Store user input into t0
     	addi,	$s5, $s5, 1		# This is a guess, so we increment.
     	move	$a0, $t0
     	jal	CheckRange		# Check of user input is out of bounds
     	jal	CheckZero		# Check if user inputed 0000
        bne 	$t0, $s4, fermij	# Check if user input is target number
        jal 	PrintWin

	# User guess wasn't correct. Check each number and print Fermi if it is right. 
	# Check each number with every other number in the target. Print Pico if found
	# If no number was correct, print Bagel
	li	$t4, 0			# number of times our digits do not appear anywhere in the target
	
fermij:	li	$t1, 10			
	div	$t0, $t1		# get the right most digit of input
	mfhi	$t3			# remainder (our right most digit)
        div	$t0, $t0, $t1		# Divide to get rest of digits and set to t0
        bne	$t3, $s3, noteq3	# check if right most digit is correct
        jal 	PrintFermi		# if it is, print Fermi
        j	nopico0
          
noteq3: beq	$t3, $s2, picoj0	# Check if the right most digit is equal to our other digits. Print pico if they are.
        beq	$t3, $s1, picoj0	#
        beq	$t3, $s0, picoj0	# If right most digit doesn't appear, go check the next digit.
        addi	$t4, $t4, 1		# our right most digit appeared nowhere in the target. 
        j	nopico0
        
picoj0: jal	PrintPico

nopico0:div	$t0, $t1		# get the right most digit of input				
        mfhi	$t3			# remainder (our right most digit)                
        div	$t0, $t0, $t1		# Divide to get rest of digits and set to t0
        bne	$t3, $s2, noteq2	# check if right most digit is correct
        jal 	PrintFermi		# if it is, print Fermi
        j	nopico1	
    
noteq2: beq	$t3, $s1, picoj1	# Check if the right most digit is equal to our other digits. Print pico if they are.
        beq	$t3, $s0, picoj1	#
        beq	$t3, $s3, picoj1	# If right most digit doesn't appear, go check the next digit.
	addi	$t4, $t4, 1		# our right most digit appeared nowhere in the target. 
        j	nopico1
        
picoj1: jal	PrintPico    
   
nopico1:div	$t0, $t1		# get the right most digit of input				
        mfhi	$t3			# remainder (our right most digit)                
        div	$t0, $t0, $t1		# Divide to get rest of digits and set to t0
        bne	$t3, $s1, noteq1	# check if right most digit is correct        
        jal 	PrintFermi		# if it is, print Fermi
        j	nopico2
     
noteq1: beq	$t3, $s0, picoj2	# Check if the right most digit is equal to our other digits. Print pico if they are.
        beq	$t3, $s2, picoj2	#
        beq	$t3, $s3, picoj2	# If right most digit doesn't appear, go check the next digit.
        addi	$t4, $t4, 1		# our right most digit appeared nowhere in the target. 
        j	nopico2
        
picoj2: jal	PrintPico   
   
nopico2:div	$t0, $t1		# get the right most digit of input				
        mfhi	$t3			# remainder (our right most digit)                
        div	$t0, $t0, $t1		# Divide to get rest of digits and set to t0
        bne	$t3, $s0, noteq0	# check if right most digit is correct         
        jal 	PrintFermi		# if it is, print Fermi
        j	nopico3 
   
noteq0: beq	$t3, $s1, picoj3	# Check if the right most digit is equal to our other digits. Print pico if they are.
        beq	$t3, $s2, picoj3	#
        beq	$t3, $s3, picoj3	# If right most digit doesn't appear, then we check if none of our values were correct.
        addi	$t4, $t4, 1		# our right most digit appeared nowhere in the target. 
        j	nopico3
        
picoj3: jal	PrintPico

nopico3:li	$t6, 4
	beq	$t4, $t6, bagelj	# Check if none of our values were correct. If they weren't, go to bagel
	j	guessagain
	
bagelj:	jal	PrintBagel
	j	guessagain
            
#--------------------------------------------------------------------------   
# Check if user inputed 0000
CheckRange:
# Usual stuff at function beginning
        addi    $sp, $sp, -4    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 	
	
	# function body	
	li	$t7, 10000
	blt	$a0, $t7, inbounds
	li	$v0, 4
	la, 	$a0, ofb
	syscall
	j	guessagain
	inbounds:
	# Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function      
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------   
# Check if user inputed 0000
CheckZero:
# Usual stuff at function beginning
        addi    $sp, $sp, -4    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 	
	
	# function body	
	bne	$a0, $0, notzero
	jal LoseGame
notzero:
	
	# Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function      
#--------------------------------------------------------------------------   

#--------------------------------------------------------------------------   
# Print that the player lost the game. Tell them the computer's number and how many guesses they made.
LoseGame:
	
	# Usual stuff at function beginning
        addi    $sp, $sp, -8    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
	
	# function body	
	li	$v0, 4
	la, 	$a0, target
	syscall			
	li	$v0, 1
	move	$a0, $s4
	syscall	
	li	$v0, 4
	la, 	$a0, lose
	syscall						
        li      $v0, 10,
        syscall   

#--------------------------------------------------------------------------

#--------------------------------------------------------------------------     
# Print out "Bagel"
PrintBagel:

	# Usual stuff at function beginning
        addi    $sp, $sp, -4    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
        
        # function body	
        
        li	$v0, 4
	la, 	$a0, bagel
	syscall
        
        # Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function      
#--------------------------------------------------------------------------  

#--------------------------------------------------------------------------     
# Print out "Pico"
PrintPico:

	# Usual stuff at function beginning
        addi    $sp, $sp, -8    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
        
        # function body	
        
        li	$v0, 4
	la, 	$a0, pico
	syscall
        
        # Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function      

#--------------------------------------------------------------------------  

#--------------------------------------------------------------------------     
# Print out "Fermi"
PrintFermi:

	# Usual stuff at function beginning
        addi    $sp, $sp, -8    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
        
        # function body	
        
        li	$v0, 4
	la, 	$a0, fermi
	syscall
        
        # Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function      

#--------------------------------------------------------------------------     

#--------------------------------------------------------------------------        
# User correctly guessed traget value.
# Print a congratulations and give the computers number
PrintWin:
	
	# Usual stuff at function beginning
        addi    $sp, $sp, -8    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
	
	# function body	
	li	$v0, 4
	la, 	$a0, target
	syscall			
	li	$v0, 1
	move	$a0, $s4
	syscall	
	li	$v0, 4
	la, 	$a0, victory
	syscall	
	li	$v0, 4
	la, 	$a0, guesses
	syscall	
	li	$v0, 1
	move	$a0, $s5
	syscall						
        li      $v0, 10,
        syscall   

#--------------------------------------------------------------------------
								
#--------------------------------------------------------------------------
# Our whole 4 digit random number is moved to v0.
# This number's individual digits are stored in a0-3.
# a0 a1 a2 a3	where the registers position corresponds to its place in the number                                                                                                                                                                                                         
NumberBuilder:

	# Usual stuff at function beginning
        addi    $sp, $sp, -8    # allocate stack space for 2 values
        sw      $ra, 0($sp)     # store off the return addr, etc 
        sw	$s0, 4($sp)
        
	# function body
	move	$s0, $a3		# _ _ _ (0-9)*1
        mul	$t0, $a2, 10		
        add	$s0, $s0, $t0		# _ _ (0-9)*10 + (0-9)*1
        mul	$t0, $a1, 100
        add	$s0, $s0, $t0		# _ (0-9)*100 + (0-9)*10 + (0-9)*1
        mul	$t0, $a0, 1000
        add	$s0, $s0, $t0		# (0-9)*1000 + (0-9)*100 + (0-9)*10 + (0-9)*1
        move	$v0, $s0

	# Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        lw	$s0, 4($sp)
        addi    $sp, $sp, 8
        jr      $ra             # return to the calling function          
#--------------------------------------------------------------------------        
        
        
#--------------------------------------------------------------------------
# Generates a random number from 1-9
GenerateNumber:

	# Usual stuff at function beginning
        addi    $sp, $sp, -4    # allocate stack space for 1 value
        sw      $ra, 0($sp)     # store off the return addr, etc 
        
	# function body
restart:li $a1, 9
        li $a0, 1
    	li $v0, 42  
    	syscall
    	beq	$a0, $s0, restart	# Check if number is unique
    	beq	$a0, $s1, restart
    	beq	$a0, $s2, restart
    	beq	$a0, $s3, restart

	# Usual stuff at function end
        lw      $ra, 0($sp)     # restore the return address, etc
        addi    $sp, $sp, 4
        jr      $ra             # return to the calling function   
#-------------------------------------------------------------------------- 
