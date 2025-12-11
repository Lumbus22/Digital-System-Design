//Control unit

module control(

	input [6:0] opcode, // 7 bit opcode from the instruciton. Used to determine the operation 
	
	input [2:0] funct3, // 3 bit func3
	input [6:0] funct7, // 7 bit funct7
	
	output reg RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch, ALUSrc2,
	output reg [2:0] ImmSrc,
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
			RegWrite = 0; MemRead = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0; ALUSrc2 = 0; Branch = 0; ALUOp = 0; ImmSrc = 0;
			
			//Case statements for determing operation. 
			case(opcode)
				
				7'b0010011: //I Type instruction
					begin
						RegWrite = 1; ALUSrc = 1; ALUOp = 4'b0000; ImmSrc = 3'b000;//Add immdiate
					end
					
			7'b0110011: // R-Type ADD/SUB
				begin
					RegWrite = 1; // Enable register write for all R-type
					ALUSrc = 0;   // Use rs2 (not immediate) for R-type
					MemToReg = 0;
					case(funct3)
						3'b000: // ADD or SUB
							begin
								if (funct7 == 7'b0000000)
									ALUOp = 4'b0000; // ADD
								else if (funct7 == 7'b0100000)
									begin
										ALUOp = 4'b0001; // SUB
										RegWrite = 1;
									end
								else
									ALUOp = 4'b0000; // Default to ADD
							end
						default: ALUOp = 4'b0000;
					endcase
				end
				
				7'b0000011: // I-Type Instruction, for load instructions
					begin
						RegWrite = 1; MemRead = 1; MemToReg = 1; ALUSrc = 1; ALUOp = 4'b0000; ImmSrc = 3'b000; //LW
					end
		
				7'b0100011: // S-Type Instruction 
					begin
						MemWrite = 1; ALUSrc = 1; ALUOp = 4'b0001; ImmSrc = 3'b001; //SW
					end
						
				7'b1100011: // B-Type Instructions. BEQ/BNE
					begin
						Branch = 1; ALUSrc = 0; ALUOp = 4'b0001; ImmSrc = 3'b010; //SUB for comparison
					end
					
				7'b0110111: //U-Type instruction.
					begin
						RegWrite = 1; ALUSrc = 1; ALUOp = 4'b0000; ImmSrc = 3'b100; ALUSrc2 = 1;//lui, load upper immidiate
					end
					
					default:	 //Default is defined outside of the case
						begin
								//Default Values
								RegWrite = 0; MemRead = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0; ALUSrc2 = 0; Branch = 0; ALUOp = 0; ImmSrc = 0;
						end
			endcase
		end
endmodule
			






	
					