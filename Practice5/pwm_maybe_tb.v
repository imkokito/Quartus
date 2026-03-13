`timescale 1ns/1ps
module pwm_maybe_tb();

reg clk;
reg [1:0] KEY;
reg [7:0] SW;

wire ARDUINO_IO;
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;


pwm_maybe UUT(
    .MAX10_CLK1_50(clk),
    .KEY(KEY),
    .SW(SW),
    .ARDUINO_IO(ARDUINO_IO),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5)

);


initial begin
    clk = 0;
    forever #10 clk = ~clk;
end


initial begin

    $dumpfile("pwm_maybe_tb.vcd");
    $dumpvars(0, pwm_maybe_tb);

    // estado inicial
    KEY = 2'b11;
    SW  = 8'd0;

    // reset
    #100
    KEY[0] = 0;
    #100
    KEY[0] = 1;

    $display("Testing PWM with different switch values");

    #20000000
    SW = 8'd0;

    #20000000
    SW = 8'd90;

    #20000000
    SW = 8'd180;

    $finish;

end
