/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#ifndef __TIMER_H__
#define __TIMER_H__

#include "__def.h"

typedef struct
{
    __IO uint32_t           cr;
    __IO uint32_t           sr;
    __IO uint32_t           psc;
    __O  uint32_t           load;
    __I  uint32_t           count;
} TIM_Type;

#define TIM_BASE            (0x20000000)

#define TIM1                ((TIM_Type*)(TIM_BASE))

// [0]: enbale
#define TIM_CR_EN           (uint32_t)(1 << 0)

// [0]: timing-up flag
#define TIM_SR_FLAG_TUF     (uint32_t)(1 << 0)

#define TIM_SR_CLR_TUF      (uint32_t)(1 << 0) //write "1" clear

#define TIM_EN              (uint8_t)0x1
#define TIM_DIS             (uint8_t)0x0

void timer_init(TIM_Type *tim, uint32_t psc, uint32_t value);

void timer_control(TIM_Type *tim, uint8_t en);
void timer_clearflag(TIM_Type *tim, uint32_t flag);

#endif //#ifndef __TIMER_H__