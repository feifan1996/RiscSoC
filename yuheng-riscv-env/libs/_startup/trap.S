/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

.section .text

.global interrupt_enable
.global interrupt_disable
.align 2

    .globl interrupt_disable
interrupt_disable:
    csrr a0, mstatus
    and t0, a0, 0xfffffff7
    csrw mstatus, t0
    ret

    .globl interrupt_enable
interrupt_enable:
    csrw mstatus, a0
    ret

/* Macro for saving task context */
.macro save_context
    addi    sp, sp, -120

    sw      x1,  0(sp)
    sw      x5,  8(sp)
    sw      x6,  12(sp)
    sw      x7,  16(sp)
    sw      x8,  20(sp)
    sw      x9,  24(sp)
    sw      x10, 28(sp)
    sw      x11, 32(sp)
    sw      x12, 36(sp)
    sw      x13, 40(sp)
    sw      x14, 44(sp)
    sw      x15, 48(sp)
    sw      x16, 52(sp)
    sw      x17, 56(sp)
    sw      x18, 60(sp)
    sw      x19, 64(sp)
    sw      x20, 68(sp)
    sw      x21, 72(sp)
    sw      x22, 76(sp)
    sw      x23, 80(sp)
    sw      x24, 84(sp)
    sw      x25, 88(sp)
    sw      x26, 92(sp)
    sw      x27, 96(sp)
    sw      x28, 100(sp)
    sw      x29, 104(sp)
    sw      x30, 108(sp)
    sw      x31, 112(sp)

    csrr    a5, mepc
    sw      a5, 116(sp)
.endm

/* Macro for restoring task context */
.macro restore_context
    lw      a5, 116(sp)
    csrw    mepc, a5

    lw      x1,  0(sp)
    lw      x5,  8(sp)
    lw      x6,  12(sp)
    lw      x7,  16(sp)
    lw      x8,  20(sp)
    lw      x9,  24(sp)
    lw      x10, 28(sp)
    lw      x11, 32(sp)
    lw      x12, 36(sp)
    lw      x13, 40(sp)
    lw      x14, 44(sp)
    lw      x15, 48(sp)
    lw      x16, 52(sp)
    lw      x17, 56(sp)
    lw      x18, 60(sp)
    lw      x19, 64(sp)
    lw      x20, 68(sp)
    lw      x21, 72(sp)
    lw      x22, 76(sp)
    lw      x23, 80(sp)
    lw      x24, 84(sp)
    lw      x25, 88(sp)
    lw      x26, 92(sp)
    lw      x27, 96(sp)
    lw      x28, 100(sp)
    lw      x29, 104(sp)
    lw      x30, 108(sp)
    lw      x31, 112(sp)

    addi    sp, sp, 120
.endm

.global trap_entry
.align 2

trap_entry:
    j       vector_handler
    mret

vector_handler:
_save:
    save_context

    mv      tp, sp
    mv      sp, gp

    csrr    a0, mcause
    csrr    a1, mepc

    srli    t0, a0, 31
    beq     t0, a0, _is_exception

    call    trap_handler

    j       _is_interrupt

_is_exception:
    addi    a1, a1, 4
    csrw    mepc, a1

_is_interrupt:
    mv      gp, sp
    mv      sp, tp

#ifdef OS_ENABLE_RT_THREAD
    la      s0, rt_thread_switch_interrupt_flag
    lw      s1, 0(s0)
    beqz    s1, _restore
    sw      zero, 0(s0)

    la      s0, rt_interrupt_from_thread
    lw      s1, 0(s0)
    beqz    s1, _switch_first

    sw      sp, 0(s1)

_switch_first:
    lw      s0, rt_interrupt_to_thread
    lw      sp, 0(s0)
#endif

_restore:
    restore_context

    mret

_nop_list:
    nop
    nop
    nop

.weak trap_handler
trap_handler:
    ret
