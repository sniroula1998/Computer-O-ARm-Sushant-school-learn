.data
prompt:       .asciz "Enter the student's name: "
prompt_grade: .asciz "Enter the student's average (0-100): "
output:       .asciz "Student: %s\nGrade: %s\n"
error_msg:    .asciz "Error: Invalid input\n"
name_format:  .asciz "%63s"      // Limit name to 63 chars + null terminator
grade_format: .asciz "%d"
student_name: .space 64          // 64 bytes for name string
average:      .space 4           // 4 bytes for integer (aligned)
A_str:        .asciz "A"
B_str:        .asciz "B"
C_str:        .asciz "C"
F_str:        .asciz "F"

.text
.global main
main:
    // Save registers (8-byte stack alignment)
    PUSH {r4, r5, r6, r7, lr}

    // Prompt for name
    LDR r0, =prompt
    BL printf

    // Get name input
    LDR r0, =name_format
    LDR r1, =student_name
    BL scanf
    CMP r0, #1                  // Check if scanf read one item
    BNE error

    // Prompt for grade
    LDR r0, =prompt_grade
    BL printf

    // Get grade input
    LDR r0, =grade_format
    LDR r1, =average
    BL scanf
    CMP r0, #1                  // Check if scanf read one item
    BNE error

    // Load average value
    LDR r4, =average
    LDR r4, [r4]                // r4 = average

    // Validate grade range
    CMP r4, #0
    BLT error
    CMP r4, #100
    BGT error

    // Determine grade
    CMP r4, #90
    BGE grade_A
    CMP r4, #80
    BGE grade_B
    CMP r4, #70
    BGE grade_C
    B grade_F                   // Default case

grade_A:
    LDR r5, =A_str
    B print_result

grade_B:
    LDR r5, =B_str
    B print_result

grade_C:
    LDR r5, =C_str
    B print_result

grade_F:
    LDR r5, =F_str
    B print_result

print_result:
    LDR r0, =output          // Format string
    LDR r1, =student_name    // Name address
    MOV r2, r5               // Grade string address
    BL printf
    B exit

error:
    LDR r0, =error_msg
    BL printf
    B exit

exit:
    // Restore registers and exit
    POP {r4, r5, r6, r7, lr}
    MOV r0, #0               // Return 0
    MOV r7, #1               // Syscall: exit
    SVC #0
