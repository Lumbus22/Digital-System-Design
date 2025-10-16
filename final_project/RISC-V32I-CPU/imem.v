//This file contains the instruciotns to be executed by the cpu 

module imem(
	input [31:0] addr, //addr is the PC
	output [31:0] instr // is the 32 bit instruction

);

	
	
	//Creating an array of 32 bit instructions for the CPU to operate on.
	reg [31:0] memory [0:63]; // 64 instructions max for now
	
	initial begin
	
	//Example Program
	memory[0] = 32'h00500093; // addi x1, x0, 5
	memory[1] = 32'h00a00113; // addi x2, x0, 10
	memory[2] = 32'h002081b3; // add x3, x1, x2
	memory[3] = 32'h00302023; // sw x3, 0(x0)
	memory[4] = 32'h00002103; // lw x4, 0(x0)
	memory[5] = 32'h0041a233; // sub x5, x4, x1
	
	// more instructions can be added as needed
	
	end
	
	
	
	//Assigns instr = is the memory at the program counter (PC)
	assign instr = memory[addr[7:2]]; // word-aligned
endmodule
	