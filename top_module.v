`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/13 16:33:03
// Design Name:
// Module Name: top_module
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input sysclk,
    input [7:0] sw,
    output [7:0] led
    );
    //adder adder0(sw[3:0], sw[7:4], led[5:0]);
    adder adder1(
    .inLeft(sw[7:4]),
    .inRight(sw[3:0]),
    .result(led[4:0])
    );
    //assign led = sw;
endmodule
