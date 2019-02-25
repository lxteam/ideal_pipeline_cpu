//`timescale 1ns / 1ps

//module MIPS_RAM(
//    input [31:0] addr,
//    input [31:0] data_in,
//    input MemWrite,
//    input clk,
//    input Byte,
//    input Half,
//    input CLR,
//    input UnsignedExt_Mem,

//    output reg[31:0] data_out
//);
//parameter WIDTH = 8;
//parameter ADDR_SIZE = 8;
//parameter DEPTH = 2**ADDR_SIZE;
//    reg [WIDTH-1:0] mem[DEPTH-1:0];
//    integer i2;
//    initial begin
//        for (i2 = 0; i2<DEPTH-1; i2 = i2+1)
//            mem[i2] = 0;
//    end
//    wire [ADDR_SIZE-1:0] tmp_addr = addr[ADDR_SIZE-1:0];
//    wire [ADDR_SIZE-1:0] real_addr = Byte ? tmp_addr : 
//        (Half ? {tmp_addr[ADDR_SIZE-1:1],1'b0} : {tmp_addr[ADDR_SIZE-1:2],2'b00});

//    //assign data_out = mem[real_addr];
////    wire [WIDTH-1:0] byte_content = mem[real_addr];
////    wire [2*WIDTH-1:0] half_content = {mem[real_addr+1],mem[real_addr]};
////    wire [
    
//    reg [ADDR_SIZE:0] i;
//    always @(posedge clk) begin
//        if (CLR) 
//            for (i=0; i < DEPTH; i = i+1)
//                mem[i] = 0;
//        else if (MemWrite) begin
//            case ({ Byte, Half})
//              // shouldn't extend_Unsign and extend_sign in a statement
//              2'b10: mem[real_addr] <= data_in[WIDTH-1:0];
//              2'b11: mem[real_addr] <= data_in[WIDTH-1:0];
//              2'b01: {mem[real_addr+1],mem[real_addr]} <= data_in[WIDTH*2-1:0];                
//              2'b00: {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]} <= data_in;
//            endcase
//        end
//    end
//    always @(*)begin
//        case ({Byte,Half})
//            2'b10: if (UnsignedExt_Mem) data_out <= mem[real_addr]; else data_out <= $signed(mem[real_addr]); 
//            2'b11: if (UnsignedExt_Mem) data_out <= mem[real_addr]; else data_out <= $signed(mem[real_addr]); 
//            2'b01: if (UnsignedExt_Mem) data_out <= {mem[real_addr+1],mem[real_addr]}; else data_out <= $signed({mem[real_addr+1],mem[real_addr]});
//            2'b00: data_out <= {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]};
        
//        endcase
//    end



//endmodule
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

    output reg[31:0] data_out,
    output reg [256*8-1:0] ram_content
);
parameter WIDTH = 8;
parameter ADDR_SIZE = 8;
parameter DEPTH = 2**ADDR_SIZE;
    reg [WIDTH-1:0] mem[DEPTH-1:0];
    integer i2;
    initial begin
        for (i2 = 0; i2<DEPTH-1; i2 = i2+1)
            mem[i2] = 0;
    end
    always @(*) begin
        for (i2 = 0; i2<DEPTH-1; i2 = i2+1)
            ram_content[i2*8+7 -: 8] = mem[i2];
    end
    wire [ADDR_SIZE-1:0] tmp_addr = addr[ADDR_SIZE-1:0];
    wire [ADDR_SIZE-1:0] real_addr = Byte ? tmp_addr : 
        (Half ? {tmp_addr[ADDR_SIZE-1:1],1'b0} : {tmp_addr[ADDR_SIZE-1:2],2'b00});

    //assign data_out = mem[real_addr];
    reg [ADDR_SIZE:0] i;
    always @(posedge clk) begin
        if (CLR) 
            for (i=0; i < DEPTH; i = i+1)
                mem[i] = 0;
        else if (MemWrite) begin
            case ({Byte,Half})
              //store
              2'b01: {mem[real_addr+1],mem[real_addr]} <= data_in[WIDTH*2-1:0];
              2'b00: {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]} <= data_in;
              default:  mem[real_addr] = data_in[WIDTH-1:0];
            endcase
        end
    end
    always @(*) begin
        case ({Byte, Half})
            2'b00: data_out <= {mem[real_addr+3],mem[real_addr+2],mem[real_addr+1],mem[real_addr]};
            2'b01: begin if (UnsignedExt_Mem) data_out <= {mem[real_addr+1],mem[real_addr]}; else data_out <= $signed({mem[real_addr+1],mem[real_addr]}); end
            default: begin if (UnsignedExt_Mem) data_out <= mem[real_addr]; else data_out <= $signed(mem[real_addr]); end
        endcase
    
    end



endmodule