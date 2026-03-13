module pwm_maybe (
    input        MAX10_CLK1_50,
    input  [1:0] KEY,
    input  [7:0] SW,
    output       ARDUINO_IO,
    output [6:0] HEX0,    // 7 bits, igual que el .qsf HEX0[0..6]
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);

    wire rst = ~KEY[0];
    wire clk_5mhz;
    wire [7:0] SW_lim = (SW >= 8'd180) ? 8'd180 : SW;
    wire [6:0] out_uni, out_dec, out_cent, out_mil;

    clk_divider_parameter #(.FREQ(5_000_000)) u_div (
        .clk    (MAX10_CLK1_50),
        .rst    (rst),
        .clk_div(clk_5mhz)
    );

    comparador #(.pwm(50), .CLK_FREQ(5_000_000)) u_comp (
        .clk(clk_5mhz),
        .rst(rst),
        .in (SW_lim),
        .out(ARDUINO_IO)
    );

    BIN_TO_4DISPLAY display_inst (
        .bcd     (SW_lim),
        .out_uni (out_uni),
        .out_dec (out_dec),
        .out_cent(out_cent),
        .out_mil (out_mil)
    );

    // BCD es [0:6], BIN_TO_4DISPLAY saca [6:0]
    // out_uni[6]=seg_a, out_uni[5]=seg_b, ..., out_uni[0]=seg_g
    // HEX[0]=seg_a, HEX[1]=seg_b, ..., HEX[6]=seg_g
    assign HEX0[0] = out_uni[6];
    assign HEX0[1] = out_uni[5];
    assign HEX0[2] = out_uni[4];
    assign HEX0[3] = out_uni[3];
    assign HEX0[4] = out_uni[2];
    assign HEX0[5] = out_uni[1];
    assign HEX0[6] = out_uni[0];

    assign HEX1[0] = out_dec[6];
    assign HEX1[1] = out_dec[5];
    assign HEX1[2] = out_dec[4];
    assign HEX1[3] = out_dec[3];
    assign HEX1[4] = out_dec[2];
    assign HEX1[5] = out_dec[1];
    assign HEX1[6] = out_dec[0];

    assign HEX2[0] = out_cent[6];
    assign HEX2[1] = out_cent[5];
    assign HEX2[2] = out_cent[4];
    assign HEX2[3] = out_cent[3];
    assign HEX2[4] = out_cent[2];
    assign HEX2[5] = out_cent[1];
    assign HEX2[6] = out_cent[0];

    assign HEX3[0] = out_mil[6];
    assign HEX3[1] = out_mil[5];
    assign HEX3[2] = out_mil[4];
    assign HEX3[3] = out_mil[3];
    assign HEX3[4] = out_mil[2];
    assign HEX3[5] = out_mil[1];
    assign HEX3[6] = out_mil[0];

    assign HEX4 = 7'h7F;  // todos apagados (activo bajo)
    assign HEX5 = 7'h7F;

endmodule
