#include "api_robot.h"

int main(int args, char **argv)
{
    while(get_us_distance() > 600){
        set_torque(90,90);
    }
    return 0;
    // int a = get_us_distance();
    // if(a > 0){
    //     set_torque(30,30);
    // } else {
    //    set_torque(100,100);
    // }
}