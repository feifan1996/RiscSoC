/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#include "__def.h"
#include "xprintf.h"

#include "timer.h"

uint32_t count = 0;

int main()
{
    timer_init(TIM1, CPU_FREQ_MHZ-1, 3000); //duty = 3ms
    timer_control(TIM1, TIM_EN);

    while (1)
    {
        if (3 == count) {
            break;
        }
    }

    simulation(0x4);
    return 0;
}

void timer1_handler(void)
{
    timer_control(TIM1, TIM_DIS);
    timer_clearflag(TIM1, TIM_SR_FLAG_TUF);

    count ++;
    xprintf("cnt: %02x\n", count);

    timer_control(TIM1, TIM_EN);
}