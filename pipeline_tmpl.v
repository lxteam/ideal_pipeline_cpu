module PIPE_LINE(
    //通用
    input In, input clk, input CLR, output reg Out
    //特化
);
    always @(posedge clk) begin
        if (CLR)
            {Out} <= 0;
        else begin
            Out <= In;
        end
    end

endmodule