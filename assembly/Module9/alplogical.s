.global checkAlphabeticLogical
.section .text

checkAlphabeticLogical:
    MOV r2, #0          // r2 is used to store the result (0 or 1)
    CMP r1, #0x41       // Compare r1 with ASCII value of 'A' (0x41)
    ADDGE r2, r2, #1    // If r1 >= 'A', increment r2
    CMP r1, #0x5A       // Compare r1 with ASCII value of 'Z' (0x5A)
    ADDLE r2, r2, #1    // If r1 <= 'Z', increment r2
    CMP r1, #0x61       // Compare r1 with ASCII value of 'a' (0x61)
    ADDGE r2, r2, #1    // If r1 >= 'a', increment r2
    CMP r1, #0x7A       // Compare r1 with ASCII value of 'z' (0x7A)
    ADDLE r2, r2, #1    // If r1 <= 'z', increment r2
    MOV r0, #0          // Set r0 to 0 (not alphabetic) by default
    CMP r2, #2          // If r2 == 2, it’s alphabetic
    MOVEQ r0, #1        // If equal, set r0 to 1 (alphabetic)
    CMP r0, #0          // Check if r0 is 0
    LDREQ r0, =errorMsg // Load error message address if not alphabetic
    BLEQ printf         // Call printf if not alphabetic
    BX lr               // Return from function

.section .data
errorMsg:
    .asciz "Not an alphabetic character\n"

.section .note.GNU-stack,"",%progbits
