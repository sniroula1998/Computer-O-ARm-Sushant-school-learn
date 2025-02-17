.global main

.section .data
prompt: .asciz "Enter a floating-point number: "  @ Define the prompt string for input
output: .asciz "You entered: %f\n"               @ Define the output format string

.section .bss
float_input: .skip 4  @ Reserve 4 bytes for a floating-point variable

.section .text
main:
    @ Print prompt message
    ldr r0, =prompt        @ Load address of the prompt string into r0
    bl printf              @ Call printf to display the prompt

    @ Read the floating-point number from the user
    ldr r0, =float_input   @ Load address of float_input variable into r0
    bl scanf               @ Call scanf to read the floating-point number

    @ Print the floating-point number
    ldr r0, =output        @ Load address of the output format string into r0
    ldr r1, =float_input   @ Load address of float_input into r1
    bl printf              @ Call printf to display the floating-point value

    @ Exit program (return from main)
    bx lr                  @ Branch to link register (effectively exits the program) 
