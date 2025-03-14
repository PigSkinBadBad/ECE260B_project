`timescale 1ns / 1ps

module mac_col_tb;

  parameter bw = 8;
  parameter bw_psum = 2*bw+6;
  parameter pr = 8;
  parameter col_id = 0;
  
  reg clk, reset;
  reg [1:0] i_inst;
  wire [1:0] o_inst;
  wire fifo_wr;
  reg signed [pr*bw-1:0] q_in;
  wire signed [pr*bw-1:0] q_out;
  wire signed [bw_psum-1:0] out;

  // Instantiate the DUT (Device Under Test)
  mac_col #(.bw(bw), .bw_psum(bw_psum), .pr(pr), .col_id(col_id)) dut (
    .clk(clk),
    .reset(reset),
    .out(out),
    .q_in(q_in),
    .q_out(q_out),
    .i_inst(i_inst),
    .fifo_wr(fifo_wr),
    .o_inst(o_inst)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    i_inst = 0;
    q_in = 0;
    
    // Apply reset
    #10 reset = 0;
    
    // Load data into q_in repeatedly to ensure cnt_q reaches at least 8
    repeat (10) begin
      #10 i_inst = 2'b01;  // Load instruction
      q_in = $random;
    end
    
    #10 i_inst = 2'b00;  // Wait state
    
    #20 i_inst = 2'b10;  // Execute instruction
    
    #10 i_inst = 2'b00;  // Wait state
    
    #50 $finish;
  end

  // Monitor output
  initial begin
    $monitor("Time=%0t | i_inst=%b | q_in=%h | q_out=%h | out=%h | fifo_wr=%b", 
             $time, i_inst, q_in, q_out, out, fifo_wr);
  end

  // Dump waveform to VCD file
  initial begin
    $dumpfile("mac_col.vcd");
    $dumpvars(0, mac_col_tb);
  end

endmodule