
.global main
.extern scanf
.extern printf
.extern getchar
 
.data
   @ Menu Prompts - Strings used for user interface
   menu_header: .asciz "\n=== RSA Encryption System ===\n"
   menu_1: .asciz "1. Generate New Keys\n"
   menu_2: .asciz "2. Encrypt Message\n"
   menu_3: .asciz "3. Decrypt Message\n"
   menu_4: .asciz "4. Exit\n"
   menu_choice: .asciz "Enter your choice (1-4): "
   menu_invalid: .asciz "Invalid choice. Please try again.\n"
   no_keys: .asciz "Please generate keys first (Option 1).\n"
   no_message: .asciz "Please encrypt a message first (Option 2).\n"
 
   @ RSA-related prompts and messages
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
 
   @ Storage variables for RSA calculations
   .align 4
   buffer: .skip 1024          @ Buffer for storing input message
   encrypted: .skip 1024       @ Buffer for storing encrypted message
   p: .word 0                  @ First prime number
   q: .word 0                  @ Second prime number
   n: .word 0                  @ Modulus (n = p * q)
   e: .word 0                  @ Public exponent
   e_value: .word 0           @ Temporary storage for e value
   d: .word 0                  @ Private exponent
   totient: .word 0           @ Euler's totient (p-1)*(q-1)
   keys_generated: .word 0     @ Flag indicating if keys are generated
   message_encrypted: .word 0  @ Flag indicating if message is encrypted
   message_length: .word 0     @ Length of the current message
 
.text
.align 2
@ Function to divide (r0 / r1), returns quotient in r0
@ Implements division through repeated subtraction
divide:
   push {r4-r7, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = Dividend (numerator)
   mov r5, r1          @ r5 = Divisor (denominator)
   mov r6, #0          @ r6 = Quotient (initialize to 0)
 
divide_loop:
   cmp r4, r5          @ Compare dividend with divisor
   blt divide_done     @ If dividend < divisor, division is complete
   sub r4, r4, r5      @ Subtract divisor from dividend
   add r6, r6, #1      @ Increment quotient
   b divide_loop       @ Continue division
 
divide_done:
   mov r0, r6          @ Move quotient to r0 for return
   pop {r4-r7, pc}     @ Restore registers and return
 
@ Function to get remainder (r0 % r1), returns remainder in r0
@ Implements modulo through repeated subtraction
mod:
   push {r4-r7, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = Dividend
   mov r5, r1          @ r5 = Divisor
 
mod_loop:
   cmp r4, r5          @ Compare dividend with divisor
   blt mod_done        @ If dividend < divisor, remainder found
   sub r4, r4, r5      @ Subtract divisor from dividend
   b mod_loop          @ Continue until remainder found
 
mod_done:
   mov r0, r4          @ Move remainder to r0 for return
   pop {r4-r7, pc}     @ Restore registers and return
 
@ Function to check if number is prime
@ Returns 1 if prime, 0 if not prime
is_prime:
   push {r4-r7, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = Number to check
   cmp r4, #1          @ Check if number is less than or equal to 1
   ble not_prime_ret   @ If so, not prime
   
   mov r5, #2          @ r5 = Counter starting at 2
prime_loop:
   cmp r5, r4          @ Compare counter with number
   beq is_prime_ret    @ If equal, number is prime
   
   mov r0, r4          @ Setup for mod operation
   mov r1, r5          @ Divisor = counter
   bl mod              @ Check if number is divisible by counter
   cmp r0, #0          @ If remainder is 0
   beq not_prime_ret   @ Number is not prime
   
   add r5, r5, #1      @ Increment counter
   b prime_loop        @ Continue checking
 
is_prime_ret:
   mov r0, #1          @ Return 1 (true, is prime)
   pop {r4-r7, pc}
 
not_prime_ret:
   mov r0, #0          @ Return 0 (false, not prime)
   pop {r4-r7, pc}
 
@ Function to calculate Greatest Common Divisor (GCD)
@ Uses Euclidean algorithm
gcd:
   push {r4-r7, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = First number
   mov r5, r1          @ r5 = Second number
 
gcd_loop:
   cmp r5, #0          @ Check if second number is 0
   beq gcd_done        @ If so, GCD found
   
   mov r0, r4          @ Setup for mod operation
   mov r1, r5
   bl mod              @ Calculate remainder
   mov r6, r4          @ Save old first number
   mov r4, r5          @ First number becomes second number
   mov r5, r0          @ Second number becomes remainder
   b gcd_loop
 
gcd_done:
   mov r0, r4          @ Move result to r0 for return
   pop {r4-r7, pc}
@ Function to perform modular multiplication (a * b % n)
@ Prevents overflow by using modulo after multiplication
mod_mul:
   push {r4-r7, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = a (first number)
   mov r5, r1          @ r5 = b (second number)
   mov r6, r2          @ r6 = n (modulus)
   
   mul r7, r4, r5      @ r7 = a * b
   mov r0, r7          @ Setup for mod operation
   mov r1, r6
   bl mod              @ Calculate (a * b) % n
   
   pop {r4-r7, pc}     @ Restore registers and return
 
@ Function to perform modular exponentiation (a^b mod n)
@ Uses square-and-multiply algorithm to efficiently calculate large powers
mod_pow:
   push {r4-r8, lr}    @ Save registers and link register
   mov r4, r0          @ r4 = base (a)
   mov r5, r1          @ r5 = exponent (b)
   mov r6, r2          @ r6 = modulus (n)
   mov r7, #1          @ r7 = result, initialize to 1
 
mod_pow_loop:
   cmp r5, #0          @ Check if exponent is zero
   beq mod_pow_done    @ If so, we're done
   
   tst r5, #1          @ Test if exponent is odd (check least significant bit)
   beq mod_pow_even    @ If even, skip multiplication step
   
   @ If odd, multiply result by base (modulo n)
   mov r0, r7          @ Setup for mod_mul
   mov r1, r4
   mov r2, r6
   bl mod_mul          @ result = (result * base) % modulus
   mov r7, r0
 
mod_pow_even:
   @ Square the base (modulo n)
   mov r0, r4          @ Setup for mod_mul
   mov r1, r4
   mov r2, r6
   bl mod_mul          @ base = (base * base) % modulus
   mov r4, r0
   
   lsr r5, r5, #1      @ Divide exponent by 2 (right shift)
   b mod_pow_loop
 
mod_pow_done:
   mov r0, r7          @ Move final result to r0
   pop {r4-r8, pc}     @ Restore registers and return
 
@ Function to calculate public exponent (e)
@ Ensures e is coprime with totient
cpubexp:
   SUB sp, sp, #4      @ Allocate stack space
   STR lr, [sp]        @ Save link register
   mov r5, r0          @ r5 = totient

cpubexp_loop:
    ldr r0, =prompte   @ Prompt for e value
    bl printf  
    ldr r0, =format    @ Setup for scanf
    ldr r1, =e_value   @ Store input in e_value
    bl scanf  
    ldr r1, =e_value   @ Load input value
    ldr r1, [r1]  
    mov r4, r1         @ Save e value in r4
    cmp r1, #1         @ Check if e > 1
    ble invalid_e  
    cmp r1, r5         @ Check if e < totient
    bge invalid_e  
    mov r2, r5         @ Setup for GCD calculation
    bl gcd  
    cmp r1, #1         @ Check if e is coprime with totient
    bne invalid_e  
    b find_e_success  

invalid_e:  
    ldr r0, =error_msg @ Print error message
    bl printf  
    b cpubexp_loop     @ Try again
 
find_e_success:  
    mov r1, r4         @ Move valid e value to r1
    ldr r0, =output_msg
    bl printf  
    ldr lr, [sp]       @ Restore link register
    add sp, sp, #4     @ Deallocate stack space
    mov pc, lr         @ Return
@ Function to calculate private key exponent (d)
@ Finds d such that (d * e) mod totient = 1
calc_private_key:
   SUB sp, sp, #4      @ Allocate stack space
   STR lr, [sp]        @ Save link register
   mov r6, #1          @ r6 = d (initialize)
   mov r7, #0          @ r7 = k (counter)
 
private_loop:
   add r7, r7, #1      @ Increment k
   mul r0, r7, r5      @ r0 = k * totient
   add r0, r0, #1      @ r0 = k * totient + 1
   mov r1, r4          @ r1 = e (public exponent)
   bl mod              @ Check if (k * totient + 1) % e == 0
   cmp r0, #0
   bne private_loop    @ If not zero, try next k
   
   mul r0, r7, r5      @ Calculate d = (k * totient + 1) / e
   add r0, r0, #1
   mov r1, r4
   bl divide
   mov r6, r0          @ Store result in r6 (private key d)
   
   ldr lr, [sp]        @ Restore link register
   add sp, sp, #4      @ Deallocate stack space
   mov pc, lr          @ Return
 
@ Function to encrypt a single character
@ Uses formula: encrypted = char^e mod n
encrypt_char:
   push {r4-r9, lr}    @ Save registers
   mov r7, r0          @ r7 = character to encrypt
   ldr r8, =e          @ Load public exponent
   ldr r8, [r8]
   ldr r9, =n          @ Load modulus
   ldr r9, [r9]
   
   mov r0, r7          @ Setup for mod_pow
   mov r1, r8          @ exponent (e)
   mov r2, r9          @ modulus (n)
   bl mod_pow          @ Calculate (char^e) mod n
   
   pop {r4-r9, pc}     @ Restore registers and return
 
@ Function to decrypt a single number
@ Uses formula: decrypted = encrypted^d mod n
decrypt_char:
   push {r4-r9, lr}    @ Save registers
   mov r7, r0          @ r7 = number to decrypt
   ldr r8, =d          @ Load private exponent
   ldr r8, [r8]
   ldr r9, =n          @ Load modulus
   ldr r9, [r9]
   
   mov r0, r7          @ Setup for mod_pow
   mov r1, r8          @ exponent (d)
   mov r2, r9          @ modulus (n)
   bl mod_pow          @ Calculate (encrypted^d) mod n
   
   pop {r4-r9, pc}     @ Restore registers and return
 
@ Function to display menu options
display_menu:
   push {lr}           @ Save link register
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
   pop {pc}            @ Return
main:
   push {r4-r11, lr}   @ Save registers and link register

menu_loop:
   bl display_menu     @ Show menu options

   @ Get user's menu choice
   ldr r0, =format_num
   sub sp, sp, #4      @ Allocate space for input
   mov r1, sp          @ Point to allocated space
   bl scanf
   ldr r4, [sp]        @ r4 = user's choice
   add sp, sp, #4      @ Clean up stack

   @ Clear input buffer
   bl getchar

   @ Branch to appropriate section based on menu choice
   cmp r4, #1
   beq generate_keys
   cmp r4, #2
   beq encrypt_message
   cmp r4, #3
   beq decrypt_message
   cmp r4, #4
   beq exit_program

   @ Handle invalid choice
   ldr r0, =menu_invalid
   bl printf
   b menu_loop

generate_keys:
   @ Get and validate first prime number (p)
get_p:
   ldr r0, =p_prompt
   bl printf

   ldr r0, =format_num
   ldr r1, =p
   bl scanf
   
   ldr r0, =p          @ Check if p is prime
   ldr r0, [r0]
   bl is_prime
   cmp r0, #0
   beq p_not_prime
   b get_q

p_not_prime:
   ldr r0, =not_prime
   bl printf
   b get_p

   @ Get and validate second prime number (q)
get_q:
   ldr r0, =q_prompt
   bl printf

   ldr r0, =format_num
   ldr r1, =q
   bl scanf
   
   ldr r0, =q          @ Check if q is prime
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
   mul r2, r0, r1      @ r2 = p * q
   ldr r3, =n
   str r2, [r3]        @ Store n

   @ Calculate totient = (p-1)(q-1)
   sub r0, r0, #1      @ p-1
   sub r1, r1, #1      @ q-1
   mul r2, r0, r1      @ r2 = (p-1)(q-1)
   ldr r3, =totient
   str r2, [r3]        @ Store totient

   @ Get public exponent e
   mov r0, r2          @ Pass totient as parameter
   bl cpubexp
   ldr r3, =e
   str r4, [r3]        @ Store e value

   @ Calculate private exponent d
   mov r0, r4          @ e value
   mov r1, r5          @ totient
   bl calc_private_key
   ldr r3, =d
   str r6, [r3]        @ Store d value

   @ Display the generated keys
   ldr r0, =keys_msg
   bl printf
   mov r2, r4          @ e value
   ldr r0, =pub_key
   ldr r1, =n
   ldr r1, [r1]
   bl printf
   mov r2, r6          @ d value
   ldr r0, =priv_key
   ldr r1, =n
   ldr r1, [r1]
   bl printf

   @ Set flags
   ldr r0, =keys_generated
   mov r1, #1
   str r1, [r0]        @ Set keys generated flag

   ldr r0, =message_encrypted
   mov r1, #0
   str r1, [r0]        @ Reset message encrypted flag

   ldr r0, =message_length
   mov r1, #0
   str r1, [r0]        @ Reset message length

   b menu_loop

encrypt_message:
   @ Check if keys exist
   ldr r0, =keys_generated
   ldr r0, [r0]
   cmp r0, #0
   beq no_keys_error

   @ Get message to encrypt
   ldr r0, =msg_prompt
   bl printf

   @ Read message character by character
   ldr r4, =buffer     @ Input buffer
   mov r5, #0          @ Character counter

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

   @ Display encryption header
   ldr r0, =msg_encrypted
   bl printf

   @ Encrypt each character
   mov r5, #0          @ Reset counter
   ldr r6, =encrypted  @ Encrypted values buffer

encrypt_loop:
   ldr r0, =message_length
   ldr r0, [r0]
   cmp r5, r0          @ Check if done
   beq encrypt_done

   ldrb r0, [r4, r5]   @ Load character
   bl encrypt_char     @ Encrypt it
   str r0, [r6, r5, lsl #2]  @ Store encrypted value
   
   mov r1, r0          @ Print encrypted value
   ldr r0, =format_int
   bl printf
   
   add r5, r5, #1      @ Next character
   b encrypt_loop

encrypt_done:
   @ Set encrypted flag
   ldr r0, =message_encrypted
   mov r1, #1
   str r1, [r0]

   ldr r0, =newline
   bl printf
   b menu_loop

decrypt_message:
   @ Check if message exists
   ldr r0, =message_encrypted
   ldr r0, [r0]
   cmp r0, #0
   beq no_message_error

   @ Display decryption header
   ldr r0, =msg_decrypted
   bl printf

   @ Get message length
   ldr r0, =message_length
   ldr r7, [r0]

   @ Decrypt each value
   mov r5, #0          @ Reset counter
   ldr r6, =encrypted  @ Load encrypted values

decrypt_loop:
   cmp r5, r7          @ Check if done
   beq decrypt_done
   
   ldr r0, [r6, r5, lsl #2]  @ Load encrypted value
   bl decrypt_char     @ Decrypt it
   
   mov r1, r0          @ Print decrypted character
   ldr r0, =format_char
   bl printf
   
   add r5, r5, #1      @ Next value
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
   pop {r4-r11, lr}    @ Restore registers
   mov r0, #0          @ Return 0
   bx lr               @ Exit program
