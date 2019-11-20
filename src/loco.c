#include "api_robot.h"
int main(int args, char **argv) {
    Vector3* a;
    get_current_GPS_position(a);
    if(a->x > 730){
        set_engine_torque(30,30);
    }
    return 0;
}