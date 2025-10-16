module midtermprep(

input Button, 
output reg [9:0]LED = 10'b0000000000


);


//parameters 


always @(negedge Button)
	begin
		if(LED[9:0] == 10'b1000000000 | LED[9:0] == 10'b0000000000) 
			begin
				LED[9:0] <= 10'b0000000001;
			end
		else
			begin
				LED <= LED * 2;
			end
	

	
	
	end


endmodule