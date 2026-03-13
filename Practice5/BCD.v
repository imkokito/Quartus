module BCD (
    input  [3:0] bcd,
    output reg [6:0] out
);

   always @(*) begin
    case (bcd)
        4'b0000: out = 7'b000_0001; 
        4'b0001: out = 7'b100_1111; 
        4'b0010: out = 7'b001_0010; 
        4'b0011: out = 7'b000_0110; 
        4'b0100: out = 7'b100_1100; 
        4'b0101: out = 7'b010_0100; 
        4'b0110: out = 7'b010_0000; 
        4'b0111: out = 7'b000_1111; 
        4'b1000: out = 7'b000_0000; 
        4'b1001: out = 7'b000_0100; 
        4'b1010: out = 7'b111_1111; 
        default: out = 7'b111_1111; 
    endcase
end

endmodule
endmodule
