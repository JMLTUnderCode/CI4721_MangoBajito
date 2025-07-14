.data
.align 2
str0: .asciiz "Ingrese numero: "
str1: .asciiz "Fibonacci("
str2: .asciiz ") = "
n: .word 0
res: .word 0
a: .word 0
b: .word 0
temp: .word 0
i: .word 0
buffer: .space 64

.text
main:
    la $a0, str0
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, n
    lw $t5, n
    li $t6, 2
    bge $t5, $t6, L4
    lw $t7, n
    sw $t7, res
    j L3
L4:
    li $t8, 0
    sw $t8, a
    li $t9, 1
    sw $t9, b
    li $t5, 2
    sw $t5, i
    lw $t6, n
    li $t7, 1
    add $t8, $t6, $t7
    move $t1, $t8
L0:
    lw $t9, i
    move $t5, $t1
    blt $t9, $t5, L1
    j L2
L1:
    lw $t6, a
    lw $t7, b
    add $t8, $t6, $t7
    move $t2, $t8
    sw $t2, temp
    lw $t9, b
    sw $t9, a
    lw $t5, temp
    sw $t5, b
    lw $t6, i
    li $t7, 1
    add $t8, $t6, $t7
    sw $t8, i
    j L0
L2:
    lw $t9, b
    sw $t9, res
L3:
    la $t3, buffer # [TODO] concat no implementado
    la $t4, buffer # [TODO] concat no implementado
    la $a0, str1
    li $v0, 4
    syscall
    lw $a0, n
    li $v0, 1
    syscall
    move $a0, $t3
    li $v0, 4
    syscall
    la $a0, str2
    li $v0, 4
    syscall
    move $a0, $t4
    li $v0, 4
    syscall
    lw $a0, res
    li $v0, 1
    syscall
