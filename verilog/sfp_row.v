// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp_row (clk, acc, div, fifo_ext_rd, sum_in, sum_out, sfp_in, sfp_out);

  parameter col = 8;
  parameter bw = 8;
  parameter bw_psum = 2*bw+4;

 
  input  clk, div, acc, fifo_ext_rd;
  input  [bw_psum+3:0] sum_in;          // sum of inputs from another core
  input  [col*bw_psum-1:0] sfp_in;      // input from array
  wire  [col*bw_psum-1:0] abs;          // absolute input
  reg    div_q;
  output [col*bw_psum-1:0] sfp_out;     // normalized output to pmem
  output [bw_psum+3:0] sum_out;         // the sum of inputs in this core
  wire [bw_psum+3:0] sum_this_core;
  wire [bw_psum+4:0] sum_2core;
  wire signed [bw_psum-1:0] sfp_in_sign0;
  wire signed [bw_psum-1:0] sfp_in_sign1;
  wire signed [bw_psum-1:0] sfp_in_sign2;
  wire signed [bw_psum-1:0] sfp_in_sign3;
  wire signed [bw_psum-1:0] sfp_in_sign4;
  wire signed [bw_psum-1:0] sfp_in_sign5;
  wire signed [bw_psum-1:0] sfp_in_sign6;
  wire signed [bw_psum-1:0] sfp_in_sign7;

  wire signed [bw_psum-1+8:0] sfp_in_sign0_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign1_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign2_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign3_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign4_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign5_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign6_shifted;
  wire signed [bw_psum-1+8:0] sfp_in_sign7_shifted;

  reg [bw_psum-1:0] sfp_out_sign0;
  reg [bw_psum-1:0] sfp_out_sign1;
  reg [bw_psum-1:0] sfp_out_sign2;
  reg [bw_psum-1:0] sfp_out_sign3;
  reg [bw_psum-1:0] sfp_out_sign4;
  reg [bw_psum-1:0] sfp_out_sign5;
  reg [bw_psum-1:0] sfp_out_sign6;
  reg [bw_psum-1:0] sfp_out_sign7;

  reg [bw_psum+3:0] sum_q;
  reg fifo_wr;

// seperate 8 data with sign
  assign sfp_in_sign0 =  sfp_in[bw_psum*1-1 : bw_psum*0];
  assign sfp_in_sign1 =  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign sfp_in_sign2 =  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign sfp_in_sign3 =  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign sfp_in_sign4 =  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign sfp_in_sign5 =  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign sfp_in_sign6 =  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign sfp_in_sign7 =  sfp_in[bw_psum*8-1 : bw_psum*7];

  assign sfp_in_sign0_shifted =  abs[bw_psum*1-1 : bw_psum*0];
  assign sfp_in_sign1_shifted =  abs[bw_psum*2-1 : bw_psum*1];
  assign sfp_in_sign2_shifted =  abs[bw_psum*3-1 : bw_psum*2];
  assign sfp_in_sign3_shifted =  abs[bw_psum*4-1 : bw_psum*3];
  assign sfp_in_sign4_shifted =  abs[bw_psum*5-1 : bw_psum*4];
  assign sfp_in_sign5_shifted =  abs[bw_psum*6-1 : bw_psum*5];
  assign sfp_in_sign6_shifted =  abs[bw_psum*7-1 : bw_psum*6];
  assign sfp_in_sign7_shifted =  abs[bw_psum*8-1 : bw_psum*7];


  assign sfp_out[bw_psum*1-1 : bw_psum*0] = sfp_out_sign0;
  assign sfp_out[bw_psum*2-1 : bw_psum*1] = sfp_out_sign1;
  assign sfp_out[bw_psum*3-1 : bw_psum*2] = sfp_out_sign2;
  assign sfp_out[bw_psum*4-1 : bw_psum*3] = sfp_out_sign3;
  assign sfp_out[bw_psum*5-1 : bw_psum*4] = sfp_out_sign4;
  assign sfp_out[bw_psum*6-1 : bw_psum*5] = sfp_out_sign5;
  assign sfp_out[bw_psum*7-1 : bw_psum*6] = sfp_out_sign6;
  assign sfp_out[bw_psum*8-1 : bw_psum*7] = sfp_out_sign7;

  assign sum_2core = sum_this_core[bw_psum+3:0] + sum_in[bw_psum+3:0];

// convert 2's comp input to abs
  assign abs[bw_psum*1-1 : bw_psum*0] = (sfp_in[bw_psum*1-1]) ?  (~sfp_in[bw_psum*1-1 : bw_psum*0] + 1)  :  sfp_in[bw_psum*1-1 : bw_psum*0];
  assign abs[bw_psum*2-1 : bw_psum*1] = (sfp_in[bw_psum*2-1]) ?  (~sfp_in[bw_psum*2-1 : bw_psum*1] + 1)  :  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign abs[bw_psum*3-1 : bw_psum*2] = (sfp_in[bw_psum*3-1]) ?  (~sfp_in[bw_psum*3-1 : bw_psum*2] + 1)  :  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign abs[bw_psum*4-1 : bw_psum*3] = (sfp_in[bw_psum*4-1]) ?  (~sfp_in[bw_psum*4-1 : bw_psum*3] + 1)  :  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign abs[bw_psum*5-1 : bw_psum*4] = (sfp_in[bw_psum*5-1]) ?  (~sfp_in[bw_psum*5-1 : bw_psum*4] + 1)  :  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign abs[bw_psum*6-1 : bw_psum*5] = (sfp_in[bw_psum*6-1]) ?  (~sfp_in[bw_psum*6-1 : bw_psum*5] + 1)  :  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign abs[bw_psum*7-1 : bw_psum*6] = (sfp_in[bw_psum*7-1]) ?  (~sfp_in[bw_psum*7-1 : bw_psum*6] + 1)  :  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign abs[bw_psum*8-1 : bw_psum*7] = (sfp_in[bw_psum*8-1]) ?  (~sfp_in[bw_psum*8-1 : bw_psum*7] + 1)  :  sfp_in[bw_psum*8-1 : bw_psum*7];
  
 ////////// Synchronization //////////

  fifo_depth16 #(.bw(bw_psum+4)) fifo_inst_int (
     .rd_clk(clk), 
     .wr_clk(clk), 
     .in(sum_q),
     .out(sum_this_core), 
     .rd(div_q), 
     .wr(fifo_wr), 
     .reset(reset)
  );

  fifo_depth16 #(.bw(bw_psum+4)) fifo_inst_ext (
     .rd_clk(clk), 
     .wr_clk(clk), 
     .in(sum_q),
     .out(sum_out), 
     .rd(fifo_ext_rd), 
     .wr(fifo_wr), 
     .reset(reset)
  );

  ////////// Calculation //////////

  always @ (posedge clk) begin
    if (reset) begin
      fifo_wr <= 0;
    end
    else begin
       div_q <= div ;
       if (acc) begin     // calculate sum
         sum_q <= 
           {4'b0, abs[bw_psum*1-1 : bw_psum*0]} +
           {4'b0, abs[bw_psum*2-1 : bw_psum*1]} +
           {4'b0, abs[bw_psum*3-1 : bw_psum*2]} +
           {4'b0, abs[bw_psum*4-1 : bw_psum*3]} +
           {4'b0, abs[bw_psum*5-1 : bw_psum*4]} +
           {4'b0, abs[bw_psum*6-1 : bw_psum*5]} +
           {4'b0, abs[bw_psum*7-1 : bw_psum*6]} +
           {4'b0, abs[bw_psum*8-1 : bw_psum*7]} ;
         fifo_wr <= 1;
       end
       else begin
         fifo_wr <= 0;
         if (div) begin   // normalize all data
           sfp_out_sign0 <= {sfp_in_sign0_shifted,8'b0} / sum_2core;
           sfp_out_sign1 <= {sfp_in_sign1_shifted,8'b0} / sum_2core;
           sfp_out_sign2 <= {sfp_in_sign2_shifted,8'b0} / sum_2core;
           sfp_out_sign3 <= {sfp_in_sign3_shifted,8'b0} / sum_2core;
           sfp_out_sign4 <= {sfp_in_sign4_shifted,8'b0} / sum_2core;
           sfp_out_sign5 <= {sfp_in_sign5_shifted,8'b0} / sum_2core;
           sfp_out_sign6 <= {sfp_in_sign6_shifted,8'b0} / sum_2core;
           sfp_out_sign7 <= {sfp_in_sign7_shifted,8'b0} / sum_2core;
         end
       end
   end
 end

endmodule

