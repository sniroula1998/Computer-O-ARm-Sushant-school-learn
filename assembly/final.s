 .data
prompt: .asciz "Enter an integer (-1 to end): "
countMsg: .asciz "Count: %d\n"
sumMsg: .asciz "Sum: %d\n"
avgMsg: .asciz "Average: %d\n"
fmt: .asciz "%d"
noneMsg: .asciz "No values entered.\n"

        .bss
input:  .skip 4                   @ Reserve space for user input

        .text
        .global main
main:
        push {lr}                @ Save return address

        mov r4, #0               @ r4 = count = 0
        mov r5, #0               @ r5 = sum = 0

loop:
        ldr r0, =prompt
        bl printf                @ printf("Enter an integer (-1 to end): ")

        ldr r0, =fmt
        ldr r1, =input
        bl scanf                 @ scanf("%d", &input)

        ldr r0, =input
        ldr r6, [r0]             @ r6 = value entered

        cmp r6, #-1
        beq done_input           @ If value == -1, break loop

        add r5, r5, r6           @ sum += value
        add r4, r4, #1           @ count += 1

        b loop                   @ Repeat input loop

done_input:
        cmp r4, #0
        beq no_values            @ If no values were entered, skip average

        mov r0, r5               @ r0 = sum
        mov r1, r4               @ r1 = count
        bl __aeabi_idiv          @ r0 = sum / count (integer division)

        mov r6, r0               @ Store average in r6

        ldr r0, =countMsg
        mov r1, r4
        bl printf                @ Print count

        ldr r0, =sumMsg
        mov r1, r5
        bl printf                @ Print sum

        ldr r0, =avgMsg
        mov r1, r6
        bl printf                @ Print average

        b end

no_values:
        ldr r0, =noneMsg
        bl printf                @ Print "No values entered."

end:
        pop {lr}
        bx lr                    @ Return from main
