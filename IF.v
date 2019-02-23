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
    parameter ADDR_WIDTH = 10;
    parameter DEPTH = 2**ADDR_WIDTH;
    integer i;
    reg [ADDR_WIDTH-1:0] pc;
    assign PC_out = pc+1;
    reg [31:0] rom[DEPTH-1:0];
    initial begin
        for (i = 0; i<DEPTH; i = i+1)
            rom[i] = 0;
        $readmemb("C:/Users/liucongyu/redirect/dc.b",rom);
        // for (i = 0; i < DEPTH; i = i+1)
        //     $display("line %d : %h\n", i, rom[i]);
//            $readmemh("/home/wc/w/sort.ht",rom);
    end
    assign bubble1 = JAL | J | JR | Branch;
    assign IR = rom[pc];
    always @(posedge clk) begin
        if (CLR)
            pc <= 0;
        else if (PC_EN) begin
            if (Branch)
                pc <= PC_branch;
            else if (JAL|JR|J)
                pc <= Jaddr;
            else
                pc <= PC_out;
            
        end
    end


endmodule // 