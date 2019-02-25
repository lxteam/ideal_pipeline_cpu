`timescale 1ns / 1ps

`define IR1 3'b001
`define IR2 3'b010
`define IR3 3'b011
`define IR1_ADDR 32'h00000009
`define IR2_ADDR 32'h0000003c
`define IR3_ADDR 32'h0000006f


//todo: int with syscall, int with priority

// Interupt Arbitration logic
module INT_ARB(
    input clk,
    input ENCP0,
    input CLR,
    input ir1,
    input ir2,
    input ir3,
    input eret,
    input ieWrite,
    input ie_value,

    output reg Int,
    output [31:0] Iaddr,
    output ir1wait,output ir2wait, output ir3wait
    
);
    reg ir1_asyn, ir2_asyn, ir3_asyn;

    // IR
    reg ie_n;
    wire [2:0] cur_ir;
//    reg ir1_asyn, ir2_asyn, ir3_asyn;//等待信号
    reg ir1_syn, ir2_syn, ir3_syn;//正在执行信号
    assign ir1wait = ir1_asyn;
    assign ir2wait = (ir1_syn & ir2_syn) | ir2_asyn;
    assign ir3wait = (ir1_syn & ir3_syn) | (ir2_syn & ir3_syn) | ir3_asyn;

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

//    wire ir1_finish, ir2_finish, ir3_finish;
//    assign ir1_finish = eret & (cur_ir == `IR1);
//    assign ir2_finish = eret & (cur_ir == `IR2);
//    assign ir3_finish = eret & (cur_ir == `IR3);

    always@ (posedge clk) begin
        if(CLR) begin
            {ir1_syn, ir2_syn, ir3_syn, Int} <= 0; 
            ie_n <= 0; 
        end
        else if (ENCP0) begin
//            ir1_syn <= ir1_finish ? 1'b0 : (ir1_asyn ? 1'b1 : ir1_syn);
//            ir2_syn <= ir2_finish ? 1'b0 : (ir2_asyn ? 1'b1 : ir2_syn);
//            ir3_syn <= ir3_finish ? 1'b0 : (ir3_asyn ? 1'b1 : ir3_syn);
            if(eret) begin
                ie_n <= 1'b0;
                case(cur_ir)
                `IR1 : ir1_syn <= 0;
                `IR2 : ir2_syn <= 0;
                `IR3 : ir3_syn <= 0;
                endcase 
            end
            else if (ieWrite)
                ie_n <= ~ie_value;
            else if(!ie_n)begin
                if(ir1_asyn & !ir1_syn)begin
                    ie_n <= 1'b1; 
                    Int <= 1;
                    ir1_syn <= 1;
                end 
                else if(ir2_asyn & !ir1_syn & !ir2_syn)begin
                    ie_n <= 1'b1; 
                    Int <= 1;
                    ir2_syn <= 1;
                end
                else if(ir3_asyn & !ir1_syn & !ir2_syn & !ir3_syn)begin
                    ie_n <= 1'b1;
                    Int <= 1;
                    ir3_syn <= 1;
                end
            end
            else if (Int)
                Int <= 0;
        end
    end
    assign cur_ir = ir1_syn ? `IR1 : ir2_syn ? `IR2 : ir3_syn ? `IR3 : 0;
    assign Iaddr =  ir1_syn ? `IR1_ADDR : ir2_syn ? `IR2_ADDR : ir3_syn ? `IR3_ADDR : 0;

endmodule

module CP0_(
    input clk,
    input ENCP0,
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
    input CP0Write,
    input [4:0] RegNum,
    input [31:0] data_in,
    input CP0_EX,
    input [31:0] data_ex,
    input CP0_MEM,
    input [31:0] data_mem,
    input CP0_WB,
    input [31:0] PC_out1,
    input [31:0] PC_out2,
    input [31:0] PC_out3,
    input [31:0] IR_out2,
    input [31:0] IR_out3,

    output Int,
    output [31:0] Iaddr,
    output reg[31:0] EPC,
    output [31:0] data_out,
    output ir1_asyn, output ir2_asyn,output ir3_asyn
);
    wire [31:0] EPC_out;
    assign data_out = CP0_EX? data_ex : CP0_MEM ? data_mem : CP0_WB ? data_in : EPC;

    wire ieWrite = CP0Write & (RegNum==13);
    INT_ARB INT_ARB1(clk, ENCP0, CLR, ir1, ir2, ir3, eret, ieWrite, data_in[0], Int, Iaddr,ir1_asyn,ir2_asyn,ir3_asyn);

    always@(posedge clk) begin
        if(CLR) begin
            EPC <= 0;
        end
        else if (ENCP0) begin
            if (CP0Write && RegNum == 14)
                EPC <= data_in;
            else if(Int)begin
                if (IR_out3 != 0)
                    EPC <= PC_out3-1;
                else if (IR_out2 != 0)
                    EPC <= PC_out2-1;
                else 
                    EPC <= PC_out1-1;
            
            end
        end
    end
endmodule
