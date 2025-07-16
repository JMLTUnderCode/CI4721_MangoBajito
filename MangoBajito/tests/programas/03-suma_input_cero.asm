.data
.align 2
str0: .asciiz "Ingrese numero: "
str1: .asciiz "La suma es: "
suma: .word 0
n: .word 0
buffer: .space 64

.text
main:
    li $t1, 0
    sw $t1, suma
L1:
    la $a0, str0
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, n
    lw $t2, n
    li $t3, 0
    bne $t2, $t3, L0
    j L2
L0:
    lw $t4, suma
    lw $t5, n
    add $t6, $t4, $t5
    sw $t6, suma
    j L1
L2:
    la $a0, str1
    li $v0, 4
    syscall
    lw $a0, suma
    li $v0, 1
    syscall
