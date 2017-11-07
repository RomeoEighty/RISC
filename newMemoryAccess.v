module dataMemory(
    input  [7:0] address,
    input  clock,
    input  [7:0] writeData,
    input  writeEnable, // assert(1): write enable, assert(0): write disable
    output [7:0] readData
);
    reg [7:0] data [0:255];

    always @(posedge clock)
        if (writeEnable == 1) data[address] <= writeData;

    assign readData = data[address];
endmodule
