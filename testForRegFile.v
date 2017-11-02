`include "writeback.v"

module test_register_file;
    reg clk, rstd, wren;
    reg [4:0] ra1, ra2, wa;
    wire [31:0] rr1, rr2;
    reg [31:0] wr;

    initial begin
        clk = 0; forever #50 clk = ~clk;
    end
    initial begin
        #1300 $finish;
    end

    initial begin
        rstd = 1;
        #30 rstd = 0;
        #40 rstd = 1;
        #10 wren = 0; ra1 = 1; ra2 = 2; wa = 3; wr = 32'haaaaaaaa;
        #100 ra1 = 3; ra2 = 3; wa = 4; wr = 32'h55555555;
        #100 ra1 = 4; ra2 = 5; wa = 5; wr = 32'h12345678;
        #100 ra1 = 5; ra2 = 4; wa = 6; wr = 32'h87654321;
        #100 ra1 = 6; ra2 = 0; wa = 1; wr = 32'h11111111;
        #100 ra1 = 1; ra2 = 6; wa = 2; wr = 32'h22222222;
        #100 ra1 = 1; ra2 = 2; wa = 7; wr = 32'h77777777;
        #100 wren = 1; ra1 = 1; ra2 = 2; wa = 8; wr = 32'haaaaaaaa;
        #100 ra1 = 3; ra2 = 4; wa = 9; wr = 32'h11111111;
        #100 ra1 = 5; ra2 = 6; wa = 10; wr = 32'hbbbbbbbb;
        #100 ra1 = 7; ra2 = 8; wa = 11; wr = 32'hcccccccc;
        #100 ra1 = 9; ra2 = 10; wa = 11; wr = 32'hdddddddd;
    end

    reg_file rf_body(.clk(clk), .rstd(rstd), .wr(wr), .ra1(ra1), .ra2(ra2), .wa(wa), .wren(wren), .rr1(rr1), .rr2(rr2));

    initial begin
        $monitor($stime, "\tclk = %d,\trstd = %d,\tra1 = 0x%h,\tra2 = 0x%h,\twa = 0x%h,\trr1 = 0x%h,\trr2 = 0x%h,\twr=0x%h,\twren = 0x%h", clk, rstd, ra1, ra2, wa, rr1, rr2, wr, wren);
    end
endmodule
