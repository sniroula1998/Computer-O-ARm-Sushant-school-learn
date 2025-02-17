.global main

.section .data
prompt: .asciz "Enter a floating-point number: "  @ Define the string for input
output: .asciz "You entered: %f\n"                @ Define the output 

.section .bss
float_input: .skip 4  @ 4 bytes for a floating-point variable

.section .text
main:
          @ Print message
    LDR r0, =prompt        @ Load address of the string
    BL printf              @ Call printf to display

          @ Read the floating-point number from the user
    LDR r0, =float_input   @ Load address
    BL scanf               @ Call scanf to read 

          @ Print the floating-point number
    LDR r0, =output        @ Load address of the output 
    LDR r1, =float_input   @ Load address of float_input
    BL printf              @ Call printf to display

          @ Exit program 
    BX LR                  @ Branch to link register 
