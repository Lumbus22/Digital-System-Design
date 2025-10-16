module sequence(IN, OUT, CLK, presentState);

input IN, CLK;

output reg OUT;

parameter reg [2:0]A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, F = 3'b101, G = 3'b110, H = 3'b111;

output reg [2:0]presentState = A; //Start in state A
 

always @(posedge CLK)
	begin

		
		case(presentState)
		
			A: begin
					
					if(IN)
						begin
							presentState = B;
							OUT = 0;
						end
					else
						begin
							presentState = F;
							OUT = 0;
						end
				end
				
				
			B: begin
					
					if(IN)
						begin
							presentState = C;
							OUT = 0;
						end
					else
						begin
							presentState = D;
							OUT = 0;
						end
				end
			
			
			C: begin
					
					if(IN)
						begin
							presentState = E;
							OUT = 0;
						end
						
					else
						begin
							presentState = F;
							OUT = 0;
						end
				end
				
				
				
			D: begin
					
					if(IN)
						begin
							presentState = A;
							OUT = 0;
						end
						
					else
						begin
							presentState = G;
							OUT = 1;
						end
				end
				
				
			E: begin
					
					if(IN)
						begin
							presentState = C;
							OUT = 0;
						end
					else
						begin
							presentState = D;	
							OUT = 0;
						end
						
				end
				
				
			F: begin
							
					if(IN)
						begin
							presentState = B;
							OUT = 1;
						end
					else
						begin
							presentState = F;
							OUT = 1;
						end
				end
				
				
			G: begin
					
					
					if(IN)
						begin
							presentState = G;
							OUT = 1;
						end
					else
						begin
							presentState = H;
							OUT = 0;
						end
				end
				
			
			H: begin
					
					OUT = 1;
					if(IN)
						begin
							presentState = A;
							OUT = 0;
						end
					else
						begin
							presentState = G;
							OUT = 1;
						end
				end
			
			
			default: begin
							presentState = A;							
							OUT = 0;
						end
		endcase
	end

endmodule