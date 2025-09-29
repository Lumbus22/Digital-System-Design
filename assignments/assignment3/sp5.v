module sp5(
    input  [3:0] m,   // multiplicand
    input  [3:0] q,   // multiplier
    output [7:0] p    // product
);

    wire [3:0] pp0, pp1, pp2, pp3;  // partial products
    wire [4:0] sum1, sum2, sum3;    // intermediate sums
    wire [3:0] s1, s2, s3;          // sum outputs of adders
    wire       c1, c2, c3;          // carry outs

    // Step 1: Generate partial products
    assign pp0 = {4{q[0]}} & m;  // q0 * m
    assign pp1 = {4{q[1]}} & m;  // q1 * m
    assign pp2 = {4{q[2]}} & m;  // q2 * m
    assign pp3 = {4{q[3]}} & m;  // q3 * m

    // Step 2: Add partial products (shifted)
    assign p[0] = pp0[0];   // LSB directly from pp0

    // First addition: pp0[3:1] + pp1
    adder4 A1 (
        .A({1'b0, pp0[3:1]}), 
        .B(pp1), 
        .Cin(1'b0), 
        .Sum(s1), 
        .Cout(c1)
    );
    assign p[4:1] = s1[3:0];

    // Second addition: {c1, s1[3:1]} + pp2
    adder4 A2 (
        .A({c1, s1[3:1]}), 
        .B(pp2), 
        .Cin(1'b0), 
        .Sum(s2), 
        .Cout(c2)
    );
    assign p[5] = s2[0];
    assign p[6] = s2[1];

    // Third addition: {c2, s2[3:1]} + pp3
    adder4 A3 (
        .A({c2, s2[3:1]}), 
        .B(pp3), 
        .Cin(1'b0), 
        .Sum(s3), 
        .Cout(c3)
    );
    assign p[7] = c3;   // final carry becomes MSB

endmodule
