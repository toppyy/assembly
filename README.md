# x86 assembly programming

Attempts to program in assembly language. The language is for [NASM](https://www.nasm.us) assembler. 

## Programs

### HowManyLines.asm
Counts the number of lines (= LF-characters) in a file. The filename is prompted. The "last line" is not included (last byte of file is not LF). The input is buffered in as 100 000 character chunks. Needs to be linked with `ASCII.asm` (see below).

To assemble under `out/`:

    mkdir -p out
    nasm -f elf64 ASCII.asm -o out/ASCII.o
    nasm -f elf64 HowManyLines.asm -o out/HowManyLines.o

Link, create object file:

    ld -o out/HowManyLines.out out/ASCII.o out/HowManyLines.o

Run it:

    out/HowManyLines.out

(`.vscode/tasks.json` has some scripts ready for VSCode)

### ASCII.asm

Utilify functions for 
- converting integers to ASCII-codes
- printing ASCII-characters.


## Some sources:
 - [NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial) by Ray Toal
 - [x86-64 Assembly Language Programming with Ubuntu](http://www.egr.unlv.edu/~ed/x86.html). For [YASM](https://yasm.tortall.net/), but great(!) free(!) book anyways

