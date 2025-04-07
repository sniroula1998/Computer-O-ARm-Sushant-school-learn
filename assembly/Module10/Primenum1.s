.global main

.text
main:
    MOV r0, #1                                  // File descriptor STDOUT
    LDR r1, =prompt                            // Address of the prompt string
    MOV r2, #30                               // Length of the prompt string
    MOV r7, #4                               // Syscall for write
    SVC #0                                  // Make the system call

                     // Read user input
    MOV r0, #0                               // File descriptor STDIN
    LDR r1, =user_input                     // Address of the input buffer
    MOV r2, #10                            // Number of bytes to read
    MOV r7, #3                            // Syscall for read
    SVC #0                               // Make the system call

                       // Convert ASCII to integer
    LDR r4, =user_input                             // Load user input to r4
    MOV r5, #0                                     // Initialize number
    MOV r6, #0                                    // Initialize index

ConvertLoop:
    LDRB r0, [r4, r6]                                  // Load the current byte
    CMP r0, #10                                       // Check if it's a newline character
    BEQ DoneConvert                                  // If it's a newline, we're done
    CMP r0, #48                                     // Check if it's a digit
    BLT InvalidInput                               // If it's not a digit, it's invalid input
    CMP r0, #57                                   // Check if it's a digit
    BGT InvalidInput                             // If it's not a digit, it's invalid input
    SUB r0, r0, #48                             // Subtract ASCII value of '0'
    MOV r7, r5                                 // Move current number to r7
    MOV r5, r7, LSL #1                        // Shift current number left by 1 bit
    MOV r5, r5, LSL #2                       // Shift current number left by 2 bits
    ADD r5, r5, r0                          // Add the new digit to the number
    ADD r6, r6, #1                         // Increment index
    B ConvertLoop                         // Continue loop

DoneConvert:
                // Check if the number is less than 2
    CMP r5, #2
    BLT InvalidInput                        // If less than 2, it's invalid input

    MOV r6, r5                            // Store the number in r6
    MOV r7, #2                           // Start divisor from 2

StartLoop: 
    CMP r7, r6                    // Compare divisor with the number
    BGE PrimeNumber              // If divisor >= number, it is prime
  
             // Check if number is divisible by divisor
    MOV r0, r6                                    // Move number to r0 for division
    MOV r1, r7                                   // Move divisor to r1
    BL Division                                 // Call the division function

    CMP r0, #0                               // Check if remainder is zero
    BEQ NotPrime                            // If remainder is zero, number is not prime

    ADD r7, r7, #1                         // Increment divisor
    B StartLoop                           // Continue loop

PrimeNumber:
                     // Print that the number is prime
    MOV r0, #1                                              // File descriptor STDOUT
    LDR r1, =prime_message                                 // Load prime message
    MOV r2, #19                                           // Length of prime message
    MOV r7, #4                                           // Syscall for write
    SVC #0                                              // Make the system call
    B AskContinue                                      // Ask if user wants to continue

NotPrime:
                         // Print that the number is not prime
    MOV r0, #1                                               // File descriptor
    LDR r1, =not_prime_message                              // Load not prime message
    MOV r2, #27                                            // Length of not prime message
    MOV r7, #4                                            // Syscall for write
    SVC #0                                               // Make the system call
    B AskContinue                                       // Ask if user wants to continue

InvalidInput:
                      // Print error message if input is invalid
    MOV r0, #1                                                // File descriptor STDOUT
    LDR r1, =error_message                                   // Load error message
    MOV r2, #27                                             // Length of error message
    MOV r7, #4                                             // Syscall for write
    SVC #0                                                // Make the system call
    B AskContinue                                        // Ask if user wants to continue

AskContinue:
                  // Ask if user wants to continue
    MOV r0, #1                                       // File descriptor STDOUT
    LDR r1, =continue_prompt                        // Load continue prompt
    MOV r2, #24                                    // Length of continue prompt
    MOV r7, #4                                    // Syscall for write
    SVC #0                                       // Make the system call

                            // Read user input
    MOV r0, #0                                               // File descriptor STDIN
    LDR r1, =continue_input                                 // Address of the input buffer
    MOV r2, #2                                             // Number of bytes to read
    MOV r7, #3                                            // Syscall for read
    SVC #0                                               // Make the system call

                           // Check if user wants to continue
    LDRB r0, [r1]                                          // Load the first byte of the input
    CMP r0, #89                                           // Check if it's 'Y'
    BEQ main                                           // If it's 'Y', start again
    CMP r0, #121                                        // Check if it's 'y'
    BEQ main                                         // If it's 'y', start again
    B EndProgram                                      // If it's not 'Y' or 'y', end the program

EndProgram:
                        // Print thank you message
    MOV r0, #1                                                 // File descriptor STDOUT
    LDR r1, =thank_you_message                                // Load thank you message
    MOV r2, #13                                              // Length of thank you message
    MOV r7, #4                                              // Syscall for write
    SVC #0                                                 // Make the system call

                        // Exit the program
    MOV r0, #0                                                // Exit syscall
    MOV r7, #1                                               // Syscall for exit
    SVC #0                                                  // Make the system call

// Division subroutine
Division:
    MOV r2, r0                                            // Copy dividend into r2
    MOV r3, #0                                           // Clear r3 (remainder)

DivideLoop:
    CMP r2, r1                                         // Compare dividend with divisor
    BLT Done                                          // If dividend < divisor, we're done
    SUB r2, r2, r1                                   // Subtract divisor from dividend
    ADD r3, r3, #1                                  // Increment remainder count
    B DivideLoop

Done:
    MOV r0, r2                                     // Return remainder in r0
    BX lr                                         // Return from function

.data
prompt: .asciz "Enter to check if it's prime: "
error_message: .asciz "Error: Number must be greater than 1\n"
prime_message: .asciz "Number is prime\n"
not_prime_message: .asciz "Number is not prime\n"
continue_prompt: .asciz "want to continue? (Y/N): "
thank_you_message: .asciz "Thank you.\n"

user_input: .space 10                             // Space for user input
continue_input: .space 2                          // Space for continue input
