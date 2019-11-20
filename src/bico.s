.globl set_engine_torque
.globl set_torque



set_torque:
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
    #retorna o contexto
    ret

set_engine_torque:
    li a7, 18
    ecall
    ret
