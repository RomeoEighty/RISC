`include "newExecute.v"
`include "newFetch.v"
`include "newResistorFile.v"

module computer(
    input clk,
    input rstd
);
    wire [31:0] pc;
    wire [31:0] ins;
    wire [31:0] reg1;
    wire [31:0] reg2;
    wire [31:0] result;
    wire [31:0] nextpc;
    wire [4:0]  wra;
    wire [3:0]  wren;

    wire [5:0]  op;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [4:0]  shift; // for sll, srl, sra
    wire [10:0] aux;
    wire [25:0] addr;
    wire [31:0] dpl_imm;
    wire [31:0] operand2;
    wire [4:0]  shortop;

    insMemory im(          // module insMemory(
        // TODO: pc size inappropriate
        // increment size
        //  assembler : 4
        //  inside processor: 1
        .pc(pc[7:0]),            //     input  [`BITWIDTHOFPROGRAMCOUNTER - 1:0]  pc, // 2 ** 8 = 256

        .ins(ins)           //     output [31:0] ins
    );                      // );
    decode dec(             // module decode(
        .clk(clk),          //     input  clk,
        .ins(ins),          //     input  [31:0] ins,
        .reg2(reg2),        //     input  [31:0] reg2,
                            // 
        .op(op),            //     output [5:0]  op,
        .rs(rs),            //     output [4:0]  rs,
        .rt(rt),            //     output [4:0]  rt,
        .rd(rd),            //     output [4:0]  rd,
        .shift(shift),      //     output [4:0]  shift, // for sll, srl, sra
        .aux(aux),          //     output [10:0] aux,
        .addr(addr),        //     output [25:0] addr,
        .dpl_imm(dpl_imm),  //     output [31:0] dpl_imm,
        .operand2(operand2),//     output [31:0] operand2,
        .shortop(shortop),  //     output [4:0]  shortop,
        .wren(wren)         //     output [3:0]  wren
    );                      // );
    execute exec(           // module execute(
        .clk(clk),          //     input  clk,
        .ins(ins),          //     input  [31:0] ins,
        .pc(pc),            //     input  [31:0] pc, // pc: program couter
        .reg1(reg1),        //     input  [31:0] reg1,
        .reg2(reg2),        //     input  [31:0] reg2,
                            //
        .op(op),            //     input  [5:0]  op,
        .rs(rs),            //     input  [4:0]  rs,
        .rt(rt),            //     input  [4:0]  rt,
        .rd(rd),            //     input  [4:0]  rd,
        .shift(shift),      //     input  [4:0]  shift, // for sll, srl, sra
        .aux(aux),          //     input  [10:0] aux,
        .addr(addr),        //     input  [25:0] addr,
        .dpl_imm(dpl_imm),  //     input  [31:0] dpl_imm,
        .operand2(operand2),//     input  [31:0] operand2,
        .shortop(shortop),  //     input  [4:0]  shortop,
        .wren(wren),        //     input  [3:0]  wren,
                            //
        .wra(wra),          //     output [4:0]  wra, // wra: write register address
        .result(result),    //     output [31:0] result,
        .nextpc(nextpc)     //     output [31:0] nextpc
    );                      // );
    writeback wb(           // module writeback(
        .clk(clk),          //     input clk,
        .rstd(rstd),        //     input rstd,
        .nextpc(nextpc),    //     input [31:0] nextpc,

        .pc(pc)             //     output [31:0] pc
    );                      // );
    registerFile rf(                        //module registerFile(
        .clk(clk),                          //    input  clk,
        .rstd(rstd),                        //     input rstd,
        .readRegisterAddress1(ins[25:21]),  //    input  [4:0]  readRegisterAddress1,
        .readRegisterAddress2(ins[20:16]),  //    input  [4:0]  readRegisterAddress2,
        .writeRegisterAddress(wra),         //    input  [4:0]  writeRegisterAddress,
        .writeRegisterData(result),         //    input  [31:0] writeRegisterData,
        .writeEnable((|wra)),               //    input  writeEnable, // assert(1): enable, deassert(0): disable

        .readData1(reg1),                   //    output [31:0] readData1,
        .readData2(reg2)                    //    output [31:0] readData2
    );                                      //);
endmodule
