 ##############################################################################################
##  Selection sort algorithm with a random number generator using MIPS - Assembly           ##
##  Developed by: Sajad Hamzenejadi                                                         ##
##  Email: sajadhamzenejadi76@gmail.com                                                     ##
##  2017, Iran                                                                              ##
##############################################################################################

# Main program elements
#   $s2 = array size
#   $s1 = array counter
#   $t1 = memory address
#   $a0 = top of the stack

# Random generator elements
#   $t8 = random number 
#   $s4 = time to start
#   $s5 = time to end

.text
j main # Jump to main routine

.text
.globl main
main:

    li $v0, 1000
    move $s2, $v0           # $s2 = n
    sll $s0, $v0, 2         # $s0 = n*4
    sub $sp, $sp, $s0       # Create a stack frame for the array

    move $s1, $zero          # Set array counter to 0

    # Seed the random number generator
    li $v0, 30               # Get time in milliseconds (as a 64-bit value)
    syscall
    move $t0, $a0            # Save the lower 32-bits of time

    # Seed the random generator (just once)
    li $a0, 1                # Random generator id (will be used later)
    move $a1, $t0            # Seed from time
    li $v0, 40               # Seed random number generator syscall
    syscall

    # Seeding done

    # Generate 1000 random integers in the range 0 - 1000
    # Seeded generator (whose id is 1)
    li $t2, 1001             # Max number of iterations + 1
    li $s1, 0                # Current iteration number

LOOP:
    li $a0, 1                # As said, this id is the same as random generator id
    li $a1, 1000             # Upper bound of the range
    li $v0, 42               # Random int range syscall
    syscall
    move $t8, $a0            # $t8 now holds the random number

    jal for_get

    # Print random number that is in $t8
    move $a0, $t8
    li $v0, 1                # Print integer syscall
    syscall

    # Print a space
    la $a0, spacestr         # Load the address of the string (pseudo-op)
    li $v0, 4                # Print string syscall
    syscall

    # Do another iteration 
    j LOOP

for_get:
    bge $s1, $s2, exit_get   # If i >= n go to exit_get
    sll $t0, $s1, 2          # $t0 = i*4
    add $t1, $t0, $sp         # $t1 = $sp + i*4

    move $v0, $t8            # Get one element of the array
    sw $v0, 0($t1)            # The element is stored at the address $t1

    la $a0, end_n_option
    li $v0, 4
    syscall
    addi $s1, $s1, 1          # Counter = Counter + 1
    jr $ra

exit_get:
    # Set time to start
    li $v0, 30
    syscall
    move $s4, $a0

    move $a0, $sp             # $a0 = Base address of the array
    move $a1, $s2             # $a1 = Size of the array

    jal isort                 # isort(a, n)
                              # In this moment, the array has been 
                              # sorted and is in the stack frame

    la $a0, sorted_array_msg  # Print sorted_array_msg
    li $v0, 4
    syscall

    move $s1, $zero           # Counter = 0

for_print:                   # This loop prints the sorted array
    bge $s1, $s2, exit_print  # If i >= n go to exit_print
    sll $t0, $s1, 2          # $t0 = i*4
    add $t1, $sp, $t0         # $t1 = address of a[i]
    lw $a0, 0($t1)            # Load element a[i]
    li $v0, 1                 # Print the element a[i]
    syscall

    la $a0, end_n_option
    li $v0, 4
    syscall

    addi $s1, $s1, 1          # Counter = Counter + 1
    j for_print

exit_print:
    # Set time to end
    li $v0, 30
    syscall
    move $s5, $a0
    sub $a0, $s5, $s4
    li $v0, 1
    syscall

    add $sp, $sp, $s0         # Elimination of the stack frame
    li $v0, 10                # EXIT
    syscall

## Selection Sort

isort:
    addi $sp, $sp, -20        # Save values on the stack
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    move $s0, $a0             # Base address of the array
    move $s1, $zero           # Counter = 0
    sub $s2, $a1, 1           # Length - 1

isort_for:
    bge $s1, $s2, isort_exit   # If counter >= length-1 -> exit loop

    move $a0, $s0             # Base address
    move $a1, $s1             # i
    move $a2, $s2             # Length - 1
    jal mini

    move $s3, $v0             # Return value of mini

    move $a0, $s0             # Array
    move $a1, $s1
    move $a2, $s3             # Mini
    jal swap

    addi $s1, $s1, 1          # Counter += 1
    j isort_for               # Go back to the beginning of the loop

isort_exit:
    lw $ra, 0($sp)            # Restore values from the stack
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20          # Restore stack pointer
    jr $ra                    # Return

## Index Minimum Routine

mini:
    move $t0, $a0             # Base of the array
    move $t1, $a1             # Mini = first = counter
    move $t2, $a2             # Last
    sll $t3, $t1, 2           # First * 4
    add $t3, $t3, $t0         # Index = base array + first * 4
    lw $t4, 0($t3)            # Min = v[first]
    addi $t5, $t1, 1          # Counter = 0

mini_for:
    bgt $t5, $t2, mini_end    # Go to mini_end
    sll $t6, $t5, 2           # Counter * 4
    add $t6, $t6, $t0         # Index = base array + counter * 4
    lw $t7, 0($t6)            # v[index]

    bge $t7, $t4, mini_if_exit # Skip the if when v[counter] >= min

    move $t1, $t5             # Mini = counter
    move $t4, $t7             # Min = v[counter]

mini_if_exit:
    addi $t5, $t5, 1          # Counter += 1
    j mini_for

mini_end:
    move $v0, $t1             # Return mini
    jr $ra

## Swap Routine

swap:
    sll $t1, $a1, 2           # Counter * 4
    add $t1, $a0, $t1         # v + counter * 4

    sll $t2, $a2, 2           # j * 4
    add $t2, $a0, $t2         # v + j * 4

    lw $t0, 0($t1)            # v[counter]
    lw $t3, 0($t2)            # v[j]
    sw $t3, 0($t1)            # v[counter] = v[j]
    sw $t0, 0($t2)            # v[j] = $t0

    jr $ra

.data
spacestr:             .asciiz " "
array_size_msg:       .asciiz "Insert the array size \n"
array_elements_msg:   .asciiz "Insert the array elements, one per line  \n"
sorted_array_msg:     .asciiz "The sorted array is : \n"
end_n_option:         .asciiz "\n"

