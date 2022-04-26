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

module pa_perips_timer (
    input  wire                         clk_i,
    input  wire                         rst_n_i,

    input  wire [7:0]                   addr_i,
    input  wire                         data_rd_i,
    input  wire                         data_we_i,
    input  wire [`DATA_BUS_WIDTH-1:0]   data_i,
    output wire [`DATA_BUS_WIDTH-1:0]   data_o,

    output wire                         irq_o
);

localparam TIMER_REG_CR                 = 8'h00;
localparam TIMER_REG_SR                 = 8'h04;
localparam TIMER_REG_PSC                = 8'h08;
localparam TIMER_REG_LOAD               = 8'h0c;
localparam TIMER_REG_COUNT              = 8'h10;

// [0]: enbale
reg  [`DATA_BUS_WIDTH-1:0]              _timer_cr;

// [0]: timing-up flag
reg  [`DATA_BUS_WIDTH-1:0]              _timer_sr;

// [31:0] : prescale, need sub 1
reg  [`DATA_BUS_WIDTH-1:0]              _timer_psc;

// [31:0] : load value
reg  [`DATA_BUS_WIDTH-1:0]              _timer_load;

// [31:0] : count
reg  [`DATA_BUS_WIDTH-1:0]              _timer_count;


reg  [`DATA_BUS_WIDTH-1:0]              timer_clk_cnt;

wire                                    timer_clk_timeup;

assign timer_clk_timeup = (timer_clk_cnt == _timer_psc[31:0]);

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        timer_clk_cnt <= `ZERO_WORD;
    end
    else if (_timer_cr[0]) begin
        if (timer_clk_timeup) begin
            timer_clk_cnt <= `ZERO_WORD;
        end
        else begin
            timer_clk_cnt <= timer_clk_cnt + 32'h1;
        end
    end
    else begin
        timer_clk_cnt <= `ZERO_WORD;
    end
end

reg                                     timer_timeup;

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        timer_timeup <= 1'b0;
    end
    else if (_timer_cr[0]) begin
        if (timer_timeup) begin
            timer_timeup <= 1'b0;
        end
        else if (_timer_count == 32'h0) begin
            timer_timeup <= 1'b1;
        end
    end
    else begin
        timer_timeup <= 1'b0;
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _timer_count <= _timer_load;
    end
    else if (_timer_cr[0]) begin
        if (_timer_count == 32'h0) begin
            _timer_count <= _timer_load; // re-load timer value
        end
        else if (timer_clk_timeup) begin
            _timer_count <= _timer_count - 32'h1;
        end
    end
    else begin
        _timer_count <= _timer_load;
    end
end

always @ (posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        _timer_cr   <= `ZERO_WORD;
        _timer_sr   <= `ZERO_WORD;
        _timer_psc  <= `ZERO_WORD;
        _timer_load <= `ZERO_WORD;
    end
    else begin
        if (data_we_i) begin
        case (addr_i[7:0])
            TIMER_REG_CR   : _timer_cr   <= {data_i[31:0]};
            TIMER_REG_SR   : _timer_sr   <= {data_i[31:1], (_timer_sr[0] & ~data_i[0])};
            TIMER_REG_PSC  : _timer_psc  <= {data_i[31:0]};
            TIMER_REG_LOAD : _timer_load <= {data_i[31:0]};
        endcase
        end
        else if (_timer_sr[0]) begin
            _timer_sr <= {data_i[31:1], 1'b0};
        end
        else begin
            if (_timer_cr[0] && timer_timeup) begin
                _timer_sr <= {data_i[31:1], 1'b1};
            end
        end
    end
end

reg  [`DATA_BUS_WIDTH-1:0]              _data = `ZERO_WORD;

always @ (posedge clk_i) begin
    if (data_rd_i) begin
    case (addr_i[7:0])
        TIMER_REG_CR    : _data <= _timer_cr;
        TIMER_REG_SR    : _data <= _timer_sr;
        TIMER_REG_PSC   : _data <= _timer_psc;
        TIMER_REG_LOAD  : _data <= _timer_load;
        TIMER_REG_COUNT : _data <= _timer_count;
        default         : _data <= `ZERO_WORD;
    endcase
    end
end

assign data_o[`DATA_BUS_WIDTH-1:0] = _data[`DATA_BUS_WIDTH-1:0];

assign irq_o = _timer_sr[0];

endmodule