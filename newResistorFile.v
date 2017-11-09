// MIPS operation field
// R type: |op(6)       |rs(5)     |rt(5)     |rd(5)     |aux(11)               |
// input bit wide: 5
//      2**5 = 32
//      equal to input resistor address bit wide
module registerFile(
    input  clk,
    input  rstd,
    input  [4:0]  readRegisterAddress1,
    input  [4:0]  readRegisterAddress2,
    input  [4:0]  writeRegisterAddress,
    input  [31:0] writeRegisterData,
    input  writeEnable, // assert(1): enable, deassert(0): disable
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] register [0:31];
    
    assign readData1 = register[readRegisterAddress1];
    assign readData2 = register[readRegisterAddress2];
    always @(negedge rstd or posedge clk)
        if (rstd == 0) register[0] <= 32'h00000000;
        else if (writeEnable == 1) register[writeRegisterAddress] <= writeRegisterData;

    initial begin
        $monitor("\n@%m", $stime, "\n[00]%h [01]%h [02]%h [03]%h\n[04]%h [05]%h [06]%h [07]%h\n[08]%h [09]%h [10]%h [11]%h\n[12]%h [13]%h [14]%h [15]%h\n[16]%h [17]%h [18]%h [19]%h\n[20]%h [21]%h [22]%h [23]%h\n[24]%h [25]%h [26]%h [27]%h\n[28]%h [29]%h [30]%h [31]%h",register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
     end
endmodule

module writeback(
    input clk,
    input rstd,
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
