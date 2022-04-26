/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date         Author          Notes
 * 2022-03-27   Lyons           first version
 */

#ifndef __SOC_H
#define __SOC_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * @brief TianXn Data Type Definition
 */
#define __I                     volatile const
#define __O                     volatile
#define __IO                    volatile

#include <stdint.h>

/**
 * @brief TianXn Clock Frequency Definition
 */
#define CPU_CLOCK_MHZ           ((uint32_t)50)
#define CPU_CLOCK_HZ            ((uint32_t)(CPU_CLOCK_MHZ*1000*1000))

/**
 * @brief TianXn Interrupt Number Definition
 */
typedef enum IRQn
{
    NMI_EXPn                    = -14,
    HardFault_IRQn              = -13,
    MemManage_IRQn              = -12,
    BusFault_IRQn               = -11,
    UsageFault_IRQn             = -10,
    SVC_IRQn                    = -5, 
    PendSV_IRQn                 = -2,
    SysTick_IRQn                = -1,

    Default_IRQn                = 16
} IRQn_Type;

/**
  * @brief General Purpose I/O
  */

typedef struct
{
    __IO uint32_t   DR;
} GPIO_TypeDef;

/**
  * @brief Timer
  */

typedef struct
{
          uint32_t  RESERVED0;
} TIM_TypeDef;

/**
  * @brief Universal Asynchronous Receiver Transmitter
  */

typedef struct
{
          uint32_t  RESERVED0;
} UART_TypeDef;

/**
  * @brief Watchdog
  */

typedef struct
{
          uint32_t  RESERVED0;
} WDT_TypeDef;

/** @addtogroup Peripheral memory map
  * @{
  */
#define AHB_BASE                ((uint32_t)0x00000000)

/*!< AHB memory map */
#define ROM_BASE                (AHB_BASE + 0x00000000)
#define RAM_BASE                (AHB_BASE + 0x20000000)
#define GPIO_BASE               (AHB_BASE + 0x40000000)
#define APB_BASE                (AHB_BASE + 0x50000000)

/*!< Peripheral memory map */
#define TIM0_BASE               (APB_BASE + 0x0000)
#define TIM1_BASE               (APB_BASE + 0x1000)
#define UART0_BASE              (APB_BASE + 0x3000)
#define UART1_BASE              (APB_BASE + 0x4000)
#define WDT_BASE                (APB_BASE + 0x8000)

/** @addtogroup Peripheral_declaration
  * @{
  */
#define GPIO                    ((GPIO_TypeDef *) GPIO_BASE  )
#define TIM0                    ((TIM_TypeDef  *) TIM0_BASE  )
#define TIM1                    ((TIM_TypeDef  *) TIM1_BASE  )
#define UART0                   ((UART_TypeDef *) UART0_BASE )
#define UART1                   ((UART_TypeDef *) UART1_BASE )
#define WDT                     ((WDT_TypeDef  *) WDT_BASE   )

/** @addtogroup Exported_macro
  * @{
  */

#define SET_BIT(REG,BITN)       ((REG) |=  (1<<(BITN)))
#define CLR_BIT(REG,BITN)       ((REG) &= ~(1<<(BITN)))
#define GET_BIT(REG,BITN)       ((REG) &   (1<<(BITN)))

#define REG_SET(REG,VALUE)      ((REG) |=  (VALUE))
#define REG_CLR(REG,VALUE)      ((REG) &= ~(VALUE))
#define REG_GET(REG,VALUE)      ((REG) &   (VALUE))

/**
* @brief Simulation Definition
*/

#include "_simulation.h"

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SOC_H */
