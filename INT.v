`timescale 1ns / 1ps

`define IR1 3'b001
`define IR2 3'b010
`define IR3 3'b011
`define IR1_ADDR 32'h00000009
`define IR2_ADDR 32'h000000c8
`define IR3_ADDR 32'h0000016c

// Interupt Arbitration logic
module INT_ARB(
    input clk,
    input CLR,
    input ir1,
    input ir2,
    input ir3,
    input eret,
    output reg ie,
    output reg Int,
    output reg [31:0] Iaddr
);
    // IR
    reg [2:0] cur_ir;
    reg ir1_asyn, ir2_asyn, ir3_asyn;//等待信号
    reg ir1_syn, ir2_syn, ir3_syn;//正在执行信号

    // Synchronize ir_syn with clk.
    // irasyn set 1 asyn, reset 0 by ir_syn.
    always@ (posedge ir1, posedge ir1_syn, posedge CLR) begin
//        ir1_asyn <= CLR ? 1'b0 : (ir1_syn ? 1'b0 : (ir1 ? 1'b1 : ir1_asyn));
        if (CLR | ir1_syn)
            ir1_asyn <= 0;
        else if (ir1)
            ir1_asyn <= 1;
    end
    always@ (posedge ir2, posedge ir2_syn, posedge CLR) begin
        ir2_asyn <= CLR ? 1'b0 : (ir2_syn ? 1'b0 : (ir2 ? 1'b1 : ir2_asyn));
    end
    always@ (posedge ir3, posedge ir3_syn, posedge CLR) begin
        ir3_asyn <= CLR ? 1'b0 : (ir3_syn ? 1'b0 : (ir3 ? 1'b1 : ir3_asyn));
    end

    wire ir1_finish, ir2_finish, ir3_finish;
    assign ir1_finish = eret & (cur_ir == `IR1);
    assign ir2_finish = eret & (cur_ir == `IR2);
    assign ir3_finish = eret & (cur_ir == `IR3);

    always@ (posedge clk) begin
<<<<<<< HEAD
        if(CLR) begin
            {ir1_syn, ir2_syn, ir3_syn, cur_ir, Int, Iaddr} <= 0; 
            ie <= 1; 
=======
        if(clr) begin
            ir1_syn <= 1'b0;
            ir2_syn <= 1'b0;
            ir3_syn <= 1'b0;
            ie <= 1'b1;
            cur_ir <= 3'b0;
>>>>>>> 5ff410ad9382c5b1e2292e4bb63a5c084757b0de
        end
        else begin
            ir1_syn <= ir1_finish ? 1'b0 : (ir1_asyn ? 1'b1 : ir1_syn);
            ir2_syn <= ir2_finish ? 1'b0 : (ir2_asyn ? 1'b1 : ir2_syn);
            ir3_syn <= ir3_finish ? 1'b0 : (ir3_asyn ? 1'b1 : ir3_syn);
            if(eret)
                ie <= 1'b1;
            else if(ie)begin
                if(ir1_syn)begin
                    ie <= 1'b0; 
<<<<<<< HEAD
                    cur_ir <= `IR1;
                    Iaddr <= `IR1_ADDR;
                    Int <= 1;
                end
                else if(ir2_syn)begin
                    ie <= 1'b0; 
                    cur_ir <= `IR2;
                    Iaddr <= `IR2_ADDR;
                    Int <= 1;
                end
                else if(ir3_syn)begin
                    ie <= 1'b0;
                    cur_ir <= `IR3;
                    Iaddr <= `IR3_ADDR;
                    Int <= 1;
=======
                    cur_ir <= IR1;
                end
                else if(ir2_syn)begin
                    ie <= 1'b0; 
                    cur_ir <= IR2;
                end
                else if(ir3_syn)begin
                    ie <= 1'b0;
                    cur_ir <= IR3;
>>>>>>> 5ff410ad9382c5b1e2292e4bb63a5c084757b0de
                end
            end
            else if (Int)
                Int <= 0;
        end
    end

endmodule

module EPC_gen(
    input clk,
    input CLR,
    input [31:0] PC,
    input [31:0] IR,
    input [31:0] Baddr,
    input J,
    input B,

    output reg [31:0] EPC_out
);
    wire [31:0] simple_next = J ? $unsigned(IR[25:0]) : (B ? Baddr : PC);
    always @(posedge clk)begin
        if (CLR)
            EPC_out <= 0;
        else if (IR != 32'h0)
            EPC_out <= simple_next;
    end

endmodule

module INTM(
    input clk,
    input CLR,
    input ir1,
    input ir2,
    input ir3,
    input eret, 
    input[31:0] PC, // pc+1
    input [31:0] IR,
    input [31:0] Baddr,
    input J,
    input B,

    output Int,
    output [31:0] Iaddr,
    output reg[31:0] EPC
);
    wire ie;
    wire [31:0] EPC_out;

    EPC_gen EPC_gen1(clk, CLR, PC, IR, Baddr, J, B, EPC_out);
    INT_ARB INT_ARB1(clk, CLR, ir1, ir2, ir3, eret, ie, Int, Iaddr);

    always@(posedge clk) begin
        if(CLR) begin
            EPC <= 0;
        end
        else begin
            if(Int) begin
                EPC <= EPC_out;
            end
        end
    end
endmodule
