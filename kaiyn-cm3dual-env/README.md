9:08 2022/4/25  

## 〇、前言

> 开阳星，北斗七星中的一颗双星。  

## 一、简介

> ARM DesignStart 项目是为开发者提供免费使用 ARM 的 IP 通往自己的定制 SoC 的一条捷径，通过这个项目，开发者可以零成本获得 ARM 的 IP 来进行开发。  

作为学习使用，可以免费申请到 Cortex-M0、Cortex-M3、Cortex-A5、Cortex-M23 等内核，以网表形式提供的，可读性很差，用来集成足够了。  
同时 DesignStart 项目提供了很多常用的外设 IP，可以快速集成出一片 SoC。  

本项目是为了辅助学习 SoC 的集成过程，选用较为通用的 ARM Cortex-M3 内核进行设计双核控制器。  

## 二、功能介绍

### 1. 环境介绍

- 内核及外设：`Cortex-M3 DesignStart Eval r0p0-02rel0`  

- 软件编译器：`GNU Tools for ARM Embedded Processors (ARM GCC) version 5-2016q2`  

### 2. 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220425105725.png)  

### 3. 地址分配

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

## 三、使用说明

- 硬件部分的设计源码存放在 `rtl/` 路径下  

- 软件部分的测试代码存放在 `libs/` 路径下  

进入 `sim/` 路径下，在各子目录下执行 `make` 即可，将自动完成以下操作  

1. 编译 c/asm file  

2. 编译 rtl design  

3. 运行 simulation  

4. 打印 c/asm 指令执行结果  

5. 结束  

*执行 make 前请先根据实际情况修改 Makefile 文件*  

## 四、致谢

在开阳（Kaiyn）的设计过程中，参考和借鉴了许多优秀的开源项目。  

## 五、修改日志

- v1.0  
  - 创建项目并集成测试（9:08 2022/4/25）  

## 六、维护

如果有任何疑问或者建议，欢迎在下方评论，或者通过邮件联系（E-mail：ytesliang@163.com），我会尽可能在 24 小时内进行回复。  

ATONEMAN  
2022.04.25  
