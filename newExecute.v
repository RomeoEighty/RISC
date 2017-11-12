`include "newMemoryAccess.v"

// operation field
//
// R type: |op(6)       |rs(5)     |rt(5)     |rd(5)     |aux(11)               |
// I type: |op(6)       |rs(5)     |rt(5)     |imm/dpl(16)                      |
// A type: |op(6)       |addr(26)                                               |
module decode(
    input  clk,
    input  [31:0] ins,
    input  [31:0] reg2,

    output [5:0]  op,
    output [4:0]  rs,
    output [4:0]  rt,
    output [4:0]  rd,
    output [4:0]  shift, // for sll, srl, sra
    output [10:0] aux,
    output [25:0] addr,
    output [31:0] dpl_imm,
    output [31:0] operand2,
    output [4:0]  shortop,
    output [3:0]  wren
);
    assign op       = ins[31:26]; // op(6)
    assign rs       = ins[25:21];
    assign rt       = ins[20:16];
    assign rd       = ins[15:11];
    assign aux      = ins[10:0];
    assign shift    = aux[10:6];
    assign addr     = ins[25:0]; // A type: |op(6)       |addr(26)                                               |
    assign dpl_imm  = {{16{ins[15]}}, ins[15:0]};
    assign operand2 = (op == 6'd0) ? reg2 : dpl_imm; // op 0:R, ~0:I


    assign shortop  = opr_gen(op, ins[4:0]);

    function [4:0] opr_gen; // {{{
        input [5:0] op;
        input [4:0] operation;

        case (op)
            6'd0:    opr_gen = operation;
            6'd1:    opr_gen = 5'd0;  // addi
            6'd4:    opr_gen = 5'd8;  // andi
            6'd5:    opr_gen = 5'd9;  // ori
            6'd6:    opr_gen = 5'd10; // xori
            default: opr_gen = 5'h1f; 
        endcase
    endfunction // }}}


    assign wren = wrengen(op);

    function [3:0] wrengen; // {{{
        input [5:0] op;

        case(op)
            6'd24:   wrengen = 4'b1111;
            6'd26:   wrengen = 4'b0011;
            6'd28:   wrengen = 4'b0001;
            default: wrengen = 4'b0000;
        endcase
    endfunction // }}}

endmodule


module execute(
    input  clk,
    input  [31:0] ins,
    input  [31:0] pc,   // pc: program couter
    input  [31:0] reg1, // register[rs]
    input  [31:0] reg2, // register[rt]

    input  [5:0]  op,
    input  [4:0]  rs,
    input  [4:0]  rt,
    input  [4:0]  rd,
    input  [4:0]  shift, // for sll, srl, sra
    input  [10:0] aux,
    input  [25:0] addr,
    input  [31:0] dpl_imm,
    input  [31:0] operand2,
    input  [4:0]  shortop,
    input  [3:0]  wren,

    output [4:0]  wra, // wra: write register address
    output [31:0] result,
    output [31:0] nextpc
);
    wire [31:0] alu_result, mem_address, dm_r_data;

    // operation field
    //
    // R type: |op(6)       |rs(5)     |rt(5)     |rd(5)     |aux(11)               |
    // I type: |op(6)       |rs(5)     |rt(5)     |imm/dpl(16)                      |
    // A type: |op(6)       |addr(26)                                               |
    assign alu_result = alu(shortop, shift, reg1, operand2);

    assign mem_address = (reg1 + dpl_imm) >>> 2;

    function [31:0] alu; // {{{
        input [4:0] opr, shift;
        input [31:0] operand1, operand2;;

        case(opr)
            5'd0:    alu = operand1 + operand2;    // addi (opr_gen)
            5'd1:    alu = operand1 - operand2;
            5'd8:    alu = operand1 & operand2;    // andi (opr_gen)
            5'd9:    alu = operand1 | operand2;    // ori  (opr_gen)
            5'd10:   alu = operand1 ^ operand2;    // xori (opr_gen)
            5'd11:   alu = ~(operand1 & operand2);
            5'd16:   alu = operand1 << shift;
            5'd17:   alu = operand1 >> shift;
            5'd18:   alu = operand1 >>> shift;
            default: alu = 32'hffffffff;
        endcase
    endfunction // }}}


    // 8bit, 4 thread memory
    dataMemory datamemory0(
        .wordaddr(mem_address),     // input [31:0]
        .clk(clk),                  // input
        .writeData(reg2[7:0]),      // input [7:0]
        .writeEnable(wren[0]),      // input
        .readData(dm_r_data[7:0])   // output [7:0]
    );
    dataMemory datamemory1(.wordaddr(mem_address), .clk(clk), .writeData(reg2[15:8]) , .writeEnable(wren[1]), .readData(dm_r_data[15:8]));
    dataMemory datamemory2(.wordaddr(mem_address), .clk(clk), .writeData(reg2[23:16]), .writeEnable(wren[2]), .readData(dm_r_data[23:16]));
    dataMemory datamemory3(.wordaddr(mem_address), .clk(clk), .writeData(reg2[31:24]), .writeEnable(wren[3]), .readData(dm_r_data[31:24]));

    assign wra       = wreg(op, rt, rd);


    function [4:0] wreg; // {{{
        input [5:0] op;
        input [4:0] rt, rd;

        case(op)
            6'd0:                                              wreg = rd;
            6'd1, 6'd3, 6'd4, 6'd5, 6'd6, 6'd16, 6'd18, 6'd20: wreg = rt;
            6'd41:                                             wreg = 5'd31;
            default:                                           wreg = 5'd0;
        endcase
    endfunction // }}}

    assign result    = calc(op, alu_result, dpl_imm, dm_r_data, pc);


    function [31:0] calc; // {{{
        input [5:0] op;
        input [31:0] alu_result, dpl_imm, dm_r_data, pc;

        case(op)
            6'd0, 6'd1, 6'd4, 6'd5, 6'd6: calc = alu_result;
            6'd3:                         calc = dpl_imm << 16; // lui
            6'd16:                        calc = dm_r_data; // lw
            6'd18:                        calc = {{16{dm_r_data[15]}}, dm_r_data[15:0]};
            6'd20:                        calc = {{24{dm_r_data[7]}}, dm_r_data[7:0]};
            6'd41:                        calc = pc + 32'd1;
            default:                      calc = 32'hffffffff;
        endcase
    endfunction // }}}


    assign nextpc    = npc(op, reg1, reg2, pc, dpl_imm, addr);


    function [31:0] npc; // {{{
        input [5:0] op;
        input [31:0] reg1, reg2, pc, dpl_imm;
        input [25:0] addr;

        case(op)
            6'd32:        npc = (reg1 == reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // beq
            6'd33:        npc = (reg1 != reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // bne
            6'd34:        npc = (reg1 <  reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // blt
            6'd35:        npc = (reg1 <= reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // ble
            6'd40, 6'd41: npc = {6'b0, addr};                                       // j, jal
            6'd42:        npc = reg1;                                               // jr
            6'd63:        $finish;                                       // halt
            default:      npc = pc + 32'd1;
        endcase
    endfunction // }}}


endmodule
