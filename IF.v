module IF(
    input [31:0] jaddr,
    input [31:0] baddr,
    input JAL,input J, input JR, input Branch,
    input clk,
    input CLR,

    output [31:0] IR,
    output reg [31:0] PC
);
    parameter width = 5;

    reg [7:0] rom[2**width-1:0];
    assign IR = {rom[PC+3],rom[PC+2],rom[PC+1],rom[PC]};
    always @(posedge clk) begin
        if (CLR)
            PC <= 0;
        else
            PC <= PC+4;
    end


endmodule // 