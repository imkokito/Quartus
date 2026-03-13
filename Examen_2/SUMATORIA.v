module SUMATORIA(
    input clk,
    input rst,
    input start,
    input [3:0] SW,
    output reg [9:0] result
);

parameter IDLE = 0,
          SUM  = 1,
          DONE = 2;

reg [1:0] state;
reg [3:0] i;
reg [9:0] sum;
reg [3:0] N;

reg start_antes;
wire start_flanco = (start == 1) && (start_antes == 0);

always @(posedge clk or posedge rst) 
begin
    if(rst) 
	 begin
        state <= IDLE;
        i <= 0;
        sum <= 0;
        result <= 0;
        start_antes <= 0;
    end
    else 
	 begin
        start_antes <= start;
        case(state)
        IDLE: begin
            if(start_flanco) 
				begin
                N <= SW;       
                i <= 0;
                sum <= 0;
                state <= SUM;
            end
        end
        SUM: begin
            if(i <= N) 
				begin
                sum <= sum + i;
                i <= i + 1;
            end
            else 
				begin
                result <= sum;
                state <= DONE;
            end
        end
        DONE: begin
            if(start_flanco)
                state <= IDLE;
        end
        endcase
    end
end

endmodule
