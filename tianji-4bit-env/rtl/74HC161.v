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

module M74HC161 (
    input                       CP,
    input                       MRn,
           
    input  [3:0]                Di,
    input                       PEn,
    input                       CEP,
    input                       CET,
           
    output                      TC,
    output [3:0]                Qo
);

reg  [3:0]                      COUNT;
reg                             TCO;

always @ (posedge CP or negedge MRn) begin
    if (!MRn) begin
        COUNT[3:0] <= 4'b0;
    end
    else if (!PEn) begin
        COUNT[3:0] <= Di[3:0];
    end
    else if (CEP && CET) begin
        COUNT[3:0] <= COUNT[3:0] + 4'b1;
    end
    else begin
        COUNT[3:0] <= COUNT[3:0];
    end
end

always @ (posedge CP or negedge MRn) begin
    if (!MRn) begin
        TCO <= 1'b0;
    end
    else if (!PEn) begin
        if (4'b1111 == COUNT[3:0]) begin
            TCO <= 1'b1;
        end
        else begin
            TCO <= 1'b0;
        end
    end
    else if (CEP && CET) begin
        if (4'b1111 == COUNT[3:0]) begin
            TCO <= 1'b1;
        end
        else begin
            TCO <= 1'b0;
        end
    end
    else if (!CET) begin
        TCO <= 1'b0;
    end
    else if (!CEP) begin
        if (4'b1111 == COUNT[3:0]) begin
            TCO <= 1'b1;
        end
        else begin
            TCO <= 1'b0;
        end
    end
    else begin
        TCO <= TCO;
    end
end

assign Qo[3:0] = COUNT[3:0];
assign TC = TCO;

endmodule