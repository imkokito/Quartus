module TOP_CRONOMETRO(
    input  MAX10_CLK1_50,
    input  [1:0] KEY,
    output reg [0:6] HEX0,
    output reg [0:6] HEX1,
    output reg [0:6] HEX2,
    output reg [0:6] HEX3
);

wire [0:6] hex0_bcd, hex1_bcd, hex2_bcd, hex3_bcd;
wire [3:0] uni, dec, centi, mil;

cronometro crono (
    .clk        (MAX10_CLK1_50),
    .rst        (~KEY[0]),
    .start_stop (~KEY[1]),
    .out_uni    (uni),
    .out_dec    (dec),
    .out_cent   (centi),
    .out_mil    (mil)
);

BCD H0 (.bcd(uni),   .out(hex0_bcd));
BCD H1 (.bcd(dec),   .out(hex1_bcd));
BCD H2 (.bcd(centi), .out(hex2_bcd));
BCD H3 (.bcd(mil),   .out(hex3_bcd));

always @(*) begin
    HEX0 = hex0_bcd;
    HEX1 = hex1_bcd;
    HEX2 = hex2_bcd;
    HEX3 = hex3_bcd;
end
endmodule
