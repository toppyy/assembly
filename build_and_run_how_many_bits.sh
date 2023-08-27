nasm  -f elf64 /home/toby/Documents/projects/assembly/HowManyBitsAndPowerOfDifference.asm -o out/HowManyBitsAndPowerOfDifference.o && 
    gcc -g -Wall -c HowManyBitsAndPowerOfDifferenceTest.c && 
    gcc -g -o bits.out HowManyBitsAndPowerOfDifferenceTest.o ./out/HowManyBitsAndPowerOfDifference.o && 
    ./bits.out
