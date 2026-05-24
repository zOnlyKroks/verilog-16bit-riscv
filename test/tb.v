`default_nettype none
`timescale 1ns / 1ps

/* Testbench for 8-bit RISC-V processor
 * Tests basic functionality including Fibonacci sequence generation
 */
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Input signal mapping for readability
  wire prog_mode = ui_in[0];
  wire debug_en  = ui_in[1];
  wire step_mode = ui_in[2];
  wire [3:0] prog_data = ui_in[6:3];
  wire prog_clk = ui_in[7];

  // Output signal mapping
  wire [3:0] pc_out = uo_out[3:0];
  wire [3:0] reg_out = uo_out[7:4];
  wire [3:0] data_bus = uio_out[3:0];
  wire [1:0] addr_out = uio_out[5:4];
  wire cpu_halt = uio_out[6];
  wire output_valid = uio_out[7];

  // 8-bit RISC-V processor instance
  tt_um_zonlykroks_8bit_riscv user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Initialize signals for cocotb (no test sequence - cocotb controls the simulation)
  initial begin
    // Initialize signals
    rst_n = 0;
    ena = 1;
    ui_in = 8'h00;
    uio_in = 8'h00;
    // Let cocotb control the rest
  end

  // Monitor removed - cocotb handles test monitoring

endmodule
