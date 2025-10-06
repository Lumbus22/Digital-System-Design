module lfsr(initialValue , Load, Clock, Y);

input [3:0] initialValue;
input Load, Clock;

output reg [3:0] Y;

wire I; // I is used to determine the next Y0

always @(posedge Clock)
	if(Load)
		Y <= initialValue;
	else
	
	begin
	
	I <= (~Y[3]&~Y[2]&~Y[1]&Y[0]) | (~Y[3]&Y[2]&Y[1]&~Y[0]);
	
	Y <= {Y[2], Y[1], Y[0], I};
	
	end
	
endmodule