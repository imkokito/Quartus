`timescale 1ns/1ps

module psw_tb();

reg clk;
reg [3:0] SW;
reg [1:0] KEY;

wire [0:6] HEX0, HEX1, HEX2, HEX3;

password_w UUT (
    .MAX10_CLK1_50(clk),
    .SW(SW),
    .KEY(KEY),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3)
);

initial clk = 0;
always #10 clk = ~clk;

initial begin
    $dumpfile("psw_tb.vcd");
    $dumpvars(0, psw_tb);

    KEY = 2'b11;
    SW  = 4'd0;

    // Reset
    #100;
    KEY[1] = 0;
    #200;
    KEY[1] = 1;
    #300;

    //1-4-0-4
    $display("password 1-4-0-4");
    SW = 4'd1;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd0;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    $display("good=%b bad=%b | esperado: good=1 bad=0", UUT.FSM.good, UUT.FSM.bad);

    // Reset
    KEY[1] = 0; #200; KEY[1] = 1; #300;

    //5-4-0-4
    $display("digito incorrecto");
    SW = 4'd5;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd0;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    $display("good=%b bad=%b | esperado: good=0 bad=1", UUT.FSM.good, UUT.FSM.bad);

    // Reset
    KEY[1] = 0; #200; KEY[1] = 1; #300;

    //1-4-9-4
    $display("diferente digito incorrecto");
    SW = 4'd1;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd9;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    SW = 4'd4;
    #100; KEY[0] = 0; #200; KEY[0] = 1; #500;

    $display("good=%b bad=%b | esperado: good=0 bad=1", UUT.FSM.good, UUT.FSM.bad);

    $display("Testbench terminado.");
    $finish;
end

initial begin
    $monitor("t=%0t | SW=%0d | KEY=%b | good=%b bad=%b",
            $time, SW, KEY,
            UUT.FSM.good, UUT.FSM.bad);
end

endmodule