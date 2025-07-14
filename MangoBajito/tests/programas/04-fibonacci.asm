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

.text
main:
    la $a0, str0
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, n
    lw $t0, n
    lw $t1, 2
    bge $t0, $t1, L4
    # res := n
    j L3
L4:
    li $t0, 0
    sw $t0, a
    li $t0, 1
    sw $t0, b
    li $t0, 2
    sw $t0, i
    # t1 := n + 1
L0:
    lw $t0, i
    lw $t1, t1
    blt $t0, $t1, L1
    j L2
L1:
    lw $t0, a
    lw $t1, b
    add $t2, $t0, $t1
    sw $t2, t2
    sw $t2, temp
    # a := b
    # b := temp
    # i := i + 1
    j L0
L2:
    # res := b
L3:
    # t3 := call concat, 2
    # t4 := call concat, 2
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
