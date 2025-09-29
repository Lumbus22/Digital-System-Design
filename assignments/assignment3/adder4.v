module adder4 (
    input  [3:0] A, B,   // 4-bit inputs
    input        Cin,    // carry in
    output [3:0] Sum,    // 4-bit sum
    output       Cout    // carry out
);
    assign {Cout, Sum} = A + B + Cin;  // continuous assignment
endmodule
