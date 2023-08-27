;-------------------------------------------------------------------------------------
;
;   Two functions:
;       - Count the number of bits set in a 32-bit little endian integer
;       - Calculate to power of difference of two doubles
;   
;-------------------------------------------------------------------------------------

section   .data
section   .bss
section   .text

global onebits
onebits:
    ; edi has the first argument, ie. the 32-bits of which we wil count the one's that are set
    ; To find out the bits set we
    ; AND with a 32-int of value 1 (the first bit is set)
    ; Increment the coiunter with the result
    ; RIGHT SHIFT the value by one
    mov edx, edi
    mov ebx, 1
    mov r11d, 0     ; Init loop counter
    mov r12d, 0     ; Init bit counter
loop:
    and ebx, edx
    add r12d, ebx
    mov ebx, 1
    shr edx, 1
    inc r11d
    cmp r11d, 32
    jle loop

    mov eax, r12d
    ret


global power_of_difference
power_of_difference:
    ; Calculates (x - y) ** b
    ; xmm0 has the 1st argument: x, a double
    ; xmm1 has the 2n  argument: y, a double
    ; rdi  has the 3rd argument: b, a signed 8-bit integer
    ; Returns: a 64-bit floating point value

    subsd xmm0, xmm1        ; x - y
    mov rax, 1              ; Init values for negative power loop
    cvtsi2sd xmm1, rax      ; Convert 1 to double
    cmp edi, 0              ; Check if exponent is negative
    jl negativepowerloop    ; If so, jump to negativepowerloop
    movsd xmm1, xmm0        ; Make a copy of initial value of x-y for multiplying

powerloop:
    ; raise to power b by looping and multiplying with self

    mulsd xmm0, xmm1        ; Multiply
    dec rdi                 ; Decrement counter (the value of b orinally)
    cmp rdi, 1              ; Loop check
    jg  powerloop           ; Return to loop beginning if b > 1
    jmp finish              ; Done. Jump to finish


negativepowerloop:
    ; Divide 1 until b is zero or more

    divsd xmm1, xmm0        ; Division
    inc edi                 ; Increment loop counter (the value of b)
    cmp edi, 0              ; Loop check
    jl  negativepowerloop   ; Return to loop beginnin if b < 0
    movsd xmm0, xmm1        ; Move result to xmm0 so it's returned

finish:
    ret                     ; Return to caller