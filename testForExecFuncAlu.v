`include "execute.v"

module test_alu;
    reg [4:0] operation, shift;
    reg [31:0] operand1, operand2, result;

    // copy from execute.v
    function [31:0] alu;
        input [4:0] opr, shift;
        input [31:0] operand1, operand2;;

        case(opr)
            5'd0:    alu = operand1 + operand2;
            5'd1:    alu = operand1 - operand2;
            5'd8:    alu = operand1 & operand2;
            5'd9:    alu = operand1 | operand2;
            5'd10:   alu = operand1 ^ operand2;
            5'd11:   alu = ~(operand1 & operand2);
            5'd16:   alu = operand1 << shift;
            5'd17:   alu = operand1 >> shift;
            5'd18:   alu = operand1 >>> shift;
            default: alu = 32'hffffffff;
        endcase
    endfunction

    initial begin
        operation = 0; shift = 0; operand1 = 32'h00000000; operand2 = 32'h00000000;
        result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h00000000; operand2 = 32'h00000001; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h0fffffff; operand2 = 32'h00000001; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'hffffffff; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);

        #100 operation = 1; operand1 = 32'h00000000; operand2 = 32'h00000000; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'hffffffff; operand2 = 32'hfffffffe; result = alu(operation, shift, operand1, operand2);

        #100 operation = 8; operand1 = 32'h00000000; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h55555555; operand2 = 32'haaaaaaaa; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'hffffffff; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);

        #100 operation = 9; operand1 = 32'h00000000; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h55555555; operand2 = 32'haaaaaaaa; result = alu(operation, shift, operand1, operand2);

        #100 operation = 10; operand1 = 32'h00000000; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h55555555; operand2 = 32'h55555555; result = alu(operation, shift, operand1, operand2);

        #100 operation = 11; operand1 = 32'h00000000; operand2 = 32'hffffffff; result = alu(operation, shift, operand1, operand2);
        #100 operand1 = 32'h55555555; operand2 = 32'h55555555; result = alu(operation, shift, operand1, operand2);

        #100 operation = 16; operand1 = 32'h12345678; shift = 2'h1; result = alu(operation, shift, operand1, operand2);
        #100 operation = 16; operand1 = 32'h12345678; shift = 2'h1; result = alu(operation, shift, operand1, operand2);

        #100 operation = 17; operand1 = 32'h12345678; shift = 2'h1; result = alu(operation, shift, operand1, operand2);

        #100 operation = 18; operand1 = 32'h12345678; shift = 2'h1; result = alu(operation, shift, operand1, operand2);

        #100 operand1 = 32'h92345678; shift = 2'h1; result = alu(operation, shift, operand1, operand2);

        #100 operation = 2; result = alu(operation, shift, operand1, operand2);

        #2000 $finish;
    end

    initial $monitor($stime, "\top = 0x%h,\tshift = 0x%h,\top1 = 0x%h,\top2 = 0x%h,\tresult = 0x%h", operation, shift, operand1, operand2, result);

endmodule
