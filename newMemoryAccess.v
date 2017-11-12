module dataMemory(
    input  [7:0] address,
    input  clk,
    input  [7:0] writeData,
    input  writeEnable, // assert(1): write enable, assert(0): write disable
    output [7:0] readData
);
    reg [7:0] data [0:255];

    always @(posedge clk) begin
        if (writeEnable == 1) begin
            data[address] <= writeData;
            $display("@%m", $stime, "[0x%h]<-0x%h", address, writeData);
        end
        $display("@%m", $stime, "[0x%h]->0x%h", address, readData);
    end

    assign readData = data[address];
endmodule
