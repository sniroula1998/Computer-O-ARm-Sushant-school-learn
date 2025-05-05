.global main
.extern scanf
.extern printf
.extern getchar
 
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
 
   @ RSA Prompts
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
   prompte: .asciz "\nEnter your public key exponent e: "  
   format: .asciz "%d"  
   error_msg: .asciz "\nSelected e does not meet criteria: "  
   debug_msg: .asciz "Code works till here %d\n"  
   debug_msg2: .asciz "Before modulo: a=%d, b=%d\n"  
   output_msg: .asciz "Valid e: %d\n"  
 
   @ Storage
   .align 4
   buffer: .skip 1024
   encrypted: .skip 1024
   p: .word 0
   q: .word 0
   n: .word 0
   e: .word 0
   e_value: .word 0
   d: .word 0
   totient: .word 0
   keys_generated: .word 0
   message_encrypted: .word 0
   message_length: .word 0
 
.text
.align 2
 
@ Function to divide (r0 / r1), returns quotient in r0
divide:
   push {r4-r7, lr}
   mov r4, r0          @ Dividend
   mov r5, r1          @ Divisor
   mov r6, #0          @ Quotient
 
divide_loop:
   cmp r4, r5
   blt divide_done
   sub r4, r4, r5
   add r6, r6, #1
   b divide_loop
 
divide_done:
   mov r0, r6          @ Return quotient
   pop {r4-r7, pc}
 
@ Function to get remainder (r0 % r1), returns remainder in r0
mod:
   push {r4-r7, lr}
   mov r4, r0          @ Dividend
   mov r5, r1          @ Divisor
 
mod_loop:
   cmp r4, r5
   blt mod_done
   sub r4, r4, r5
   b mod_loop
 
mod_done:
   mov r0, r4          @ Return remainder
   pop {r4-r7, pc}
 
@ Function to check if number is prime
is_prime:
   push {r4-r7, lr}
   mov r4, r0          @ Number to check
   cmp r4, #1
   ble not_prime_ret
   
   mov r5, #2          @ Counter
prime_loop:
   cmp r5, r4
   beq is_prime_ret
   
   mov r0, r4
   mov r1, r5
   bl mod              @ Check if r4 is divisible by r5
   cmp r0, #0
   beq not_prime_ret
   
   add r5, r5, #1
   b prime_loop
 
is_prime_ret:
   mov r0, #1
   pop {r4-r7, pc}
 
not_prime_ret:
   mov r0, #0
   pop {r4-r7, pc}
 
@ Function to calculate GCD
gcd:
   push {r4-r7, lr}
   mov r4, r0          @ First number
   mov r5, r1          @ Second number
 
gcd_loop:
   cmp r5, #0
   beq gcd_done
   
   mov r0, r4
   mov r1, r5
   bl mod              @ Calculate remainder
   mov r6, r4          @ Save old value
   mov r4, r5          @ Update values
   mov r5, r0          @ Store remainder
   b gcd_loop
 
gcd_done:
   mov r0, r4
   pop {r4-r7, pc}
 
@ Function to perform modular multiplication (a * b % n)
mod_mul:
   push {r4-r7, lr}
   mov r4, r0          @ a
   mov r5, r1          @ b
   mov r6, r2          @ n
   
   mul r7, r4, r5      @ a * b
   mov r0, r7
   mov r1, r6
   bl mod              @ (a * b) % n
   
   pop {r4-r7, pc}
 
@ Function to perform modular exponentiation (a^b mod n)
mod_pow:
   push {r4-r8, lr}
   mov r4, r0          @ base (a)
   mov r5, r1          @ exponent (b)
   mov r6, r2          @ modulus (n)
   mov r7, #1          @ result
 
mod_pow_loop:
   cmp r5, #0
   beq mod_pow_done
   
   tst r5, #1          @ Test if exponent is odd
   beq mod_pow_even
   
   @ result = (result * base) % modulus
   mov r0, r7
   mov r1, r4
   mov r2, r6
   bl mod_mul
   mov r7, r0
 
mod_pow_even:
   @ base = (base * base) % modulus
   mov r0, r4
   mov r1, r4
   mov r2, r6
   bl mod_mul
   mov r4, r0
   
   lsr r5, r5, #1      @ exponent = exponent / 2
   b mod_pow_loop
 
mod_pow_done:
   mov r0, r7          @ Return result
   pop {r4-r8, pc}
 
@ Function to calculate public exponent
cpubexp:
   SUB sp, sp, #4
   STR lr, [sp]
   mov r5, r0          @ totient

cpubexp_loop:
    ldr r0, =prompte  
    bl printf  
    ldr r0, =format  
    ldr r1, =e_value @ e value  
    bl scanf  
    ldr r1, =e_value  
    ldr r1, [r1]  
    mov r4, r1  
    cmp r1, #1  
    ble invalid_e  
    cmp r1, r5  
    bge invalid_e  
    mov r2, r5  
    bl gcd  
    cmp r1, #1  
    bne invalid_e  
    b find_e_success  

invalid_e:  
    ldr r0, =error_msg  
    bl printf  
    b cpubexp_loop  

find_e_success:  
    mov r1, r4  
    ldr r0, =output_msg  
    bl printf  
    ldr lr, [sp]  
    add sp, sp, #4  
    mov pc, lr  

@ Function to calculate private key exponent
calc_private_key:
   SUB sp, sp, #4
   STR lr, [sp]
   mov r6, #1          @ d
   mov r7, #0          @ k
 
private_loop:
   add r7, r7, #1
   mul r0, r7, r5      @ k * totient
   add r0, r0, #1      @ k * totient + 1
   mov r1, r4
   bl mod              @ (k * totient + 1) % e
   cmp r0, #0
   bne private_loop
   
   mul r0, r7, r5
   add r0, r0, #1
   mov r1, r4
   bl divide           @ (k * totient + 1) / e
   mov r6, r0
   
   ldr lr, [sp]  
   add sp, sp, #4  
   mov pc, lr  
 
@ Function to encrypt a single character
encrypt_char:
   push {r4-r9, lr}
   mov r7, r0          @ character
   ldr r8, =e          @ public exponent
   ldr r8, [r8]
   ldr r9, =n          @ modulus
   ldr r9, [r9]
   
   mov r0, r7          @ base (character)
   mov r1, r8          @ exponent (e)
   mov r2, r9          @ modulus (n)
   bl mod_pow          @ Calculate (char^e) mod n
   
   pop {r4-r9, pc}
 
@ Function to decrypt a single number
decrypt_char:
   push {r4-r9, lr}
   mov r7, r0          @ encrypted number
   ldr r8, =d          @ private exponent
   ldr r8, [r8]
   ldr r9, =n          @ modulus
   ldr r9, [r9]
   
   mov r0, r7          @ base (encrypted number)
   mov r1, r8          @ exponent (d)
   mov r2, r9          @ modulus (n)
   bl mod_pow          @ Calculate (encrypted^d) mod n
   
   pop {r4-r9, pc}
 
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
   ldr r4, [sp]        @ r4 contains menu choice
   add sp, sp, #4
 
   @ Clear input buffer
   bl getchar
 
   @ Process menu choice
   cmp r4, #1
   beq generate_keys
   cmp r4, #2
   beq encrypt_message
   cmp r4, #3
   beq decrypt_message
   cmp r4, #4
   beq exit_program
 
   @ Invalid choice
   ldr r0, =menu_invalid
   bl printf
   b menu_loop
 
generate_keys:
   @ Generate new RSA keys
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
 
   @ Calculate totient = (p-1)(q-1)
   sub r0, r0, #1
   sub r1, r1, #1
   mul r2, r0, r1
   ldr r3, =totient
   str r2, [r3]
 
   @ Calculate public exponent e
   mov r0, r2
   bl cpubexp
   ldr r3, =e
   str r4, [r3]        @ Store e value
 
   @ Calculate private exponent d
   mov r0, r4          @ e
   mov r1, r5          @ totient
   bl calc_private_key
   ldr r3, =d
   str r6, [r3]        @ Store d value
 
   @ Display generated keys
   ldr r0, =keys_msg
   bl printf
   mov r2, r4
   ldr r0, =pub_key
   ldr r1, =n
   ldr r1, [r1]
   bl printf
   mov r2, r6
   ldr r0, =priv_key
   ldr r1, =n
   ldr r1, [r1]
   bl printf
 
   @ Set keys generated flag
   ldr r0, =keys_generated
   mov r1, #1
   str r1, [r0]
 
   @ Reset message encrypted flag
   ldr r0, =message_encrypted
   mov r1, #0
   str r1, [r0]
 
   @ Reset message length
   ldr r0, =message_length
   mov r1, #0
   str r1, [r0]
 
   b menu_loop
 
encrypt_message:
   @ Check if keys are generated
   ldr r0, =keys_generated
   ldr r0, [r0]
   cmp r0, #0
   beq no_keys_error
 
   @ Get and encrypt message
   ldr r0, =msg_prompt
   bl printf
 
   @ Clear input buffer
   bl getchar
 
   @ Read message
   ldr r4, =buffer     @ input buffer
   mov r5, #0          @ counter
 
read_loop:
   bl getchar
   cmp r0, #10         @ Check for newline
   beq read_done
   cmp r0, #-1         @ Check for EOF
   beq read_done
   strb r0, [r4, r5]   @ Store character
   add r5, r5, #1
   b read_loop
 
read_done:
   @ Save message length
   ldr r0, =message_length
   str r5, [r0]
 
   @ Print encrypted header
   ldr r0, =msg_encrypted
   bl printf
 
   @ Encrypt and print each character
   mov r5, #0          @ Reset counter
   ldr r6, =encrypted  @ Store encrypted values
 
encrypt_loop:
   ldr r0, =message_length
   ldr r0, [r0]
   cmp r5, r0
   beq encrypt_done
 
   ldrb r0, [r4, r5]   @ Load character
   bl encrypt_char     @ Encrypt character
   str r0, [r6, r5, lsl #2]  @ Store encrypted value
   
   mov r1, r0          @ Move encrypted value to r1
   ldr r0, =format_int
   bl printf
   
   add r5, r5, #1
   b encrypt_loop
 
encrypt_done:
   @ Set message encrypted flag
   ldr r0, =message_encrypted
   mov r1, #1
   str r1, [r0]
 
   ldr r0, =newline
   bl printf
   b menu_loop
 
decrypt_message:
   @ Check if message is encrypted
   ldr r0, =message_encrypted
   ldr r0, [r0]
   cmp r0, #0
   beq no_message_error
 
   @ Print decrypted header
   ldr r0, =msg_decrypted
   bl printf
 
   @ Get saved message length
   ldr r0, =message_length
   ldr r7, [r0]
 
   @ Decrypt and print message
   mov r5, #0          @ Reset counter
   ldr r6, =encrypted  @ Load encrypted values
 
decrypt_loop:
   cmp r5, r7
   beq decrypt_done
   
   ldr r0, [r6, r5, lsl #2]  @ Load encrypted value
   bl decrypt_char     @ Decrypt value
   
   mov r1, r0          @ Move decrypted character to r1
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
