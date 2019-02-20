`timescale 1ns / 1ps
module IF(
    input [31:0] jaddr,
    input [31:0] baddr,
    input JAL,input J, input JR, input Branch,
    input clk,
    input CLR,

    output [31:0] IR,
    output reg [31:0] PC
);
    parameter width = 5;
    integer i;
    reg [31:0] rom[2**width-1:0];
    initial begin
        for (i = 0; i<2**width; i = i+1)
            rom[i] = 0;
        $readmemh("/home/wc/w/ideal_test.hex",rom);
    end
    assign IR = rom[PC];
    always @(posedge clk) begin
        if (CLR)
            PC <= 0;
        else
            PC <= PC+1;
    end


endmodule // 