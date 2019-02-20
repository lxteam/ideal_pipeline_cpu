module FIVE_STAGE1(
    input clk,
    input CLR
);
    wire[31:0] jaddr,baddr;
    wire[3:0] ALUOP,ALUOP_out2;
    wire[4:0] WbRegNum,WbRegNum_out2,WbRegNum_out3,WbRegNum_out4;
    wire[4:0] shamt,shamt_out2;
    wire[31:0] IR,PC,IR_out1,IR_out2,IR_out3,IR_out4,PC_out1,PC_out2,PC_out3,PC_out4;
    wire[31:0] R1,R2,R1_out3,R1_out4,R2_out3,R2_out4,R1_in4;
    wire[31:0] Extended_Imm,Extended_Imm_out2,HI,LO,HI_out2,LO_out2;
    wire[31:0] RD1,RD1_out2,RD2,RD2_out2,RD2_out3;


    IF IF1(jaddr,baddr,JAL,J,JR,Branch,clk,CLR,IR,PC);
    IFtoID IFtoID1(clk,CLR,Out1,IR,IR_out1,PC,PC_out1);
    ID ID1(IR_out1,clk,SYSCALL,UnsignedExt_Imm,RegDst_out4,JMP,JR,JAL,RegWrite_out4,LOWrite_out4,
        HIWrite_out4,R1_out4,R2_out4,WbRegNum_out4,RD1,RD2,WbRegNum,Extended_Imm,shamt,HI,LO,jaddr);
    IDtoEX_reg IDtoEX_reg1(Out1,clk,CLR,Out2b,IR_out1,IR_out2,PC_out1,PC_out2,RD1,RD1_out2,RD2,RD2_out2,WbRegNum,WbRegNum_out2,Extended_Imm,Extended_Imm_out2,shamt,shamt_out2,HI,HI_out2,LO,LO_out2);
    IDtoEX_signal IDtoEX_signlal1(Out1,clk,CLR,Out2a,RegWrite,RegWrite_out2,LOWrite,LOWrite_out2,HIWrite,HIWrite_out2,MemtoReg,MemtoReg_out2,MemWrite,MemWrite_out2,UnsignedExt_Mem,UnsignedExt_Mem_out2,Byte,Byte_out2,Half,Half_out2,ALUOP,ALUOP_out2,ALUSRC,ALUSRC_out2,B,B_out2,EQ,EQ_out2,Less,Less_out2,Reverse,Reverse_out2,BGEZ,BGEZ_out2,LUI,LUI_out2,Regtoshamt,Regtoshamt_out2,LOAlusrc,LOAlusrc_out2,HIAlusrc,HIAlusrc_out2);
    EX EX1(ALUOP_out2,clk,ALUSRC_out2,PC_out2,LUI_out2,Regtoshamt_out2,RD1_out2,RD2_out2,Extended_Imm_out2,shamt_out2,HIAlusrc_out2,LOAlusrc_out2,HI_out2,LO_out2,R1,R2,OF,UOF,Equal);
    EXtoMEM_reg EXtoMEM_reg1(Out2b,clk,CLR,Out3b,IR_out2,IR_out3,PC_out2,PC_out3,R1,R1_out3,R2,R2_out3,RD2_out2,RD2_out3,WbRegNum_out2,WbRegNum_out3);
    ExtoMEM_signal ExtoMEM_signal1(Out2a,clk,CLR,Out3a,RegWrite_out2,RegWrite_out3,LOWrite_out2,LOWrite_out3,HIWrite_out2,HIWrite_out3,MemtoReg_out2,MemtoReg_out3,MemWrite_out,MemWrite_out3,UnsignedExt_Mem_out2,UnsignedExt_Mem_out3,Byte_out2,Byte_out3,Half_out2,Half_out3);
    MEM MEM1(R1_out3,RD2_out3,clk,MemWrite_out3,MemtoReg_out3,UnsignedExt_Mem_out3,Byte_out3,Half_out3,CLR,R1_in4 );
    MEMtoWB_reg MEMtoWB_reg1(Out3b,clk,CLR,Out4b,IR_out3,IR_out4,PC_out3,PC_out4,R1_in4,R1_out4,R2_out3,R2_out4,WbRegNum_out3,WbRegNum_out4);
    MEMtoWB_signal MEMtoWB_signal1(Out3a,clk,CLR,Out4a,RegWrite_out3,RegWrite_out4,LOWrite_out3,LOWrite_out4,HIWrite_out3,HIWrite_out4);
    control_unit control_unit1(IR_out1,SYSCALL,RegDst,ALUOP,
        ALUSRC,LUI,Regtoshamt,LOAlusrc,HIAlusrc,MemWrite,
        Byte,Half,RegWrite,LOWrite,HIWrite,MemtoReg,UnsignedExt_Imm,
        UnsignedExt_Mem,B,EQ,Less,Reverse,BGEZ,JR,JMP,JAL);




endmodule // 