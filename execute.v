module data_mem(
    input [7:0] address,
    input clk,
    input [7:0] write_data,
    input wren, // wren 0: write enable, 1: write disable
    output [7:0] read_data
);
    reg [7:0] d_mem [0:255];

    always @(posedge clk)
        if (wren == 0) d_mem [address] <= write_data;

    assign read_data = d_mem [address];
endmodule

module execute(
    input  clk,
    input  [31:0] ins, pc, reg1, reg2, // pc: program couter
    output [4:0] wra, // wra: write register address
    output [31:0] result, nextpc
);
    wire [5:0] op;
    wire [4:0] shift, operation;
    wire [25:0] addr;
    wire [31:0] dpl_imm, operand2, alu_result, mem_address, dm_r_data;
    wire [3:0] wren;

    function [4:0] opr_gen;
        input [5:0] op;
        input [4:0] operation;

        case (op)
            6'd0:    opr_gen = operation;
            6'd1:    opr_gen = 5'd0;
            6'd4:    opr_gen = 5'd8;
            6'd5:    opr_gen = 5'd9;
            6'd6:    opr_gen = 5'd10;
            default: opr_gen = 5'h1f;
        endcase
    endfunction

    function [31:0] alu;
        input [4:0] opr, shift;
        input [31:0] operand1, operand2;;

        case(opr)
            5'd0:    alu = operand1 + operand2;
            5'd1:    alu = operand1 - operand2;
            5'd8:    alu = operand1 & operand2;
            5'd9:    alu = operand1 | operand2;
            5'd10:   alu = operand1 ^ operand2;
            5'd11:   alu = ~(operand1 & operand2);
            5'd16:   alu = operand1 << shift;
            5'd17:   alu = operand1 >> shift;
            5'd18:   alu = operand1 >>> shift;
            default: alu = 32'hffffffff;
        endcase
    endfunction

    // operation field
    //
    // R type: |op(6)       |rs(5)     |rt(5)     |rd(5)     |aux(11)               |
    // I type: |op(6)       |rs(5)     |rt(5)     |imm/dpl(16)                      |
    // A type: |op(6)       |addr(26)                                               |
    assign op         = ins [31:26]; // op(6)
    assign shift      = ins [10:6];
    assign operation  = ins [4:0];
    assign dpl_imm    = {{16{ins[15]}}, ins[15:0]};
    assign operand2   = (op == 6'd0) ? reg2 : dpl_imm; // op 0:R, ~0:I
    assign alu_result = alu(opr_gen(op, operation), shift, reg1, operand2);

    assign mem_address = (reg1 + dpl_imm) >>> 2;
    assign wren = wrengen(op);


    function [3:0] wrengen;
        input [5:0] op;

        case(op)
            6'd24:   wrengen = 4'b0000;
            6'd26:   wrengen = 4'b1100;
            6'd28:   wrengen = 4'b1110;
            default: wrengen = 4'b1111;
        endcase
    endfunction


    // 8bit, 4 thread memory
    data_mem data_meme_body0(.address(mem_address[7:0]),   .clk(clk), .write_data(reg2[7:0])  , .wren(wren[0]), .read_data(dm_r_data[7:0]));
    data_mem data_meme_body1(.address(mem_address[15:8]),  .clk(clk), .write_data(reg2[15:8]) , .wren(wren[1]), .read_data(dm_r_data[15:8]));
    data_mem data_meme_body2(.address(mem_address[23:16]), .clk(clk), .write_data(reg2[23:16]), .wren(wren[2]), .read_data(dm_r_data[23:16]));
    data_mem data_meme_body3(.address(mem_address[31:24]), .clk(clk), .write_data(reg2[31:24]), .wren(wren[3]), .read_data(dm_r_data[31:24]));

    assign wra       = wreg(op, ins[20:16], ins[15:11]);
    assign result    = calc(op, alu_result, dpl_imm, dm_r_data, pc);


    function [31:0] calc;
        input [5:0] op;
        input [31:0] alu_result, dpl_imm, dm_r_data, pc;

        case(op)
            6'd0, 6'd1, 6'd4, 6'd5, 6'd6: calc = alu_result;
            6'd3:                         calc = dpl_imm << 16;
            6'd16:                        calc = dm_r_data;
            6'd18:                        calc = {{16{dm_r_data[15]}}, dm_r_data[15:0]};
            6'd20:                        calc = {{24{dm_r_data[7]}}, dm_r_data[7:0]};
            6'd41:                        calc = pc + 32'd1;
            default:                      calc = 32'hffffffff;
        endcase
    endfunction

    function [4:0] wreg;
        input [5:0] op;
        input [4:0] rt, rd;

        case(op)
            6'd0:                                              wreg = rd;
            6'd1, 6'd3, 6'd4, 6'd5, 6'd6, 6'd16, 6'd18, 6'd20: wreg = rt;
            6'd41:                                             wreg = 5'd31;
            default:                                           wreg = 5'd0;
        endcase
    endfunction


    assign addr      = ins[25:0];

    assign nextpc    = npc(op, reg1, reg2, pc, dpl_imm, addr);


    function [31:0] npc;
        input [5:0] op;
        input [31:0] reg1, reg2, pc, dpl_imm;
        input [25:0] addr;

        case(op)
            6'd32:        npc = (reg1 == reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // beq
            6'd33:        npc = (reg1 != reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // bne
            6'd34:        npc = (reg1 < reg2)  ? pc + 32'd1 + dpl_imm : pc + 32'd1; // blt
            6'd35:        npc = (reg1 <= reg2) ? pc + 32'd1 + dpl_imm : pc + 32'd1; // ble
            6'd40, 6'd41: npc = {6'b0, addr};                                       // j, jal
            6'd42:        npc = reg1;                                               // jr
            default:      npc = pc + 32'd1;
        endcase
    endfunction


endmodule
