;-------------------------------------------------------------------------------------
;
;   Count the number of lines (LF) in a file
;
;-------------------------------------------------------------------------------------

STDIN       equ 0           ; Code for standard input
STDOUT      equ 1           ; Code for standard output
SYS_WRITE   equ 1           ; System call for writing
SYS_READ    equ 0           ; System call for reading
SYS_OPEN    equ 2           ; System call for opening a file
O_RDONLY    equ 000000q     ; Read only -flag for reading files; zero, but base8 representation advised(?)
BUFFER_SIZE equ 100000      ; How many bytes are read from the file
LF          equ 10          ; ASCII-code for line feed (= newline)
NULL        equ 0           ; ASCII-code for NULL

%macro printBytes 3                   ; %1 = address of string to output, %2 = byte offset, %3 = number of bytes
    mov       rax, 1                  ; System call for write
    mov       rdi, 1                  ; File handle 1 is stdout
    mov       rsi, %1                 ; Address of string to output
    add       rsi, %2                 ; Byte offset
    mov       rdx, %3                 ; Number of bytes to write
    syscall                           ; Invoke operating system to do the write
%endmacro

extern PrintInteger
extern PrintASCII

section .bss
    data        resb    BUFFER_SIZE  ; Reserve space for data read from the file. Threshold not imposed, so don't cross it
    filename    resb    100          ; Reserve space for filename-input

section .data
    prompt:     db "Enter filename: "              ; Prompt-message for input
    prompt_size equ $-prompt                       ; Prompt-message size
    message:    db "Number of lines: "             ; Message base
    message_size equ $-message                     ; Base-message size
section .text
global _start

_start:
    printBytes prompt, 0, prompt_size   ; Print prompt for the input
    mov r9, 0                           ; Init counter for characters read from STDIN
ReadCharacter:                          ; Loop to read characters one-by-one from input
    mov rax, SYS_READ                   ; System call is read
    mov rdi, STDIN                      ; Reading from standard input
    lea rsi, byte[filename + r9]        ; Specify address of the space reserved for filename
    mov rdx, 1                          ; Read one byte (=character) at a time
    syscall                             ; Make the call

    cmp byte[filename + r9], LF         ; Is the input character LF?
    je FileNameRead                     ;   If yes, stop reading
    inc r9                              ;   If not, increment character count
    jmp ReadCharacter                   ;   And read another character

FileNameRead:
    mov byte[filename + r9], NULL       ; Terminate the filename with NULL (required to read from it); NOTE: Writes over the LF ending the string
    mov rdi, filename                   ; Specify file to read
    mov rsi, O_RDONLY                   ; Read only
    mov rax, SYS_OPEN                   ; Specify file open system call
    syscall                             ; Execute system call
    
    mov rdi, rax            ; Rax has the file descriptor for opened file
    mov rsi, data           ; Address where to store read data
    mov rdx, BUFFER_SIZE    ; Number of characters to read
    mov rax, SYS_READ       ; Specify read system call
    syscall                 ; Execute system call

    mov r8, BUFFER_SIZE     ; Counter for loop iterating the data
    mov r9d, 0              ; Counter of LF occurences

Counter:                    ; Start of loop. Iterate BUFFER from end to start
    dec r8                  ; Decrement loop counter
    cmp r8, 0               ; Have we reached the end of the loop?
    je Output               ; If we have, break out of the loop
    cmp byte[data + r8], LF ; Is the current byte equal to LF?
    jne Counter             ;   If not, continue to next
    inc r9d                 ;   If yes, increment LF-counter
    jmp Counter             ; Continue to next iteration

Output:
    printBytes message, 0, message_size ; Use macro to print base-message
    mov edi, r9d                        ; Set the value of the LF-counter as a parameter
    call PrintInteger                   ; Print the count (appending it to the message)
    mov dil, LF                         ; Print new line to wrap up
    call PrintASCII                     ; Function call to print the character
Exit:
    mov       rax, 60               ; System call for exit
    xor       rdi, 0                ; Set exit code 0 for success
    syscall                         ; Make the call