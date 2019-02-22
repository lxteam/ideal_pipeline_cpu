`timescale 1ns / 1ps
module ID(
    input [31:0] IR,
    input clk,
    input CLR,
    input SYSCALL,
    input UnsignedExt_Imm,
    input RegDst,
    input JMP,
    input JR,
    input JAL,
    input RegWrite,
    input LOWrite,
    input HIWrite,
    input [31:0] WbData,
    input [31:0] HI_in,
    input [4:0] WbRegNum_in,
    input Branch,
    input R1_EX,
    input R1_MEM,
    input R2_EX,
    input R2_MEM,
    input HI_EX,
    input HI_MEM,
    input LO_EX,
    input LO_MEM,
    input ZDX_EX,
    input ZDX_MEM,

    output [31:0] RD1,
    output [31:0] RD2,
    output [4:0] WbRegNum,
    output reg [31:0] Extended_Imm,
    output [4:0] shamt,
    output reg [31:0] HI,
    output reg [31:0] LO,
    output [31:0] jaddr
);
    wire [5:0] OP = IR[31:26];
    wire [5:0] Func = IR[5:0];
    wire [4:0] rs = IR[25:21];
    wire [4:0] rt = IR[20:16];
    wire [4:0] rd = IR[15:11];
    wire [15:0] Imm = IR[15:0];
    wire [4:0] R1Num = SYSCALL ? 2 : rs;
    wire [4:0] R2Num = SYSCALL ? 4 : rt;
    wire A_1 , B_1, HI_1, LO_1;
    assign WbRegNum = JAL ? 31 : (RegDst ? rd : rt);
    assign jaddr = JR ? RD1 : $unsigned(IR[25:0]); //J addr PC[31:28]
    assign shamt = IR[10:6];
    // negedge to deal with WB data conflict.
    always @(negedge clk) begin
        if (CLR) begin
            HI_1 <= 0;
            LO_1 <= 0;
        end
        else begin
            if (HIWrite)
                HI_1 <= HI_in;
            if (LOWrite)
                LO_1 <= WbData;
        end
    end
    always @(*)begin
        if (UnsignedExt_Imm)
            Extended_Imm = $unsigned(Imm);
        else
            Extended_Imm = $signed(Imm);
    end
    REGFILE reg1(WbData, clk, RegWrite,WbRegNum_in, R1Num, R2Num, A_1, B_1);
    assign RD1 = (R1_EX) ? ZDX_EX : ((R1_MEM) ? ZDX_MEM : A_1);
    assign RD2 = (R2_EX) ? ZDX_EX : ((R2_MEM) ? ZDX_MEM : B_1);
    assign HI  = (HI_EX) ? ZDX_EX : ((HI_MEM) ? ZDX_MEM :HI_1);
    assign LO  = (LO_EX) ? ZDX_EX : ((HI_MEM) ? ZDX_MEM :LO_1); 
endmodule // 

/*
module REGFILE(
	input [31:0] WbData, 
	input clk, 
	input RegWrite, 
	input [4:0]WbRegNum, 
	input [4:0]R1Num, 
	input [4:0]R2Num,
	input JAL,

	output [31:0]A, 
	output [31:0]B
);
*/