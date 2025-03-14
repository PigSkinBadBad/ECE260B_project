module binary_to_gray #(parameter N = 4)(
    input  [N-1:0] binary_value,
    output [N-1:0] gray_value
);

    assign gray_value = binary_value ^ (binary_value >> 1);
    
endmodule
