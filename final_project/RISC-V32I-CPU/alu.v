//ALU - Arithmatic Logic Unit


module  alu(

input [31:0] A,
input [31:0] B, 
input [3:0] ALUControl, // 0000=ADD, 0001=SUB, 0010=AND, 0011=OR, 0100=XOR 

output reg[31:0] Result,
output Zero

);


assign Zero = (Result == 0);

always @(*) 
	begin
		case(ALUControl)
			4'b0000: Result = A + B; //ADD
			4'b0001: Result = A - B; //SUB
			4'b0010: Result = A & B; //AND
			4'b0011: Result = A | B; //OR
			4'b0100: Result = A ^ B; //XOR
			
			default: Result = 0;
		endcase
	end
endmodule