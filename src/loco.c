#include "api_robot.h"
char* itoa(int value, char* result, int base) {
    // check that the base if valid
    if (base < 2 || base > 36) { *result = '\0'; return result; }

    char* ptr = result, *ptr1 = result, tmp_char;
    int tmp_value;

    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
    } while ( value );

    // Apply negative sign
    if (tmp_value < 0) *ptr++ = '-';
    *ptr-- = '\0';
    while(ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr--= *ptr1;
        *ptr1++ = tmp_char;
    }
    return result;
}
void turn_left(int wait){
  
    get_time();
    // char *a;
    // itoa(i,a,10);
    // puts(a);
    // set_torque(20,-20);
    // int time = get_time();
    // while(time < 100){
        // time = get_time();
    // }    
    // set_torque(0,0);

}
int main(int args, char **argv) {
    char* oi = "ALOALO";
    puts(oi);
    int i = get_time();
    char* a;
    itoa(i,a,10);
    puts(a);

    return 0;
}