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

module core_tb(
    );

`define CPU_CYCLE               (32'd1_000_000_000/`CPU_FREQ_HZ)

reg                             sys_clk;
reg                             sys_rst_n;

reg  [3:0]                      key;
wire [3:0]                      led;

initial begin
`ifdef DUMP_VCD
    $dumpfile("wave.vcd");
    $dumpvars(0, core_tb);
`endif
end

pa_soc_cpu u_pa_soc_cpu (
    .clk_i                      (sys_clk),
    .rst_n_i                    (sys_rst_n),

    .input_i                    (key),
    .output_o                   (led)
);

initial begin
    sys_clk = 1;
    sys_rst_n = 0;
end

initial begin
    key = 0;
end

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

initial begin
    u_pa_soc_cpu.MEMORY[ 0] = 8'b1011_0001;
    u_pa_soc_cpu.MEMORY[ 1] = 8'b1011_0010;
    u_pa_soc_cpu.MEMORY[ 2] = 8'b1011_0100;
    u_pa_soc_cpu.MEMORY[ 3] = 8'b1011_1000;
    u_pa_soc_cpu.MEMORY[ 4] = 8'b1011_0001;
    u_pa_soc_cpu.MEMORY[ 5] = 8'b1011_0010;
    u_pa_soc_cpu.MEMORY[ 6] = 8'b1011_0100;
    u_pa_soc_cpu.MEMORY[ 7] = 8'b1011_1000;
    u_pa_soc_cpu.MEMORY[ 8] = 8'b1011_0001;
    u_pa_soc_cpu.MEMORY[ 9] = 8'b1011_0010;
    u_pa_soc_cpu.MEMORY[10] = 8'b1011_0100;
    u_pa_soc_cpu.MEMORY[11] = 8'b1011_1000;
    u_pa_soc_cpu.MEMORY[12] = 8'b1011_0001;
    u_pa_soc_cpu.MEMORY[13] = 8'b1011_0010;
    u_pa_soc_cpu.MEMORY[14] = 8'b1011_0100;
    u_pa_soc_cpu.MEMORY[15] = 8'b1011_1000;
end

always begin
    @ (posedge sys_clk) sys_rst_n = 0;
    @ (posedge sys_clk) sys_rst_n = 1;

    repeat (16) begin
        @ (posedge sys_clk);
    end

    $stop();
end

always #(`CPU_CYCLE/2) sys_clk = ~sys_clk;

endmodule