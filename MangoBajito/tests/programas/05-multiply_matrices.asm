.data
.align 2
str0: .asciiz "Ingrese el número de filas: "
str1: .asciiz "El número de filas debe ser mayor que 0."
str2: .asciiz "Ingrese el número de columnas: "
str3: .asciiz "El número de columnas debe ser mayor que 0."
str4: .asciiz "Multiplicación de matrices A y B"
str5: .asciiz "Definición de matrices A:"
str6: .asciiz "Ingrese el elemento A["
str7: .asciiz "]["
str8: .asciiz "]: "
str9: .asciiz "Definición de matrices B:"
str10: .asciiz "Ingrese el elemento B["
str11: .asciiz "]["
str12: .asciiz "]: "
str13: .asciiz "El número de columnas de A debe ser igual al número de filas de B."
str14: .asciiz "Resultado de la multiplicación de matrices A y B:"
str15: .asciiz "C["
str16: .asciiz "]["
str17: .asciiz "] = "
filas: .word 0
columnas: .word 0
filas_A: .word 0
columnas_A: .word 0
A: .word 0
i: .word 0
j: .word 0
filas_B: .word 0
columnas_B: .word 0
B: .word 0
C: .word 0
k: .word 0
buffer: .space 64

.text
main:
    # read_rows:
    # begin_func:
    li $t9, 0
    sw $t9, filas
L1:
    lw $t9, filas
    li $t9, 1
    bge $t9, $t9, L2
    la $a0, str0
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, filas
    lw $t9, filas
    li $t9, 1
    bge $t9, $t9, L0
    la $a0, str1
    li $v0, 4
    syscall
    li $t9, 0
    sw $t9, filas
L0:
    j L1
L2:
    # return filas
    # end_func:
    # read_columns:
    # begin_func:
    li $t9, 0
    sw $t9, columnas
L4:
    lw $t9, columnas
    li $t9, 1
    bge $t9, $t9, L5
    la $a0, str2
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t1, $v0
    sw $t1, columnas
    lw $t9, columnas
    li $t9, 1
    bge $t9, $t9, L3
    la $a0, str3
    li $v0, 4
    syscall
    li $t9, 0
    sw $t9, columnas
L3:
    j L4
L5:
    # return columnas
    # end_func:
    la $a0, str4
    li $v0, 4
    syscall
    la $a0, str5
    li $v0, 4
    syscall
    li $t9, 1
    sw $t9, filas_A
    # t2 := call read_rows, 0
    sw $t2, filas_A
    li $t9, 1
    sw $t9, columnas_A
    # t3 := call read_columns, 0
    sw $t3, columnas_A
    li $t9, 0
    sw $t9, i
L9:
    lw $t9, i
    lw $t9, filas_A
    blt $t9, $t9, L10
    j L11
L10:
    li $t9, 0
    sw $t9, j
L6:
    lw $t9, j
    lw $t9, columnas_A
    blt $t9, $t9, L7
    j L8
L7:
    # t9 := i * 4
    # t10 := j * 4
    move $t9, $t9
    move $t9, $t10
    add $t9, $t9, $t9
    move $t11, $t9
    la $t4, buffer # [TODO] concat no implementado
    la $t5, buffer # [TODO] concat no implementado
    la $t6, buffer # [TODO] concat no implementado
    la $t7, buffer # [TODO] concat no implementado
    la $a0, str6
    li $v0, 4
    syscall
    # [TODO] No se encontró variable destino.
    # A[t11] := (int)t8
    lw $t9, j
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, j
    j L6
L8:
    lw $t9, i
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, i
    j L9
L11:
    la $a0, str9
    li $v0, 4
    syscall
    li $t9, 1
    sw $t9, filas_B
    # t12 := call read_rows, 0
    sw $t12, filas_B
    li $t9, 1
    sw $t9, columnas_B
    # t13 := call read_columns, 0
    sw $t13, columnas_B
    li $t9, 0
    sw $t9, i
L15:
    lw $t9, i
    lw $t9, filas_B
    blt $t9, $t9, L16
    j L17
L16:
    li $t9, 0
    sw $t9, j
L12:
    lw $t9, j
    lw $t9, columnas_B
    blt $t9, $t9, L13
    j L14
L13:
    # t19 := i * 4
    # t20 := j * 4
    move $t9, $t19
    move $t9, $t20
    add $t9, $t9, $t9
    move $t21, $t9
    la $t14, buffer # [TODO] concat no implementado
    la $t15, buffer # [TODO] concat no implementado
    la $t16, buffer # [TODO] concat no implementado
    la $t17, buffer # [TODO] concat no implementado
    la $a0, str10
    li $v0, 4
    syscall
    # [TODO] No se encontró variable destino.
    # B[t21] := (int)t18
    lw $t9, j
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, j
    j L12
L14:
    lw $t9, i
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, i
    j L15
L17:
    lw $t9, columnas_A
    lw $t9, filas_B
    beq $t9, $t9, L40
    la $a0, str13
    li $v0, 4
    syscall
    j L39
L40:
    li $t9, 0
    sw $t9, i
L21:
    lw $t9, i
    lw $t9, filas_A
    blt $t9, $t9, L22
    j L23
L22:
    li $t9, 0
    sw $t9, j
L18:
    lw $t9, j
    lw $t9, columnas_B
    blt $t9, $t9, L19
    j L20
L19:
    # t22 := i * 4
    # t23 := j * 4
    move $t9, $t22
    move $t9, $t23
    add $t9, $t9, $t9
    move $t24, $t9
    # C[t24] := 0
    lw $t9, j
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, j
    j L18
L20:
    lw $t9, i
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, i
    j L21
L23:
    li $t9, 0
    sw $t9, i
L30:
    lw $t9, i
    lw $t9, filas_A
    blt $t9, $t9, L31
    j L32
L31:
    li $t9, 0
    sw $t9, j
L27:
    lw $t9, j
    lw $t9, columnas_B
    blt $t9, $t9, L28
    j L29
L28:
    li $t9, 0
    sw $t9, k
L24:
    lw $t9, k
    lw $t9, columnas_A
    blt $t9, $t9, L25
    j L26
L25:
    # t34 := i * 4
    # t35 := j * 4
    move $t9, $t34
    move $t9, $t35
    add $t9, $t9, $t9
    move $t36, $t9
    # t25 := i * 4
    # t26 := k * 4
    move $t9, $t25
    move $t9, $t26
    add $t9, $t9, $t9
    move $t27, $t9
    # t28 := A[t27]
    # t29 := k * 4
    # t30 := j * 4
    move $t9, $t29
    move $t9, $t30
    add $t9, $t9, $t9
    move $t31, $t9
    # t32 := B[t31]
    # t33 := t28 * t32
    # t37 := C[t36]
    move $t9, $t37
    move $t9, $t33
    add $t9, $t9, $t9
    move $t38, $t9
    # C[t36] := t38
    lw $t9, k
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, k
    j L24
L26:
    lw $t9, j
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, j
    j L27
L29:
    lw $t9, i
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, i
    j L30
L32:
    la $a0, str14
    li $v0, 4
    syscall
    li $t9, 0
    sw $t9, i
L36:
    lw $t9, i
    lw $t9, filas_A
    blt $t9, $t9, L37
    j L38
L37:
    li $t9, 0
    sw $t9, j
L33:
    lw $t9, j
    lw $t9, columnas_B
    blt $t9, $t9, L34
    j L35
L34:
    la $t39, buffer # [TODO] concat no implementado
    la $t40, buffer # [TODO] concat no implementado
    la $t41, buffer # [TODO] concat no implementado
    la $t42, buffer # [TODO] concat no implementado
    # t43 := i * 4
    # t44 := j * 4
    move $t9, $t43
    move $t9, $t44
    add $t9, $t9, $t9
    move $t45, $t9
    # t46 := C[t45]
    la $a0, str15
    li $v0, 4
    syscall
    lw $a0, i
    li $v0, 1
    syscall
    move $a0, $t39
    li $v0, 4
    syscall
    la $a0, str16
    li $v0, 4
    syscall
    move $a0, $t40
    li $v0, 4
    syscall
    lw $a0, j
    li $v0, 1
    syscall
    move $a0, $t41
    li $v0, 4
    syscall
    la $a0, str17
    li $v0, 4
    syscall
    move $a0, $t42
    li $v0, 4
    syscall
    lw $a0, t46
    li $v0, 1
    syscall
    lw $t9, j
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, j
    j L33
L35:
    lw $t9, i
    li $t9, 1
    add $t9, $t9, $t9
    sw $t9, i
    j L36
L38:
L39:
