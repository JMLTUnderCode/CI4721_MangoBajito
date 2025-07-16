.data
.align 2
str0: .asciiz "Hola mundo"
buffer: .space 64

.text
.globl main
main:
# param &str0
# call print, 1
    la $a0, str0
    li $v0, 4
    syscall
