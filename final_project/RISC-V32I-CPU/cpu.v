//Top-Level CPU

module cpu(
	input clk,
	input reset,
	output [31:0] pc,
	output [31:0] instr,

	
	
	output [7:0] LEDOut,
	output [41:0]sevenSegementDisplayValues,
	
	input updateDisplay,
	input [4:0] selectRegisterBits,
	
	output [7:0] DeadBits
);

	wire [31:0] pc_next, pc_plus4; 
	wire [31:0] rs1_data, rs2_data, alu_result, mem_read_data, Immidiate;
	wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, ALUSrc2, Branch;
	wire [3:0] ALUOp;
	wire [2:0] ImmSrc;

	assign DeadBits [7:0] = 8'b11111100;
	
	//Add the new allows us to read selected veiwRegister from the Register File (RF). See RF module for definition
	wire [31:0] viewRegister; 
	wire [5:0] selectedRegister;
	
	assign selectedRegister [4:0] = selectRegisterBits [4:0];

	//Assign PC so it is viewable internaly
	
	
	
	// Program Counter (PC)
	
	reg [31:0] PC;
	assign pc = PC;
	assign pc_plus4 = PC + 4;
	
	always @(posedge clk or negedge reset)
		begin
			if(~reset)
				PC <= 0;
			
			else
				PC <= pc_plus4; //simple sequenctial PC, will need to be updated a J and B instructions
		end
		
		// Instruction Memory
		imem IMEM (
			.addr(pc), 			//the cpu asks imem for the instruction using the current pc
			.instr(instr)
		); 
		
		// Control Unit
		
		// The control unit decodes the instructions opcode (bits[6:0]) and generates control signals
		control CTRL (
			.opcode(instr[6:0]),
			.RegWrite(RegWrite),
			.MemRead(MemRead),
			.MemWrite(MemWrite),
			.MemToReg(MemToReg),
			.ALUSrc(ALUSrc),
			.ALUSrc2(ALUSrc2),
			.Branch(Branch),
			.ALUOp(ALUOp[3:0]),
			.ImmSrc(ImmSrc[2:0]),
			.funct3(instr[14:12]),
			.funct7(instr[31:25])
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
			.ReadData2(rs2_data),
			.viewRegister(viewRegister),
			.selectRegister(selectedRegister),
			.displayRegister(updateDisplay)
		);
		
		//Register 1 represented as LEDs and Seven Segment. Last 8 LEDS and all Seven segemnt displays give allow for the user to represent 32 bits as
		//binary and hex
		
		Extend EXTEND (
			
			.instruction(instr[31:7]),
			.ImmSrc(ImmSrc[2:0]),
			.ImmExt(Immidiate[31:0])
			
		); 
		
		
		//ALU
		
		wire [31:0] alu_in1 = ALUSrc2 ? 32'b0 : rs1_data;				//If ALUSrc2 = 1 then alu_in1 = 0, else if ALUSrc2 = 0 use the rs1 data
		wire [31:0] alu_in2 = ALUSrc ? Immidiate[31:0] : rs2_data; //if ALUSrc = 1, use the immediate value (sign-extend bits [31:20]). If ALUSrc = 0, use the second register operand (rs2_data). 																								//The second operand is either an imidiate or a reg value

		
		alu ALU (
			.A(alu_in1), 
			.B(alu_in2), 
			.ALUControl(ALUOp[3:0]), 
			.Result(alu_result), 
			.Zero()
		);
		
		
		
		//Data Memory
		//Accessed when using lw and sw instrucitons
		dmem DMEM (
			.clk(clk), 
			.MemWrite(MemWrite), 
			.MemRead(MemRead),
			.addr(alu_result), 
			.WriteData(rs2_data), 
			.ReadData(mem_read_data)
		
		);
						
						
						
						

		//Now assigning DisplayLogic for viewing Register 1 on the LED's and 7 Segment Display
		

				
			//Assigning each 7 segemnt display to display the proper hex number given the register value			
						 

					
					
					
			//Assings 4 bit binary to the corresponding display bits for the 7 segment display.
			function [0:6] segment;
				input [3:0] fourBitChunk;
					
					begin
						case(fourBitChunk [3:0])
						
							default	:	segment = ~7'b0000000; //Negating because the 7-segment LEDS are active low
							
							4'b0000	:	segment = ~7'b0111111; //0
							4'b0001	:	segment = ~7'b0110000; //1
							4'b0010	:	segment = ~7'b1011011; //2
							4'b0011	:	segment = ~7'b1001111; //3
							4'b0100	:	segment = ~7'b1100110; //4
							4'b0101	:	segment = ~7'b1101101; //5
							4'b0110	:	segment = ~7'b1111101; //6
							4'b0111	:	segment = ~7'b0000111; //7
							4'b1000	:	segment = ~7'b1111111; //8
							4'b1001	:	segment = ~7'b1100111; //9
							4'b1010	:	segment = ~7'b1110111; //A
							4'b1011	:	segment = ~7'b1111100; //B
							4'b1100	:	segment = ~7'b0111000; //C
							4'b1101	:	segment = ~7'b1011110; //D
							4'b1110	:	segment = ~7'b1111001; //E
							4'b1111	:	segment = ~7'b1110001; //F
						
							
						endcase
					end
				endfunction
					
				//always @ (~updateDisplay)
					//begin
					
							//LED Assigned to register Values
							assign LEDOut [7:0] = viewRegister [7:0];	
					
							//Assigning Segment Values
							assign sevenSegementDisplayValues [6:0] 	= segment(viewRegister[11:8]);
							assign sevenSegementDisplayValues [13:7] 	= segment(viewRegister[15:12]);
							assign sevenSegementDisplayValues [20:14] 	= segment(viewRegister[19:16]);
							assign sevenSegementDisplayValues [27:21] 	= segment(viewRegister[23:20]);
							assign sevenSegementDisplayValues [34:28] 	= segment(viewRegister[27:24]);
							assign sevenSegementDisplayValues [41:35] 	= segment(viewRegister[31:28]);
							
							
					//end
						
	endmodule
		
		
		
		
		
		
		
	
