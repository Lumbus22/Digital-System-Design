//Proggramming a MUX in verilog

module MUX(w0, w1, S, F);

input w0, w1, S;
output F;

assign F = (~S & w0) | (S & w1); //if S is 0, F = w0; if S is 1, F = w1

endmodule

//another way to write it usign the internal logic of a mux

module moreMUX(w0, w1, S, F);
input w0, w1, S;
output F;

wire F0, F1, F3; //Wires for internal connections, are optional as they can be inferred by the compiler 

and A1 (F0, w0, F3); 
and A2 (F1, S, w1); 
not A3 (F3, S); 
 
or A4 (F, F0, F1);

endmodule




//Now using conditional statements
module conditionalMUX(w0, w1, F, S);

assign F = (S) ? w1 : w0; //if S is true, F = w1, else F = w0

endmodule 

//This is a 4x1 MUX, 4 inputs, 1 output, 2 select lines
module conditional4x1Mux(w0, w1, w2, w3, S1, S0, F);

input w0, w1, w2, w3; //4 inputs
input S1, S0; //2 select lines
output F;

assign F = S1 ? (S0 ? w3 : w2) : (S0 ? w1 : w0); //if S1 is true, check S0 for w3 or w2, else check S0 for w1 or w0

endmodule

//Prodcedural Statements
//If Else statement, Case Statement, For loop
// always @(*) means always when any input changes

module proceduralMUX(w0, w1, S, F);
input w0, w1, S;

output reg F; //F is a reg because it is assigned in an always block

always @(w0, w1, S)  //sensitivity list, when any of these change, the block is executed
    begin
    if (S == 1)  
        F = w1; //if S is true, F = w1   
    else 
        F = w0; //if S is false, F = w0
    end

endmodule

//Defining numbers in verilog

//binary 
3'b100 //3 bits, binary, value 4

//octal
3'04 //3 bits, octal, value 4

//hexa
3'h4 //3 bits, hexadecimal, value 4 

//decimal
3'd4 //3 bits, decimal, value 4

//Case statement
module caseMUX(w, S, F);
input [3:0] w; //4 inputs
input [1:0] S; //2 select lines
output reg F; //F is a reg because it is assigned in an always block

always @(w, S)

    begin
        case(S)
        
        2'b00: F = w[0];
        2'b01: F = w[1];
        2'b10: F = w[2];
        3: F = w[3];
        default: F = 1'bx; //if S is not 0,1,2,3, F is unknown
        
        endcase
    end

endmodule

//For loop
module forMUX(w, S, F);
input [3:0] w; //4 inputs  
input [1:0] S; //2 select lines
output reg F; //F is a reg because it is assigned in an always block

integer i; //integer for loop variable

always @(w, S)
    begin
        F = 1'bx; //default value
        for (i = 0; i <= 3; i = i + 1) //loop from 0 to 3
            begin
                if (S[i] == 1'b1) //if the ith bit of S is 1
                    F = w[i]; //F is equal to the corresponding input
                else
                    F = F; //else F remains the same
            end
    end
endmodule
//Note: For loops in verilog are unrolled, meaning the compiler will create multiple instances of the loop for each iteration. This is different from software programming where the loop is executed sequentially.
//For loops are not recommended for synthesis, but can be used for testbenches and simulations.
//For loops are more commonly used for generating repetitive structures, such as arrays of registers or wires.
//For loops can also be used in initial blocks for testbenches to initialize values.
//For loops can also be used in generate blocks to create multiple instances of a module or a block of code.
//For loops can also be used in functions to perform repetitive calculations.
//For loops can also be used in tasks to perform repetitive operations.