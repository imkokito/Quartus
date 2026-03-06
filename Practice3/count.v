module count(
    input clk,
    input rst,
    input up_down,
    input load,
    input [6:0] data_in,
    output reg [7:0] counter
);

reg load_prev;  // estado anterior de load
wire load_edge; // cambio de 1 a 0
assign load_edge = (load == 0) && (load_prev == 1);

always @(posedge clk or posedge rst) begin
    if (rst)
        counter <= 0;
    else begin
        load_prev <= load;  

        if (load_edge) begin       
            if (data_in > 100)
                counter <= 100;
            else
                counter <= data_in;
        end
        else if (up_down == 1) begin
            if (counter == 0)
                counter <= 100;
            else
                counter <= counter - 1;
        end
        else begin
            if (counter >= 100)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end
end

endmodule