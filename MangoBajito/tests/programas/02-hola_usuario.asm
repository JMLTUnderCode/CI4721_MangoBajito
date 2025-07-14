.data
.align 2
str0: .asciiz "nombre de usuario: "
str1: .asciiz "Hola "
nombre: .word 0
buffer: .space 64

.text
main:
    la $a0, str0
    li $v0, 4
    syscall
    la $a0, nombre
    li $a1, 32
    li $v0, 8
    syscall
    move $t0, $a0
    move $t1, $t0
    la $t2, nombre
copy_nombre:
    lb $t3, 0($t1)
    sb $t3, 0($t2)
    addiu $t1, $t1, 1
    addiu $t2, $t2, 1
    bnez $t3, copy_nombre
    la $a0, str1
    li $v0, 4
    syscall
    la $a0, nombre
    li $v0, 4
    syscall
