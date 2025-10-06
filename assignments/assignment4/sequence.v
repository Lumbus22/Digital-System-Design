module sequence(IN, OUT, CLK, presentState);

input IN, CLK;

output reg OUT;

parameter reg [2:0]A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101, G = 3'b110, H = 3'b111;

output reg [2:0]presentState = A;
 

always @(posedge CLK)
	begin

		
		case(presentState)
		
			A: begin
					
					OUT = 0;
					if(IN)
						presentState = B;
					else
						presentState = A;
				end
				
			B: begin
					
					OUT = 0;
					if(IN)
						presentState = D;
					else
						presentState = C;
				end
			
			C: begin
					
					OUT = 0;
					if(IN)
						presentState = A;
					else
						presentState = E;
				end
				
				
				
			D: begin
					
					OUT = 0;
					if(IN)
						presentState = G;
					else
						presentState = C;
				end
				
			E: begin
					
					OUT = 0;
					if(IN)
						presentState = F;
					else
						presentState = A;
				end
				
				
			F: begin
					
					OUT = 1;
					if(IN)
						presentState = D;
					else
						presentState = C;
				end
				
			G: begin
					
					OUT = 0;
					if(IN)
						presentState = H;
					else
						presentState = C;
				end
				
				
			H: begin
					
					OUT = 1;
					if(IN)
						presentState = H;
					else
						presentState = C;
				end
			
			default: begin
							presentState = A;							
							OUT = 0;
						end
		endcase
	end

endmodule