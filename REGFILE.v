`timescale 1ns / 1ps


module REGFILE(
	input [31:0] WbData, 
	input clk, 
	input RegWrite, 
	input [4:0]WbRegNum, 
	input [4:0]R1Num, 
	input [4:0]R2Num,

	output [31:0]A, 
	output [31:0]B,
    output reg [32*32-1:0] reg_content
);
	reg [31:0] mem[31:0];
	integer i,j;
	initial begin
		for(i=0;i<32;i=i+1)
			mem[i] <= 0;
	end
	always @(*) begin
       for (j = 0; j<32; j=j+1)
           reg_content[j*32+31-:32] <= mem[j];    
    end
    
	
	always @ (negedge clk) begin
		if (RegWrite && WbRegNum!=0)
			mem[WbRegNum] <= WbData;
	end
	assign A=mem[R1Num];
    assign B=mem[R2Num];
endmodule

