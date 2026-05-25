/*
 * Shared Circuit Multiplier for RISC-V CPU
 * Reuses ALU and barrel shifter for area-efficient multiplication
 * Copyright (c) 2024 Finn Rades (zOnlyKroks)
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module shared_multiplier (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,        // Start multiplication
    input  wire [15:0] a,           // Multiplicand
    input  wire [15:0] b,           // Multiplier
    input  wire        high_result, // 1=return high 16 bits, 0=return low 16 bits

    output reg  [15:0] result,      // Multiplication result
    output reg         done,        // Multiplication complete

    // Shared resource interfaces
    output reg  [15:0] alu_a,       // ALU input A
    output reg  [15:0] alu_b,       // ALU input B
    output reg         alu_add,     // ALU operation (1=add, 0=sub)
    input  wire [15:0] alu_result,  // ALU result

    output reg  [15:0] shift_data,  // Shifter input
    output reg  [3:0]  shift_amount,// Shift amount
    output reg         shift_left,  // Shift direction
    input  wire [15:0] shift_result // Shifter result
);

    // State machine
    localparam IDLE = 2'b00;
    localparam MULTIPLY = 2'b01;
    localparam DONE_STATE = 2'b10;

    reg [1:0] state;
    reg [31:0] accumulator;  // 32-bit accumulator
    reg [15:0] multiplicand; // Current multiplicand
    reg [15:0] multiplier;   // Current multiplier
    reg [4:0]  counter;      // Bit counter

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 1'b0;
            result <= 16'h0000;
            accumulator <= 32'h00000000;
            counter <= 5'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= MULTIPLY;
                        accumulator <= 32'h00000000;
                        multiplicand <= a;
                        multiplier <= b;
                        counter <= 5'd16;  // 16 iterations
                    end
                end

                MULTIPLY: begin
                    if (counter == 0) begin
                        state <= DONE_STATE;
                        result <= high_result ? accumulator[31:16] : accumulator[15:0];
                    end else begin
                        // Shift and add algorithm
                        if (multiplier[0]) begin
                            // Add multiplicand to accumulator
                            accumulator <= accumulator + {16'h0000, multiplicand};
                        end
                        // Shift multiplier right, multiplicand left
                        multiplier <= multiplier >> 1;
                        multiplicand <= multiplicand << 1;
                        counter <= counter - 1;
                    end
                end

                DONE_STATE: begin
                    done <= 1'b1;
                    if (!start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // ALU interface (for additions)
    always @(*) begin
        alu_a = accumulator[15:0];
        alu_b = multiplicand;
        alu_add = 1'b1;  // Always addition

        // Shifter interface (for shifts)
        shift_data = (counter[0]) ? multiplier : multiplicand;
        shift_amount = 4'd1;
        shift_left = counter[0];  // Alternate between left and right
    end

endmodule