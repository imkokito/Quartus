`timescale 1ns/1ps

module uart_tb();

localparam BAUD_RATE  = 9600;
localparam CLOCK_FREQ = 50_000_000;
localparam BITS       = 8;
localparam BAUD_TICK  = CLOCK_FREQ / BAUD_RATE; 
localparam BIT_PERIOD = BAUD_TICK * 20;          

reg clk;
reg [1:0] KEY;
reg [9:0] SW;
reg [15:0] ARDUINO_IO_in;

wire [15:0] ARDUINO_IO_tx;
wire [0:6] HEX0_tx, HEX1_tx, HEX2_tx, HEX3_tx;
wire [0:6] HEX0_rx, HEX1_rx, HEX2_rx, HEX3_rx;

top_tx TX_UUT (
    .MAX10_CLK1_50(clk),
    .KEY(KEY),
    .SW(SW),
    .ARDUINO_IO(ARDUINO_IO_tx),
    .HEX0(HEX0_tx),
    .HEX1(HEX1_tx),
    .HEX2(HEX2_tx),
    .HEX3(HEX3_tx)
);

top_rx RX_UUT (
    .MAX10_CLK1_50(clk),
    .KEY(KEY),
    .ARDUINO_IO({15'b0, ARDUINO_IO_tx[1]}), 
    .HEX0(HEX0_rx),
    .HEX1(HEX1_rx),
    .HEX2(HEX2_rx),
    .HEX3(HEX3_rx)
);

initial clk = 0;
always #10 clk = ~clk;

// -------------------------
// Estímulos
// -------------------------
initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);

    KEY = 2'b11;
    SW  = 10'd0;

    // Reset
    #100;
    KEY[1] = 0;
    #200;
    KEY[1] = 1;
    #200;

    SW = 10'b0011111111; //255
    @(posedge clk); KEY[0] = 0;
    @(posedge clk); KEY[0] = 1;
    #2000000;

    SW = 10'b0000000000; //0
    @(posedge clk); KEY[0] = 0;
    @(posedge clk); KEY[0] = 1;
    #2000000;

    SW = 10'b0010100101; //165
    @(posedge clk); KEY[0] = 0;
    @(posedge clk); KEY[0] = 1;
    #2000000;

    SW = 10'b0001111111; //127
    @(posedge clk); KEY[0] = 0;
    @(posedge clk); KEY[0] = 1;
    #2000000;

    $display("Testbench terminado.");
    $finish;
end

initial begin
    $monitor("t=%0t | SW=%0d | tx_out=%b | data_ready=%b | data_out=%0d",
            $time, SW[7:0],
            ARDUINO_IO_tx[1],
            RX_UUT.data_ready,
            RX_UUT.data_out);
end

endmodule
