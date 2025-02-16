.global main
.extern scanf, printf

.section .data
prompti: .asciz "Enter your age: "            @  user input
format1: .asciz "\t%d"                          @  string for reading an integer
outputl: .asciz "\"Your age is: \t%d\"\n"           @ Output with tab and formatted output

.section .bss
age: .skip 4                                  @ Reserve space for user input

.section .text
main:
               @ Push the stack record
    SUB sp, sp, #4                @ Allocate space for 4 bytes
    STR lr, [sp, #0]              @ Save the return address

             @ Print  "Enter your age:"
    LDR r0, =prompti              @ Load the address of the prompt
    BL printf                     @ Call printf to print

                @ Read user input: the age
    LDR r0, =format1              @ Load the format string
    LDR r1, =age                  @ Load the address of the variable
    BL scanf                      @ Call scanf to read the input and store 

                @ Print the message with the user input
    LDR r0, =outputl              @ Load the format string
    LDR r1, =age                  @ Load the address of 'age'
    LDR r1, [r1]                  @  'age' to get 
    BL printf                     @ Call printf to print

    @ Pop the stack record 
    LDR lr, [sp, #0]              @ Load the link 
    ADD sp, sp, #4                @  space on the stack

    @ Exit the program
    BX lr                         @ Return to the called 
