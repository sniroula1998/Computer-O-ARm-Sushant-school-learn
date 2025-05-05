
.global is_prime
.global gcd
.global mod
.global divide
.global mod_mul
.global mod_pow
.global cpubexp
.global calc_private_key
.global encrypt_char
.global decrypt_char

.section .data
    prompte: .asciz "\nEnter your public key exponent e: "  
    format: .asciz "%d"  
    error_msg: .asciz "\nSelected e does not meet criteria: "  
    output_msg: .asciz "Valid e: %d\n"  
    e_value: .word 0

.section .text
.align 2

@ Function to divide (r0 / r1), returns quotient in r0
divide:
    push {r4-r7, lr}    
    mov r4, r0          
    mov r5, r1          
    mov r6, #0          

divide_loop:
    cmp r4, r5          
    blt divide_done     
    sub r4, r4, r5      
    add r6, r6, #1      
    b divide_loop       

divide_done:
    mov r0, r6          
    pop {r4-r7, pc}     

@ Function to get remainder (r0 % r1)
mod:
    push {r4-r7, lr}    
    mov r4, r0          
    mov r5, r1          

mod_loop:
    cmp r4, r5          
    blt mod_done        
    sub r4, r4, r5      
    b mod_loop          

mod_done:
    mov r0, r4          
    pop {r4-r7, pc}     

@ Function to check if number is prime
is_prime:
    push {r4-r7, lr}    
    mov r4, r0          
    cmp r4, #1          
    ble not_prime_ret   
    
    mov r5, #2          
prime_loop:
    cmp r5, r4          
    beq is_prime_ret    
    
    mov r0, r4          
    mov r1, r5          
    bl mod              
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
    mov r4, r0          
    mov r5, r1          

gcd_loop:
    cmp r5, #0          
    beq gcd_done        
    
    mov r0, r4          
    mov r1, r5
    bl mod              
    mov r6, r4          
    mov r4, r5          
    mov r5, r0          
    b gcd_loop

gcd_done:
    mov r0, r4          
    pop {r4-r7, pc}

@ Function for modular multiplication
mod_mul:
    push {r4-r7, lr}    
    mov r4, r0          
    mov r5, r1          
    mov r6, r2          
    
    mul r7, r4, r5      
    mov r0, r7          
    mov r1, r6
    bl mod              
    
    pop {r4-r7, pc}     

@ Function for modular exponentiation
mod_pow:
    push {r4-r8, lr}    
    mov r4, r0          
    mov r5, r1          
    mov r6, r2          
    mov r7, #1          

mod_pow_loop:
    cmp r5, #0          
    beq mod_pow_done    
    
    tst r5, #1          
    beq mod_pow_even    
    
    mov r0, r7          
    mov r1, r4
    mov r2, r6
    bl mod_mul          
    mov r7, r0

mod_pow_even:
    mov r0, r4          
    mov r1, r4
    mov r2, r6
    bl mod_mul          
    mov r4, r0
    
    lsr r5, r5, #1      
    b mod_pow_loop

mod_pow_done:
    mov r0, r7          
    pop {r4-r8, pc}     

@ Function to calculate public exponent
cpubexp:
    push {r4-r7, lr}    
    mov r5, r0          

cpubexp_loop:
    ldr r0, =prompte    
    bl printf  
    ldr r0, =format     
    ldr r1, =e_value    
    bl scanf  
    ldr r1, =e_value    
    ldr r1, [r1]  
    mov r4, r1          
    cmp r1, #1          
    ble invalid_e  
    cmp r1, r5          
    bge invalid_e  
    mov r0, r4
    mov r2, r5          
    bl gcd  
    cmp r0, #1          
    bne invalid_e  
    b find_e_success  

invalid_e:  
    ldr r0, =error_msg  
    bl printf  
    b cpubexp_loop      

find_e_success:  
    mov r0, r4          
    pop {r4-r7, pc}     

@ Function to calculate private key
calc_private_key:
    push {r4-r7, lr}    
    mov r4, r0          @ e
    mov r5, r1          @ totient
    mov r6, #1          @ d
    mov r7, #0          @ k

private_loop:
    add r7, r7, #1      
    mul r0, r7, r5      
    add r0, r0, #1      
    mov r1, r4          
    bl mod              
    cmp r0, #0
    bne private_loop    
    
    mul r0, r7, r5      
    add r0, r0, #1
    mov r1, r4
    bl divide
    
    pop {r4-r7, pc}     

@ Function to encrypt a character
encrypt_char:
    push {r4-r7, lr}    
    mov r4, r0          @ character
    mov r5, r1          @ e
    mov r6, r2          @ n
    
    mov r0, r4          
    mov r1, r5          
    mov r2, r6          
    bl mod_pow          
    
    pop {r4-r7, pc}     

@ Function to decrypt a character
decrypt_char:
    push {r4-r7, lr}    
    mov r4, r0          @ encrypted value
    mov r5, r1          @ d
    mov r6, r2          @ n
    
    mov r0, r4          
    mov r1, r5          
    mov r2, r6          
    bl mod_pow          
    
    pop {r4-r7, pc} 
