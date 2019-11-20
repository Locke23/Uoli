.globl set_engine_torque
.globl set_torque
.globl set_head_servo
.globl get_us_distance
.globl get_current_GPS_position
.globl get_gyro_angles
.globl get_time
.globl set_time

#############################################################################################
set_torque:
    li t1, 100
    bgt a0, t1, erroRange # if a1 > t1 then target

    li t1, -100
    blt a0, t1, erroTorque # if a1 < t1 then target

     li t1, 100
    bgt a1, t1, erroTorque # if a1 > t1 then target

    li t1, -100
    blt a1, t1, erroTorque # if a1 < t1 then target
    
    #passagem de parametros
    mv s0, a0
    mv s1, a1
    #seta o torque do motor 0
    li a0, 0
    mv a1, s0
    jal set_engine_torque
    #seta o torque do motor 1
    li a0, 1
    li a1, s1
    jal set_engine_torque
    j fim1
    erroTorque:
        li a0, -1
        j fim1
    #retorna o contexto
    fim1:
        ret
#############################################################################################

set_engine_torque:
    
    li t1, 100
    bgt a1, t1, erroRange # if a1 > t1 then target

    li t1, -100
    blt a1, t1, erroRange # if a1 < t1 then target
    
    li a7, 18
    ecall

    li t1, -1
    beq a0, t1,  erroID # if a0 == t1 then target
    
    erroID:
        li a0, -2
        j fim  # jump to fim

    erroRange:
        li a0, -1
        j fim

    fim:
        ret
#############################################################################################

set_head_servo:
    jal set_servo_angles
    
    beqz a0, fimAngle
    
    li t0, -1
    beq a0, t0, trata

    li a0, -1
    j fimAngle

    trata:
        li a0, -2

    fimAngle:
    ret

#############################################################################################

set_servo_angles:
    
    li a7, 17
    ecall
    ret