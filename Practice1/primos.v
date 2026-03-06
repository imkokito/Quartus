module primos(
	input [3:0] SW,
	output LED
);

	assign LED=(SW==4'd2) || 
				(SW==4'd3) ||
				(SW==4'd5) ||
				(SW==4'd7) ||
				(SW==4'd11) ||
				(SW==4'd13);
endmodule
