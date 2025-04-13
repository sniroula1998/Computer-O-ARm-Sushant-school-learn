.global main

.section .data
prompt:      .asciz "\nEnter the value of n to calculate Fibonacci(n): "  // Promp to enter n value 
output:      .asciz "\nFibonacci(%d) = %d\n"                             // Output fibonacci calculation 
format:      .asciz "%d"                                                // Format string for scanf/printf 
number:      .word 0
discard:     .asciz "%*c"

.section .text
main:
    PUSH {lr}                                    // Save link register to return after main
 
                      // Prompt for n
    LDR r0, =prompt                            // Load address of prompt string
    BL printf                                 // Call printf to display the prompt

    LDR r0, =format                          // Load address of format string for scanf
    LDR r1, =number                         // Load address of number
    BL scanf                               // Call scanf to read the integer

                      // Discard any remaining input
    LDR r0, =discard                      // Load address of discard format
    MOV r1, #0                           // Initialize count to 0
discard_loop:
    BL scanf                            // Call scanf to discard input
    CMP r0, #1                         // Check if scanf read a character
    BEQ discard_loop                  // If yes, continue discarding

    LDR r0, =number                 // Load address of number
    LDR r0, [r0]                   // Load the value of n into r0

                      // Call the recursive Fibonacci function
    BL Fibonacci

                      // Print the result
    LDR r1, =number                          // Load address of number 
    STR r0, [r1]                            // Store result into number
    LDR r1, =number                        // Load address of number 
    LDR r1, [r1]                          // Load result into r1
    LDR r0, =output                      // Load address of output format
    MOV r2, r1                          // Move result to r2 for printf
    LDR r1, =number                    // Load address of number 
    LDR r1, [r1]                      // Load input into r1
    BL printf                        // Call printf to display the result

    POP {pc}                       // Restore program counter and return to the caller

                      // Recursive function to compute Fibonacci(n)
Fibonacci:
    PUSH {r4, r5, lr}                                 // Save r4, r5, and lr 

    CMP r0, #0                                      // Compare n with 0
    BEQ fib_zero                                   // If n == 0, jump to fib_zero

    CMP r0, #1                                   // Compare n with 1
    BEQ fib_one                                 // If n == 1, jump to fib_one

    MOV r4, r0                                // Copy n to r4
    SUB r0, r0, #1                           // n = n - 1
    BL Fibonacci                            // Recursive call Fibonacci(n-1)
    MOV r5, r0                             // Save Fibonacci(n-1) in r5

    MOV r0, r4                           // Restore n
    SUB r0, r0, #2                      // n = n - 2
    BL Fibonacci                       // Recursive call Fibonacci(n-2)

    ADD r0, r0, r5                   // Fibonacci(n) = Fibonacci(n-1) + Fibonacci(n-2)
  
    POP {r4, r5, pc}               // Restore r4, r5, and pc

fib_zero:
    MOV r0, #0                   // If n == 0, return 0
    POP {r4, r5, pc}            // Restore r4, r5, and pc

fib_one:
    MOV r0, #1                // If n == 1, return 1
    POP {r4, r5, pc}         // Restore r4, r5, and pc (program counter)
