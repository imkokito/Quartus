module tick_1hz #(
    parameter CLK_FREQ = 50_000_000
)(
    input clk,
    input rst,
    output reg tick
);

reg [25:0] count;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
        tick <= 0;
    end else begin
        if (count == CLK_FREQ-1) begin
            count <= 0;
            tick <= 1;
        end else begin
            count <= count + 1;
            tick <= 0;
        end
    end
end

endmodule
