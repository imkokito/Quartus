module contador(
	input clk,
	input rst,
	input load,
	input up_down,
	input [6:0] data_in,
	output [0:6] out_uni, out_dec, out_cent, out_mil
);

wire reloj;
wire [7:0] counter;


//clock divider
clk_divider_parameter DIV(
	.clk(clk),
	.rst(rst),
	.clk_div(reloj)
);

//contador
count CUENTA(
	.clk(reloj),
	.rst(rst),
	.data_in(data_in),
	.load(load),
	.up_down(up_down),
	.counter(counter)
);

//displays
BIN_TO_4DISPLAY DISPLAY(
    .bcd(counter),
    .out_uni(out_uni),
    .out_dec(out_dec),
    .out_cent(out_cent),
    .out_mil(out_mil)
);
endmodule