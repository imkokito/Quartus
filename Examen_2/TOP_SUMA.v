module TOP_SUMA(
    input MAX10_CLK1_50,
    input [3:0] SW,
    input [1:0] KEY,
    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3

);

wire rst;
wire start;
wire [9:0] result;
wire [0:6] hex0_bcd, hex1_bcd, hex2_bcd, hex3_bcd;

SUMATORIA SUM (
    .clk(MAX10_CLK1_50),
    .rst(~KEY[0]),
    .start(~KEY[1]),
    .SW(SW),
    .result(result)
);

BIN_TO_4DISPLAY DISP (
    .bcd(result),
    .out_uni(hex0_bcd),
    .out_dec(hex1_bcd),
    .out_cent(hex2_bcd),
    .out_mil(hex3_bcd)
);

assign HEX0 = hex0_bcd;
assign HEX1 = hex1_bcd;
assign HEX2 = hex2_bcd;
assign HEX3 = hex3_bcd;

endmodule