module reg_file(
    input clk, rstd,
    input [31:0] wr,
    input [4:0] ra1, ra2, wa,
    input wren,
    output [31:0] rr1, rr2
);
    reg [31:0] rf [0:31];

    assign rr1 = rf [ra1];
    assign rr2 = rf [ra2];
    always @(negedge rstd or posedge clk)
        if (rstd == 0) rf [0] <= 32'h00000000;
        else if (wren == 0) rf [wa] <= wr;
endmodule
