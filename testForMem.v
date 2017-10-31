`include "execute.v"

module test_mem;
    reg [7:0] address;
    reg clk, wren;
    reg [7:0] ra, wa, write_data;
    wire [7:0] read_data;

    initial begin
        clk = 0; forever #50 clk = ~clk;
    end

    initial begin
        #40  address = 0; write_data = 8'h21; wren = 0;
        #100 address = 1; write_data = 8'h43; wren = 0;
        #100 address = 2; write_data = 8'h65; wren = 1;
        #100 address = 2; write_data = 8'h87; wren = 0;
        #100 address = 3; write_data = 8'ha9; wren = 0;
        #100 address = 0;                     wren = 1;
        #100 address = 1;                     wren = 1;
        #100 address = 2;                     wren = 1;
        #100 address = 3;                     wren = 1;
        #110 $finish;
    end

    initial $monitor($stime, "address = %d, clk = %d, write_data = 0x%h, wren = %d, read_data = 0x%h", address, clk, write_data, wren, read_data);
    data_mem data_mem_body(.address(address), .clk(clk), .write_data(write_data), .wren(wren), .read_data(read_data));
endmodule
