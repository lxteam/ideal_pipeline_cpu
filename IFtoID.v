//流水信息传递
`timescale 1ns / 1ps
module IFtoID(
    //通用
    input clk, input EN, input CLR, 
    input [31:0] IR_in, output reg [31:0] IR,
    input [31:0] PC_in, output reg [31:0] PC,
    input bb
    //特化
);
    always @(posedge clk) begin
        if (CLR | (bb & EN)) begin
            {IR,PC} <= 0;
            
        end
        else if(EN) begin
            IR <= IR_in;
            PC <= PC_in;
        end

    end

endmodule