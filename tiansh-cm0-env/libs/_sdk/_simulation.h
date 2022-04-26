/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date         Author          Notes
 * 2022-03-27   Lyons           first version
 */

#ifndef __SIMULATION_H
#define __SIMULATION_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#define _simulation(cmd)        GPIO->DR = (((cmd) & 0xf) << 8);

#define _timestamp()            \
do {                            \
    _simulation(0x4);           \
    _simulation(0x0);           \
} while (0);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SIMULATION_H */
