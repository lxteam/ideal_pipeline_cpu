`timescale 1ns / 1ps
module MEM(
    input [31:0] R1_in,
    input [31:0] data_in,
    input clk,
    input MemWrite,
    input MemtoReg,
    input UnsignedExt_Mem,
    input Byte,
    input Half,
    input CLR,
    
    output [31:0] R1,
    output [31:0] ZDX_ID_MEM,
    output [256*8-1:0] ram_content
);
    wire [31:0] R1_t;
    MIPS_RAM ram1(R1_in, data_in, MemWrite, clk, Byte, Half, CLR, UnsignedExt_Mem, R1_t, ram_content);
    assign R1 = MemtoReg ? R1_t : R1_in;
    assign ZDX_ID_MEM = R1_t;
endmodule // 

// module MIPS_RAM(
//     input [31:0] addr,
//     input [31:0] data_in,
//     input MemWrite,
//     input clk,
//     input Byte,
//     input Half,
//     input CLR,
//     input UnsignedExt_Mem,

//     output reg[31:0] data_out
// );