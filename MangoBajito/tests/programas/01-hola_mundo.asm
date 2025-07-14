.data
.align 2
str0: .asciiz "Hola mundo"

.text
main:
    la $a0, str0
    li $v0, 4
    syscall
