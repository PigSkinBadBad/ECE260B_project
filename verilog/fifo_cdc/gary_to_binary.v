module gray_to_binary #(parameter N = 4)(
  input       [N-1:0] gray_value, 
  output      [N-1:0] binary_value);

assign binary_value[N-1] = gray_value[N-1];
generate 
genvar i;
	for(i=N-2; i>=0; i=i-1) begin
		assign binary_value[i] = gray_value[i]^binary_value[i+1]; 
	end
endgenerate

endmodule