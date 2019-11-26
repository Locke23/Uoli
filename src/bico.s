.globl set_engine_torque
.globl set_torque
.globl set_head_servo
.globl get_us_distance
.globl get_current_GPS_position
.globl get_gyro_angles
.globl get_time
.globl set_time
.globl puts
#############################################################################################
set_torque:
    addi sp, sp, -12 # Aloca espaço da pilha
    sw ra, 8(sp)
    sw s0, 4(sp) # Salva s0 na pilha
    sw s1, 0(sp) # Salva s1 na pilha
    
    li t1, 100
    bgt a0, t1, erroRange1 # if a1 > t1 then target

    li t1, -100
    blt a0, t1, erroRange1 # if a1 < t1 then target

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
    mv a1, s1
    jal set_engine_torque
   
    j fimTorque

    erroRange1:
        li a0, -2
        j fimTorque

    erroTorque:
        li a0, -1
        j fimTorque
    #retorna o contexto
    fimTorque:
        lw s1, 0(sp) # Recupera s2 da pilha
        lw s0, 4(sp) # Recupera s1 da pilha
        lw ra, 8(sp)
        addi sp, sp, 8 # Desaloca espaço da pilha
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
#############################################################################################

get_us_distance:
    li a7, 16
    ecall
    li a1, -1
    bne a0, a1, fim_distance
    li a0, 0xFFFF
    fim_distance:
    ret
#############################################################################################

get_current_GPS_position:
    li a7, 19
    ecall
    ret
#############################################################################################

get_gyro_angles:
    li a7, 20
    ecall 
    ret
#############################################################################################

get_time:
    li a7, 21
    ecall
    ret
#############################################################################################
set_time:
    li a7, 22
    ecall
    ret
#############################################################################################
puts:
    li a2, 0
    mv t1, a0
    while_puts:
        lbu t0, 0(t1)
        addi a2, a2, 1
        add t1, a0, a2
        bnez t0, while_puts
    li a7, 64
    mv a1, a0
    li a0, 0
    ecall
    ret


