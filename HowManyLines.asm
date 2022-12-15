;-------------------------------------------------------------------------------------
;
;   Count the number of lines (LF) in a file
;
;-------------------------------------------------------------------------------------

STDIN       equ 0           ; Code for standard input
STDOUT      equ 1           ; Code for standard output
SYS_READ    equ 0           ; System call for reading
SYS_OPEN    equ 2           ; System call for opening a file
SYS_LSEEK   equ 8           ; System call for repositioning read/write offset
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
    data        resb    BUFFER_SIZE         ; Reserve space for data read from the file. Threshold not imposed, so don't cross it
    filename    resb    100                 ; Reserve space for filename-input
    
section .data
    eof_reached     db      0                   ; Flag used to identify when end of file reached
    result          dd      0                   ; Used for storing the result
    prompt:         db      "Enter filename: "  ; Prompt-message for input
    prompt_size     equ     $-prompt            ; Prompt-message size
    message:        db      "Number of lines: " ; Message base
    message_size    equ     $-message           ; Base-message size
    ioerr_msg:      db      "IO-error!"         ; Message for reporting IO errors
    ioerr_msg_size  equ     $-message           ; IO-error message size
    file            dq      0                   ; For storing file descriptor of opened file
    current_index   dq      0                   ; Holds the index for seeking through the file

section .text
global _start

_start:
    printBytes prompt, 0, prompt_size   ; Print prompt for the input
    mov r9, 0                           ; Init counter for characters read from STDIN
    mov dword[result], 0

ReadCharacter:                          ; Loop to read characters one-by-one from input
    mov rax, SYS_READ                   ; System call is read
    mov rdi, STDIN                      ; Reading from standard input
    lea rsi, byte[filename + r9]        ; Specify address of the space reserved for filename
    mov rdx, 1                          ; Read one byte (=character) at a time
    syscall                             ; Make the call

    cmp byte[filename + r9], LF         ; Is the input character LF?
    je InitReadFile                     ;   If yes, stop reading
    inc r9                              ;   If not, increment character count
    jmp ReadCharacter                   ;   And read another character

InitReadFile:
    mov byte[filename + r9], NULL       ; Terminate the filename with NULL (required to read from it); NOTE: Writes over the LF ending the string
    mov rdi, filename                   ; Specify file to read
    mov rsi, O_RDONLY                   ; Mode: Read only
    mov rax, SYS_OPEN                   ; System call: file open
    syscall                             ; Execute system call
    
    mov qword[file], rax                ; Store file descriptor
    mov r9d, 0                          ; Init counter of LF occurences before filling the buffer for the first time

; We return to filling the buffer until eof_reached -flag's been set
FillBuffer:
    mov rdi, qword[file]                ; Specify the file we want to read from
    mov rsi, data                       ; Address where to store read data
    mov rdx, BUFFER_SIZE                ; Number of characters to read
    mov rax, SYS_READ                   ; System call: file read
    syscall                             ; Execute system call

    mov r10, qword[current_index]       ; Get current index
    add r10, rax                        ; Add the number of read characters
    mov qword[current_index], r10       ; ..to store the current index after reading

    cmp rax, 0                          ; Check if IO-failed
    jl IOError                          ; If so, jump to error handler

    cmp rax, BUFFER_SIZE                ; Did we reach EOF? Let's find out by comparing number read characters to buffer size.
    je SetupCounter                     ;   If the number of read characters is equal to BUFFER_SIZE, we did not. So skip setting the flag.
    mov byte[eof_reached], 1            ;   We reached EOF, set flag.

SetupCounter:
    mov r8, -1                           ; Init counter
    
Counter:                                ; Start of loop. Loop by decrementing counter    
    inc r8                              ; Increment loop counter
    cmp r8, rax                         ; Have we reached the end of the loop?
    je EOFReachedOrNot                  ; If we have, break out of the loop
    cmp byte[data + r8], LF             ; Is the current byte equal to LF?
    jne Counter                         ;   No? continue to next
    inc r9d                             ;   Yes? increment LF-counter
    jmp Counter                         ; Continue to next iteration

EOFReachedOrNot:                        ; To check if EOF's been reached and whether or not refill the buffer and count again
    cmp byte[eof_reached], 1            ; Is EOF-flag set?
    je Output                           ;   Yes? Go to output
                                        ;   No? Go back and read more characters after repositioning the reader
    mov r10, 1                          ; Create file offset: It's one +
    add r10, BUFFER_SIZE                ; .. BUFFER_SIZE
    mov rsi, r10                        ; Prep system call by storing offset
    mov rdx, qword[current_index]       ; and origin
    mov rax, SYS_LSEEK                  ; Sys call: Reposition file read offset
    syscall                             ; Make the call
    jmp FillBuffer                      ; Back to filling the buffer


Output:
    printBytes message, 0, message_size ; Use macro to print base-message
    mov edi,r9d                         ; Set the value of the LF-counter as a parameter for the function
    call PrintInteger                   ; Print the count (appending it to the message)

    mov dil, LF                         ; Print new line to wrap up
    call PrintASCII                     ; Function call to print the character
Exit:
    mov       rax, 60               ; System call for exit
    xor       rdi, 0                ; Set exit code 0 for success
    syscall                         ; Make the call

IOError:    
    printBytes ioerr_msg, 0, ioerr_msg_size ; Use macro to print err-message
    mov     rdi, 0                          ; Set exit code 1 for fail
    mov     rax, 60                         ; System call for exit
    syscall                                 ; Make the call
    