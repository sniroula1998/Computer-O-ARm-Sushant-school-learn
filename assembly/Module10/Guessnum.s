.global main
main:

                  // push the stack record
    SUB sp, sp, #4                                   // Stack to create space
    STR lr, [sp, #0]                                // Save link register onto the stack

                      // Asking for the maximum value
    LDR r0, =prompt_max                                   // Load address into r0
    BL printf                                            // Call printf to display

                   // Read the maximum value input
    LDR r0, =format_int                                 // Load the address into r0
    LDR r1, =max_value                                 // Load the address into r1
    BL scanf                                          // Call scanf to read the integer

                   // Load max value into r4, set min value
    LDR r0, =max_value                                       // Load address into r0
    LDR r4, [r0, #0]                                        // Load the value into r4 (max)
    MOV r5, #1                                             // Set r5 (min value) to 1

                     // Start the guess loop
    B guess_loop

guess_loop:
                   // Compute (min + max) / 2 -> r7 (middle value)
    ADD r0, r5, r4                                                // Add min (r5) and max (r4)
    MOV r1, #2                                                   // Set r1 to 2 
    BL __aeabi_idiv                                             // Call division function 

                    // Saving middle value (guess)
    MOV r7, r0                                         // Store the result of division in r7

                   // Display guess message to user
    MOV r1, r7                                       // Move the middle value to r1 
    LDR r0, =guess_msg                              // Load address into r0
    BL printf                                      // Call printf to prompt the guess message

                 // Prompt for the response 
    LDR r0, =response_prompt                           // Load address of response_prompt string into r0
    BL printf                                         // Call printf to show the prompt
 
                     // Read the user response
    LDR r0, =format_char                               // Load address into r0
    LDR r1, =response                                 // Load address of response variable into r1
    BL scanf                                         // Call scanf to read the response char 

                  // Load response character
    LDR r0, =response                               // Load address into r0
    LDRB r1, [r0, #0]                              // Load the response character 

                 // Check if response is 'c' (correct)
    CMP r1, #'c'                                          // Compare response with 'c'
    BEQ correct                                          // If response is 'c', to correct label

                // Check if response is 'l' (too low)
    CMP r1, #'l'                                       // Compare response with 'l'
    BEQ too_low                                       // If response is 'l', to too_low label

               // Check if response is 'h' (too high)
    CMP r1, #'h'                                       // Compare response with 'h'
    BEQ too_high                                      // If response is 'h', to too_high label

                  // If invalid, repeat the guess loop
    B guess_loop

too_low:
                   // If guess is too low, 
    ADD r5, r7, #1                             // Set min value (r5) to middle value (r7) + 1
    B guess_loop                               // Repeat the guess loop

too_high:
                        // If guess is too high,
    SUB r4, r7, #1                                               // Set max value (r4) to middle value (r7) - 1
    B guess_loop                                                // Repeat the guess loop
 
correct:
                    // If correct guess
    LDR r0, =correct_guess                       // Load address of success_msg string into r0
    MOV r1, r7                                  // Move the correct guess (r7) to r1
    BL printf                                  // Call printf to display the success message

    B exit                                    // Branch to exit (end of the program)

exit:
    // Restore stack and return
    LDR lr, [sp, #0]                            // Load the link register (return address) from the stack
    ADD sp, sp, #4                             // Restore the stack pointer
    MOV pc, lr                                // Return from main (branch to link register)

.data
    // Define the strings and variables
prompt_max:        .asciz "Enter a number: "
format_int:        .asciz "%d"                                  // For reading an integer
format_char:       .asciz " %c"                                // For reading a character
max_value:         .word 0                                    // Reserve space for the max_value 
response:          .byte 0                                   // Reserve space for user response
guess_msg:         .asciz "Is the number %d? (h = too high, l = too low, c = correct):"
response_prompt:   .asciz ""                                                               // Empty string for the prompt between guesses
correct_guess:       .asciz "Congrulation you guessed the number correctly: %d\n"         // Message after correct guess
