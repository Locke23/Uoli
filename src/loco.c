#include "api_robot.h"
int main(int args, char **argv) {
    Vector3* a;
    get_current_GPS_position(a);
    if(a->x > 730){
        set_engine_torque(30,30);
    }
    return 0;
    // int a = get_us_distance();
    // if(a > 0){
    //     set_torque(30,30);
    // } else {
    //    set_torque(100,100);
    // }
}