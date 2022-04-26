.section .text
.set noat

.globl _start
.type _start,@function

_start:
    li $k0, 0
    li $k1, 0

/*
 * void test(void);
 */
test:
    jal uart_test
    j pass

fail:
    li $k0, 1
    li $k1, 0
    j exit

pass:
    li $k0, 1
    li $k1, 1
    j exit

exit:
    j exit

/*
 * void uart_test(void);
 */
uart_test:
    add $s0, $zero, $ra

    li $a0, 'h'
    jal uart_send

    li $a0, 'e'
    jal uart_send

    li $a0, 'l'
    jal uart_send

    li $a0, 'l'
    jal uart_send

    li $a0, 'o'
    jal uart_send

    li $a0, ','
    jal uart_send

    li $a0, 'd'
    jal uart_send

    li $a0, 'a'
    jal uart_send

    li $a0, 'r'
    jal uart_send

    li $a0, 'k'
    jal uart_send

    li $a0, 'm'
    jal uart_send

    li $a0, 'i'
    jal uart_send

    li $a0, 'p'
    jal uart_send

    li $a0, 's'
    jal uart_send

    li $a0, '!'
    jal uart_send

    li $a0, '\n'
    jal uart_send

    add $ra, $zero, $s0
    jr $ra

/*
 * void uart_send(data);
 */
uart_send:
_uart_send:
    li $at, 0
    sw $a0, 16($at)

_uart_wait:
    lw $t0, 4($at)
    beqz $t0, _uart_wait

_uart_clear:
    li $t0, 1
    sw $t0, 4($at)

    jr $ra
