module cronometro(
    input  clk,
    input  rst,
    input  start_stop,
    output [3:0] out_uni,
    output [3:0] out_dec,
    output [3:0] out_cent,
    output [3:0] out_mil
);

reg [6:0] ms;
reg [5:0] seg;
reg contando;
reg start_antes;
wire clk_lento;
reg ms_carry;

clk_divider_parameter #(.FREQ(100)) DIV (
    .clk    (clk),
    .rst    (rst),
    .clk_div(clk_lento)
);


always @(posedge clk or posedge rst) 
begin
    if (rst) 
	 begin
        contando <= 0;
        start_antes <= 0;
    end 
	 else 
	 begin
        if (start_stop && !start_antes)
            contando <= ~contando;
        start_antes <= start_stop;
    end
end


always @(posedge clk_lento or posedge rst) 
begin
    if (rst) 
	 begin
        ms <= 0;
        ms_carry <= 0;
    end 
	 else if (contando) 
	 begin
        if (ms == 7'd99) 
		  begin
            ms <= 0;
            ms_carry <= 1;   
        end 
		  else 
		  begin
            ms <= ms + 1;
            ms_carry <= 0;
        end
    end 
	 else 
	 begin
        ms_carry <= 0;
    end
end

always @(posedge clk_lento or posedge rst) 
begin
    if (rst) 
	 begin
        seg <= 0;
    end 
	 else if (ms_carry) 
	 begin
        if (seg == 6'd59)
            seg <= 0;
        else
            seg <= seg + 1;
    end
end

assign out_uni  = ms % 10;
assign out_dec  = ms / 10;
assign out_cent = seg  % 10;
assign out_mil  = seg  / 10;

endmodule
