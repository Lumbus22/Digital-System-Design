module lfsr(initialValue, Load, Clock, Z);

input Load, Clock;
input [3:0] initialValue;

output reg Z; //Y is a single bit as the seequence only outputs one bit at a time

reg [3:0] Y;

reg I; // I is used to determine the next Y0. I is set as an output to see the logic of assigning I


always @(posedge Clock)
	
	if(Load)
	
		begin
	
			Y <= initialValue;
	
		end
	
	else
	
		begin
	
			case(Y)
	
				
				4'b1101: I = 1;
				4'b1011: I = 1;
				4'b0111: I = 0;
				4'b1110: I = 0;
				4'b1100: I = 1;
				4'b1001: I = 0;
				4'b0010: I = 0;
				4'b0100: I = 0;
				4'b1000: I = 1;
				4'b0001: I = 1;
				4'b0011: I = 0;
				4'b0110: I = 1;
		
				default: I = 1'bX;
				
			endcase 
	
	
	
	Y <= {Y[2], Y[1], Y[0], I};
	Z <= Y[3];
	
	end
	
endmodule