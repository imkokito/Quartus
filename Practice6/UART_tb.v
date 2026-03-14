`timescale 1ns/1ps

module uart_tb();

// -------------------------
// Parámetros
// -------------------------
localparam BAUD_RATE  = 9600;
localparam CLOCK_FREQ = 50_000_000;
localparam BITS       = 8;
localparam BAUD_TICK  = CLOCK_FREQ / BAUD_RATE; 
localparam BIT_PERIOD = BAUD_TICK * 20;         

// -------------------------
// Señales
// -------------------------
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

task send_and_check;
    input [7:0] data;
    begin
        SW = {2'b00, data};
        $display("\n--- Enviando SW=0x%02X (%0d) ---", data, data);

        // Pulso en KEY[0] para activar start
        @(posedge clk);
        KEY[0] = 0;
        @(posedge clk);
        KEY[0] = 1;

        // Esperar que busy se active
        wait(TX_UUT.busy);
        $display("t=%0t | TX busy=1, transmitiendo...", $time);

        // Esperar que busy baje (transmisión completa)
        wait(!TX_UUT.busy);
        $display("t=%0t | TX busy=0, transmision completa", $time);

        // Esperar data_ready en RX
        wait(RX_UUT.data_ready);
        $display("t=%0t | RX data_ready=1 | data_out=0x%02X (%0d)",
                 $time, RX_UUT.data_out, RX_UUT.data_out);

        // Verificar
        if (RX_UUT.data_out === data)
            $display("✓ PASS: enviado=0x%02X recibido=0x%02X", data, RX_UUT.data_out);
        else
            $display("✗ FAIL: enviado=0x%02X recibido=0x%02X", data, RX_UUT.data_out);

        // Pausa entre transmisiones
        repeat(BAUD_TICK * 2) @(posedge clk);
    end
endtask

initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);

    // Estado inicial
    KEY  = 2'b11;
    SW   = 10'd0;

    // Reset
    #100;
    KEY[1] = 0;
    #200;
    KEY[1] = 1;
    #200;

    $display("=== Inicio testbench UART ===");

    // Caso 1: dato minimo
    send_and_check(8'h00);

    // Caso 2: dato tipico
    send_and_check(8'h41); // 'A'

    // Caso 3: dato medio
    send_and_check(8'h7F);

    send_and_check(8'hFF);

    send_and_check(8'hA5);

    $display("\n=== Testbench terminado ===");
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
