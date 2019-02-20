`timescale 1ns / 1ps
module ID(
    input [31:0] IR,
    input clk,
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
    wire [4:0] R1Num = SYSCALL ? 4 : rs;
    wire [4:0] R2Num = SYSCALL ? 2 : rt;
    assign WbRegNum = JAL ? 31 : (RegDst ? rd : rt);
    assign jaddr = JR ? RD1 : $unsigned(IR[25:0]);
    assign shamt = IR[10:6];
    
    always @(posedge clk) begin
        if (HIWrite)
            HI <= HI_in;
        if (LOWrite)
            LO <= WbData;
    end
    always @(*)begin
        if (UnsignedExt_Imm)
            Extended_Imm = $unsigned(Imm);
        else
            Extended_Imm = $signed(Imm);
    end
    REGFILE reg1((JAL ? jaddr : WbData), clk, RegWrite,WbRegNum_in, R1Num, R2Num, JAL, RD1, RD2);
    

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