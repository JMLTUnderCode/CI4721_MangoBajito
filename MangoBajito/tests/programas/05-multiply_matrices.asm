.data
.align 2
buffer: .space 64

.text
.globl main
main:
    # [UNHANDLED] A[0] := 1
    # [UNHANDLED] A[4] := 2
    # [UNHANDLED] A[8] := 3
    # [UNHANDLED] A[12] := 4
    # [UNHANDLED] B[0] := 5
    # [UNHANDLED] B[4] := 6
    # [UNHANDLED] B[8] := 7
    # [UNHANDLED] B[12] := 8
    # [UNHANDLED] i := 0
# L3:
L3:
# if i < 2 goto L4
    li $t0, 2
    blt $t0, $t0, L4
# goto L5
    j L5
# L4:
L4:
    # [UNHANDLED] j := 0
# L0:
L0:
# if j < 2 goto L1
    li $t1, 2
    blt $t1, $t1, L1
# goto L2
    j L2
# L1:
L1:
    # [UNHANDLED] t0 := i * 8
    # [UNHANDLED] t1 := j * 4
# t2 := t0 + t1
    add $t1, $t3, $t1
    # [UNHANDLED] C[t2] := 0
    # [UNHANDLED] j := j + 1
# goto L0
    j L0
# L2:
L2:
    # [UNHANDLED] i := i + 1
# goto L3
    j L3
# L5:
L5:
    # [UNHANDLED] i := 0
# L12:
L12:
# if i < 2 goto L13
    li $t2, 2
    blt $t0, $t2, L13
# goto L14
    j L14
# L13:
L13:
    # [UNHANDLED] j := 0
# L9:
L9:
# if j < 2 goto L10
    li $t3, 2
    blt $t1, $t3, L10
# goto L11
    j L11
# L10:
L10:
    # [UNHANDLED] k := 0
# L6:
L6:
# if k < 2 goto L7
    li $t4, 2
    blt $t4, $t4, L7
# goto L8
    j L8
# L7:
L7:
    # [UNHANDLED] t12 := i * 8
    # [UNHANDLED] t13 := j * 4
# t14 := t12 + t13
    add $t3, $t3, $t5
    # [UNHANDLED] t3 := i * 8
    # [UNHANDLED] t4 := k * 4
# t5 := t3 + t4
    add $t5, $t5, $t6
    # [UNHANDLED] t6 := A[t5]
    # [UNHANDLED] t7 := k * 8
    # [UNHANDLED] t8 := j * 4
# t9 := t7 + t8
    add $t4, $t4, $t6
    # [UNHANDLED] t10 := B[t9]
    # [UNHANDLED] t11 := t6 * t10
    # [UNHANDLED] t15 := C[t14]
# t16 := t15 + t11
    add $t4, $t5, $t4
    # [UNHANDLED] C[t14] := t16
    # [UNHANDLED] k := k + 1
# goto L6
    j L6
# L8:
L8:
    # [UNHANDLED] j := j + 1
# goto L9
    j L9
# L11:
L11:
    # [UNHANDLED] i := i + 1
# goto L12
    j L12
# L14:
L14:
    # [UNHANDLED] i := 0
# L18:
L18:
# if i < 2 goto L19
    li $t5, 2
    blt $t0, $t5, L19
# goto L20
    j L20
# L19:
L19:
    # [UNHANDLED] j := 0
# L15:
L15:
# if j < 2 goto L16
    li $t6, 2
    blt $t1, $t6, L16
# goto L17
    j L17
# L16:
L16:
# param 3
# call print, 1
    lw $t7, 3
    move $a0, $t7
    li $v0, 1
    syscall
    # [UNHANDLED] j := j + 1
# goto L15
    j L15
# L17:
L17:
    # [UNHANDLED] i := i + 1
# goto L18
    j L18
# L20:
L20:
