`timescale 1ns / 1ps
//流水信息传递
module MEMtoWB_reg(
    //通用
    input clk,input EN, input CLR, 
    input [31:0] IR_in, output reg [31:0] IR,
    input [31:0] PC_in, output reg [31:0] PC,
    input bb,
    //特化
    input [31:0] R1_in, output reg [31:0] R1,
    input [31:0] R2_in, output reg [31:0] R2,
    input [31:0] RD1_in, output reg [31:0] RD1,
    input [31:0] RD2_in, output reg [31:0] RD2,
    input [4:0] WbRegNum_in, output reg [4:0] WbRegNum,
    input [31:0] CP0data_in, output reg [31:0] CP0data,
    input [4:0] CP0Num_in, output reg[4:0] CP0Num
);
    always @(posedge clk) begin
        if (CLR | (bb&EN))begin
            {IR,PC,R1,R2,RD1,RD2,WbRegNum,CP0data,CP0Num} <= 0;
        end
        else if (EN) begin
            IR <= IR_in;
            PC <= PC_in;
            R1 <= R1_in;
            R2 <= R2_in;
            RD1 <= RD1_in;
            RD2 <= RD2_in;
            WbRegNum <= WbRegNum_in;
            CP0data <= CP0data_in;
            CP0Num <= CP0Num_in;
        end
    end
endmodule
//流水信号传递
module MEMtoWB_signal(
    //通用
    input clk,input EN, input CLR, 
    input bb,
    //特化
    //WB
    input RegWrite_in, output reg RegWrite,
    input LOWrite_in, output reg LOWrite,
    input HIWrite_in, output reg HIWrite,
    input JAL_in, output reg JAL,
    input SYSCALL_in, output reg SYSCALL,
    input CP0Write_in, output reg CP0Write,
    input CP0toReg_in, output reg CP0toReg
);
    always @(posedge clk) begin
        if (CLR | (bb&EN))
            {RegWrite,LOWrite,HIWrite,JAL} <= 0;
        else if (EN) begin
            RegWrite <= RegWrite_in;
            LOWrite <= LOWrite_in;
            HIWrite <= HIWrite_in;
            JAL <= JAL_in;
            SYSCALL <= SYSCALL_in;
            CP0Write <= CP0Write_in;
            CP0toReg <= CP0toReg_in;

        end
    end

endmodule