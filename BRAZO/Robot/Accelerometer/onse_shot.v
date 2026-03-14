module one_shot(
    input clk,
    input rst,
    input btn,
    output reg pulse
);

reg btn_d;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        btn_d <= 0;
        pulse <= 0;
    end else begin
        pulse <= btn & ~btn_d;   // pulso al detectar flanco de subida
        btn_d <= btn;
    end
end

endmodule
