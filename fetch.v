module fetch(
    input [7:0] pc,
    output [31:0] ins
);
    reg [31:0] ins_mem [0:255];

    initial begin
        $readmemb("sample.bnr", ins_mem); // for porgram load
    end

    assign ins = ins_mem[pc];
endmodule
