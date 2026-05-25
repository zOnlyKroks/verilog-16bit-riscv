/*
 * Shared Barrel Shifter for RISC-V CPU
 * Supports SLL, SRL, SRA with single hardware unit
 * Copyright (c) 2024 Finn Rades (zOnlyKroks)
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module barrel_shifter (
    input  wire [15:0] data_in,      // Input data to shift
    input  wire [3:0]  shift_amount, // Shift amount (0-15)
    input  wire        shift_left,   // 1=left, 0=right
    input  wire        shift_arith,  // 1=arithmetic, 0=logical (for right shifts)
    output reg  [15:0] data_out      // Shifted result
);

    // Optimized single-stage shift implementation
    wire fill_bit = shift_arith & data_in[15];  // Optimized fill bit logic

    // Single combinational shift logic
    always @(*) begin
        if (shift_left) begin
            data_out = data_in << shift_amount;
        end else begin
            if (shift_arith) begin
                data_out = $signed(data_in) >>> shift_amount;
            end else begin
                data_out = data_in >> shift_amount;
            end
        end
    end

endmodule