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
module instructionMemory(
    input  [`BITWIDTHOFPROGRAMCOUNTER - 1:0]  programCounter, // 2 ** 8 = 256
    output [31:0] instruction
);
    reg [31:0] instructionMemory [0:2 ** `BITWIDTHOFPROGRAMCOUNTER];

    initial begin
        $readmemb("sample.bnr", instructionMemory); // load binary file to instructionMemory
    end

    assign instruction = instructionMemory[programCounter];
endmodule
