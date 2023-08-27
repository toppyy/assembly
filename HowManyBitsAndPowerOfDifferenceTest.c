#include<stdio.h>
#include<stdint.h>
#include <assert.h>

// Assignments from https://cs.lmu.edu/~ray/classes/sp/assignment/5/

uint32_t onebits(int32_t x);
double power_of_difference(double x, double y, int b);


int main() {
    
    // How many bits are set? (does not follow Ray's instructions but counts the sum of bits one-by-one)
    assert(onebits(0) == 0);
    assert(onebits(-1) == 32);
    assert(onebits(0x264b743d) == 16);
    assert(onebits(0x12345678) == 13);
    puts("onebits: All tests passed");

    // Take to doubles, calculate the difference and take power
    assert(power_of_difference(5, 5, 20) == 0);
    assert(power_of_difference(50, 45, 10) == 9765625);    
    assert(power_of_difference(206, 204, 20) == 1048576);    
    assert(power_of_difference(206, 204, -3) == 0.125);
    assert(power_of_difference(-30, -26, -4) == 0.00390625);
    assert(power_of_difference(16.5, 15, 3) == 3.375);
    puts("power_of_difference: All tests passed");

    return 0;
}


