module BIN_TO_4DISPLAY #(parameter num_in=10, num_out=7)(
    input [num_in - 1:0] bcd,
    output [num_out -1:0] out_uni, out_dec, out_cent, out_mil
);

    wire [3:0] uni, dec, centi, mil;

    assign uni = bcd % 10; // Unidades
    assign dec = (bcd / 10) % 10; // Decenas
    assign centi = (bcd / 100) % 10; // Centenas
    assign mil = (bcd / 1000) % 10; // miles

    BCD uni_disp(
        .bcd(uni),
        .out(out_uni)
    );
    BCD dec_disp(
        .bcd(dec),
        .out(out_dec)
    );
    BCD centi_disp(
        .bcd(centi),
        .out(out_cent)
    );
    BCD mil_disp(
        .bcd(mil),
        .out(out_mil)
    );
endmodule


