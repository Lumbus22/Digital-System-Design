//Top-Level CPU

module cpu(
	input clk, reset

);

	wire [31:0] pc, pc_next, pc_plus4;
	wire [31:0] instr; 
	wire [31:0] rs1_data, rs2_data, alu_result, mem_read_data;
	wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch;
	wire [3:0] ALUOp;

	// Program Counter (PC)
	
	reg [31:0] PC;
	assign pc = PC;
	assign pc_plus4 = PC + 4;
	
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				PC <= 0;
			
			else
				PC <= pc_plus4; //simple sequenctial PC
		end
		
		// Instruction Memory
		imem IMEM (.addr(pc), .instr(instr)); //the cpu asks imem for the instruction using the current pc
		
		// Control Unit
		
		// The control unit decodes the instructions opcode (bits[6:0]) and generates control signals
		control CTRL (
			.opcode(instr[6:0]),
			.RegWrite(RegWrite),
			.MemRead(MemRead),
			.MemWrite(MemWrite),
			.MemToReg(MemToReg),
			.ALUSrc(ALUSrc),
			.Branch(Branch),
			.ALUOp(ALUOp)
		);
		
		//The Register file holds the 32 RISC-V registers (0x-x31)
		regfile RF (
			
			.clk(clk),
			.RegWrite(RegWrite),
			.rs1(instr[19:15]),
			.rs2(instr[24:20]),
			.rd(instr[11:7]),
			.WriteData(MemToReg ? mem_read_data : alu_result), //If the instruction is a (lw): write back the data from mem. else instruciton is (add, addi, and, ect...): write back the ALU result
			.ReadData1(rs1_data),
			.ReadData2(rs2_data)
		);
		
		
		
		//ALU
		
		//This line chooses the second ALU operand
		wire [31:0] alu_in2 = ALUSrc ? {{20{instr[31]}}, instr[31:20]} : rs2_data; //if ALUSrc = 1, use the immediate value (sign-extend bits [31:20]). If ALUSrc = 0, use the second register operand (rs2_data).
		
		alu ALU (.A(rs1_data), .B(alu_in2), .ALUControl(ALUOp), .Result(alu_result), .Zero());
		
		
		
		//Data Memory
		//Accessed when using lw and sw instrucitons
		dmem DMEM (.clk(clk), .MemWrite(MemWrite), .MemRead(MemRead),
						.addr(alu_result), .WriteData(rs2_data), .ReadData(mem_read_data));
						
	endmodule
		
		
		
		
		
		
		
	