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

`include "pa_soc_param.v"

module pa_soc_uart (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [7:0]                   addr_i,
    input  wire                         data_rd_i,
    input  wire                         data_we_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   data_i,
    output wire [`DATA_BUS_WIDTH-1:0]   data_o,

    output wire                         pad_txd
);

localparam UART_BAUD                    = 32'd115200; // fixed!

localparam UART_REG_CR                  = 8'h00;
localparam UART_REG_SR                  = 8'h04;
localparam UART_REG_TXD                 = 8'h10;

localparam UART_STATE_IDLE              = 2'b00;
localparam UART_STATE_START             = 2'b01;
localparam UART_STATE_RUN               = 2'b10;
localparam UART_STATE_END               = 2'b11;

// [0]: tx enbale
reg  [`DATA_BUS_WIDTH-1:0]      _uart_cr;

// [0]: tx flag
reg  [`DATA_BUS_WIDTH-1:0]      _uart_sr;

// [7:0] : tx data
reg  [`DATA_BUS_WIDTH-1:0]      _uart_txd;


wire [`DATA_BUS_WIDTH-1:0]      uart_tx_clk_cycle;

reg  [`DATA_BUS_WIDTH-1:0]      uart_tx_clk_cnt;

wire                            uart_tx_clk_timeup;

// stop=1 datah...datal start=0 10bit=1
reg  [19:0]                     uart_tx_pipe;

reg  [1:0]                      uart_tx_state;

assign uart_tx_clk_cycle[`DATA_BUS_WIDTH-1:0] = `CPU_FREQ_HZ / UART_BAUD;

assign uart_tx_clk_timeup = (uart_tx_clk_cnt == uart_tx_clk_cycle[31:0]);

// uart tx pipeline

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_tx_clk_cnt <= `ZERO_WORD;
    end
    else if (uart_tx_clk_timeup) begin
        uart_tx_clk_cnt <= `ZERO_WORD;
    end
    else begin
        uart_tx_clk_cnt <= uart_tx_clk_cnt + 32'h1;
    end
end

reg                                     uart_tx_start;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_tx_start <= `INVALID;
    end
    else if (uart_tx_state[1:0] == UART_STATE_IDLE) begin
        if (_uart_cr[0] && (addr_i[7:0] == UART_REG_TXD) && data_we_i) begin
            uart_tx_start <= `VALID;
        end
    end
    else if (uart_tx_state[1:0] == UART_STATE_RUN) begin
        uart_tx_start <= `INVALID;
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_tx_state[1:0] <= UART_STATE_IDLE;
    end
    else if (uart_tx_clk_timeup) begin
        if (uart_tx_state[1:0] == UART_STATE_START) begin
            uart_tx_state[1:0] <= UART_STATE_RUN;
        end
        else if (uart_tx_start) begin
            uart_tx_state[1:0] <= UART_STATE_START;
        end
        else if (uart_tx_state[1:0] == UART_STATE_RUN) begin
            if (~uart_tx_pipe[0]) begin
                uart_tx_state[1:0] <= UART_STATE_END;
            end
        end
        else if (uart_tx_state[1:0] == UART_STATE_END) begin
            uart_tx_state[1:0] <= UART_STATE_IDLE;
        end
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_tx_pipe[19:0] <= 20'hf_ffff;
    end
    else if (uart_tx_clk_timeup) begin
        if (_uart_cr[0]) begin
        case (uart_tx_state[1:0])
            UART_STATE_IDLE  : uart_tx_pipe[19:0] <= {20'hf_ffff};
            UART_STATE_START : uart_tx_pipe[19:0] <= {1'b1, _uart_txd[7:0], 1'b0, 10'h3ff};
            UART_STATE_RUN   : uart_tx_pipe[19:0] <= {1'b1, uart_tx_pipe[19:1]};
            UART_STATE_END   : uart_tx_pipe[19:0] <= {20'hf_ffff};
        endcase
        end
    end
end

assign pad_txd = uart_tx_pipe[10];

wire                            uart_tx_idle;

assign uart_tx_idle = (uart_tx_state[1:0] == UART_STATE_IDLE);

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _uart_cr  <= 32'h0000_0001; //enable uart tx default
        _uart_sr  <= 32'h0000_0000;
        _uart_txd <= 32'hffff_ffff; //default high level
    end
    else if (_uart_cr[0] && (uart_tx_state[1:0] == UART_STATE_END)) begin
        _uart_sr  <= {_uart_sr[31:1], 1'b1};
    end
    else begin
        if (data_we_i) begin
        case (addr_i[7:0])
            UART_REG_CR  : _uart_cr  <= {data_i[31:0]};
            UART_REG_SR  : _uart_sr  <= {data_i[31:1], (_uart_sr[0] & ~data_i[0])};
            UART_REG_TXD : _uart_txd <= {24'b0, data_i[7:0]};
        endcase
        end
    end
end

reg  [`DATA_BUS_WIDTH-1:0]      _data;

always @ (*) begin
    _data = 32'h0000_0000;
    if (data_rd_i) begin
    case (addr_i[7:0])
        UART_REG_CR : _data = {_uart_cr[31:0]};
        UART_REG_SR : _data = {_uart_sr[31:1], (uart_tx_idle & _uart_sr[0])};
    endcase
    end
end

assign data_o[`DATA_BUS_WIDTH-1:0] = _data[`DATA_BUS_WIDTH-1:0];

endmodule