// MIPS operation field
// R type: |op(6)       |rs(5)     |rt(5)     |rd(5)     |aux(11)               |
// input bit wide: 5
//      2**5 = 32
//      equal to input resistor address bit wide
module registorFile(
    input  [4:0]  readResitorAddress1,
    input  [4:0]  readResitorAddress2,
    input  [4:0]  writeResistorAddress,
    input  [31:0] writeResistorData,
    input  clock,
    input  writeEnable, // assert(1): enable, deassert(0): disable
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] registor [0:31];
    
    assign readData1 = registor[readResitorAddress1];
    assign readData2 = registor[readResitorAddress2];
    always @(posedge clock)
        if (writeEnable == 1) registor[writeResistorAddress] <= writeResistorData;
endmodule
