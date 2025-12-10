//Control unit

module control(

	input [6:0] opcode, // 7 bit opcode from the instruciton. Used to determine the operation 
	
	output reg RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch,
	output reg [3:0] ALUOp

);

/*
Notes for Control. The controller generates the control signals RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch, ALUOp

RegWrite: 1 will force the pc to write "WriteData" to the current register destination (rd). 0 Disables RegWrite. See "regfile"

MemRead: 1 will force a "ReadData" to a value in memory. the memory address is given in the machine code

MemWrite: 1 writes "WriteData" or (rs2) to a location in memory. the memory address is set in the machine code. see "dmem"

MemToReg: 1 set "WriteData" to mem_read_data if 0 then "WriteData" is the alu_result. 

*/

	always @(*) 
		begin
			//Default Values
			RegWrite = 0; MemRead = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0; Branch = 0; ALUOp = 0;
			
			//Case statements for determing operation. 
			case(opcode)
				
				7'b0010011: //ADDI
					begin
						RegWrite = 1; ALUSrc = 1; ALUOp = 4'b0000; //Add
					end
					
				7'b0110011: // R-Type ADD/SUB
					begin
						RegWrite = 1; ALUSrc = 0; ALUOp = 4'b0000; //Funct7 / funct3 needs to be refined
					end
				
				7'b0000011: // LW
					begin
						RegWrite = 1; MemRead = 1; MemToReg = 1; ALUSrc = 1; ALUOp = 4'b0000;
					end
		
				7'b0100011: // SW
					begin
						MemWrite = 1; ALUSrc = 1; ALUOp = 4'b0001;
					end
						
				7'b1100011: // BEQ/BNE
					begin
						Branch = 1; ALUSrc = 0; ALUOp = 4'b0001; //SUB for comparison
					end
		
					default: ; //Default is defined outside of the case
					
			endcase
		end
endmodule
			






	
					