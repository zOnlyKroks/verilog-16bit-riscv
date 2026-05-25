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

    // Internal wires for each shift stage
    wire [15:0] stage0, stage1, stage2, stage3;
    wire fill_bit = shift_arith ? data_in[15] : 1'b0;  // Sign bit for arithmetic shifts

    // Stage 0: Shift by 1 bit
    assign stage0 = shift_amount[0] ?
                    (shift_left ? {data_in[14:0], 1'b0} :
                                  {fill_bit, data_in[15:1]}) : data_in;

    // Stage 1: Shift by 2 bits
    assign stage1 = shift_amount[1] ?
                    (shift_left ? {stage0[13:0], 2'b00} :
                                  {{2{fill_bit}}, stage0[15:2]}) : stage0;

    // Stage 2: Shift by 4 bits
    assign stage2 = shift_amount[2] ?
                    (shift_left ? {stage1[11:0], 4'b0000} :
                                  {{4{fill_bit}}, stage1[15:4]}) : stage1;

    // Stage 3: Shift by 8 bits
    assign stage3 = shift_amount[3] ?
                    (shift_left ? {stage2[7:0], 8'b00000000} :
                                  {{8{fill_bit}}, stage2[15:8]}) : stage2;

    // Output assignment
    always @(*) begin
        data_out = stage3;
    end

endmodule