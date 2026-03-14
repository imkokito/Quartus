module fsm_brazo( 
	input selector, 
	input rst, 
	input guardar,
	input clk, 
	
	output reg guardar_dato, 
	output reg habilitar_contador, 
	output reg [1:0] state

	); 
	
parameter MANUAL= 0, GUARDADO=1, AUTOMATICO=2; 

always @(posedge clk or posedge rst) 
	begin 
		if(rst)begin 
			state<=MANUAL; 
			guardar_dato<=0; 
			habilitar_contador<=0; 
		end 
	else begin 
		case (state) 
			MANUAL: begin 
				guardar_dato <=0; 
				habilitar_contador <=0; 
				
				if (guardar)
					state<=GUARDADO; 
				else if (selector )
					state <= AUTOMATICO; 
			end 
			
			GUARDADO: begin 
				guardar_dato<=1; 
				habilitar_contador<=1; 
				state<=MANUAL; 
			end 
					
			AUTOMATICO: begin 	
				guardar_dato<=0; 
				habilitar_contador <=1; 
				
				if(!selector) 
					state <= MANUAL; 
				else 
					state <= AUTOMATICO; 	
			end 
			
			default: begin 
				state <= MANUAL; 
				guardar_dato <=0; 
				habilitar_contador <=0; 
			end 
		endcase 
	end 
end 

endmodule
