`timescale 1ns / 1ps

module mac_array_tb;

  parameter col = 8;
  parameter bw = 8;
  parameter bw_psum = 2*bw+6;
  parameter pr = 8;
  
  reg clk, reset;
  reg [1:0] inst;
  wire [col-1:0] fifo_wr;
  reg signed [pr*bw-1:0] in;
  wire signed [bw_psum*col-1:0] out;

  // Instantiate the DUT (Device Under Test)
  mac_array #(.col(col), .bw(bw), .bw_psum(bw_psum), .pr(pr)) dut (
    .clk(clk),
    .reset(reset),
    .in(in),
    .out(out),
    .fifo_wr(fifo_wr),
    .inst(inst)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    inst = 0;
    in = 0;
    
    // Apply reset
    #10 reset = 0;
    
    // Load data into in repeatedly to ensure processing occurs in all columns
    repeat (10) begin
      #10 inst = 2'b01;  // Load instruction
      in = $random;
    end
    
    #10 inst = 2'b00;  // Wait state
    
    #20 inst = 2'b10;  // Execute instruction
    
    #10 inst = 2'b00;  // Wait state
    
    #50 $finish;
  end

  // Monitor output
  initial begin
    $monitor("Time=%0t | inst=%b | in=%h | out=%h | fifo_wr=%b", 
             $time, inst, in, out, fifo_wr);
  end

  // Dump waveform to VCD file
  initial begin
    $dumpfile("mac_array.vcd");
    $dumpvars(0, mac_array_tb);
  end

endmodule