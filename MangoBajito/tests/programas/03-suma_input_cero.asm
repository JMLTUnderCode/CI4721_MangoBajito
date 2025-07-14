.data
.align 2
str0: .asciiz "Ingrese numero: "
str1: .asciiz "La suma es: "
suma: .word 0
n: .word 0

.text
main:
    li $t0, 0
    sw $t0, suma
L1:
    la $a0, str0
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, n
    lw $t0, n
    li $t1, 0
    bne $t0, $t1, L0
    j L2
L0:
    lw $t0, suma
    lw $t1, n
    add $t2, $t0, $t1
    sw $t2, suma
    j L1
L2:
    la $a0, str1
    li $v0, 4
    syscall
    lw $a0, suma
    li $v0, 1
    syscall
