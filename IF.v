`timescale 1ns / 1ps
module IF(
    input [31:0] Jaddr,
    input [31:0] PC_branch,
    input JAL,input J, input JR, input Branch,
    input clk,
    input PC_EN,
    input CLR,

    output [31:0] IR,
    output [31:0] PC_out,
    output bubble1
);
    parameter ADDR_WIDTH = 5;
    parameter DEPTH = 2**ADDR_WIDTH;
    integer i;
    reg [ADDR_WIDTH-1:0] pc;
    assign PC_out = pc;
    reg [31:0] rom[DEPTH-1:0];
    initial begin
        for (i = 0; i<DEPTH; i = i+1)
            rom[i] = 0;
        $readmemh("/home/wc/w/ideal_test.hex",rom);
    end
    assign bubble1 = JAL || J || JR || Branch;
    assign IR = rom[pc];
    always @(posedge clk) begin
        if (CLR)
            pc <= 0;
        else if (PC_EN)
            pc <= JAL ? Jaddr : (Branch ? PC_branch : pc+1);
    end


endmodule // 