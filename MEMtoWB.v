`timescale 1ns / 1ps
//流水信息传递
module MEMtoWB_reg(
    //通用
    input In, input clk,input EN, input CLR, output reg Out,
    input [31:0] IR_in, output reg [31:0] IR,
    input [31:0] PC_in, output reg [31:0] PC,
    //特化
    input [31:0] R1_in, output reg [31:0] R1,
    input [31:0] R2_in, output reg [31:0] R2,
    input [31:0] RD1_in, output reg [31:0] RD1,
    input [31:0] RD2_in, output reg [31:0] RD2,
    input [4:0] WbRegNum_in, output reg [4:0] WbRegNum        
);
    always @(posedge clk) begin
        if (CLR)begin
            {Out,IR,PC} <= 0;
            R1 <= 0;
            R2 <= 0;
            RD1 <= 0;
            RD2 <= 0;
            WbRegNum <= 0;
        end
        else if (EN) begin
            Out <= In;
            IR <= IR_in;
            PC <= PC_in;
            R1 <= R1_in;
            R2 <= R2_in;
            RD1 <= RD1_in;
            RD2 <= RD2_in;
            WbRegNum <= WbRegNum_in;
        end
    end
endmodule
//流水信号传递
module MEMtoWB_signal(
    //通用
    input In, input clk,input EN, input CLR, output reg Out,
    //特化
    //WB
    input RegWrite_in, output reg RegWrite,
    input LOWrite_in, output reg LOWrite,
    input HIWrite_in, output reg HIWrite,
    input JAL_in, output reg JAL,
    input SYSCALL_in, output reg SYSCALL
);
    always @(posedge clk) begin
        if (CLR)
            {Out,RegWrite,LOWrite,HIWrite,JAL} <= 0;
        else if (EN) begin
            Out <= In;
            RegWrite <= RegWrite_in;
            LOWrite <= LOWrite_in;
            HIWrite <= HIWrite_in;
            JAL <= JAL_in;
            SYSCALL <= SYSCALL_in;
        end
    end

endmodule