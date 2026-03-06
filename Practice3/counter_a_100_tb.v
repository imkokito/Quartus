module counter_a_100_tb();

reg clk, rst, load, up_down;
reg [6:0] data_in;

wire [6:0] out_uni, out_dec, out_cent, out_mil;

contador UUT(
    .clk(clk),
    .rst(rst),
    .load(load),
    .up_down(up_down),
    .data_in(data_in),
    .out_uni(out_uni),
    .out_dec(out_dec),
    .out_cent(out_cent),
    .out_mil(out_mil)
);

initial begin
        clk = 0;
        forever #10 clk = ~clk;  
    end

    initial begin
        $dumpfile("counter_a_100_tb.vcd");
        $dumpvars(0, counter_a_100_tb);

        rst = 1;
        up_down = 0;
        load = 1;
        data_in = 0;
        #200;
        rst = 0;

        $display("Counting Up...");
        #150_000_000;

        $display("Switching to Count Down...");
        up_down = 1;
        #150_000_000;

        $display("Loading value 37...");
        data_in = 37;
        load = 0;   
        #20;
        load = 1;   
        #150_000_000;

        $display("Counting Up from 37...");
        up_down = 0;
        #150_000_000;

        $finish;
    end

    initial begin
        $monitor("time=%0t | counter=%0d | load=%b | up_down=%b",
                $time, UUT.CUENTA.counter, load, up_down);
    end

endmodule