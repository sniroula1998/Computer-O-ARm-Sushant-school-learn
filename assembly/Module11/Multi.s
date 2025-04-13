.global main

.section .data
prompt:   .asciz "\nEnter the multiplier (m): "                       // Prompt for first input (m)
prompt2:  .asciz "\nEnter the number of iterations (n): "            // Prompt for second input (n)
output:   .asciz "\nResult of multiplication is: %d\n"              // Output message format
format:   .asciz "%d"                                              // Format string for scanf/printf
m_val:    .word 0                                                 // Storage for user input m
n_val:    .word 0                                                // Storage for user input n

.section .text
main:
                 // Prompt for multiplier (m)
    LDR r0, =prompt                         // Load address of prompt string into r0
    BL printf                              // Call printf(prompt)

    LDR r0, =format                      // Load address of "%d" format string into r0
    LDR r1, =m_val                      // Load address of m_val variable into r1
    BL scanf                           // Call scanf("%d", &m_val)

                 // Prompt for number of iterations (n)
    LDR r0, =prompt2                 // Load address of second prompt string
    BL printf                       // Call printf(prompt2)

    LDR r0, =format                 // Load "%d" format again
    LDR r1, =n_val                 // Load address of n_val variable
    BL scanf                      // Call scanf("%d", &n_val)

                // Load user inputs into registers
    LDR r1, =m_val                // Load address of m_val
    LDR r1, [r1]                 // Load actual m value into r1

    LDR r2, =n_val                // Load address of n_val
    LDR r2, [r2]                 // Load actual n value into r2

                // Call the recursive multiplication function: Mult(m, n)
    BL Mult                         // Result returned in r0

               // Print the result
    MOV r1, r0                    // Move result into r1 (second printf argument)
    LDR r0, =output              // Load address of output string
    BL printf                   // Call printf("\nThe result is %d\n", result)

              // Exit the program using Linux syscall
    MOV r7, #1                    // syscall number for exit
    SWI 0                        // software interrupt (exit)

               // Arguments: r1 = m, r2 = n
              // Returns: result in r0
Mult:
    PUSH {lr}                      // Save link register (return address)

    CMP r2, #1                    // Compare n with 1 (base case)
    BEQ base_case                // If n == 1, return m

              // Recursive case: return m + Mult(m, n - 1)
    PUSH {r1, r2}               // Save m and n
    SUB r2, r2, #1             // r2 = n - 1
    BL Mult                   // Recursive call: Mult(m, n-1)
    POP {r1, r2}             // Restore m and n
    ADD r0, r0, r1          // r0 = result + m
    POP {pc}               // Return to caller

base_case:
    MOV r0, r1                // Base case: return m
    POP {pc}                 // Return to caller
