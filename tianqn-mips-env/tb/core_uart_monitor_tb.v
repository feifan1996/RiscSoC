`timescale 1ns / 1ps
/*
 * Copyright (c) 2020-2021, SERI Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-10-29     Lyons        first version
 */

`include "pa_soc_param.v"

module core_uart_monitor_tb (
    input  wire                 clk_i,
    input  wire                 rst_n_i,

    input  wire                 rxd,
    output wire                 txd
);

`define UART_BAUD               32'd115200 // fixed!

wire [31:0]                     uart_rx_clk_cycle;

reg  [31:0]                     uart_rx_clk_cnt;

wire                            uart_rx_clk_timeup;

assign uart_rx_clk_cycle[31:0] = `CPU_FREQ_HZ / `UART_BAUD;

assign uart_rx_clk_timeup = (uart_rx_clk_cnt == uart_rx_clk_cycle[30:0]);

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_rx_clk_cnt <= 0;
    end
    else if (uart_rx_clk_timeup) begin
        uart_rx_clk_cnt <= 0;
    end
    else begin
        uart_rx_clk_cnt <= uart_rx_clk_cnt + 1;
    end
end

// stop=1 datah...datal start=0 10bit-1
reg  [8:0]                      uart_rx_pipe;
reg  [7:0]                      uart_rx_data;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_rx_pipe[8:0] <= 9'h1ff;
    end
    else if (uart_rx_clk_timeup) begin
        uart_rx_pipe[8:0] <= {rxd, uart_rx_pipe[8:1]};
    end
end

always @ (negedge uart_rx_pipe[0]) begin
    uart_rx_data[7:0] <= uart_rx_pipe[8:1];
    uart_rx_pipe[8:0] <= 9'h1ff;
end

reg  [7:0]                      data_buffer [0:127];
reg  [7:0]                      data_length;

integer                         i;

reg                             debug_mode;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        data_length <= 0;
        debug_mode <= 0;
    end
    else if (debug_mode || (uart_rx_data == 8'h1b)) begin
        if (uart_rx_data == 8'h1b) begin
            debug_mode <= 1;
        end
        else if (debug_mode) begin
            if (uart_rx_data == 8'h04) begin
                $write("DEBG: SIMULATION END.\n");
                $stop();
            end
            if (uart_rx_data != 8'hff) begin // 0xff is default rx value
                debug_mode <= 0;
            end
        end
    end
    else if (uart_rx_data == 8'h0a) begin
        $write("UART: ");
        for (i=0; i<data_length; i=i+1) begin
            $write("%s", data_buffer[i]);
        end
        $write("\n");

        data_length <= 0;
    end
    else if (uart_rx_data == 8'h0d) begin
        // '\r' is no used under simulation.
    end
    else if (uart_rx_data != 8'hff) begin
        data_buffer[data_length] <= uart_rx_data;
        data_length <= data_length + 1;

        if (data_length == 8'd128) begin
            $write("UART: ");
            for (i=0; i<data_length; i=i+1) begin
                $write("%s", data_buffer[i]);
            end
            $write("\n");

            data_length <= 0;
        end
    end

    uart_rx_data <= 8'hff;
end

endmodule