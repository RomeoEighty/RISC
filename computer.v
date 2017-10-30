// rs: the first source resistor
// rt: the second source resistor ('cause 't' is the next letter after 's')
// imm: immidiate value
// 
// computer ──┬── fetch
//            ├── data_mem
//            ├── execute ──┬── opr_gen
//            │             ├── alu
//            │             ├── wrengen
//            │             ├── wreg
//            │             ├── clac
//            │             └── npc
//            ├── writeback
//            └── regr_file
`include "execute.v"
`include "reg_file.v"

module fetch(
    input [7:0] pc,
    output [31:0] ins
);
    reg [31:0] ins_mem [0:255];

    initial begin
        $readmemb("sample2.bnr", ins_mem); // for porgram load
    end

    assign ins = ins_mem[pc];
endmodule

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

module computer(
    input clk, rstd
);
    wire [31:0] pc, ins, reg1, reg2, result, nextpc;
    wire [4:0] wra;
    wire [3:0] wren;

    fetch fetch_body(.pc(pc[7:0]), .ins(ins));
    execute execute_body(.clk(clk), .ins(ins), .pc(pc), .reg1(reg1), .reg2(reg2), .wra(wra), .result(result), .nextpc(nextpc));
    writeback writeback_body(.clk(clk), .rstd(rstd), .nextpc(nextpc), .pc(pc));
    reg_file rf_body(.clk(clk), .rstd(rstd), .wr(result), .ra1(ins[25:21]), .ra2(ins[20:16]), .wa(wra), .wren((~|wra)), .rr1(reg1), .rr2(reg2));

    initial $monitor($time, " rstd = %d, clk = %d, pc = %h, ins = %h, wra = %h, reg1 = %h, reg2 = %h", rstd, clk, pc, ins, wra, reg1, reg2);

endmodule
