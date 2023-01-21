;-------------------------------------------------------------------------------------
;
;   Find all prime numbers up to N
;   Uses the Sieve of Eratosthenes for finding primes
;
;-------------------------------------------------------------------------------------

LF          equ 10
STDIN       equ 0         ; Code for standard input
STDOUT      equ 1         ; Code for standard output
N           equ 1000000   ; Number up to which primes are printed

%macro printIntegerAndLF 1
    mov edi, %1
    call PrintInteger
    mov dil, LF
    call PrintASCII
%endmacro

%macro mPrintASCII 1
    mov edi, %1
    call PrintASCII
%endmacro


%macro mPrintInteger 1
    mov edi, %1
    call PrintInteger
%endmacro

%macro divideInt 2
    mov eax, %1                 ; %1 = dividend
    cdq                         ; convert dword in eax to qword in edx:eax
    idiv %2                     ; %2 = divisor
    ;mov dword[remainder], edx;  ; store remainder
    ;mov dword[quotient],  eax;  ; store quotient
%endmacro


extern PrintInteger         ; Helper function for printing an integer
extern PrintASCII           ; Helper function for printing an ASCII-character

section .bss
    numbers        resd    N   ; Reserve space for N 32-bit integers
    removed        resd    N   ; Keep track which numbers are not primes

section .data
    number      dd 55
    cursor      dd 0
    bytecount   dq 0

section .text
global _start

_start:
    ; Init numbers from 2 to N and removed-array to zeroes
    mov ebp, 0
    mov r12d, 2

    ; Calculate the number of bytes reserved for the numbers
    mov eax, N
    mov edi, 4
    mul edi
    mov dword[bytecount], eax
    mov dword[bytecount + 4], edx
    
InitLoop:
    mov dword[numbers + ebp], r12d
    mov dword[removed + ebp], 0
    add ebp, 4
    inc r12d
    cmp r12d, N
    jle InitLoop

    mov r14d, 0      ; ecx will work as the "cursor"

OuterLoop:

    mov ebp, dword[numbers + r14d]                     ; ebp will hold the *value* pointed by the cursor ecx
    mov edx, dword[removed + r14d]
    cmp edx, 1
    je OuterLoopNext
    printIntegerAndLF ebp

    ; -------------- InnerLoop: All numbers that can be divided by cursor are marked as removed ----
InitInnerLoop:
    mov r12d, r14d                                ; Init byte counter for loop
    ; Store number of bytes to increment in r13d
    ; That is: current number * 4
    mov eax, ebp
    mov r13d, 4
    mul r13d        
    mov r13d, eax ; NOTE: This fail when the result of the multiplication is over 32bits (the result is in edx:eax)

InnerLoop:
    add r12d, r13d
    cmp r12d, dword[bytecount]
    jge OuterLoopNext
    mov dword[removed + r12d], 1            ; Mark as removed

    jmp InnerLoop
    ; -------------- InnerLoop: Done -----------------------------------------------------------------

 OuterLoopNext:
    cmp ebp, N
    je Finish
    
    add r14d, 4
    jmp OuterLoop


Finish:
    mov dil, LF                         ; Print new line to wrap up
    call PrintASCII                     ; Function call to print the character
    
Exit:
    mov       rax, 60               ; System call for exit
    xor       rdi, 0                ; Set exit code 0 for success
    syscall                         ; Make the call
