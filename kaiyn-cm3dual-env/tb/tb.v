`timescale 1ns/1ns
/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date         Author          Notes
 * 2022-03-27   Lyons           first version
 */

module tb (
);

`define CLK_CYCLE_NS            32'd10

reg                             sys_clk;
reg                             sys_rst_n;

wire                            TRSTn;
wire                            TCK;
wire                            TDI;
wire                            TMS;
wire                            TDO;

pullup (TRSTn);
pulldown (TCK);
pullup (TDI);
pullup (TMS);
pullup (TDO);

wire  [15:0]                    GPIO;

wire                            RXD0;
wire                            TXD0;

wire                            RXD1;
wire                            TXD1;

tran (RXD0, TXD0);
tran (RXD1, TXD1);

wire  [17:0]                    EMIADDR;
wire  [15:0]                    EMIDATA;
wire                            EMIWEn;
wire                            EMIOEn;
wire                            EMICEn;
wire                            EMILBn;
wire                            EMIUBn;

initial begin
`ifdef DUMP_VCD
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
`endif
end

sys #(
    .IMAGE0                     ("image0.pat"),
    .IMAGE1                     ("image1.pat")
) u_sys (
    .XTAL                       (sys_clk),
    .NRST                       (sys_rst_n),

    .TEST                       (1'b0),

    .TRSTn                      (TRSTn),
    .TCK                        (TCK),
    .TDI                        (TDI),
    .TMS                        (TMS),
    .TDO                        (TDO),

    .GPIO                       (GPIO),

    .EMIADDR                    (EMIADDR),
    .EMIDATA                    (EMIDATA),
    .EMIWEn                     (EMIWEn),
    .EMIOEn                     (EMIOEn),
    .EMICEn                     (EMICEn),
    .EMILBn                     (EMILBn),
    .EMIUBn                     (EMIUBn),

    .RXD0                       (RXD0),
    .TXD0                       (TXD0),

    .RXD1                       (RXD1),
    .TXD1                       (TXD1)
);

initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    repeat (20) @(negedge sys_clk);    
    sys_rst_n = 1;
end

initial begin
    #500000000;
    $finish();
end

wire                            charflag = GPIO[7];
wire  [7:0]                     chardata = {1'b0, GPIO[6:0]};

always @ (charflag) begin
    if (charflag) begin
        $write("%c", chardata);
    end
end

pulldown (GPIO[8]);
pulldown (GPIO[9]);

// wire test_complete = u_sys.u_cm0.cm0_r07;
// wire test_pass = u_sys.u_cm0.cm0_r06;

wire test_timestamp = GPIO[10];
wire test_complete = GPIO[9];
wire test_pass = GPIO[8];

always @ (posedge test_timestamp) begin
    if (test_timestamp) begin
        $display("[DEBG] Time: %-d", $time());
    end
end

always @ (posedge sys_clk) begin
    if (test_complete) begin
        if (test_pass) begin
            $display("[DEBG] TEST PASS.");
        end
        else begin
            $display("[DEBG] TEST FAIL!");
        end
        $finish();
    end
end

always #(`CLK_CYCLE_NS/2) sys_clk = ~sys_clk;

endmodule