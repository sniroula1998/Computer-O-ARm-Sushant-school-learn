.global checkAlphabeticWithoutLogical
.section .text

checkAlphabeticWithoutLogical:
    MOV r2, #0           // Initialize r2 to 0 (flag for alphabetic status)
    CMP r1, #0x41        // Compare r1 with ASCII value of 'A' (0x41)
    BLT notAlphabetic    // If r1 < 'A', jump to notAlphabetic
    CMP r1, #0x5A        // Compare r1 with ASCII value of 'Z' (0x5A)
    BGT notAlphabetic    // If r1 > 'Z', jump to notAlphabetic
    MOV r2, #1           // Set r2 to 1 (alphabetic)
    B endCheck           // Skip lowercase check
notAlphabetic:
    CMP r1, #0x61        // Compare r1 with ASCII value of 'a' (0x61)
    BLT notAlphabeticEnd // If r1 < 'a', jump to notAlphabeticEnd
    CMP r1, #0x7A        // Compare r1 with ASCII value of 'z' (0x7A)
    BGT notAlphabeticEnd // If r1 > 'z', jump to notAlphabeticEnd
    MOV r2, #1           // Set r2 to 1 (alphabetic)
notAlphabeticEnd:
    MOV r0, #0           // Default r0 to 0 (not alphabetic)
    CMP r2, #1           // Check if r2 is 1 (alphabetic)
    MOVEQ r0, #1         // If r2 == 1, set r0 to 1 (alphabetic)
    CMP r0, #0           // Check if r0 is 0 (not alphabetic)
    LDREQ r0, =notAlphaMsg // Load "not alphabetic" message if r0 == 0
    LDRNE r0, =resultMsg // Load "alphabetic" message if r0 == 1
    BL printf            // Call printf to display the message
endCheck:
    BX lr                // Return from function

.section .data
resultMsg:
    .asciz "This is an alphabetic character\n"
notAlphaMsg:
    .asciz "This is not an alphabetic character\n"

.section .note.GNU-stack,"",%progbits
