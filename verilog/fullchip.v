// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, mem_in, inst, reset, out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;

input  clk; 
input  [pr*bw-1:0] mem_in; 

// input  [16:0] inst;
input [18:0] inst;
// inst[18] = div;
// inst[17] = acc;
// inst[16] = ofifo_rd;
// inst[15:12] = qkmem_add;
// inst[11:8]  = pmem_add;
// inst[7] = execute;
// inst[6] = load;
// inst[5] = qmem_rd;
// inst[4] = qmem_wr;
// inst[3] = kmem_rd;
// inst[2] = kmem_wr;
// inst[1] = pmem_rd;
// inst[0] = pmem_wr;

input  reset;
output [bw_psum*col-1:0] out;

// , sum_out, ,
core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
      .reset(reset), 
      .clk(clk), 
      .mem_in(mem_in), 
      .inst(inst),
      .out(out)
);



endmodule
