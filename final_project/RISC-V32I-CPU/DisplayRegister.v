module DisplayRegister (
	input [31:0] registerOne,

	
	output [8:0] LEDOut
);

//LED Indicator. indicated the first 8 bits of register 1. 


assign LEDOut [8:0] = registerOne [8:0];


//Chunk bits. 4 bits per seven segemnt display. 


endmodule