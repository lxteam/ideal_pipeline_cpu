`timescale 1ns / 1ps
module MIPS_RAM(
    input [31:0] addr,
    input [31:0] data_in,
    input MemWrite,
    input clk,
    input Byte,
    input Half,
    input CLR,
    input UnsignedExt_Mem,

    output reg[31:0] data_out
);
    parameter width = 5;

    reg [7:0] mem[2**width-1:0];
    wire [width-1:0] tmp_addr = addr[width-1:0];
    wire [width-1:0] real_addr = Byte ? tmp_addr : 
        (Half ? {tmp_addr[width-1:1],1'b0} : {tmp_addr[width-1:2],2'b00});

    //assign data_out = mem[real_addr];
    reg [width:0] i;
    always @(posedge clk) begin
        if (CLR) 
            for (i=0; i < 2**width-1; i = i+1)
                mem[i] = 0;
        else begin
            casez ({MemWrite, Byte, Half})
              //load
              // shouldn't extend_Unsign and extend_sign in a statement
              3'b01?: begin if (UnsignedExt_Mem) data_out <= mem[real_addr]; else data_out <= $signed(mem[real_addr]); end
              3'b001: begin if (UnsignedExt_Mem) data_out <= {mem[real_addr+1],mem[real_addr]}; else data_out <= $signed({mem[real_addr+1],mem[real_addr]}); end
              3'b000: data_out <= {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]};
              //store
              3'b11?:  mem[real_addr] = data_in[width-1:0];
              3'b101: {mem[real_addr+1],mem[real_addr]} <= data_in[2*width-1:0];
              3'b100: {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]} <= data_in;
            endcase
        end
    end



endmodule