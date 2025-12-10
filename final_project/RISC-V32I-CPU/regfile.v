//Register File


module regfile(

	input clk,
	input RegWrite,
	input [4:0] rs1, rs2, rd,
	input [31:0] WriteData,
	output [31:0] ReadData1, ReadData2, viewRegister,
	input [4:0] selectRegister //5 bit Selection for one of hte 32 bit registers. 
	
);

	reg [31:0] regs [0:31]; //an array of 32 registers, 32 bits wide
	
	//Read Ports
	assign ReadData1 = (rs1 != 0) ? regs[rs1] : 0; // IF rs1 != 0, then ReadData1 = regs[rs1]
	assign ReadData2 = (rs2 != 0) ? regs[rs2] : 0; //Combinational logic will imidialtely change values making ReadData1 & ReadData2 imidiately available
	assign viewRegister = regs[selectRegister];
	
	//Write port
	always @(posedge clk) 
		begin
			if(RegWrite && rd != 0)
				regs[rd] <= WriteData;
			regs[0] <= 0;
		end
				
endmodule