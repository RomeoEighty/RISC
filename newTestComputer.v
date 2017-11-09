`include "newComputer.v"

module test;
    reg clk;
    reg rstd;
    initial begin
        $dumpfile("newDump.vcd");
        $dumpvars(0, cmp);
        #1000 $finish;
    end
    initial begin
        clk <= 0;
        forever #10 clk = ~clk;
    end
    initial begin
        rstd <= 0;
        #30 rstd <= 1;
    end

    computer cmp(
        .clk(clk),
        .rstd(rstd)
    );
endmodule
