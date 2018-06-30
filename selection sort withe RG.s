
##############################################################################################
##  selection sort algorithm with a random number generator using MIPS - Assembly           ##
##  engineer: sajad hamzenejadi                                                             ##
##  email: sajadhamzenejadi76@gmail.com                                                     ##
##  2017, iran                                                                              ##
##############################################################################################

#main program elements

#   s2 =  array size
#   s1 = array counter
#   t1 = memory address
#   a0 = top of the stack

#random generator elements

#   t8 = random number 
#   s4 = time to start
#   s5 = time to end



# انتقالی از کد بعدی
.text
			j	main								# Jump to main-routine
			
			.text
			.globl	main
	main: 
			
			
			li $v0, 1000                        
			move    $s2, $v0					# $s2 = n   
			sll	$s0, $v0, 2						# $s0=n*4    
			sub	$sp, $sp, $s0					# This instruction creates a stack 
												# frame large enough to contain
												# the array					

			move	$s1, $zero					# seting array counter to 0
			


# seed the random number generator
# get the time
li	$v0, 30		    # get time in milliseconds (as a 64-bit value)
syscall

move	$t0, $a0	# save the lower 32-bits of time

# seed the random generator (just once)

li	$a0, 1		    # random generator id (will be used later)
move 	$a1, $t0	# seed from time
li	$v0, 40		    # seed random number generator syscall
syscall

# seeding done

# generate 1000 random integers in the range 0 - 1000
# seeded generator (whose id is 1)
li	$t2, 1001	# max number of iterations + 1
li	$s1, 0		# current iteration number                         

LOOP:
                
li	$a0, 1		# as said, this id is the same as random generator id
li	$a1, 1000	# upper bound of the range
li	$v0, 42		# random int range
syscall
move $t8, $a0   
# $t8 now holds the random number

jal for_get     
                

# $t8 still has the random number

# print random number that is into $t8

# move $t8 into $a0 because in sintax we print $a0
move $a0, $t8
li	$v0, 1		# print integer syscall
syscall

# print a space
la	$a0, spacestr	# load the address of the string (pseudo-op)	
li	$v0, 4		# print string syscall
syscall

# Do another iteration 
j	LOOP


	for_get:
	
			bge	$s1, $s2, exit_get				# if i>=n go to exit_get         
			sll	$t0, $s1, 2						# $t0=i*4                        
			add	$t1, $t0, $sp					# $t1=$sp+i*4
						                                  							  
			move $v0, $t8						# Get one element of the array
			sw	$v0, 0($t1)						# The element is stored
												# at the address $t1
			la	$a0, end_n_option               
			li	$v0, 4
			syscall
			addi	$s1, $s1, 1					# counter= counter +1
			jr $ra                         
			
			#in this code we want to calculate that
			#how much time we need to sort 1000 random numbers
			#with selection_sort algorithm
			
	exit_get:
	        #seting time to start
			li $v0 , 30
			syscall
			move $s4, $a0
			move	$a0, $sp					# $a0=base address af the array       
			move	$a1, $s2					# $a1=size of the array           

			jal	isort							# isort(a,n)             
												# In this moment the array has been 
												# sorted and is in the stack frame 
			la	$a0, sorted_array_msg			# Print of sorted_array_msg     
			li	$v0, 4
			syscall

			move	$s1, $zero					# counter = 0
			
	for_print:                                  # this loop prints the sorted array
	
			bge	$s1, $s2, exit_print			# if i>=n go to exit_print          
			sll	$t0, $s1, 2						# $t0=i*4                       
			add	$t1, $sp, $t0					# $t1=address of a[i]               
			lw	$a0, 0($t1)						                                  
			li	$v0, 1							# print of the element a[i]         
			syscall								
			la	$a0, end_n_option
			li	$v0, 4
			syscall
			addi	$s1, $s1, 1					# counter = counter +1
			j	for_print
			
	exit_print:	
	        #seting time to end
			li $v0 , 30
			syscall
			move $s5, $a0
			sub $a0, $s5 ,$s4
			li $v0, 1
			syscall
			add	$sp, $sp, $s0					# elimination of the stack frame 
   			li	$v0, 10							# EXIT
			syscall										
				
	## selection_sort
	
	isort:
	
			addi	$sp, $sp, -20				# save values on stack
			sw	$ra, 0($sp)                     # 
			sw	$s0, 4($sp)                     #
			sw	$s1, 8($sp)                     #
			sw	$s2, 12($sp)                    #
			sw	$s3, 16($sp)                    #
			move 	$s0, $a0					# base address of the array
			move	$s1, $zero					# counter=0
			sub	$s2, $a1, 1						# lenght -1
			
	isort_for:	
	
			bge 	$s1, $s2, isort_exit		# if counter >= length-1 -> exit loop
		
			move	$a0, $s0					# base address
			move	$a1, $s1					# i      
			move	$a2, $s2					# length - 1
			jal	mini
			move	$s3, $v0					# return value of mini
		
			move	$a0, $s0					# array
			move	$a1, $s1					
			move	$a2, $s3					# mini
			jal	swap
			addi	$s1, $s1, 1					# counter += 1
			j	isort_for						# go back to the beginning of the loop
		
	isort_exit:
	
			lw	$ra, 0($sp)						# restore values from stack
			lw	$s0, 4($sp)
			lw	$s1, 8($sp)
			lw	$s2, 12($sp)
			lw	$s3, 16($sp)
			addi	$sp, $sp, 20				# restore stack pointer
			jr	$ra								# return


	## index_minimum routine
	mini:
	
			move	$t0, $a0					# base of the array
			move	$t1, $a1					# mini = first = counter
			move	$t2, $a2					# last
			sll	$t3, $t1, 2						# first * 4
			add	$t3, $t3, $t0					# index = base array + first * 4		
			lw	$t4, 0($t3)						# min = v[first]
			addi	$t5, $t1, 1					# counter = 0         
			
	mini_for:
	
			bgt	$t5, $t2, mini_end				# go to min_end
			sll	$t6, $t5, 2						# counter * 4
			add	$t6, $t6, $t0					# index = base array + counter * 4		
			lw	$t7, 0($t6)						# v[index]

			bge	$t7, $t4, mini_if_exit			# skip the if when v[counter] >= min
		
			move	$t1, $t5					# mini = counter
			move	$t4, $t7					# min = v[counter]

	mini_if_exit:
	
			addi	$t5, $t5, 1					# counter += 1
			j	mini_for

	mini_end:
	
			move 	$v0, $t1					# return mini
			jr	$ra

	## swap routine
	
	swap:
	
			sll	$t1, $a1, 2						# counter * 4
			add	$t1, $a0, $t1					# v + counter * 4
		
			sll	$t2, $a2, 2						# j * 4
			add	$t2, $a0, $t2					# v + j * 4

			lw	$t0, 0($t1)						# v[counter]
			lw	$t3, 0($t2)						# v[j]

			sw	$t3, 0($t1)						# v[counter] = v[j]
			sw	$t0, 0($t2)						# v[j] = $t0

			jr	$ra
			
		.data
	spacestr:           	.asciiz " " 	
	array_size_msg:	 		.asciiz "Insert the array size \n"
	array_elements_msg:		.asciiz "Insert the array elements,one per line  \n"
	sorted_array_msg:		.asciiz "The sorted array is : \n"
	end_n_option:			.asciiz "\n"
	