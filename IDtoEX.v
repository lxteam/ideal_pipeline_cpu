//流水信息传递
module IDtoEX_reg(
    //通用
    input In, input clk, input CLR, output reg Out,
    input [31:0] IR_in, output reg [31:0] IR,
    input [31:0] PC_in, output reg [31:0] PC,
    //特化
    input [31:0] RD1_in, output reg [31:0] RD1,
    input [31:0] RD2_in, output reg [31:0] RD2,
    input [4:0] WbRegNum_in, output reg [4:0] WbRegNum,
    input [31:0] Extended_Imm_in, output reg [31:0] Extended_Imm,
    input [4:0] shamt_in, output reg[4:0] shamt,
    input [31:0] HI_in, output reg [31:0] HI,
    input [31:0] LO_in, output reg [31:0] LO
);
    always @(posedge clk) begin
        if (CLR)
            {Out,IR,PC,RD1,RD2,WbRegNum,Extended_Imm,shamt,HI,LO} <= 0;
        else begin
            Out <= In;
            IR <= IR_in;
            PC <= PC_in;
            RD1 <= RD1_in;
            RD2 <= RD2_in;
            WbRegNum <= WbRegNum_in;
            Extended_Imm <= Extended_Imm;
            shamt <= shamt_in;
            HI <= HI_in;
            LO <= LO_in;
        end
    end

endmodule

//流水信号传递
module IDtoEX_signal(
    //通用
    input In, input clk, input CLR, output reg Out,
    //特化
    //WB
    input RegWrite_in, output reg RegWrite,
    input LOWrite_in, output reg LOWrite,
    input HIWrite_in, output reg HIWrite,
    input MemtoReg_in, output reg MemtoReg,
    //MEM
    input MemWrite_in, output reg MemWrite,
    input UnsignedExt_Mem_in, output reg UnsignedExt_Mem,
    input Byte_in, output reg Byte,
    input Half_in, output reg Half,
    //EX
    input ALU_OP_in, output reg ALU_OP,
    input ALU_SRC_in, output reg ALU_SRC,
    input B_in, output reg B,
    input EQ_in, output reg EQ,
    input Less_in, output reg Less,
    input Reverse_in, output reg Reverse,
    input BGEZ_in, output reg BGEZ,
    input LUI_in, output reg LUI,
    input Regtoshamt_in, output reg Regtoshamt,
    input LOAlusrc_in, output reg LOAlusrc,
    input HIAlusrc_in, output reg HIAlusrc    
);
    always @(posedge clk) begin
        if (CLR)
            {Out,RegWrite,LOWrite,HIWrite,MemtoReg,MemWrite,UnsignedExt_Mem,Byte,Half,
                ALU_OP,ALU_SRC,B,EQ,Less,Reverse,BGEZ,LUI,Regtoshamt,LOAlusrc,HIAlusrc} <= 0;
        else begin
            Out <= In;

            RegWrite <= RegWrite_in;
            LOWrite <= LOWrite_in;
            HIWrite <= HIWrite_in;
            MemtoReg <= MemtoReg_in;

            MemWrite <= MemWrite_in;
            UnsignedExt_Mem <= UnsignedExt_Mem_in;
            Byte <= Byte_in;
            Half <= Half_in;

            ALU_OP <= ALU_OP_in;
            ALU_SRC <= ALU_SRC_in;
            B <= B_in;
            EQ <= EQ_in;
            Less <= Less_in;
            Reverse <= Reverse_in;
            BGEZ <= BGEZ_in;
            LUI <= LUI_in;
            Regtoshamt <= Regtoshamt_in;
            LOAlusrc <= LOAlusrc_in;
            HIAlusrc <= HIAlusrc_in;
        end
    end

endmodule
