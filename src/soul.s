.globl _start
.equ INTERRUPCAO_GPT, 0xFFFF0100 #define quanto tempo esperar ate a proxima interrupcao. Caso seja 0, nao tera interrupcoes
.equ MOTOR_TOP, 0xFFFF001C
.equ MOTOR_MID, 0xFFFF001D
.equ MOTOR_BASE, 0xFFFF001E
.equ ULTRASSOM, 0xFFFF0024
.equ POSICAO_UOLI_X, 0xFFFF0008
.equ POSICAO_UOLI_Y, 0xFFFF000C
.equ POSICAO_UOLI_Z, 0xFFFF0010
.equ ANGULOS_ROTACAO_UOLI, 0xFFFF0014
.equ TORQUE_MOTOR_1, 0xFFFF001A
.equ TORQUE_MOTOR_2, 0xFFFF0018
.equ ANGULO_MOTOR_TOP, 0xFFFF001C
.equ ANGULO_MOTOR_MID, 0xFFFF001D
.equ ANGULO_MOTOR_BASE, 0xFFFF001E
.equ ESCRITA_UART, 0xFFFF0109 #escreve alguma informacao na saida padrao
.equ LEITURA_UART, 0xFFFF010B #le alguma informacao da saida padrao

.equ FLAG_POSICAO_UOLI, 0xFFFF0004 #setar pra 0 quando quiser comecar a ler a posicao do robo. vira 1 quando terminar
.equ FLAG_ULTRASSOM, 0xFFFF0020 #seta pra 0 quando quiser comecar a fazer a leitura do ultrassom
.equ FLAG_INTERRUPCAO_GPT, 0xFFFF0104 # é setado pra 1 quando ha uma interrupcao nao tratada do gpt
.equ FLAG_ESCRITA_UART, 0xFFFF0108 # seta pra 1 pra comecar o processo de escrita
.equ FLAG_LEITURA_UART, 0xFFFF010A # seta ra 1 pra comecar o processo de leitura

int_handler:
    #tratamento de interrupcoes
######################################################################################    
    #salva o contexto
    csrrw t0, mscratch, t0 #troca o valor de t0 com mscratch
    sw a0, 0(t0)
    sw a1, 4(t0)
    sw a2, 8(t0)
    sw a3, 12(t0)
    sw a4, 16(t0)
    sw a5, 20(t0)
    sw a6, 24(t0)
    sw a7, 28(t0)
    
    sw t1, 32(t0)
    sw t2, 36(t0)
    sw t3, 40(t0)
    sw t4, 44(t0)
    sw t5, 48(t0)
    sw t6, 52(t0)
    
    sw s0, 56(t0)
    sw s1, 60(t0)
    sw s2, 64(t0)
    sw s3, 68(t0)
    sw s4, 72(t0)
    sw s5, 76(t0)
    sw s6, 80(t0)
    sw s7, 84(t0)
    sw s8, 88(t0)
    sw s9, 92(t0)
    sw s10, 96(t0)
    sw s11, 100(t0)
######################################################################################    
    #causa da interrupcao
    csrr t2, mcause
    bltz t2, sys_gpt
    #Tratamento das interrupcoes
    li t1, 16
    beq t1, a7, sys_read_ultrasonic_sensor
    li t1, 17
    beq t1, a7, sys_set_servo_angles
    li t1, 18
    beq t1, a7, sys_set_engine_torque
    li t1, 19
    beq t1, a7, sys_read_gps
    li t1, 20
    beq t1, a7, sys_read_gyroscope
    li t1, 21
    beq t1, a7, sys_get_time
    li t1, 22
    beq t1, a7, sys_set_time
    li t1, 64
    beq t1, a7, sys_write
######################################################################################    

    sys_write:
        li t3, 0 #i=0
        la t1, ESCRITA_UART
        while_not_EOT:
        add t2, a1, t3 #string[i] - address
        lbu t2, 0(t2) #valor string[i]
        sb t2, 0(t1) #escreve byte em escrita_uart
        wait_sys_write:
            lbu t5, 0(t1)
            bne t5, t2, wait_sys_write #verifica se foi escrito
        li t4, 1
        la t5, FLAG_ESCRITA_UART
        sb t4, 0(t5)
        flag_sys_write:
            lb t4, 0(t5)
            bnez t4, flag_sys_write #aguarda a uart estar pronta pra proxima operacao
        addi t3, t3, 1 #i++
        beqz t2, fim
        blt t3, a2, while_not_EOT

    j fim
######################################################################################    

    sys_read_ultrasonic_sensor:
        la t1, FLAG_ULTRASSOM
        sw zero, 0(t1)
        while_ultrassom:
            lw t2, 0(t1)
            beqz t2, while_ultrassom
        la a1, ULTRASSOM
        lw a0, 0(a1)
        j fim
######################################################################################    

    sys_set_servo_angles:
    #verifica o valor de a0
        li t1, 0
        beq a0, t1, motor_base
        li t1, 1
        beq a0, t1, motor_mid
        li t1, 2
        beq a0, t1, motor_top
        #id do motor servo invalido
        li a0, -2
        j fim
        motor_base:
            #se(a1 < 16 ou a1 > 166) angulo_servo_invalido
            li t1, 16
            blt a1, t1, angulo_servo_invalido
            li t1, 116
            bgt a1, t1, angulo_servo_invalido
            mv a0, a1
            la a1, MOTOR_BASE
            sb a0, 0(a1)
            wait_motor_base:
                lb a2, 0(a1)
                bne a2, a0, wait_motor_base
            j fim
        motor_mid:
            li t1, 52
            blt a1, t1, angulo_servo_invalido
            li t1, 90
            bgt a1, t1, angulo_servo_invalido
            mv a0, a1
            la a1, MOTOR_MID
            sb a0, 0(a1)
            wait_motor_mid:
                lb a2, 0(a1)
                bne a2, a0, wait_motor_mid
            j fim
        motor_top:
            li t1, 0
            blt a1, t1, angulo_servo_invalido
            li t1, 156
            bgt a1, t1, angulo_servo_invalido
            mv a0, a1
            la a1, MOTOR_TOP
            sb a0, 0(a1)
            wait_motor_top:
                lb a2, 0(a1)
                bne a2, a0, wait_motor_top
            j fim
        angulo_servo_invalido:
            li a0, -1
            j fim
######################################################################################    

    sys_set_engine_torque:
        #verifica id do motor
        beqz a0, torque_motor_1
        li t1, 1
        beq a0, t1, torque_motor_2
        #id do motor invalido
        li a0, -1
        j fim
        torque_motor_1:
            mv a0, a1
            la a1, TORQUE_MOTOR_1
            sh a0, 0(a1)
            
            mv a0, zero
            j fim
        torque_motor_2:
            mv a0, a1
            la a1, TORQUE_MOTOR_2
            sh a0, 0(a1)

            mv a0, zero
            j fim
######################################################################################    

    sys_read_gps:
        la t1, FLAG_POSICAO_UOLI
        sw zero, 0(t1)
        while_posicao:
            lw t2, 0(t1)
            beqz t2, while_posicao #verifica se os valores do gps ja estao disponiveis
            
        la a1, POSICAO_UOLI_X
        lw a2, 0(a1)
        sw a2, 0(a0)
        wait_posicao_x:
            lw a3, 0(a0)
            bne a2, a3, wait_posicao_x#verifica se o valor gravado esta certo
        
        la a1, POSICAO_UOLI_Y
        lw a2, 0(a1)
        sw a2, 4(a0)
        wait_posicao_y:
            lw a3, 4(a0)
            bne a2, a3, wait_posicao_y

        la a1, POSICAO_UOLI_Z
        lw a2, 0(a1)
        sw a2, 8(a0)
        wait_posicao_z:
            lw a3, 8(a0)
            bne a2, a3, wait_posicao_z

    j fim
######################################################################################    

    sys_read_gyroscope:
        la t1, FLAG_POSICAO_UOLI
        sw zero, 0(t1)
        while_gyroscope:
            lw t3, 0(t1)
            bnez t3, while_gyroscope #espera os valores estarem disponiveis
        
        la t1, ANGULOS_ROTACAO_UOLI
        lw t2, 0(t1)
        
        srli t3, t2, 20 
        sw t3, 0(a0) #grava o valor de x
        
        srli t3, t2, 10
        andi t3, t3, 1023
        sw t3, 4(a0) #grava o valor de y

        andi t2, t2, 1023
        sw t2, 8(a0) #grava o valor de z
        
        j fim
######################################################################################    

    sys_get_time:
        la a0, sys_time
        lw a0, 0(a0)
        j fim
######################################################################################    

    sys_set_time:
        la a1, sys_time
        sw a0, 0(a1)
        j fim
######################################################################################    

    sys_gpt:
        la a1, FLAG_INTERRUPCAO_GPT
        lw a0, 0(a1)
        beqz a0, fim
        la a1, sys_time
        lw a0, 0(a1)
        addi a0, a0, 100
        sw a0, 0(a1)
        li a0, 100 #interrupcoes a cada 100 ms
        la a1, INTERRUPCAO_GPT
        sw a0, 0(a1)
        wait_sure_gpt:
            lw a2, 0(a1)
            bne a0, a2, wait_sure_gpt
        la a1, FLAG_INTERRUPCAO_GPT
        sw zero, 0(a1) #seta zero para indicar que a interrupcao foi tratada
        wait_flag_gpt:
            lw a2, 0(a1)
            bnez a2, wait_flag_gpt
        j fim_gpt #interrupcoes do gpt nao devem ajustar o endereco de retorno
######################################################################################    

    fim:
    csrr t1, mepc  # carrega endereco de retorno (endereco da instrucao que invocou a syscall)
    addi t1, t1, 4 # soma 4 no endereco de retorno (para retornar para a ecall) 
    csrw mepc, t1  # armazena endereco de retorno de volta no mepc
######################################################################################    

    fim_gpt:
        #restaurando o contexto
        lw s11, 100(t0)
        lw s10, 96(t0)
        lw s9, 92(t0)
        lw s8, 88(t0)
        lw s7, 84(t0)
        lw s6, 80(t0)
        lw s5, 76(t0)
        lw s4, 72(t0)
        lw s3, 68(t0)
        lw s2, 64(t0)
        lw s1, 60(t0)
        lw s0, 56(t0)
        
        lw t6, 52(t0)
        lw t5, 48(t0)
        lw t4, 44(t0)
        lw t3, 40(t0)
        lw t2, 36(t0)
        lw t1, 32(t0)

        lw a7, 28(t0)
        lw a6, 24(t0)
        lw a5, 20(t0)
        lw a4, 16(t0)
        lw a3, 12(t0)
        lw a2, 8(t0)
        lw a1, 4(t0)
        csrrw t0, mscratch, t0 #troca o valor de t0 com mscratch
        mret           # Recuperar o restante do contexto (pc <- mepc)
######################################################################################    

_start:
    li a0, 100 #interrupcoes a cada 100 ms
    la a1, INTERRUPCAO_GPT
    sw a0, 0(a1)
    wait_1:
        lw a2, 0(a1)
        bne a2, a0, wait_1
    #seta torque dos motores pra zero
    li a0, 0
    la a1, TORQUE_MOTOR_1
    sh a0, 0(a1)
    wait_2:
        lh a2, 0(a1)
        bne a2, a0, wait_2
    li a0, 0
    la a1, TORQUE_MOTOR_2
    sh a0, 0(a1)
    wait_3:
        lh a2, 0(a1)
        bne a2, a0, wait_3
    
    li a0, 31
    la a1, MOTOR_BASE
    sb a0, 0(a1)
    wait_4:
        lb a2, 0(a1)
        bne a2, a0, wait_4
    
    li a0, 80
    la a1, MOTOR_MID
    sb a0, 0(a1)
    wait_5:
        lb a2, 0(a1)
        bne a2, a0, wait_5

    li a0, 78
    la a1, MOTOR_TOP
    sb a0, 0(a1)
    wait_6:
        lb a2, 0(a1)
        bne a2, a0, wait_6

    # Configura o tratador de interrupções
    la t0, int_handler # Grava o endereço do rótulo int_handler
    csrw mtvec, t0 # no registrador mtvec

    # Habilita Interrupções Global
    csrr t1, mstatus # Seta o bit 7 (MPIE)
    ori t1, t1, 0x80 # do registrador mstatus
    csrw mstatus, t1

    # Habilita Interrupções Externas
    csrr t1, mie # Seta o bit 11 (MEIE)
    li t2, 0x800 # do registrador mie
    or t1, t1, t2
    csrw mie, t1

    # Ajusta o mscratch
    la t1, reg_buffer # Coloca o endereço do buffer para salvar
    csrw mscratch, t1 # registradores em mscratch
    li t0, 4000
    add sp, sp, t0

    # Muda para o Modo de usuário
    csrr t1, mstatus # Seta os bits 11 e 12 (MPP)
    li t2, ~0x1800 # do registrador mstatus
    and t1, t1, t2 # com o valor 00
    csrw mstatus, t1
    
    la t0, main # Grava o endereço do rótulo user
    csrw mepc, t0 # no registrador mepc
    mret # PC <= MEPC; MIE <= MPIE; Muda modo para MPP

reg_buffer: .skip 124
sys_time: .word 0