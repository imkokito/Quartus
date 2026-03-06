module BCD_4displays_w( 
	input [9:0] SW, 
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3
	); 
	
	BIN_TO_4DISPLAY WRAP( 
		.bcd(SW), 	
		.out_uni(HEX0),
		.out_dec(HEX1),
		.out_cent(HEX2), 
		.out_mil(HEX3)
); 

endmodule 