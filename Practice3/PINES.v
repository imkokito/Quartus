module PINES(
	input  [1:0] KEY,
	input MAX10_CLK1_50,
	input  [9:0] SW,
    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3
);

wire [0:6] out_uni, out_dec, out_cent, out_mil;

contador CONTANDO(.clk(MAX10_CLK1_50),
	.rst (~KEY[0]),
	.up_down (SW[9]),
	.load (~KEY[1]),
	.data_in (SW[6:0]), .out_uni(HEX0),.out_dec(HEX1),.out_cent(HEX2),.out_mil(HEX3)); 
endmodule
