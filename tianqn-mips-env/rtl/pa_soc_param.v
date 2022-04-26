/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2022-01-17     Lyons        first version
 */

// test control define(only choose one)
`define TEST_NONE
// `define TEST_ISA

// core clock freq define
`define CPU_FREQ_HZ             32'd10_000_000

// bus width
`define ADDR_BUS_WIDTH          8'd32
`define DATA_BUS_WIDTH          8'd32
`define REG_BUS_WIDTH           8'd5

// register number(fixed 32)
`define REG_NUM                 8'd32

// data width(bit)
`define INT_WIDTH               8'd32

// memory size define(KByte)
`define ROM_SIZE                32'd4
`define RAM_SIZE                32'd4

// default data define
`define ZERO_WORD               32'h0000_0000

// valid signal value define
`define VALID                   1'b1
`define INVALID                 1'b0

// pin level define
`define LEVEL_HIGH              1'b1
`define LEVEL_LOW               1'b0