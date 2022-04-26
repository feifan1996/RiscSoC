19:06 2022/4/24  

## 〇、前言

> 天回北斗挂西楼，金屋无人萤火流。  
> 月光欲到长门殿，别作深宫一段愁。  

## 一、简介

```
                                                                
            KaiYang                                     TianShu 
               #        YuHeng                             +    
    v                     x      TianQuan                       
 YaoGuang                           =                           
                                                                
                                                                
                                       o                        
                                     TianJi          +          
                                                 TianXuan       
                                                                
```

本项目是为了学习 RISC-V、MIPS、ARM Cortex-M0、ARM Cortex-M3 架构的 SoC 集成，其中 RISC-V 和 MIPS 使用自己设计的内核（YuHeng RISC-V 和 DARKMIPS）。  

### 1. YaoGuang

null  

### 2. KaiYang

基于 ARM DesignStart Cortex-M3 的双核微控制器设计。  

#### 环境介绍

- 内核及外设：`Cortex-M3 DesignStart Eval r0p0-02rel0`  

- 软件编译器：`GNU Tools for ARM Embedded Processors (ARM GCC) version 5-2016q2`  

#### 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220425105725.png)  

#### 地址分配

|起始地址   |结束地址   |大小|外设  |支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x0000_0000|0x0000_ffff|64K |ROM   |√   |
|0x2000_0000|0x2000_ffff|64K |RAM   |√   |
|0x4000_0000|0x4000_07ff| 2K |GPIO  |√   |
|0x5000_0000|0x5000_0fff| 4K |TIMER0|√   |
|0x5000_1000|0x5000_1fff| 4K |TIMER1|×   |
|0x5000_3000|0x5000_3fff| 4K |UART0 |×   |
|0x5000_4000|0x5000_4fff| 4K |UART1 |×   |
|0x5000_8000|0x5000_8fff| 4K |WDT   |×   |

*core 0 和 core 1 各自拥有一个 64KB 的 ROM，RAM 资源共用一块，但每个核使用空间独立，其他外设资源是共用的*  

|起始地址   |结束地址   |大小|主设备|支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x2000_0000|0x2000_7fff|32K |core0 |√   |
|0x2000_8000|0x2000_bfff|16K |core1 |√   |
|0x2000_c000|0x2000_ffff|16K |share |√   |

### 3. YuHeng

基于自己设计的 RISC-V 内核的微控制器，5 级流水线。  

`https://gitee.com/dengchow/yuheng-riscv-soc.git`  

#### 环境介绍

- 内核及外设：`YuHeng 5-state RISC-V Core`  

- 软件编译器：`GNU MCU Eclipse RISC-V Embedded GCC, 64-bit (gcc version 8.2.0)`  

#### 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220404203958.png)  

#### 地址分配

|起始地址   |结束地址   |大小|外设  |支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x0000_0000|0x0fff_ffff|256M|ROM   |√   |
|0x1000_0000|0x1fff_ffff|256M|RAM   |√   |
|0x2000_0000|0x2fff_ffff|256M|TIMER1|√   |
|0x3000_0000|0x3fff_ffff|256M|UART1 |√   |
|0x4000_0000|0x4fff_ffff|256M|UART2 |√   |
|0x5000_0000|0x5fff_ffff|256M|UART3 |√   |
|0x6000_0000|0x6fff_ffff|256M|×     |×   |

*实际使用的空间大小详见 link.lds 文件。*  

### 4. TianQuan

基于自己设计的 MIPS 内核的微控制器设计，无流水线。  

#### 环境介绍

- 内核及外设：`DARKMIPS 1-state MIPS Core`  

- 软件编译器：`Codescape GNU Tools 2019.02-05 for MIPS IMG Bare Metal (gcc version 7.4.0)`  

#### 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220404215747.png)  

#### 地址分配

|起始地址   |结束地址   |大小|外设  |支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x0000_0000|0x0fff_ffff|256M|ROM   |√   |
|0x0000_0000|0x0fff_ffff|256M|UART1 |√   |

*ROM 只存放指令，没有数据存储器。实际使用的空间大小详见 link.lds 文件。*  

### 5. TianJi

基于 4-bit 的分立式微处理器设计，支持 16 条指令。  

最多存储 16 条指令，可以进行数字量的输入、输出，以及算术运算。  

### 6. TianXuan

基于 ARM DesignStart Cortex-M3 的微控制器设计。  

#### 环境介绍

- 内核及外设：`Cortex-M3 DesignStart Eval r0p0-02rel0`  

- 软件编译器：`GNU Tools for ARM Embedded Processors (ARM GCC) version 5-2016q2`  

#### 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220329183053.png)  

#### 地址分配

|起始地址   |结束地址   |大小|外设  |支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x0000_0000|0x0000_ffff|64K |ROM   |√   |
|0x2000_0000|0x2000_ffff|64K |RAM   |√   |
|0x4000_0000|0x4000_07ff| 2K |GPIO  |√   |
|0x5000_0000|0x5000_0fff| 4K |TIMER0|√   |
|0x5000_1000|0x5000_1fff| 4K |TIMER1|×   |
|0x5000_3000|0x5000_3fff| 4K |UART0 |×   |
|0x5000_4000|0x5000_4fff| 4K |UART1 |×   |
|0x5000_8000|0x5000_8fff| 4K |WDT   |×   |

### 7. TianShu

基于 ARM DesignStart Cortex-M0 的微控制器设计。  

#### 环境介绍

- 内核及外设：`Cortex-M0 DesignStart Eval r2p0-00rel0`  

- 软件编译器：`GNU Tools for ARM Embedded Processors (ARM GCC) version 5-2016q2`  

#### 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220329183036.png)  

#### 地址分配

|起始地址   |结束地址   |大小|外设  |支持|
|:-:        |:-:        |:-: |:-:   |:-: |
|0x0000_0000|0x0000_ffff|64K |ROM   |√   |
|0x2000_0000|0x2000_ffff|64K |RAM   |√   |
|0x4000_0000|0x4000_07ff| 2K |GPIO  |√   |
|0x5000_0000|0x5000_0fff| 4K |TIMER0|√   |
|0x5000_1000|0x5000_1fff| 4K |TIMER1|×   |
|0x5000_3000|0x5000_3fff| 4K |UART0 |×   |
|0x5000_4000|0x5000_4fff| 4K |UART1 |×   |
|0x5000_8000|0x5000_8fff| 4K |WDT   |×   |

## 二、使用说明

本项目提供完整的 SoC 集成设计和 SDK 软件包，在 testbench 上增加了 UART Monitor，可以在仿真时直观的观测 UART 的输出。  

- 仿真工具使用 iverilog+vvp+gtkwave，相关软件请自行下载。  

- 软件编译工具链使用 gcc，相关软件请自行下载（版本号详见每个子项目的 readme 文件）。  

- 仿真前请先修改 makefile 文件。  

## 三、维护

如果有任何疑问或者建议，欢迎在下方评论，或者通过邮件联系（E-mail：ytesliang@163.com），我会尽可能在 24 小时内进行回复。  

ATONEMAN  
2022.04.24  
