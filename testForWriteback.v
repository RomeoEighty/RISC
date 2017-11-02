`include "writeback.v"
module test_writeback;
    reg clk, rstd;
    reg [31:0] nextpc;
    wire [31:0] pc;

    initial begin
        clk = 0; forever #50 clk = ~clk;
    end
    initial begin
        rstd = 1;
        #10 rstd = 0;
        #20 rstd = 1;
    end
    initial begin
        #30  nextpc = 32'h00000001;
        #100 nextpc = 32'h12345678;
        #100 nextpc = 32'h87654321;
        #100 nextpc = 32'hffffffff;
        #400 $finish;
    end

    writeback writeback_body(.clk(clk), .rstd(rstd), .nextpc(nextpc), .pc(pc));

    initial $monitor($stime, "\trstd = %d,\tclk = %d,\tnextpc = 0x%h,\tpc=0x%h", rstd, clk, nextpc, pc);
endmodule
