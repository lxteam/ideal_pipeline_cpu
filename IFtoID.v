//流水信息传递
module IFtoID(
    //通用
    input clk, input CLR, output reg Out,
    input [31:0] IR_in, output reg [31:0] IR,
    input [31:0] PC_in, output reg [31:0] PC
    //特化
);
    always @(posedge clk) begin
        if (CLR)
            {Out,IR,PC} <= 0;
        else begin
            Out <= 1;
            IR <= IR_in;
            PC <= PC_in;
        end
    end

endmodule