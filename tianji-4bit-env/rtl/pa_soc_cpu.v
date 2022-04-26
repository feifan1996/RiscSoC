`timescale 1ns / 1ps
/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2022-01-26     Lyons        first version
 */

`include "pa_soc_param.v"

module pa_soc_cpu (
    input                       clk_i,
    input                       rst_n_i,

    input  [3:0]                input_i,
    output [3:0]                output_o
);

// ROM SPACE, ONLY SUPPORT 16 BYTES

reg  [7:0]                      MEMORY [0:15];

// REGISTER LOAD SIGNAL, LOW ACTIVE

wire                            LOAD0;
wire                            LOAD1;
wire                            LOAD2;
wire                            LOAD3;

wire [3:0]                      OUT0;
wire [3:0]                      OUT1;

wire [3:0]                      ADDER0;
wire [3:0]                      ADDER1;
wire [3:0]                      RESULT;

wire [3:0]                      MADDR;
wire [7:0]                      MDATA;

wire [3:0]                      OP;
wire [3:0]                      IMM;

assign OP[3:0]  = MDATA[7:4];
assign IMM[3:0] = MDATA[3:0];

// GENERAL PURPOSE REGISTER: A, B, OUT

M74HC161 REG_A (
    .CP                         (clk_i),
    .MRn                        (rst_n_i),

    .Di                         (RESULT),
    .PEn                        (LOAD0),
    .CEP                        (1'b0),
    .CET                        (1'b0),

    .TC                         (),
    .Qo                         (OUT0)
);

M74HC161 REG_B (
    .CP                         (clk_i),
    .MRn                        (rst_n_i),

    .Di                         (RESULT),
    .PEn                        (LOAD1),
    .CEP                        (1'b0),
    .CET                        (1'b0),

    .TC                         (),
    .Qo                         (OUT1)
);

M74HC161 REG_OUT (
    .CP                         (clk_i),
    .MRn                        (rst_n_i),

    .Di                         (RESULT),
    .PEn                        (LOAD2),
    .CEP                        (1'b0),
    .CET                        (1'b0),

    .TC                         (),
    .Qo                         (output_o)
);

// GENERATE PC VALUE, AUTO INC WITH CLK POSEDGE

M74HC161 REG_PC (
    .CP                         (clk_i),
    .MRn                        (rst_n_i),

    .Di                         (RESULT),
    .PEn                        (LOAD3),
    .CEP                        (1'b1),
    .CET                        (1'b1),

    .TC                         (),
    .Qo                         (MADDR)
);

// GENERATE ADDITION OPERATION DATA
// ADDER0 FROM REGISTER
// ADDER1 FROM INSTRUCTIONS

M74HC153 DATA_SEL_L (           //ZR=11 IN=10       B=01     A=00
    .IN1                        ({1'b0, input_i[0], OUT1[0], OUT0[0]}),
    .IN2                        ({1'b0, input_i[1], OUT1[1], OUT0[1]}),

    .ENn                        (1'b0),
    .SEL                        (OP[1:0]),

    .OUT                        (ADDER0[1:0])
);

M74HC153 DATA_SEL_H (           //ZR=11 IN=10       B=01     A=00
    .IN1                        ({1'b0, input_i[2], OUT1[2], OUT0[2]}),
    .IN2                        ({1'b0, input_i[3], OUT1[3], OUT0[3]}),

    .ENn                        (1'b0),
    .SEL                        (OP[1:0]),

    .OUT                        (ADDER0[3:2])
);

assign ADDER1[3:0] = IMM[3:0];

// ADDITION OPERATION, ALL INSTRUCTIONS GO THROUGH THE ADDER

M74HC283 DATA_ADDER (
    .A                          (ADDER0),
    .B                          (ADDER1),
    .Ci                         (1'b0),

    .S                          (RESULT),
    .Co                         ()
);

// READ MEMORY DATA BY PC VALUE

wire [15:0]                     MEM_DATA_SEL;
wire [7:0]                      MEM_DATA;

M74HC154 MEMORY_SEL (
    .A                          (MADDR),
    .ENn                        (2'b0),

    .Y                          (MEM_DATA_SEL)
);

assign MEM_DATA[7:0] = {8{~MEM_DATA_SEL[0] }} & ~MEMORY[0]
                     | {8{~MEM_DATA_SEL[1] }} & ~MEMORY[1]
                     | {8{~MEM_DATA_SEL[2] }} & ~MEMORY[2]
                     | {8{~MEM_DATA_SEL[3] }} & ~MEMORY[3]
                     | {8{~MEM_DATA_SEL[4] }} & ~MEMORY[4]
                     | {8{~MEM_DATA_SEL[5] }} & ~MEMORY[5]
                     | {8{~MEM_DATA_SEL[6] }} & ~MEMORY[6]
                     | {8{~MEM_DATA_SEL[7] }} & ~MEMORY[7]
                     | {8{~MEM_DATA_SEL[8] }} & ~MEMORY[8]
                     | {8{~MEM_DATA_SEL[9] }} & ~MEMORY[9]
                     | {8{~MEM_DATA_SEL[10]}} & ~MEMORY[10]
                     | {8{~MEM_DATA_SEL[11]}} & ~MEMORY[11]
                     | {8{~MEM_DATA_SEL[12]}} & ~MEMORY[12]
                     | {8{~MEM_DATA_SEL[13]}} & ~MEMORY[13]
                     | {8{~MEM_DATA_SEL[14]}} & ~MEMORY[14]
                     | {8{~MEM_DATA_SEL[15]}} & ~MEMORY[15];

M74HC540 MEMORY_DATA (
    .A                          (MEM_DATA),
    .OEn                        (2'b0),

    .Y                          (MDATA)
);

// CREATE REGISTER DATA LOAD SIGNAL, LOW ACTIVE

assign LOAD0 =  (OP[3] | OP[2]); // 00
assign LOAD1 =  (OP[3] | ~(OP[2] & 1'b1 & 1'b1)); // 01
assign LOAD2 = ~(OP[3] & ~(OP[2] & 1'b1 & 1'b1)); // 10
assign LOAD3 = ~(OP[3] & OP[2]); // 11

// APPENDIX

// OP       COMMAND         EQUAL
//
// 0000     ADD A, Im       A   = A  + Im
// 0001     MOV A, B        A   = B  + 0(Im)
// 0010     IN  A           A   = IN + 0(Im)
// 0011     MOV A, Im       A   = 0  + Im
//
// 0100     MOV B, A        B   = A  + 0(Im)
// 0101     ADD B, Im       B   = B  + Im
// 0110     IN  B           B   = IN + 0(Im)
// 0111     MOV B, Im       B   = 0  + Im
//
// 1000     OUT A           OUT = A  + (0)Im
// 1001     OUT B           OUT = B  + (0)Im
// 1010     X               OUT = 
// 1011     OUT Im          OUT = 0  + Im
//
// 1100     JMP A           PC  = A  + (0)Im
// 1101     JMP B           PC  = B  + (0)Im
// 1110     X               PC  = 
// 1111     JMP Im          PC  = 0  + Im

endmodule