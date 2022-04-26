/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#include "timer.h"

void timer_init(TIM_Type *tim, uint32_t psc, uint32_t value)
{
    tim->cr &= ~TIM_CR_EN; //close first

    tim->sr |=  TIM_SR_CLR_TUF;

    tim->psc = (0 == psc) ? 0 : (psc-1);
    tim->load = value;
}

void timer_control(TIM_Type *tim, uint8_t en)
{
    uint32_t dummy;

    dummy = tim->cr;

    if (TIM_EN == en)
    {
        dummy |=  TIM_CR_EN;
    } else {
        dummy &= ~TIM_CR_EN;
    }

    tim->cr = dummy;
}

void timer_clearflag(TIM_Type *tim, uint32_t flag)
{
    tim->sr = flag;
}