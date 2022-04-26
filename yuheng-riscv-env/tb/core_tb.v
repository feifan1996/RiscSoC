`timescale 1ns / 1ps
/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date             Author      Notes
 * 2021-10-29       Lyons       first version
 * 2022-04-04       Lyons       v2.0
 */

module core_tb(
    );

`include "pa_chip_param.v"

reg                             sys_clk;
reg                             sys_rst_n;

wire                            TXD;

initial begin
`ifdef DUMP_VCD
    $dumpfile("wave.vcd");
    $dumpvars(0, core_tb);
`endif
end

pa_chip_top u_pa_chip_top (
    .clk_i                      (sys_clk),
    .rst_n_i                    (sys_rst_n),

    .rxd                        (),
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

`ifndef ROM_MODE_BRAM
    $readmemh("image.pat", u_pa_chip_top.u_pa_perips_rom._ram);
`endif
end

always begin
    @ (posedge sys_clk) sys_rst_n = 0;
    @ (posedge sys_clk) sys_rst_n = 1;

    while (1) begin
        @ (posedge sys_clk);
    end

    $stop();
end

`ifdef TEST_ISA

wire [`DATA_BUS_WIDTH-1:0]      x3  = u_pa_chip_top.u_pa_core_top.u_pa_core_rtu.u_pa_core_xreg._x3 ;
wire [`DATA_BUS_WIDTH-1:0]      x26 = u_pa_chip_top.u_pa_core_top.u_pa_core_rtu.u_pa_core_xreg._x26;
wire [`DATA_BUS_WIDTH-1:0]      x27 = u_pa_chip_top.u_pa_core_top.u_pa_core_rtu.u_pa_core_xreg._x27;

always begin
    wait (x26 == 32'b1);
    # (100);

    if (x27 == 32'b1) begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    ####  ~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #      ~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    ####  ~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       # ~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    # ~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    ####  ~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    else begin
        $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~ ######   ##       #    #      ~~~~~~~~~");
        $display("~~~~~~~~~~ #       #  #      #    #      ~~~~~~~~~");
        $display("~~~~~~~~~~ #####  #    #     #    #      ~~~~~~~~~");
        $display("~~~~~~~~~~ #      ######     #    #      ~~~~~~~~~");
        $display("~~~~~~~~~~ #      #    #     #    #      ~~~~~~~~~");
        $display("~~~~~~~~~~ #      #    #     #    ###### ~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("fail testnum = %2d", x3);
    end

    $stop();
end

`endif

always #((32'd1_000_000_000/`CPU_FREQ_HZ)/2) sys_clk = ~sys_clk;

endmodule