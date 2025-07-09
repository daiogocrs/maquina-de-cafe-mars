.data
caminho_base: .asciiz "cupom_" 
extensao:     .asciiz ".txt"
nome_arquivo: .space 64

# Estoques e contador
contador:  .word 1 
cafe:      .word 20
leite:     .word 20
chocolate: .word 20
acucar:    .word 20

# --- DADOS PARA PRE�O ---
precos_base:   .word 200, 300, 400 # Pre�os em centavos para Cafe, Leite, Mocha
adicional_gde: .word 150           # Adicional para tamanho grande em centavos

# Mensagens (ASCII)
menu_principal: .asciiz "\n===== MAQUINA DE CAFE =====\nEscolha sua bebida:\n  1 - Cafe puro\n  2 - Cafe com Leite\n  3 - Mochaccino\n\n  5 - Reabastecer Estoque\n  0 - Sair\n\nOpcao: "
menu_reabastecer: .asciiz "\n--- MODO MANUTENCAO ---\nQual ingrediente reabastecer?\n  1 - Cafe\n  2 - Leite\n  3 - Chocolate\n  4 - Acucar\n\nOpcao: "
menu_tamanho:     .asciiz "Tamanho (p - pequeno | g - grande): "
menu_acucar:      .asciiz "Adicionar acucar? (s/n): "
msg_reabastecido: .asciiz "Ingrediente reabastecido com sucesso!\n"
msg_opcao_invalida: .asciiz "\n>>> Opcao invalida. Por favor, tente novamente.\n"
msg_saida:        .asciiz "\nObrigado por utilizar nossa maquina!\n"
erro_estoque:     .asciiz "Erro: Ingrediente insuficiente. Favor reabastecer.\n"
erro_arquivo:     .asciiz "Erro: Nao foi possivel criar o arquivo do cupom.\n"
preparando:       .asciiz "Preparando bebida...\n"
pronto:           .asciiz "Bebida pronta!\n"
salvando:         .asciiz "Gerando cupom...\n"

# Buffers e strings (ASCII)
input_buffer:   .space 8
cupom_conteudo: .space 256
num_buffer:     .space 16
temp_buffer:    .space 16
texto_bebida:   .asciiz "Bebida: "
texto_tamanho:  .asciiz "\nTamanho: "
texto_acucar:   .asciiz "\nAcucar: "
texto_preco:    .asciiz "\nPreco: R$ "
nome_cafe:      .asciiz "Cafe Puro"
nome_leite:     .asciiz "Cafe com Leite"
nome_mocha:     .asciiz "Mochaccino"
nome_pequeno:   .asciiz "Pequeno"
nome_grande:    .asciiz "Grande"
nome_sim:       .asciiz "Sim"
nome_nao:       .asciiz "Nao"
virgula:        .asciiz ","
zero_str:       .asciiz "0"

.text
.globl main

#=====================================================================
# ROTINA PRINCIPAL
#=====================================================================
main:
    # jal inicializar_estoques
    jal inicializar_contador

loop_menu_principal:
    li $v0, 4
    la $a0, menu_principal
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    
    beq $t0, 0, sair
    beq $t0, 5, reabastecer_estoque
    bgt $t0, 3, opcao_invalida
    blt $t0, 1, opcao_invalida
    
loop_tamanho:
    li $v0, 4
    la $a0, menu_tamanho
    syscall
    li $v0, 8
    la $a0, input_buffer
    li $a1, 4
    syscall
    lb $t1, input_buffer
    
    li $t7, 'p'
    beq $t1, $t7, loop_acucar
    li $t7, 'g'
    beq $t1, $t7, loop_acucar
    j opcao_invalida_e_volta_tamanho
    
loop_acucar:
    li $v0, 4
    la $a0, menu_acucar
    syscall
    li $v0, 8
    la $a0, input_buffer
    li $a1, 4
    syscall
    lb $t2, input_buffer

    li $t7, 's'
    beq $t2, $t7, checar_e_preparar
    li $t7, 'n'
    beq $t2, $t7, checar_e_preparar
    j opcao_invalida_e_volta_acucar

checar_e_preparar:
    jal verificar_estoque
    beq $v0, 0, preparar_bebida
    li $v0, 4
    la $a0, erro_estoque
    syscall
    j loop_menu_principal

opcao_invalida_e_volta_tamanho:
    li $v0, 4
    la $a0, msg_opcao_invalida
    syscall
    j loop_tamanho
    
opcao_invalida_e_volta_acucar:
    li $v0, 4
    la $a0, msg_opcao_invalida
    syscall
    j loop_acucar

opcao_invalida:
    li $v0, 4
    la $a0, msg_opcao_invalida
    syscall
    j loop_menu_principal

preparar_bebida:
    li $v0, 4
    la $a0, preparando
    syscall
    jal timer_bebida
    jal reduzir_estoque
    li $v0, 4
    la $a0, pronto
    syscall
    jal gerar_cupom
    j loop_menu_principal

sair:
    li $v0, 4
    la $a0, msg_saida
    syscall
    li $v0, 10
    syscall

######################################################################
# PROCEDIMENTO: inicializar_estoques
######################################################################
inicializar_estoques:
    li $t5, 20
    la $t6, cafe
    sw $t5, 0($t6)
    la $t6, leite
    sw $t5, 0($t6)
    la $t6, chocolate
    sw $t5, 0($t6)
    la $t6, acucar
    sw $t5, 0($t6)
    jr $ra

######################################################################
# PROCEDIMENTO: reabastecer_estoque
######################################################################
reabastecer_estoque:
    li $v0, 4
    la $a0, menu_reabastecer
    syscall
    li $v0, 5
    syscall
    move $t5, $v0
    li $t6, 20
    beq $t5, 1, repor_cafe
    beq $t5, 2, repor_leite
    beq $t5, 3, repor_chocolate
    beq $t5, 4, repor_acucar
    j opcao_invalida
repor_cafe:
    la $a0, cafe
    sw $t6, 0($a0)
    j repor_fim
repor_leite:
    la $a0, leite
    sw $t6, 0($a0)
    j repor_fim
repor_chocolate:
    la $a0, chocolate
    sw $t6, 0($a0)
    j repor_fim
repor_acucar:
    la $a0, acucar
    sw $t6, 0($a0)
repor_fim:
    li $v0, 4
    la $a0, msg_reabastecido
    syscall
    j loop_menu_principal

######################################################################
# PROCEDIMENTO: verificar_estoque
######################################################################
verificar_estoque:
    li $v0, 0
    li $t3, 'g'
    li $t4, 1
    beq $t1, $t3, dose_grande
    j check_doses
dose_grande:
    li $t4, 2
check_doses:
    la $t5, cafe
    la $t6, leite
    la $t7, chocolate
    la $t8, acucar
    lw $t9, 0($t5)
    blt $t9, $t4, estoque_falho
    beq $t0, 2, check_leite
    beq $t0, 3, check_leite_choc
    j check_acucar
check_leite:
    lw $t9, 0($t6)
    blt $t9, $t4, estoque_falho
    j check_acucar
check_leite_choc:
    lw $t9, 0($t6)
    blt $t9, $t4, estoque_falho
    lw $t9, 0($t7)
    blt $t9, $t4, estoque_falho
check_acucar:
    li $s0, 's'
    bne $t2, $s0, end_check
    lw $t9, 0($t8)
    blt $t9, $t4, estoque_falho
end_check:
    jr $ra
estoque_falho:
    li $v0, 1
    jr $ra

######################################################################
# PROCEDIMENTO: reduzir_estoque
######################################################################
reduzir_estoque:
    li $t3, 'g'
    li $t4, 1
    beq $t1, $t3, r_dose_grande
    j reduzir
r_dose_grande:
    li $t4, 2
reduzir:
    la $t5, cafe
    la $t6, leite
    la $t7, chocolate
    la $t8, acucar
    lw $t9, 0($t5)
    sub $t9, $t9, $t4
    sw $t9, 0($t5)
    beq $t0, 2, red_leite
    beq $t0, 3, red_leite_choc
    j red_acucar
red_leite:
    lw $t9, 0($t6)
    sub $t9, $t9, $t4
    sw $t9, 0($t6)
    j red_acucar
red_leite_choc:
    lw $t9, 0($t6)
    sub $t9, $t9, $t4
    sw $t9, 0($t6)
    lw $t9, 0($t7)
    sub $t9, $t9, $t4
    sw $t9, 0($t7)
    j red_acucar
red_acucar:
    li $s0, 's'
    bne $t2, $s0, end_red
    lw $t9, 0($t8)
    sub $t9, $t9, $t4
    sw $t9, 0($t8)
end_red:
    jr $ra

######################################################################
# PROCEDIMENTO: timer_bebida
######################################################################
timer_bebida:
    li   $t4, 1          
    li   $t3, 5         
    li   $t5, 'g'
    bne  $t1, $t5, t_calc_ingredientes
    li   $t4, 2           
    li   $t3, 10          
t_calc_ingredientes:
    add  $t3, $t3, $t4 
    beq  $t0, 1, t_check_chocolate
    add  $t3, $t3, $t4  
t_check_chocolate:
    bne  $t0, 3, t_check_acucar 
    add  $t3, $t3, $t4   
t_check_acucar:
    li   $t5, 's'
    bne  $t2, $t5, t_iniciar_timer 
    add  $t3, $t3, $t4 
t_iniciar_timer:
    move $t6, $t3
t_loop_timer:
    li   $v0, 30        
    syscall
    move $t7, $a0
wait_loop:
    li   $v0, 30          
    syscall
    sub  $t8, $a0, $t7
    li   $t9, 1000   
    blt  $t8, $t9, wait_loop
    subi $t6, $t6, 1
    bgtz $t6, t_loop_timer
    
    jr   $ra

######################################################################
# PROCEDIMENTO: gerar_cupom
######################################################################
gerar_cupom:
    addiu $sp, $sp, -44 
    sw $ra, 40($sp)
    sw $s0, 36($sp)
    sw $s1, 32($sp)
    sw $s2, 28($sp)
    sw $s3, 24($sp)
    sw $s4, 20($sp)
    sw $s5, 16($sp) 
    sw $t0, 12($sp) 
    sw $t1, 8($sp)  
    sw $t2, 4($sp)  

    li $v0, 4
    la $a0, salvando
    syscall
    
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)

    la $a0, nome_arquivo
    li $a1, 64
    jal zerar_buffer
    
    la $a0, nome_arquivo
    la $a1, caminho_base
    jal strcat
    
    lw $a0, contador
    la $a1, num_buffer
    jal int_to_ascii
    
    la $a0, nome_arquivo
    la $a1, num_buffer
    jal strcat
    
    la $a0, nome_arquivo
    la $a1, extensao
    jal strcat
    
    lw $s0, contador
    addi $s0, $s0, 1
    sw $s0, contador

    la $a0, cupom_conteudo
    li $a1, 256
    jal zerar_buffer

    la $a0, cupom_conteudo
    la $a1, texto_bebida
    jal strcat
    
    beq $s1, 1, set_bebida_cafe
    beq $s1, 2, set_bebida_leite
    la $a1, nome_mocha
    j append_nome_bebida
set_bebida_cafe:
    la $a1, nome_cafe
    j append_nome_bebida
set_bebida_leite:
    la $a1, nome_leite
append_nome_bebida:
    jal strcat

    la $a1, texto_tamanho
    jal strcat
    li $t7, 'g'
    bne $s2, $t7, set_tam_pequeno
    la $a1, nome_grande
    j append_nome_tamanho
set_tam_pequeno:
    la $a1, nome_pequeno
append_nome_tamanho:
    jal strcat

    la $a1, texto_acucar
    jal strcat
    li $t7, 's'
    bne $s3, $t7, set_acucar_nao
    la $a1, nome_sim
    j append_nome_acucar
set_acucar_nao:
    la $a1, nome_nao
append_nome_acucar:
    jal strcat
    
    la $a1, texto_preco
    jal strcat 
    
    move $s5, $a0
    
    move $a0, $s1
    move $a1, $s2
    jal calcular_preco
    move $a0, $v0
    la $a1, num_buffer
    jal formatar_preco
    
    move $a0, $s5
    la $a1, num_buffer
    jal strcat

    li $v0, 13
    la $a0, nome_arquivo
    li $a1, 1
    li $a2, 0
    syscall
    move $s4, $v0
    bltz $s4, erro_abertura_cupom

    la $a0, cupom_conteudo
    jal strlen
    move $a2, $v0

    li $v0, 15
    move $a0, $s4
    la $a1, cupom_conteudo
    syscall

    li $v0, 16
    move $a0, $s4
    syscall
    j fim_cupom

erro_abertura_cupom:
    li $v0, 4
    la $a0, erro_arquivo
    syscall

fim_cupom:
    lw $ra, 40($sp)
    lw $s0, 36($sp)
    lw $s1, 32($sp)
    lw $s2, 28($sp)
    lw $s3, 24($sp)
    lw $s4, 20($sp)
    lw $s5, 16($sp)
    lw $t0, 12($sp)
    lw $t1, 8($sp)
    lw $t2, 4($sp)
    addiu $sp, $sp, 44
    jr $ra

# --- PROCEDIMENTOS AUXILIARES ---

######################################################################
# PROCEDIMENTO: strlen
######################################################################
strlen:
    li $v0, 0
strlen_loop:
    lb $t0, 0($a0)
    beq $t0, $zero, strlen_end
    addi $a0, $a0, 1
    addi $v0, $v0, 1
    j strlen_loop
strlen_end:
    jr $ra

######################################################################
# PROCEDIMENTO: zerar_buffer
######################################################################
zerar_buffer:
    add $t8, $a0, $a1 
zerar_loop:
    beq $a0, $t8, zerar_end
    sb $zero, 0($a0)
    addi $a0, $a0, 1
    j zerar_loop
zerar_end:
    jr $ra

######################################################################
# PROCEDIMENTO: strcat (Concatena string)
######################################################################
strcat:
find_end_loop_strcat:
    lb $t8, 0($a0)
    beq $t8, $zero, copy_loop_strcat
    addiu $a0, $a0, 1
    j find_end_loop_strcat
copy_loop_strcat:
    lb $t9, 0($a1)
    sb $t9, 0($a0)
    beq $t9, $zero, strcat_done
    addiu $a0, $a0, 1
    addiu $a1, $a1, 1
    j copy_loop_strcat
strcat_done:
    jr $ra

######################################################################
# PROCEDIMENTO: int_to_ascii
######################################################################
int_to_ascii:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0
    move $s1, $a1
    move $a0, $s1
    li $a1, 12 
    jal zerar_buffer
    move $t0, $s0
    move $t1, $s1
    li $t3, 0
    bne $t0, $zero, i2a_main_loop
    li $t2, '0'
    sb $t2, 0($t1)
    addi $t1, $t1, 1
    j i2a_done_loop
i2a_main_loop:
    addi $t3, $t3, 1
    rem $t2, $t0, 10
    addi $t2, $t2, 48
    addiu $sp, $sp, -4
    sw $t2, 0($sp)
    div $t0, $t0, 10
    bnez $t0, i2a_main_loop
i2a_pop_loop:
    lw $t2, 0($sp)
    addiu $sp, $sp, 4
    sb $t2, 0($t1)
    addi $t1, $t1, 1
    addi $t3, $t3, -1
    bnez $t3, i2a_pop_loop
i2a_done_loop:
    sb $zero, 0($t1)
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addiu $sp, $sp, 12
    jr $ra

######################################################################
# PROCEDIMENTO: calcular_preco
######################################################################
calcular_preco:
    subi $a0, $a0, 1
    sll $a0, $a0, 2
    la $t5, precos_base
    add $t5, $t5, $a0
    lw $v0, 0($t5)
    li $t5, 'g'
    bne $a1, $t5, fim_calcular_preco
    lw $t6, adicional_gde
    add $v0, $v0, $t6
fim_calcular_preco:
    jr $ra

######################################################################
# PROCEDIMENTO: formatar_preco
######################################################################
formatar_preco:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s1, 8($sp) 
    sw $t5, 4($sp)
    sw $t6, 0($sp)

    move $s1, $a0      
    move $t6, $a1      
    
    move $a0, $t6
    li   $a1, 16
    jal  zerar_buffer
    
    div  $a0, $s1, 100 
    la   $a1, temp_buffer
    jal  int_to_ascii
    
    move $a0, $t6     
    la   $a1, temp_buffer
    jal  strcat  

    la   $a1, virgula
    jal  strcat          
    move $t6, $a0 

    rem $t5, $s1, 100 
    
    blt $t5, 10, fp_add_zero
    
    j fp_convert_cents

fp_add_zero:
    move $a0, $t6      
    la   $a1, zero_str
    jal  strcat  
    move $t6, $a0     
    
fp_convert_cents:
    move $a0, $t5    
    la   $a1, temp_buffer
    jal  int_to_ascii 

    move $a0, $t6 
    la   $a1, temp_buffer
    jal  strcat        
    
    lw $ra, 12($sp)
    lw $s1, 8($sp)
    lw $t5, 4($sp)
    lw $t6, 0($sp)
    addiu $sp, $sp, 16
    jr $ra
    
######################################################################
# PROCEDIMENTO: inicializar_contador
######################################################################
inicializar_contador:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, 1
init_loop:
    la $a0, nome_arquivo
    li $a1, 64
    jal zerar_buffer
    la $a0, nome_arquivo
    la $a1, caminho_base
    jal strcat
    move $a0, $t0
    la $a1, num_buffer
    jal int_to_ascii
    la $a0, nome_arquivo
    la $a1, num_buffer
    jal strcat
    la $a0, nome_arquivo
    la $a1, extensao
    jal strcat
    li $v0, 13
    la $a0, nome_arquivo
    li $a1, 0
    li $a2, 0
    syscall
    bltz $v0, init_done 
    move $a0, $v0
    li $v0, 16
    syscall
    addi $t0, $t0, 1
    j init_loop
init_done:
    sw $t0, contador
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
