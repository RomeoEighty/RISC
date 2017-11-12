`define MEMWORDADDRLEN 32

module dataMemory(
    input  [31:0] wordaddr,
    input  clk,
    input  [7:0] writeData,
    input  writeEnable,         // assert(1): write enable, assert(0): write disable
    output [7:0] readData
);
    reg [7:0] data [0:255];

    always @(posedge clk) begin
        if (writeEnable == 1) begin
            data[wordaddr] <= writeData;
            $display("@%m", $stime, "[0x%h]<-0x%h", wordaddr, writeData);
        end
        $display("@%m", $stime, "[0x%h]->0x%h", wordaddr, readData);
    end

    assign readData = data[wordaddr];
endmodule
