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

extern void trap_entry();

void init(void)
{
    write_csr(mtvec, &trap_entry);
    write_csr(mstatus, 0x1888); // MPP = 11, MPIE = 1, MIE = 1
}