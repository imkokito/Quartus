module PASSWORD(
    input clk,        
    input rst,        
    input enter,     
    input [3:0] SW,

    output reg [3:0] d0,
    output reg [3:0] d1,
    output reg [3:0] d2,
    output reg [3:0] d3,

    output reg good,
    output reg bad
);


parameter PASS1 = 4'd1;
parameter PASS2 = 4'd4;
parameter PASS3 = 4'd0;
parameter PASS4 = 4'd4;


parameter IDLE = 0,
          DIG1 = 1,
          DIG2 = 2,
          DIG3 = 3,
          DIG4 = 4,
          GOOD = 5,
          BAD  = 6;

reg [2:0] state;


reg enter_prev;//estado anterior de enter
wire enter_edge = (enter == 1) && (enter_prev == 0);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        d0 <= 0; 
		  d1 <= 0; 
		  d2 <= 0; 
		  d3 <= 0;
        good <= 0;
        bad <= 0;
        enter_prev <= 0;
    end
    else begin
        enter_prev <= enter;
        case(state)
        IDLE: begin
            if (enter_edge) begin
                d3 <= SW;
                if (SW == PASS1)
						state <= DIG1;
                else
						state <= BAD;
            end
        end
        DIG1: begin
            if (enter_edge) begin
                d2 <= SW;
                if (SW == PASS2) 
						state <= DIG2;
                else             
						state <= BAD;
            end
        end
        DIG2: begin
            if (enter_edge) begin
                d1 <= SW;
                if (SW == PASS3) 
						state <= DIG3;
                else             
						state <= BAD;
            end
        end
        DIG3: begin
            if (enter_edge) begin
                d0 <= SW;
                if (SW == PASS4) 
						state <= GOOD;
                else            
						state <= BAD;
            end
        end
        GOOD: good <= 1;
        BAD:  bad  <= 1;
        default: state <= IDLE;
        endcase
    end
end

endmodule