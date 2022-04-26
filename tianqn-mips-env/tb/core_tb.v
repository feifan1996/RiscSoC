`timescale 1ns / 1ps
/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2022-01-17     Lyons        first version
 */

`include "pa_soc_param.v"

module core_tb(
    );

`define CPU_CYCLE               (32'd1_000_000_000/`CPU_FREQ_HZ)

reg                             sys_clk;
reg                             sys_rst_n;

wire                            TXD;

initial begin
`ifdef DUMP_VCD
    $dumpfile("wave.vcd");
    $dumpvars(0, core_tb);
`endif
end

pa_soc_core u_pa_soc_core (
    .clk_i                      (sys_clk),
    .rst_n_i                    (sys_rst_n),

    .txd                        (TXD)
);

core_uart_monitor_tb u_core_uart_monitor_tb (
    .clk_i                      (sys_clk),
    .rst_n_i                    (sys_rst_n),

    .rxd                        (TXD),
    .txd                        ()
);

initial begin
    sys_clk = 1;
    sys_rst_n = 0;

    $readmemh("image.pat", u_pa_soc_core.u_pa_soc_itcm._rom);
end

always begin
    @ (posedge sys_clk) sys_rst_n = 0;
    @ (posedge sys_clk) sys_rst_n = 1;

    while (1) begin
        @ (posedge sys_clk);
    end

    $stop();
end

wire [`DATA_BUS_WIDTH-1:0]      k0 = u_pa_soc_core.u_pa_soc_xreg._xreg[26];
`ifdef TEST_ISA
wire [`DATA_BUS_WIDTH-1:0]      k1 = u_pa_soc_core.u_pa_soc_xreg._xreg[27];
`endif

always begin
    wait (k0 == 32'b1);
    # (`CPU_CYCLE*2);

`ifdef TEST_ISA
    if (k1 == 32'b1) begin
        $display("TEST PASSED.");
    end
    else begin
        $display("TEST FAILED!");
    end
`endif

    $stop();
end

always #(`CPU_CYCLE/2) sys_clk = ~sys_clk;

endmodule