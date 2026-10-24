`timescale 1ns/1ps

module tb_top_halfadder;
    reg clk;
    reg rst;
    reg a;
    reg b;
    wire sum;
    wire carry;

    top_halfadder dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );

    always #2.5 clk = ~clk; // Period = 5ns (matches SDC clk period 5)

    initial begin
        clk = 0;
        rst = 1;
        a = 0;
        b = 0;
        #10 rst = 0;

        #5 a = 0; b = 0;
        #5 a = 0; b = 1;
        #5 a = 1; b = 0;
        #5 a = 1; b = 1;
        #10;
        $finish;
    end
endmodule
