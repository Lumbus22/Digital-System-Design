module Extend(
input [31:7] instruction,
input [2:0] ImmSrc,
output reg [31:0] ImmExt

);


always @ (*)
	begin
		case(ImmSrc)
			3'b000: ImmExt = {{20{instruction[31]}}, instruction[31:20]}; // I-Type immidiate extension
	        3'b001: ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};// S -type immidiate extension
         	3'b010: ImmExt = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};// B - type immidiate instruction
         	3'b011: ImmExt = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};// j - Type immidiate instruction
			3'b100: ImmExt = {instruction[31:12], 12'b0}; // U - Type Instruction
		endcase
	end
endmodule	
