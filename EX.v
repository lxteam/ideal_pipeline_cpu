`timescale 1ns / 1ps
module EX(
    input [3:0] ALU_OP,
    input clk_in,
    input ALU_SRC,
    input [31:0] PC,
    input LUI,
    input Regtoshamt,
    input [31:0] RD1,
    input [31:0] RD2,
    input [31:0] Extended_Imm,
	input [4:0] shamt,
    input HIAlu_Src,
    input LOAlu_Src,
    input [31:0] HI,
    input [31:0] LO,
	
	output [31:0] R1,
	output [31:0] R2,	
	output OF,
    output UOF,
    output Equal
	);
    wire [31:0] y = ALU_SRC ? (LOAlu_Src|HIAlu_Src ? (HIAlu_Src ? HI : LO) : Extended_Imm) : RD2 ;//ALU第二个输入
    wire [4:0] alu_shamt = LUI ? 16 : (Regtoshamt ? RD2[4:0] : shamt);
   ALU alu_0(RD1,y,ALU_OP,alu_shamt,R1,R2,OF,UOF,Equal); 
endmodule