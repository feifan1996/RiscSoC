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

`include "pa_chip_param.v"

module pa_perips_uart (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [7:0]                   addr_i,
    input  wire                         data_rd_i,
    input  wire                         data_we_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   data_i,
    output wire [`DATA_BUS_WIDTH-1:0]   data_o,

    input  wire                         pad_rxd,
    output wire                         pad_txd
);

localparam UART_BAUD                    = 32'd115200; // fixed!

localparam UART_REG_CR                  = 8'h00;
localparam UART_REG_SR                  = 8'h04;
localparam UART_REG_BAUD                = 8'h08;
localparam UART_REG_RXD                 = 8'h0c;
localparam UART_REG_TXD                 = 8'h10;

localparam UART_STATE_IDLE              = 2'b00;
localparam UART_STATE_START             = 2'b01;
localparam UART_STATE_RUN               = 2'b10;
localparam UART_STATE_END               = 2'b11;

wire                                    pin_rxd;

assign pin_rxd = pad_rxd;

// [0]: tx enbale
// [1]: rx enbale
reg  [`DATA_BUS_WIDTH-1:0]              _uart_cr;

// [0]: tx flag
// [1]: rx flag
reg  [`DATA_BUS_WIDTH-1:0]              _uart_sr;

// [31:0] : baud
reg  [`DATA_BUS_WIDTH-1:0]              _uart_baud;

// [31:0] : rx data
reg  [`DATA_BUS_WIDTH-1:0]              _uart_rxd;

// [31:0] : tx data
reg  [`DATA_BUS_WIDTH-1:0]              _uart_txd;


wire [`DATA_BUS_WIDTH-1:0]              uart_tx_clk_cycle;
wire [`DATA_BUS_WIDTH-1:0]              uart_rx_clk_cycle;

reg  [`DATA_BUS_WIDTH-1:0]              uart_tx_clk_cnt;
reg  [`DATA_BUS_WIDTH-1:0]              uart_rx_clk_cnt;

wire                                    uart_tx_clk_timeup;
wire                                    uart_rx_clk_timeup;

// stop=1 datah...datal start=0 10bit=1
reg  [19:0]                             uart_tx_pipe;
reg  [8:0]                              uart_rx_pipe;

reg  [1:0]                              uart_tx_state;
reg  [1:0]                              uart_rx_state;

assign uart_tx_clk_cycle[`DATA_BUS_WIDTH-1:0] = `CPU_FREQ_HZ / UART_BAUD;
assign uart_rx_clk_cycle[`DATA_BUS_WIDTH-1:0] = `CPU_FREQ_HZ / UART_BAUD;

assign uart_tx_clk_timeup = (uart_tx_clk_cnt == uart_tx_clk_cycle[31:0]);
assign uart_rx_clk_timeup = (uart_rx_clk_cnt == uart_rx_clk_cycle[31:0]);

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

// uart rx pipeline

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_rx_clk_cnt <= `ZERO_WORD;
    end
    else if (uart_rx_state[1:0] == UART_STATE_IDLE) begin
        uart_rx_clk_cnt <= `ZERO_WORD;
    end
    else if (uart_rx_clk_timeup) begin
        uart_rx_clk_cnt <= `ZERO_WORD;
    end
    else begin
        uart_rx_clk_cnt <= uart_rx_clk_cnt + 32'h1;
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_rx_state[1:0] <= UART_STATE_IDLE;
    end
    else if (uart_rx_state[1:0] == UART_STATE_IDLE) begin
        if (~pin_rxd) begin
            uart_rx_state[1:0] <= UART_STATE_RUN;
        end
    end
    else if (uart_rx_clk_timeup) begin
        if (uart_rx_state[1:0] == UART_STATE_RUN) begin
            if (~uart_rx_pipe[0]) begin
                uart_rx_state[1:0] <= UART_STATE_END;
            end
        end
        else if (uart_rx_state[1:0] == UART_STATE_END) begin
            uart_rx_state[1:0] <= UART_STATE_IDLE;
        end
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        uart_rx_pipe[8:0] <= 9'h1ff;
    end
    else if (_uart_cr[1]) begin
        if (uart_tx_clk_timeup) begin
        case (uart_rx_state[1:0])
            UART_STATE_IDLE  : uart_rx_pipe[8:0] <= {9'h1ff};
            UART_STATE_START : uart_rx_pipe[8:0] <= {9'h1ff};
            UART_STATE_RUN   : uart_rx_pipe[8:0] <= {pin_rxd, uart_rx_pipe[8:1]};
            UART_STATE_END   : uart_rx_pipe[8:0] <= {uart_rx_pipe[8:0]}; //keep 1-uart-clk
        endcase
        end
    end
end

wire                                    uart_tx_idle;
wire                                    uart_rx_idle;

assign uart_tx_idle = (uart_tx_state[1:0] == UART_STATE_IDLE);
assign uart_rx_idle = (uart_rx_state[1:0] == UART_STATE_IDLE);

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _uart_cr   <= 32'h0000_0003; // enable uart rx/tx default
        _uart_sr   <= 32'h0000_0000;
        _uart_baud <= UART_BAUD; // read-only
        _uart_rxd  <= 32'hffff_ffff; // default high level
        _uart_txd  <= 32'hffff_ffff; // default high level
    end
    else if (_uart_cr[0] && (uart_tx_state[1:0] == UART_STATE_END)) begin
        _uart_sr  <= {_uart_sr[31:1], 1'b1};
    end
    else if (_uart_cr[1] && (uart_rx_state[1:0] == UART_STATE_END)) begin
        _uart_sr  <= {_uart_sr[31:2], 1'b1, _uart_sr[0]};
        _uart_rxd <= {24'b0, uart_rx_pipe[8:1]};
    end
    else begin
        if (data_we_i) begin
        case (addr_i[7:0])
            UART_REG_CR  : _uart_cr  <= {data_i[31:0]};
            UART_REG_SR  : _uart_sr  <= {data_i[31:2], (_uart_sr[1] & ~data_i[1]), (_uart_sr[0] & ~data_i[0])};
            UART_REG_TXD : _uart_txd <= {24'b0, data_i[7:0]};
        endcase
        end
    end
end

reg  [`DATA_BUS_WIDTH-1:0]              _data = `ZERO_WORD;

always @ (posedge clk_i) begin
    if (data_rd_i) begin
    case (addr_i[7:0])
        UART_REG_CR   : _data <= {_uart_cr[31:0]};
        UART_REG_SR   : _data <= {_uart_sr[31:2], (uart_rx_idle & _uart_sr[1]), (uart_tx_idle & _uart_sr[0])};
        UART_REG_BAUD : _data <= {_uart_baud[31:0]};
        UART_REG_RXD  : _data <= {24'b0, _uart_rxd[7:0]};
        UART_REG_TXD  : _data <= {24'b0, _uart_txd[7:0]};
        default       : _data <= {32'h0000_0000};
    endcase
    end
end

assign data_o[`DATA_BUS_WIDTH-1:0] = _data[`DATA_BUS_WIDTH-1:0];

endmodule