module BIN_TO_4DISPLAY_tb;

    reg  [9:0] in;
    wire [6:0] out_uni, out_dec, out_cent, out_mil;

    BIN_TO_4DISPLAY DUT (
        .in(in),
        .out_uni(out_uni),
        .out_dec(out_dec),
        .out_cent(out_cent),
        .out_mil(out_mil)
    );

initial begin 
$display("sim iniciada") ; 
repeat(50)
begin 
    in = $random%1023;
    #10;
end
$display("sim finalizada"); 
$stop;
$finish;
end


initial begin
    $monitor("in = %d,out_uni= %b, out_dec= %b, out_cent= %b, out_mil = %b",in,out_uni, out_dec, out_cent, out_mil);
end

initial begin
    $dumpfile("BIN_TO_4DISPLAY_tb.vcd");
    $dumpvars(0,BIN_TO_4DISPLAY_tb);

end
endmodule