`timescale 1ns / 1ps
module SYSCALL_ctrl(
    input clk,
    input CLR,
    input SYSCALL,
    input GO,
    input [31:0] v0,
    input [31:0] a0,
    
    
    output reg [31:0] display,
    output reg halt
    );
    wire print = v0 == 34 & SYSCALL;
    reg [1:0] GO_last;
    always @(posedge clk)begin
        case ({GO,GO_last})
            3'b100: GO_last <= 2'b01;
            3'b101: GO_last <= 2'b10;
            3'b110: GO_last <= 2'b10;
//            3'b111: GO_last <= 2'b00;
            default: GO_last <= 2'b00;
        endcase
    end
    always @(posedge CLR, posedge SYSCALL, posedge GO_last[0]) begin
        if (CLR)
            halt <= 0;
        else if (GO_last[0]) begin
            halt <= v0==10;       
        end
        else if (SYSCALL)
            halt <= 1; 
    end
    always @(posedge print)
        display <= a0;
    
    
endmodule