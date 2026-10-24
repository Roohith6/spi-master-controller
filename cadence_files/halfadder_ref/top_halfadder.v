module top_halfadder(
    input wire clk,
    input wire rst,
    input wire a,
    input wire b,
    output reg sum,
    output reg carry
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum   <= 1'b0;
            carry <= 1'b0;
        end else begin
            sum   <= a ^ b;
            carry <= a & b;
        end
    end

endmodule
