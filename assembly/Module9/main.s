.global main
.extern printf
.extern scanf

.section .text

main:
    PUSH {lr}                // Save link register

    // Print prompt
    LDR r0, =promptMsg       // Load address of prompt message
    BL printf                // Call printf to display "Please write some"

    // Read user input
    LDR r0, =inputFormat     // Load format string for scanf ("%c")
    LDR r1, =inputChar       // Load address to store input character
    BL scanf                 // Call scanf to read a character

    // Load the input character into r1 for checking
    LDR r1, =inputChar       // Load address of inputChar
    LDRB r1, [r1]            // Load the byte (character) into r1

    // Check if uppercase (A-Z)
    CMP r1, #0x41            // Compare with 'A' (0x41)
    BLT checkLowercase       // If less than 'A', check lowercase
    CMP r1, #0x5A            // Compare with 'Z' (0x5A)
    BLE isUppercase          // If less than or equal to 'Z', it’s uppercase

checkLowercase:
    // Check if lowercase (a-z)
    CMP r1, #0x61            // Compare with 'a' (0x61)
    BLT notAlphabetic        // If less than 'a', not alphabetic
    CMP r1, #0x7A            // Compare with 'z' (0x7A)
    BLE isLowercase          // If less than or equal to 'z', it’s lowercase
    B notAlphabetic          // Otherwise, it’s not alphabetic

isUppercase:
    LDR r0, =uppercaseMsg    // Load uppercase message
    BL printf                // Print uppercase message
    B exit                   // Exit

isLowercase:
    LDR r0, =lowercaseMsg    // Load lowercase message
    BL printf                // Print lowercase message
    B exit                   // Exit

notAlphabetic:
    LDR r0, =notAlphaMsg     // Load non-alphabetic message
    BL printf                // Print non-alphabetic message

exit:
    MOV r0, #0               // Return code 0
    POP {pc}                 // Restore link register and return

.section .data
promptMsg:
    .asciz "Please insert character\n"
inputFormat:
    .asciz "%c"              // Format string for scanf to read a character
uppercaseMsg:
    .asciz "THIS IS AN UPPERCASE ALPHABETIC CHARACTER\n"
lowercaseMsg:
    .asciz "this is a lowercase alphabetic character\n"
notAlphaMsg:
    .asciz "this is not an alphabetic character\n"
inputChar:
    .space 1                 // Reserve 1 byte for input character

.section .note.GNU-stack,"",%progbits
