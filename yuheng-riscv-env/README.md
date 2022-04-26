18:05 2022/4/4  

## 〇、前言

> 玉衡星，北斗七星中最亮的星。  

## 一、简介

本项目是为了学习 RISC-V 内核架构，自行设计 RISC-V 内核并进行 SoC 集成。  

## 二、功能介绍

### 1. 环境介绍

- 内核及外设：`YuHeng 5-state RISC-V Core`  

- 软件编译器：`GNU MCU Eclipse RISC-V Embedded GCC, 64-bit (gcc version 8.2.0)`  

### 2. 整体框图

![](https://gitee.com/backheart/picgo-image/raw/master/img/20220404203958.png)  

### 3. 地址分配

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

在玉衡（YuHeng）的设计过程中，参考和借鉴了许多优秀的开源项目。  

## 五、修改日志

- v2.0  
  - 统一几个工程的文件结构（11:45 2022/4/5）  

- v1.0  
  - 创建项目并集成测试（18:05 2022/4/4）  

## 六、维护

如果有任何疑问或者建议，欢迎在下方评论，或者通过邮件联系（E-mail：ytesliang@163.com），我会尽可能在 24 小时内进行回复。  

ATONEMAN  
2022.04.04  
