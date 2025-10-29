//Control unit

module control(

	input [6:0] opcode, // 7 bit opcode from the instruciton. Used to determine the operation 
	input [2:0] funct3, // 3 bit function code for instruction variants
	input [6:0] funct7, // 7 bit function code for R-type variants
	
	output reg RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch,
	output reg Jump, JALRSel, LUISel, AUIPCSel, // New control signals for jumps and upper immediates
	output reg [3:0] ALUOp

);

/*
Notes for Control. The controller generate the control sgnals RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch, ALUOp

RegWrite: 1 will force the pc to write "WriteData" to the current register destination (rd). 0 Disables RegWrite. See "regfile"

MemRead: 1 will force a "ReadData" to a value in memory. the memory address is given in the machine code

MemWrite: 1 writes "WriteData" or (rs2) to a location in memory. the memory address is set in the machine code. see "dmem"

MemToReg: 1 set "WriteData" to mem_read_data if 0 then "WriteData" is the alu_result. 

*/

	always @(*) 
		begin
		//Default Values
		RegWrite = 0; MemRead = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0; Branch = 0; 
		Jump = 0; JALRSel = 0; LUISel = 0; AUIPCSel = 0; ALUOp = 0;
			
			//Case statements for determing operation. 
			case(opcode)
				
				7'b0010011: // I-Type (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI)
					begin
						RegWrite = 1; ALUSrc = 1;
						case(funct3)
							3'b000: ALUOp = 4'b0000; // ADDI
							3'b111: ALUOp = 4'b0010; // ANDI
							3'b110: ALUOp = 4'b0011; // ORI
							3'b100: ALUOp = 4'b0100; // XORI
							3'b010: ALUOp = 4'b0101; // SLTI (set less than immediate)
							3'b011: ALUOp = 4'b0110; // SLTIU (set less than immediate unsigned)
							3'b001: ALUOp = 4'b0111; // SLLI (shift left logical immediate)
							3'b101: ALUOp = (funct7[5]) ? 4'b1001 : 4'b1000; // SRAI : SRLI
							default: ALUOp = 4'b0000;
						endcase
					end
					
				7'b0110011: // R-Type (ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA)
					begin
						RegWrite = 1; ALUSrc = 0;
						case(funct3)
							3'b000: ALUOp = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
							3'b111: ALUOp = 4'b0010; // AND
							3'b110: ALUOp = 4'b0011; // OR
							3'b100: ALUOp = 4'b0100; // XOR
							3'b010: ALUOp = 4'b0101; // SLT (set less than)
							3'b011: ALUOp = 4'b0110; // SLTU (set less than unsigned)
							3'b001: ALUOp = 4'b0111; // SLL (shift left logical)
							3'b101: ALUOp = (funct7[5]) ? 4'b1001 : 4'b1000; // SRA : SRL
							default: ALUOp = 4'b0000;
						endcase
					end
				
				7'b0000011: // LW
					begin
						RegWrite = 1; MemRead = 1; MemToReg = 1; ALUSrc = 1; ALUOp = 4'b0000;
					end
		
			7'b0100011: // SW
				begin
					MemWrite = 1; ALUSrc = 1; ALUOp = 4'b0000; // ADD for address calculation
				end
						
			7'b1100011: // Branch (BEQ, BNE, BLT, BGE, BLTU, BGEU)
				begin
					Branch = 1; ALUSrc = 0;
					case(funct3)
						3'b000: ALUOp = 4'b0001; // BEQ - subtract for comparison
						3'b001: ALUOp = 4'b0001; // BNE - subtract for comparison
						3'b100: ALUOp = 4'b1010; // BLT - signed less than
						3'b101: ALUOp = 4'b1011; // BGE - signed greater or equal
						3'b110: ALUOp = 4'b1100; // BLTU - unsigned less than
						3'b111: ALUOp = 4'b1101; // BGEU - unsigned greater or equal
						default: ALUOp = 4'b0001;
					endcase
				end
				
			7'b1101111: // JAL (Jump and Link)
				begin
					RegWrite = 1; Jump = 1;
				end
				
			7'b1100111: // JALR (Jump and Link Register)
				begin
					RegWrite = 1; Jump = 1; JALRSel = 1; ALUSrc = 1; ALUOp = 4'b0000; // Add rs1 + imm
				end
				
			7'b0110111: // LUI (Load Upper Immediate)
				begin
					RegWrite = 1; LUISel = 1;
				end
				
			7'b0010111: // AUIPC (Add Upper Immediate to PC)
				begin
					RegWrite = 1; AUIPCSel = 1;
				end
	
				default: ; //Default is defined outside of the case
					
			endcase
		end
endmodule
			






	
					