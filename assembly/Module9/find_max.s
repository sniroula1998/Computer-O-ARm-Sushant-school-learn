.data
prompt:     .asciz "\nEnter 3 integers to find the largest: "
output:     .asciz "The largest value is: %d\n"
format:     .asciz "%d %d %d"
val1:       .word 0
val2:       .word 0
val3:       .word 0

.text
.global main
main:
    // Preserve registers and set up stack frame
    push {r4, r5, r6, lr}      // Save registers we'll use
    sub sp, sp, #12            // Allocate space for local variables

    // Prompt user
    ldr r0, =prompt
    bl printf

    // Read three integers
    ldr r0, =format
    ldr r1, =val1              // Address of val1
    ldr r2, =val2              // Address of val2
    ldr r3, =val3              // Address of val3
    bl scanf

    // Check scanf success (optional but good practice)
    cmp r0, #3                // Should return 3 if all inputs were read
    bne error_exit

    // Load values and find max
    ldr r4, =val1
    ldr r0, [r4]              // First value
    ldr r4, =val2
    ldr r1, [r4]              // Second value
    ldr r4, =val3
    ldr r2, [r4]              // Third value
    bl findMaxOf3

    // Print result
    mov r1, r0                // Move max value to r1 (printf expects arg in r1)
    ldr r0, =output           // Format string in r0
    bl printf

    // Clean up and exit
    mov r0, #0                // Return 0
    b exit

error_exit:
    mov r0, #1                // Return 1 on error

exit:
    add sp, sp, #12           // Clean up stack
    pop {r4, r5, r6, lr}      // Restore registers
    bx lr                     // Return

findMaxOf3:
    push {lr}                 // Save return address
    cmp r0, r1                // Compare first and second
    bge check_third
    mov r0, r1                // If r1 > r0, use r1

check_third:
    cmp r0, r2                // Compare current max with third
    bge end_function
    mov r0, r2                // If r2 > r0, use r2

end_function:
    pop {lr}
    bx lr

// Add this to avoid the GNU-stack warning
.section .note.GNU-stack,"",%progbits       
