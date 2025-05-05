.global main
.extern scanf
.extern printf
.extern getchar
.extern is_prime
.extern gcd
.extern mod
.extern divide
.extern mod_mul
.extern mod_pow
.extern cpubexp
.extern calc_private_key
.extern encrypt_char
.extern decrypt_char

.data
    @ Menu Prompts
    menu_header: .asciz "\n=== RSA Encryption System ===\n"
    menu_1: .asciz "1. Generate New Keys\n"
    menu_2: .asciz "2. Encrypt Message\n"
    menu_3: .asciz "3. Decrypt Message\n"
    menu_4: .asciz "4. Exit\n"
    menu_choice: .asciz "Enter your choice (1-4): "
    menu_invalid: .asciz "Invalid choice. Please try again.\n"
    no_keys: .asciz "Please generate keys first (Option 1).\n"
    no_message: .asciz "Please encrypt a message first (Option 2).\n"

    @ RSA-related prompts
    p_prompt: .asciz "Enter first prime number (p < 50): "
    q_prompt: .asciz "Enter second prime number (q < 50): "
    not_prime: .asciz "Number is not prime. Try again.\n"
    keys_msg: .asciz "\nGenerated Keys:\n"
    pub_key: .asciz "Public Key (n,e): (%d,%d)\n"
    priv_key: .asciz "Private Key (n,d): (%d,%d)\n"
    msg_prompt: .asciz "Enter message (text): "
    msg_encrypted: .asciz "\nEncrypted (numeric): "
    msg_decrypted: .asciz "\nDecrypted (text): "
    format_str: .asciz "%s"
    format_char: .asciz "%c"
    format_int: .asciz "%d "
    format_num: .asciz "%d"
    newline: .asciz "\n"

    @ Storage variables
    .align 4
    buffer: .skip 1024
    encrypted: .skip 1024
    p: .word 0
    q: .word 0
    n: .word 0
    e: .word 0
    d: .word 0
    totient: .word 0
    keys_generated: .word 0
    message_encrypted: .word 0
    message_length: .word 0

.text
.align 2

@ Function to display menu
display_menu:
    push {lr}
    ldr r0, =menu_header
    bl printf
    ldr r0, =menu_1
    bl printf
    ldr r0, =menu_2
    bl printf
    ldr r0, =menu_3
    bl printf
    ldr r0, =menu_4
    bl printf
    ldr r0, =menu_choice
    bl printf
    pop {pc}

main:
    push {r4-r11, lr}

menu_loop:
    bl display_menu

    @ Get menu choice
    ldr r0, =format_num
    sub sp, sp, #4
    mov r1, sp
    bl scanf
    ldr r4, [sp]
    add sp, sp, #4

    bl getchar

    cmp r4, #1
    beq generate_keys
    cmp r4, #2
    beq encrypt_message
    cmp r4, #3
    beq decrypt_message
    cmp r4, #4
    beq exit_program

    ldr r0, =menu_invalid
    bl printf
    b menu_loop

generate_keys:
get_p:
    ldr r0, =p_prompt
    bl printf

    ldr r0, =format_num
    ldr r1, =p
    bl scanf
    
    ldr r0, =p
    ldr r0, [r0]
    bl is_prime
    cmp r0, #0
    beq p_not_prime
    b get_q

p_not_prime:
    ldr r0, =not_prime
    bl printf
    b get_p

get_q:
    ldr r0, =q_prompt
    bl printf

    ldr r0, =format_num
    ldr r1, =q
    bl scanf
    
    ldr r0, =q
    ldr r0, [r0]
    bl is_prime
    cmp r0, #0
    beq q_not_prime
    b calculate_keys

q_not_prime:
    ldr r0, =not_prime
    bl printf
    b get_q

calculate_keys:
    @ Calculate n = p * q
    ldr r0, =p
    ldr r0, [r0]
    ldr r1, =q
    ldr r1, [r1]
    mul r2, r0, r1
    ldr r3, =n
    str r2, [r3]

    @ Calculate totient
    sub r0, r0, #1
    sub r1, r1, #1
    mul r2, r0, r1
    ldr r3, =totient
    str r2, [r3]

    @ Get public exponent
    mov r0, r2
    bl cpubexp
    ldr r3, =e
    str r0, [r3]

    @ Calculate private key
    ldr r1, =totient
    ldr r1, [r1]
    bl calc_private_key
    ldr r3, =d
    str r0, [r3]

    @ Display keys
    ldr r0, =keys_msg
    bl printf
    
    ldr r0, =pub_key
    ldr r1, =n
    ldr r1, [r1]
    ldr r2, =e
    ldr r2, [r2]
    bl printf
    
    ldr r0, =priv_key
    ldr r1, =n
    ldr r1, [r1]
    ldr r2, =d
    ldr r2, [r2]
    bl printf

    @ Set flags
    ldr r0, =keys_generated
    mov r1, #1
    str r1, [r0]

    ldr r0, =message_encrypted
    mov r1, #0
    str r1, [r0]

    b menu_loop

encrypt_message:
    @ Check for keys
    ldr r0, =keys_generated
    ldr r0, [r0]
    cmp r0, #0
    beq no_keys_error

    @ Get message
    ldr r0, =msg_prompt
    bl printf

    ldr r4, =buffer
    mov r5, #0

read_loop:
    bl getchar
    cmp r0, #10
    beq read_done
    cmp r0, #-1
    beq read_done
    strb r0, [r4, r5]
    add r5, r5, #1
    b read_loop

read_done:
    ldr r0, =message_length
    str r5, [r0]

    ldr r0, =msg_encrypted
    bl printf

    mov r5, #0
    ldr r6, =encrypted
    ldr r7, =e
    ldr r7, [r7]
    ldr r8, =n
    ldr r8, [r8]

encrypt_loop:
    ldr r0, =message_length
    ldr r0, [r0]
    cmp r5, r0
    beq encrypt_done

    ldrb r0, [r4, r5]
    mov r1, r7
    mov r2, r8
    bl encrypt_char
    str r0, [r6, r5, lsl #2]
    
    mov r1, r0
    ldr r0, =format_int
    bl printf
    
    add r5, r5, #1
    b encrypt_loop

encrypt_done:
    ldr r0, =message_encrypted
    mov r1, #1
    str r1, [r0]

    ldr r0, =newline
    bl printf
    b menu_loop

decrypt_message:
    @ Check for encrypted message
    ldr r0, =message_encrypted
    ldr r0, [r0]
    cmp r0, #0
    beq no_message_error

    ldr r0, =msg_decrypted
    bl printf

    mov r5, #0
    ldr r6, =encrypted
    ldr r7, =d
    ldr r7, [r7]
    ldr r8, =n
    ldr r8, [r8]
    ldr r9, =message_length
    ldr r9, [r9]

decrypt_loop:
    cmp r5, r9
    beq decrypt_done
    
    ldr r0, [r6, r5, lsl #2]
    mov r1, r7
    mov r2, r8
    bl decrypt_char
    
    mov r1, r0
    ldr r0, =format_char
    bl printf
    
    add r5, r5, #1
    b decrypt_loop

decrypt_done:
    ldr r0, =newline
    bl printf
    b menu_loop

no_keys_error:
    ldr r0, =no_keys
    bl printf
    b menu_loop

no_message_error:
    ldr r0, =no_message
    bl printf
    b menu_loop

exit_program:
    ldr r0, =newline
    bl printf
    pop {r4-r11, lr}
    mov r0, #0
    bx lr
