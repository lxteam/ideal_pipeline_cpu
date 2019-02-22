`timescale 1ns/10ps

module RAM_test();
    reg [31:0] addr;
    reg [31:0] data_in;
    reg MemWrite, clk, Byte, Half, CLR, UnsignedExt_Mem;
    wire [31:0]data_out;
    MIPS_RAM ram1(addr,data_in,MemWrite,clk,Byte,Half,CLR,UnsignedExt_Mem,data_out);
    wire [19:0] real_addr = ram1.real_addr;
    wire [63:0] mem_content = {ram1.mem[7],ram1.mem[6],ram1.mem[5],ram1.mem[4],ram1.mem[3],ram1.mem[2],ram1.mem[1],ram1.mem[0]};
    initial begin
        {addr,data_in,MemWrite, clk, Byte, Half, CLR, UnsignedExt_Mem} = 0;
        #20 CLR = 1;
        #20 CLR = 0;
        //sw 0
        #20 addr = 0; data_in = 32'h12345678; {Byte,Half}=0; MemWrite = 1; 
        //sh 2
        #20 addr = 2; data_in = 16'h5678; {Byte,Half}=2'b01;
        //lw 0
        #20 addr = 0; MemWrite = 0; {Byte,Half}=0;
        //sb 4
        #20 addr = 4; data_in = 8'h9a; {Byte,Half}=2'b10; MemWrite=1;
        //sh 6
        #20 addr = 6; data_in = 16'h00ef; {Byte,Half}=2'b01;
        //lw 4
        #20 addr = 4; MemWrite = 0; {Byte,Half}=0;
        //lb 7
        #20 addr = 7; {Byte,Half}=2'b10; 
        //lhu 6
        #20 addr = 6; {Byte,Half}=2'b01; UnsignedExt_Mem =1;
        //sh 4
        #20 addr = 4; data_in = 16'h8000 ;{Byte,Half}=2'b01; MemWrite = 1;
        //lhu 4
        #20 MemWrite = 0;
        //lh 4
        #20 UnsignedExt_Mem = 0;
        
    end
    always begin
        #3 clk = ~clk;
    end
    always @(data_out)
        $monitor("load, data_out = %h", data_out);
        

endmodule // 

/*
module MIPS_RAM(
    input [31:0] addr,
    input [31:0] data_in,
    input MemWrite,
    input clk,
    input Byte,
    input Half,
    input CLR,
    input UnsignedExt_Mem,

    output [31:0] data_out
);
*/