module mem #(parameter data_width= 32, parameter add_width=3)(
	input clk, 
	input rst, 
	input guardar_dato, 
	input [add_width-1:0] addr,
	input [data_width-1:0] data_in, 
	output reg [data_width-1:0] data_out
); 

reg[data_width-1:0] mem [0:2**add_width-1];

always @(posedge clk or posedge rst)
	begin
		if(rst)
			data_out<=0; 
		else begin 
			if(guardar_dato)
				mem[addr]<=data_in; 
			
			data_out<=mem[addr];
		end 
end 

endmodule
