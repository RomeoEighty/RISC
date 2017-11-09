module writeback(
    input clk, rstd,
    input [31:0] nextpc,
    output [31:0] pc
);
    reg [31:0] pc;

    always @(negedge rstd or posedge clk)
        begin
            if(rstd == 0) pc <= 32'h00000000;
            else if (clk == 1) pc <= nextpc;
        end
endmodule

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

    initial begin
        $monitor("#", $stime, "\n[00]%h [01]%h [02]%h [03]%h\n[04]%h [05]%h [06]%h [07]%h\n[08]%h [09]%h [10]%h [11]%h\n[12]%h [13]%h [14]%h [15]%h\n[16]%h [17]%h [18]%h [19]%h\n[20]%h [21]%h [22]%h [23]%h\n[24]%h [25]%h [26]%h [27]%h\n[28]%h [29]%h [30]%h [31]%h",rf[0], rf[1], rf[2], rf[3], rf[4], rf[5], rf[6], rf[7], rf[8], rf[9], rf[10], rf[11], rf[12], rf[13], rf[14], rf[15], rf[16], rf[17], rf[18], rf[19], rf[20], rf[21], rf[22], rf[23], rf[24], rf[25], rf[26], rf[27], rf[28], rf[29], rf[30], rf[31]);
    end
endmodule
