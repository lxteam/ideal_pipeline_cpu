`timescale 1ns / 1ps
module FIVE_STAGE1(
    input clk_in,
    input btnl,
    input btnr,
    input btnu,
    input btnc,
    input btnd,
    input [15:0] sw,
    output [15:0] led,
    output [7:0] an,
    output [7:0] seg
);
//name : '1' means stage1(IF), '2' means stage2(ED)....
    wire[31:0] Jaddr,PC_branch,Iaddr,EPC;
    wire[3:0] ALUOP,ALUOP_out2;
    wire[4:0] WbRegNum,WbRegNum_out2,WbRegNum_out3,WbRegNum_out4;
    wire[4:0] shamt,shamt_out2;
    wire[31:0] IR,PC,IR_out1,IR_out2,IR_out3,IR_out4,PC_out1,PC_out2,PC_out3,PC_out4;
    wire[31:0] R1,R2,R1_out3,R1_out4,R2_out3,R2_out4,R1_in4;
    wire[31:0] Extended_Imm,Extended_Imm_out2,HI,LO,HI_out2,LO_out2;
    wire[31:0] RD1,RD1_out2,RD1_out3,RD1_out4,RD2,RD2_out2,RD2_out3,RD2_out4;
    wire R1_EX,R2_EX,R1_MEM,R2_MEM,Hi_EX,Lo_EX,Hi_MEM,Lo_MEM;
    wire [31:0] ZDX_EX,ZDX_MEM,ZDX_ID_MEM;
    wire CP0Write, CP0toReg;
    wire [31:0] CP0data,CP0data_out2,CP0data_out3,CP0data_out4;
    wire [4:0] R1Num,R2Num,CP0Num,CP0Num_out2,CP0Num_out3,CP0Num_out4;
    wire [31:0] display;
    wire [32*32-1:0] reg_content;
    wire [256*8-1:0] ram_content;
    reg [12:0] Num_cycle;
    wire pause;
    
    assign led[12:0] = sw[12:0];
    assign led[15] = ir1_asyn,led[14]=ir2_asyn,led[13]=ir3_asyn;
    always @(posedge clk)begin
        if (CLR)
            Num_cycle <= 0;
        else if (!(halt | pause))
            Num_cycle <= Num_cycle+1;
    end
    
    
//enable list, 'a' is signal part enable, 'b' is reg part enable
    wire PC_EN,EN1,EN2a,EN2b,EN3a,EN3b,EN4a,EN4b,ENCP0; 
    wire J = JAL | JMP | JR;
    wire Int, Branch, ERET, LOAD_USE;
    wire bubble1 = J | Branch | Int | ERET, bubble2 = LOAD_USE | Branch | Int, bubble3 = Int, bubble4 = Int;
    assign PC_EN = (!halt) & (!LOAD_USE) & !pause,  EN1 = (!halt)& (!LOAD_USE) &!pause, EN2a = !halt & !pause , EN2b = !halt & !pause, EN3a = !halt & !pause , EN3b = !halt & !pause , EN4a = !halt & !pause , EN4b = !halt & !pause , ENCP0 = !halt & !pause;
    IF IF1(Jaddr,PC_branch,Iaddr,EPC,J,Branch,Int,ERET,clk,PC_EN,CLR,IR,PC);
    IFtoID IFtoID1(clk,EN1,CLR,IR,IR_out1,PC,PC_out1,bubble1);
    ID ID1(IR_out1,clk,CLR,SYSCALL,UnsignedExt_Imm,RegDst,JMP,JR,JAL,RegWrite_out4,LOWrite_out4,
        HIWrite_out4,CP0toReg_out4? CP0data_out4 : (JAL_out4?PC_out4:R1_out4),R2_out4,WbRegNum_out4,Branch,R1_EX,R1_MEM,R2_EX,R2_MEM,Hi_EX,Hi_MEM,Lo_EX,Lo_MEM,R2_CP0_EX, CP0data_out2, R2_CP0_MEM, CP0data_out3,ZDX_EX,ZDX_MEM,RD1,RD2,WbRegNum,Extended_Imm,shamt,HI,LO,Jaddr,R1Num,R2Num,CP0Num,reg_content);
    IDtoEX_reg IDtoEX_reg1(clk,EN2b,CLR,IR_out1,IR_out2,PC_out1,PC_out2, bubble2, RD1,RD1_out2,RD2,RD2_out2,WbRegNum,WbRegNum_out2,Extended_Imm,Extended_Imm_out2,shamt,shamt_out2,HI,HI_out2,LO,LO_out2,CP0data,CP0data_out2,CP0Num,CP0Num_out2);
    IDtoEX_signal IDtoEX_signlal1(clk,EN2a,CLR, bubble2, RegWrite,RegWrite_out2,LOWrite,LOWrite_out2,HIWrite,HIWrite_out2,MemtoReg,MemtoReg_out2,JAL,JAL_out2,SYSCALL,SYSCALL_out2,CP0Write,CP0Write_out2,CP0toReg,CP0toReg_out2,MemWrite,MemWrite_out2,UnsignedExt_Mem,UnsignedExt_Mem_out2,Byte,Byte_out2,Half,Half_out2,ALUOP,ALUOP_out2,ALUSRC,ALUSRC_out2,B,B_out2,EQ,EQ_out2,Less,Less_out2,Reverse,Reverse_out2,BGEZ,BGEZ_out2,LUI,LUI_out2,Regtoshamt,Regtoshamt_out2,LOAlusrc,LOAlusrc_out2,HIAlusrc,HIAlusrc_out2,J,J_out2,ERET,ERET_out2);
    EX EX1(ALUOP_out2,clk,ALUSRC_out2,PC_out2,LUI_out2,Regtoshamt_out2,RD1_out2,RD2_out2,Extended_Imm_out2,shamt_out2,HIAlusrc_out2,LOAlusrc_out2,HI_out2,LO_out2,B_out2,EQ_out2,Less_out2,Reverse_out2,BGEZ_out2,WbRegNum_out2[0],R1,R2,OF,UOF,Equal,Branch,PC_branch);
    EXtoMEM_reg EXtoMEM_reg1(clk,EN3b,CLR,IR_out2,IR_out3,PC_out2,PC_out3,bubble3,R1,R1_out3,R2,R2_out3,RD1_out2,RD1_out3,RD2_out2,RD2_out3,WbRegNum_out2,WbRegNum_out3,CP0data_out2,CP0data_out3,CP0Num_out2,CP0Num_out3);
    ExtoMEM_signal ExtoMEM_signal1(clk,EN3a,CLR,bubble3,RegWrite_out2,RegWrite_out3,LOWrite_out2,LOWrite_out3,HIWrite_out2,HIWrite_out3,MemtoReg_out2,MemtoReg_out3,JAL_out2,JAL_out3,SYSCALL_out2,SYSCALL_out3,CP0Write_out2,CP0Write_out3,CP0toReg_out2,CP0toReg_out3,MemWrite_out2,MemWrite_out3,UnsignedExt_Mem_out2,UnsignedExt_Mem_out3,Byte_out2,Byte_out3,Half_out2,Half_out3);
    MEM MEM1(R1_out3,RD2_out3,clk,MemWrite_out3,MemtoReg_out3,UnsignedExt_Mem_out3,Byte_out3,Half_out3,CLR,R1_in4 ,ZDX_ID_MEM, ram_content);
    MEMtoWB_reg MEMtoWB_reg1(clk,EN4b,CLR,IR_out3,IR_out4,PC_out3,PC_out4,bubble4,R1_in4,R1_out4,R2_out3,R2_out4,RD1_out3,RD1_out4,RD2_out3,RD2_out4,WbRegNum_out3,WbRegNum_out4,CP0data_out3,CP0data_out4,CP0Num_out3,CP0Num_out4);
    MEMtoWB_signal MEMtoWB_signal1(clk,EN4a,CLR,bubble4,RegWrite_out3,RegWrite_out4,LOWrite_out3,LOWrite_out4,HIWrite_out3,HIWrite_out4,JAL_out3,JAL_out4,SYSCALL_out3,SYSCALL_out4,CP0Write_out3,CP0Write_out4,CP0toReg_out3,CP0toReg_out4);
    control_unit control_unit1(IR_out1,SYSCALL,RegDst,ALUOP,
        ALUSRC,LUI,Regtoshamt,LOAlusrc,HIAlusrc,MemWrite,
        Byte,Half,RegWrite,LOWrite,HIWrite,MemtoReg,UnsignedExt_Imm,
        UnsignedExt_Mem,B,EQ,Less,Reverse,BGEZ,JR,JMP,JAL,ERET, CP0Write, CP0toReg, R1Used, R2Used, HiUsed, LoUsed,CP0Used);
    SYSCALL_ctrl SysC1(clk,CLR,SYSCALL_out4,GO,RD1_out4,RD2_out4,display,halt);
    DataConflict_ctrl DatC1(R1Used, R2Used, HiUsed, LoUsed, CP0Used, R1Num, R2Num, CP0Num,CP0toReg_out2, CP0toReg_out3,CP0toReg_out4, CP0Write_out2, CP0Num_out2, CP0Write_out3, CP0Num_out3, CP0Write_out4, CP0Num_out4, RegWrite_out2, WbRegNum_out2, RegWrite_out3, WbRegNum_out3, HIWrite_out2, LOWrite_out2, HIWrite_out3, LOWrite_out3, R2,R1,JAL_out2,PC_out2,MemtoReg_out3,ZDX_ID_MEM,JAL_out3,PC_out3,R2_out3,R1_out3,MemtoReg_out2,R1_EX,R2_EX,R1_MEM,R2_MEM,Hi_EX,Lo_EX,Hi_MEM,Lo_MEM,R2_CP0_EX,R2_CP0_MEM,CP0_EX,CP0_MEM,CP0_WB,ZDX_EX,ZDX_MEM,LOAD_USE);

    CP0_ CP0(clk, ENCP0, CLR, ir1, ir2, ir3, ERET_out2, PC_out2, IR_out2, PC_branch, J_out2, Branch,CP0Write_out4,CP0Num_out4,RD2_out4, CP0_EX, RD2_out2, CP0_MEM, RD2_out3, CP0_WB,PC_out1,PC_out2,PC_out3,IR_out2,IR_out3, Int, Iaddr, EPC,CP0data, ir1_asyn, ir2_asyn,ir3_asyn);
    
    FPGA_ctrl board(clk_in, display, Num_cycle, sw, btnl, btnr, btnu, btnc, btnd, reg_content, ram_content, ir1, ir2, ir3, clk, CLR, GO, pause, an, seg);
    
endmodule // 

/*
module FPGA_ctrl(
    input clk_in,
    input [31:0] Todisplay,
    input [12:0] num_clcye,
    input [15:0] sw,
    input btnl,
    input btnr,
    input [32*32-1:0] reg_content,
    input [256*8-1:0] ram_content,
    
    output clk,
    output CLR,
    output GO,
    output reg pause,
    output [7:0] an,
    output [7:0] seg
    

*/
