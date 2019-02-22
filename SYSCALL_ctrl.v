`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/20 19:27:44
// Design Name: 
// Module Name: SYSCALL_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//generate syscall control signal
module SYSCALL_ctrl(
    input CLR,
    input SYSCALL,
    input GO,
    input [31:0] v0,
    input [31:0] a0,
    
    
    output reg [31:0] display,
    output reg halt
    );
    assign print = v0 == 34 & SYSCALL;
    always @(posedge CLR, posedge SYSCALL, posedge GO) begin
        if (CLR)
            halt <= 0;
        else if (SYSCALL)
            halt <= v0 == 10;
//        else if (GO) begin
//            halt <= v0==10;       
//        end
    
    end
    always @(posedge print)
        display <= a0;
    
    
endmodule
