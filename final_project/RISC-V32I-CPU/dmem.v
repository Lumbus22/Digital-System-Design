//Data Memory
//This part of the cpu storoes nad retrieves data during hte SW and LW instructions
//Writes happen at clk edge, reads happen imidiately (combinational)
module dmem(

input clk,	
input MemWrite, 				// Enables memory write
input MemRead, 				// Enables memory read
input [31:0] addr,			// The address to read or write
input [31:0] WriteData,		// The data to store

output reg [31:0] ReadData // The data read from memory

);

	reg [31:0] memory [0:63]; // defines a memory array of 64, 32bit words. So 256 bytes of mem
	
	
	//Write to memory at the posedge of clk, if MemWrite = 1
	always @(posedge clk)
		begin
			if(MemWrite)
				memory[addr[7:2]] <= WriteData;
		end
		
	//Read memory into ReadData if MemRead = 1. 
	//This block works combinationaly. no need for the clock
	always @(*) 
		begin
			if (MemRead)
				ReadData = memory[addr[7:2]];
			else
				ReadData = 0;
		end
		
endmodule
		
			
			
			
			