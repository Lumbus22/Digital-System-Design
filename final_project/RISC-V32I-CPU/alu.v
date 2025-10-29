//ALU - Arithmatic Logic Unit


module  alu(

input [31:0] A,
input [31:0] B, 
input [3:0] ALUControl, // Extended ALU operations

output reg[31:0] Result,
output Zero,
output LT, LTU, GE, GEU // Comparison outputs for branches

);


// Comparison outputs
assign Zero = (Result == 0);
assign LT = ($signed(A) < $signed(B));     // Signed less than
assign LTU = (A < B);                       // Unsigned less than
assign GE = ($signed(A) >= $signed(B));    // Signed greater or equal
assign GEU = (A >= B);                      // Unsigned greater or equal

always @(*) 
	begin
		case(ALUControl)
			4'b0000: Result = A + B;           // ADD
			4'b0001: Result = A - B;           // SUB
			4'b0010: Result = A & B;           // AND
			4'b0011: Result = A | B;           // OR
			4'b0100: Result = A ^ B;           // XOR
			4'b0101: Result = LT ? 32'd1 : 32'd0;  // SLT (set less than)
			4'b0110: Result = LTU ? 32'd1 : 32'd0; // SLTU (set less than unsigned)
			4'b0111: Result = A << B[4:0];     // SLL (shift left logical)
			4'b1000: Result = A >> B[4:0];     // SRL (shift right logical)
			4'b1001: Result = $signed(A) >>> B[4:0]; // SRA (shift right arithmetic)
			4'b1010: Result = LT ? 32'd1 : 32'd0;  // BLT comparison
			4'b1011: Result = GE ? 32'd1 : 32'd0;  // BGE comparison
			4'b1100: Result = LTU ? 32'd1 : 32'd0; // BLTU comparison
			4'b1101: Result = GEU ? 32'd1 : 32'd0; // BGEU comparison
			
			default: Result = 0;
		endcase
	end
endmodule