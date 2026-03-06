module password_w(
    input MAX10_CLK1_50,
    input [3:0] SW,
    input [1:0] KEY,
    output reg [0:6] HEX0,
    output reg [0:6] HEX1,
    output reg [0:6] HEX2,
    output reg [0:6] HEX3
);

wire clk_slow;
wire enter;
wire rst;
wire [3:0] d0, d1, d2, d3;
wire good, bad;
wire [0:6] hex0_bcd, hex1_bcd, hex2_bcd, hex3_bcd;

assign rst   = ~KEY[1];
assign enter = ~KEY[0];

localparam SEG_G = 7'b010_0000;
localparam SEG_O = 7'b000_0001; 
localparam SEG_D = 7'b100_0010; 
localparam SEG_B = 7'b110_0000;
localparam SEG_A = 7'b000_1000;
localparam SEG_BLANK = 7'b111_1111; 

// clock divider
clk_divider_parameter #(
    .FREQ(5)
) CLKDIV (
    .clk(MAX10_CLK1_50),
    .rst(rst),
    .clk_div(clk_slow)
);

// FSM
PASSWORD FSM (
    .clk(MAX10_CLK1_50),
    .rst(rst),
    .enter(enter),
    .SW(SW),
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .good(good),
    .bad(bad)
);

// BCD para dígitos normales
BCD H0 (.bcd(d0), .out(hex0_bcd));
BCD H1 (.bcd(d1), .out(hex1_bcd));
BCD H2 (.bcd(d2), .out(hex2_bcd));
BCD H3 (.bcd(d3), .out(hex3_bcd));

always @(*) begin
    if (good) begin
        HEX3 = SEG_G;
        HEX2 = SEG_O;
        HEX1 = SEG_O;
        HEX0 = SEG_D;
    end
    else if (bad) begin
        HEX3 = SEG_B;
        HEX2 = SEG_A;
        HEX1 = SEG_D;
        HEX0 = SEG_BLANK;
    end
    else begin
        HEX0 = hex0_bcd;
        HEX1 = hex1_bcd;
        HEX2 = hex2_bcd;
        HEX3 = hex3_bcd;
    end
end

endmodule