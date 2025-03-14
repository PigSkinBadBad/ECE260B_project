// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_col (clk, reset, out, q_in, q_out, i_inst, fifo_wr, o_inst);

parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;
parameter col_id = 1;

output signed [bw_psum-1:0] out;
input  signed [pr*bw-1:0] q_in;
output signed [pr*bw-1:0] q_out;
input  clk, reset;
input  [1:0] i_inst; // [1]: execute, [0]: load 
output [1:0] o_inst; // [1]: execute, [0]: load 
output fifo_wr;
reg    load_ready_q;
reg    [3:0] cnt_q;
reg    [1:0] inst_q;
reg    [1:0] inst_2q;
reg   signed [pr*bw-1:0] query_q;
reg   signed [pr*bw-1:0] key_q;
wire  signed [bw_psum-1:0] psum;

assign o_inst = inst_q;
assign fifo_wr = inst_2q[1];
assign q_out  = query_q;  // to next col
assign out = psum;        // to sfp

mac_16in #(.bw(bw), .bw_psum(bw_psum), .pr(pr)) mac_16in_instance (
        .a(query_q), 
        .b(key_q),
	.out(psum)
); 


always @ (posedge clk) begin
  if (reset) begin
    cnt_q <= 0;
    load_ready_q <= 1;
    inst_q <= 0;
    inst_2q <= 0;
  end
  else begin
    inst_q <= i_inst;
    inst_2q <= inst_q;
    if (inst_q[0]) begin      // inst[0]==1: load 
       query_q <= q_in;       // load input to query
       if (cnt_q == 9-col_id)begin  // wait for 8 cyls and load K8, wait 7 cycs and load K7, ... wait 1 cyc and load K1.
         cnt_q <= 0;                // as the input data first goes into K1, so must wait until the 8th cyc coming at first.
         key_q <= q_in;             // 8 cols' key_q <= q_in happen at the same time.
         load_ready_q <= 0;
       end
       else if (load_ready_q)
         cnt_q <= cnt_q + 1;
    end
    else if(inst_q[1]) begin  // inst[1]==1: exe
      //out     <= psum;
      query_q <= q_in;
    end
  end
end

endmodule
