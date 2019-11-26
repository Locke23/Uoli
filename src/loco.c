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

void girar_90graus( int i  ) {
    //0 -> direita 
    //1-> esquerda
    Vector3 *angles;
    Vector3 *new;
    get_gyro_angles(angles);
    get_gyro_angles(new);

    if( i == 0){
        set_torque(10,-10);
        while(new->y != angles->y + 90){
            get_gyro_angles(new);
        }
        set_torque(0,0);
    }
    else{
        set_torque(-10,10);
        while(new->y != angles->y - 90){
            get_gyro_angles(new);
        }
        set_torque(0,0);
    }
}


int main(int args, char **argv) {
    girar_90graus(0);

    return 0;
}
