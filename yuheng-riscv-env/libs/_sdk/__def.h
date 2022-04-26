/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

#ifndef __DEF_H__
#define __DEF_H__

#include <stdint.h>

#define CPU_FREQ_HZ                 (50000000)
#define CPU_FREQ_MHZ                (50)

#ifdef __cplusplus
    #define __I                     volatile             /*!< Defines 'read only' permissions                 */
#else
    #define __I                     volatile const       /*!< Defines 'read only' permissions                 */
#endif
#define     __O                     volatile             /*!< Defines 'write only' permissions                */
#define     __IO                    volatile             /*!< Defines 'read / write' permissions              */

#ifndef UNUSED
#define UNUSED(X)                   ((void)X)
#endif 

#define CLEAR_ARRAY(ins,data)       memset((uint8_t*)ins,data,sizeof(ins))
#define CLEAR_STRUCT(ins,data)      memset((uint8_t*)ins,data,sizeof(ins))

#define GET_ARRAY_NUM(ins)          ((uint32_t)(sizeof(ins)/sizeof(ins[0])))
#define GET_STRUCT_SIZE(ins)        ((uint32_t)(sizeof(ins)))

#define GET_WORD_BYTE0(w)           ((uint8_t)((w)    & 0xFF))
#define GET_WORD_BYTE1(w)           ((uint8_t)((w>>8) & 0xFF))

#define GET_DWORD_BYTE0(d)          GET_WORD_BYTE0(d)
#define GET_DWORD_BYTE1(d)          GET_WORD_BYTE1(d)
#define GET_DWORD_BYTE2(d)          ((uint8_t)(((d)>>16) & 0xFF))
#define GET_DWORD_BYTE3(d)          ((uint8_t)(((d)>>24) & 0xFF))

#define BUILD_WORD(a,b)             ((uint16_t)(((a)<<8 ) |  (b)))
#define BUILD_DWORD(a,b,c,d)        ((uint32_t)(((a)<<24) | ((b)<<16) | ((c)<<8) | (d)))

#define _internal_ro                static const
#define _internal_rw                static
#define _internal_zi                static

#define read_csr(reg)               ({ unsigned long __tmp; \
    asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
    __tmp; })

#define write_csr(reg, val)         ({ \
    if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
        asm volatile ("csrw " #reg ", %0" :: "i"(val)); \
    else \
        asm volatile ("csrw " #reg ", %0" :: "r"(val)); })

#include "__simulation.h"

#endif //#ifndef __DEF_H__