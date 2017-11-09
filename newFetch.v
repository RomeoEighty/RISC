// ------------ fig 4.6 ------------ 
// fetch

// if there was no branch instruction, this adder would work.
`define BITWIDTHOFPROGRAMCOUNTER 8

module adderForPc(
    input  [`BITWIDTHOFPROGRAMCOUNTER - 1:0] pc,
    output [`BITWIDTHOFPROGRAMCOUNTER - 1:0] nextPc
);
    assign nextPc = pc + `BITWIDTHOFPROGRAMCOUNTER'b1;
endmodule

// contains 256 insturctions whose wide of bit is 32.
module insMemory(
    input  [`BITWIDTHOFPROGRAMCOUNTER - 1:0]  pc, // 2 ** 8 = 256
    output [31:0] ins
);
    reg [31:0] insMemory [0:2 ** `BITWIDTHOFPROGRAMCOUNTER];

    initial begin
        $readmemb("sample1.bin", insMemory); // load binary file to insMemory
    end

    assign ins = insMemory[pc];
endmodule
