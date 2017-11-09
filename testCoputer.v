`include "computer.v"
module test;
    reg clk, rstd;
    initial begin
        $dumpfile("dumpfile.vcd");
        $dumpvars(0, comp);
        clk <= 0;
        rstd <= 0;
        #100
        rstd <= ~rstd;
        #1000
        $finish;
    end

    always #10 clk <= ~clk;

    computer comp(.clk(clk), .rstd(rstd));
endmodule
