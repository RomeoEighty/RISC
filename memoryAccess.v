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
