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
    sw $t0, -4($fp)
    lw $t5, -4($fp)
    li $t6, 2
    bge $t5, $t6, L4
    lw $t7, -4($fp)
    sw $t7, res
    j L3
L4:
    li $t8, 0
    sw $t8, -8($fp)
    li $t9, 1
    sw $t9, -12($fp)
    li $t5, 2
    sw $t5, -16($fp)
    lw $t6, -4($fp)
    li $t7, 1
    add $t8, $t6, $t7
    move $t1, $t8
L0:
    lw $t9, -16($fp)
    move $t5, $t1
    blt $t9, $t5, L1
    j L2
L1:
    lw $t6, -8($fp)
    lw $t7, -12($fp)
    add $t8, $t6, $t7
    move $t2, $t8
    sw $t2, -20($fp)
    lw $t9, -12($fp)
    sw $t9, -8($fp)
    lw $t5, -20($fp)
    sw $t5, -12($fp)
    lw $t6, -16($fp)
    li $t7, 1
    add $t8, $t6, $t7
    sw $t8, -16($fp)
    j L0
L2:
    lw $t9, -12($fp)
    sw $t9, res
L3:
    la $t3, buffer # [TODO] concat no implementado
    la $t4, buffer # [TODO] concat no implementado
    la $a0, str1
    li $v0, 4
    syscall
    lw $a0, -4($fp)
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
