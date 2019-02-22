`timescale 1ns / 1ps
module FIVE_STAGE1(
    input clk,
    input CLR,
    input GO,
    output [31:0] display
);
//name : '1' means stage1(IF), '2' means stage2(ED)....

    wire[31:0] Jaddr,PC_branch;
    wire[3:0] ALUOP,ALUOP_out2;
    wire[4:0] WbRegNum,WbRegNum_out2,WbRegNum_out3,WbRegNum_out4;
    wire[4:0] shamt,shamt_out2;
    wire[31:0] IR,PC,IR_out1,IR_out2,IR_out3,IR_out4,PC_out1,PC_out2,PC_out3,PC_out4;
    wire[31:0] R1,R2,R1_out3,R1_out4,R2_out3,R2_out4,R1_in4;
    wire[31:0] Extended_Imm,Extended_Imm_out2,HI,LO,HI_out2,LO_out2;
    wire[31:0] RD1,RD1_out2,RD1_out3,RD1_out4,RD2,RD2_out2,RD2_out3,RD2_out4;

//enable list, 'a' is signal part enable, 'b' is reg part enable
    wire PC_EN,EN1,EN2a,EN2b,EN3a,EN3b,EN4a,EN4b,bubble1;
    assign PC_EN = (!halt) & (!bb_data),  EN1 = (!halt)& (!bb_data), EN2a = !halt, EN2b = !halt, EN3a = !halt, EN3b = !halt, EN4a = !halt, EN4b = !halt;
    IF IF1(Jaddr,PC_branch,JAL,JMP,JR,Branch,clk,PC_EN,CLR,IR,PC,bubble1);
    IFtoID IFtoID1(clk,EN1,CLR,IR,IR_out1,PC,PC_out1,bubble1);
    ID ID1(IR_out1,clk,CLR,SYSCALL,UnsignedExt_Imm,RegDst,JMP,JR,JAL,RegWrite_out4,LOWrite_out4,
        HIWrite_out4,(JAL_out4?PC_out4:R1_out4),R2_out4,WbRegNum_out4,Branch,RD1,RD2,WbRegNum,Extended_Imm,shamt,HI,LO,Jaddr);
    IDtoEX_reg IDtoEX_reg1(clk,EN2b,CLR,IR_out1,IR_out2,PC_out1,PC_out2, bb_data|Branch, RD1,RD1_out2,RD2,RD2_out2,WbRegNum,WbRegNum_out2,Extended_Imm,Extended_Imm_out2,shamt,shamt_out2,HI,HI_out2,LO,LO_out2);
    IDtoEX_signal IDtoEX_signlal1(clk,EN2a,CLR, bb_data | Branch,RegWrite,RegWrite_out2,LOWrite,LOWrite_out2,HIWrite,HIWrite_out2,MemtoReg,MemtoReg_out2,JAL,JAL_out2,SYSCALL,SYSCALL_out2,MemWrite,MemWrite_out2,UnsignedExt_Mem,UnsignedExt_Mem_out2,Byte,Byte_out2,Half,Half_out2,ALUOP,ALUOP_out2,ALUSRC,ALUSRC_out2,B,B_out2,EQ,EQ_out2,Less,Less_out2,Reverse,Reverse_out2,BGEZ,BGEZ_out2,LUI,LUI_out2,Regtoshamt,Regtoshamt_out2,LOAlusrc,LOAlusrc_out2,HIAlusrc,HIAlusrc_out2);
    EX EX1(ALUOP_out2,clk,ALUSRC_out2,PC_out2,LUI_out2,Regtoshamt_out2,RD1_out2,RD2_out2,Extended_Imm_out2,shamt_out2,HIAlusrc_out2,LOAlusrc_out2,HI_out2,LO_out2,B_out2,EQ_out2,Less_out2,Reverse_out2,BGEZ_out2,WbRegNum_out2[0],R1,R2,OF,UOF,Equal,Branch,PC_branch);
    EXtoMEM_reg EXtoMEM_reg1(clk,EN3b,CLR,IR_out2,IR_out3,PC_out2,PC_out3,1'b0,R1,R1_out3,R2,R2_out3,RD1_out2,RD1_out3,RD2_out2,RD2_out3,WbRegNum_out2,WbRegNum_out3);
    ExtoMEM_signal ExtoMEM_signal1(clk,EN3a,CLR,1'b0,RegWrite_out2,RegWrite_out3,LOWrite_out2,LOWrite_out3,HIWrite_out2,HIWrite_out3,MemtoReg_out2,MemtoReg_out3,JAL_out2,JAL_out3,SYSCALL_out2,SYSCALL_out3,MemWrite_out2,MemWrite_out3,UnsignedExt_Mem_out2,UnsignedExt_Mem_out3,Byte_out2,Byte_out3,Half_out2,Half_out3);
    MEM MEM1(R1_out3,RD2_out3,clk,MemWrite_out3,MemtoReg_out3,UnsignedExt_Mem_out3,Byte_out3,Half_out3,CLR,R1_in4 );
    MEMtoWB_reg MEMtoWB_reg1(clk,EN4b,CLR,IR_out3,IR_out4,PC_out3,PC_out4,1'b0,R1_in4,R1_out4,R2_out3,R2_out4,RD1_out3,RD1_out4,RD2_out3,RD2_out4,WbRegNum_out3,WbRegNum_out4);
    MEMtoWB_signal MEMtoWB_signal1(clk,EN4a,CLR,1'b0,RegWrite_out3,RegWrite_out4,LOWrite_out3,LOWrite_out4,HIWrite_out3,HIWrite_out4,JAL_out3,JAL_out4,SYSCALL_out3,SYSCALL_out4);
    control_unit control_unit1(IR_out1,SYSCALL,RegDst,ALUOP,
        ALUSRC,LUI,Regtoshamt,LOAlusrc,HIAlusrc,MemWrite,
        Byte,Half,RegWrite,LOWrite,HIWrite,MemtoReg,UnsignedExt_Imm,
        UnsignedExt_Mem,B,EQ,Less,Reverse,BGEZ,JR,JMP,JAL, R1Used, R2Used, HiUsed, LoUsed);
    SYSCALL_ctrl SysC1(clk,CLR,SYSCALL_out4,GO,RD1_out4,RD2_out4,display,halt);
    DataConflict_ctrl DatC1(R1Used, R2Used, HiUsed, LoUsed, ID1.R1Num, ID1.R2Num, RegWrite_out2, WbRegNum_out2, RegWrite_out3, WbRegNum_out3, HIWrite_out2, LOWrite_out2, HIWrite_out3, LOWrite_out3, bb_data);
endmodule // 


