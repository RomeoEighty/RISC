// ------------ fig 4.6 ------------ 
// fetch

// if there was no branch instruction, this adder would work.
module adderForPc(
    input pc,
    output nextPc
);
    assign nextPc = pc + 1;
endmodule

// contains 256 insturctions whose wide of bit is 32.
module instructionMemory(
    input  [7:0]  programCounter, // 2 ** 8 = 256
    output [31:0] instruction
);
    reg [31:0] instructionMemory [0:255];

    initial begin
        $readmemb("sample.bnr", instructionMemory); // load binary file to instructionMemory
    end

    assign instruction = instructionMemory[programCounter];
endmodule
