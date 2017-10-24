`timescale 1ns / 1ps

module adder(input [3:0] inLeft, input [3:0] inRight, output [4:0] result);
    reg [3:0] regL;
    reg [3:0] regR;
    reg [4:0] regResult;

    assign result = inLeft + inRight;

    initial begin
        regL <= inLeft;
        regR <= inRight;
    end

endmodule
