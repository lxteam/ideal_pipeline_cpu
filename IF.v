`timescale 1ns / 1ps
module IF(
    input [31:0] Jaddr,
    input [31:0] PC_branch,
    input [31:0] Iaddr,
    input [31:0] EPC,
    input J, input Branch, input Int, input ERET, 
    input clk,
    input PC_EN,
    input CLR,

    output [31:0] IR,
    output [31:0] PC_out
);
    parameter ADDR_WIDTH = 10;
    parameter DEPTH = 2**ADDR_WIDTH;
    integer i;
    reg [ADDR_WIDTH-1:0] pc;
    assign PC_out = pc+1;
    reg [31:0] rom[DEPTH-1:0];
    initial begin
        for (i = 0; i<DEPTH; i = i+1)
            rom[i] = 0;
        $readmemh("/home/wc/w/int2.ht",rom);
        // for (i = 0; i < DEPTH; i = i+1)
        //     $display("line %d : %h\n", i, rom[i]);
//            $readmemh("/home/wc/w/sort.ht",rom);
    end
    assign IR = rom[pc];
    always @(posedge clk) begin
        if (CLR)
            pc <= 0;
        else if (PC_EN) begin
            if (Int)
                pc <= Iaddr;
            else if (Branch)
                pc <= PC_branch;
            else if (J)
                pc <= Jaddr;
            else if (ERET)
                pc <= EPC;
            else
                pc <= PC_out;
            
        end
    end


endmodule // 