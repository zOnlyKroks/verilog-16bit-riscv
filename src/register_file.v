/*
 * 16-bit Register File for RISC-V CPU
 * 16 registers (x0-x15) - full 4-bit address space utilization
 * Copyright (c) 2024 Finn Rades (zOnlyKroks)
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module register_file (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  read_addr1,   // Read port 1 address (rs1) - 4 bits, 12 registers
    input  wire [3:0]  read_addr2,   // Read port 2 address (rs2) - 4 bits, 12 registers
    input  wire [3:0]  write_addr,   // Write port address (rd) - 4 bits, 12 registers
    input  wire [15:0] write_data,   // Write data
    input  wire        write_enable, // Write enable
    output wire [15:0] data_out1,    // Read port 1 data
    output wire [15:0] data_out2     // Read port 2 data
);

    // Register array: 12 x 16-bit registers (x0-x11) - good compromise
    reg [15:0] registers [11:0];

    // Initialize registers
    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 12; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
        end else if (write_enable && write_addr != 4'h0 && write_addr < 4'd12) begin
            // Don't write to register x0 (always zero) and only valid registers (x0-x11)
            registers[write_addr] <= write_data;
        end
    end

    // Read ports (combinatorial) - x0 always reads as zero, invalid addresses read as zero
    assign data_out1 = (read_addr1 == 4'h0 || read_addr1 >= 4'd12) ? 16'h0000 : registers[read_addr1];
    assign data_out2 = (read_addr2 == 4'h0 || read_addr2 >= 4'd12) ? 16'h0000 : registers[read_addr2];

endmodule