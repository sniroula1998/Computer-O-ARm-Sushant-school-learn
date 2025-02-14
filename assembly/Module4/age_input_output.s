.global _start
.extern scanf    // scanf function from C library 
_start:
.section .data
prompt: .asciz "Please enter your age: "          // Prompt message
age_str: .asciz "\"Your age is: \t\""            // "Your age is: " with quotes around it and a tab
new_line: .asciz "\n"                             // For better formatting
fmt_str: .asciz "%d"                              // Format for scanf 


.section .bss
age: .skip 4                                      // Space to store user input

.section .text
    // Print the prompt message
    MOV r0, #1                // File descriptors
    LDR r1, =prompt           // Load address 
    MOV r2, #21               // Length of message
    MOV r7, #4                // System call number for write 
    SVC #0                    // System call to write

           // Read user input for age
    MOV r0, #0                // File descriptor
    LDR r1, =age              // Address to store input
    MOV r2, #4                // Max input length (4 bytes)
    MOV r7, #3                // System call number for read
    SVC #0                    // System call to read input

           // Print the message "Your age is: 
    MOV r0, #1                // File descriptor
    LDR r1, =age_str          // Load address of the "Your age is: "
    MOV r2, #15               // Length of "Your age is: "
    MOV r7, #4                // System call number for write
    SVC #0                    // System call to write

            // Print the user input (age)
    MOV r0, #1                // File descriptor 
    LDR r1, =age              // Load the user input
    MOV r2, #4                // Length of the user input
    MOV r7, #4                // System call number for write
    SVC #0                    // System call to write

    // Exit the program
    MOV r0, #0                // Exit status
    MOV r7, #1                // System call number for exit
    SVC #0                    // System call to exit
