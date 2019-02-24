`timescale 1ns / 1ps

`define IR1 3'b001;
`define IR2 3'b010;
`define IR3 3'b011;
`define IR1_ADDR 32'h00003024;
`define IR2_ADDR 32'h000030c8;
`define IR3_ADDR 32'h0000316c;

// Interupt Arbitration logic
module INT_ARB(
    input clk,
    input clr,
    input ir1,
    input ir2,
    input ir3,
    input eret,
    output reg ie,
    output reg[3:0] cur_ir
);
    // IR
    reg ir1_asyn, ir2_asyn, ir3_asyn;
    reg ir1_syn, ir2_syn, ir3_syn;

    // Synchronize ir_syn with clk.
    // irasyn set 1 asyn, reset 0 by ir_syn.
    always@ (posedge ir1, posedge ir1_syn) begin
        ir1_asyn <= clr ? 1'b0 : (ir1_syn ? (1'b0 : (ir1 ? (1'b1 : ir1_asyn))));
    end
    always@ (posedge ir2, posedge ir2_status) begin
        ir2_asyn <= clr ? 1'b0 : (ir2_syn ? (1'b0 : (ir2 ? (1'b1 : ir2_asyn))));
    end
    always@ (posedge ir3, posedge ir3_status) begin
        ir3_asyn <= clr ? 1'b0 : (ir3_syn ? (1'b0 : (ir3 ? (1'b1 : ir3_asyn))));
    end

    wire ir1_finish, ir2_finish, ir3_finish;
    assign ir1_finish = eret & (cur_ir == IR1);
    assign ir2_finish = eret & (cur_ir == IR2);
    assign ir3_finish = eret & (cur_ir == IR3);

    always@ (posedge clk) begin
        if(clr) begin
            ir1_syn <= 1'b0;
            ir2_syn <= 1'b0;
            ir3_syn <= 1'b0;
            ie <= 1'b1;
        end
        else begin
            ir1_syn <= ir1_finish ? 1'b0 ? (ir1_asyn ? 1'b1 : ir1_syn);
            ir2_syn <= ir2_finish ? 1'b0 ? (ir2_asyn ? 1'b1 : ir2_syn);
            ir3_syn <= ir3_finish ? 1'b0 ? (ir3_asyn ? 1'b1 : ir3_syn);
            if(eret)
                ie <= 1'b1;
            else if(ie)begin
                if(ir1_syn)begin
                ie <= 1'b0; 
                cur_ir <= IR1;
                end
                else if(ir2_syn)begin
                ie <= 1'b0; 
                cur_ir <= IR2;
                end
                else if(ir3_syn)begin
                ie <= 1'b0; 
                cur_ir <= IR3;
                end
            end
        end
    end

endmodule

module PCNEXT(
    input clk,
    input clr,
    input[31:0] if_pcn, // pc+1
    input bubble1,
    input bubble2,
    input j_id,
    input jr_id,
    input jal_id,
    input j_addr,
    input branchen_ex,
    input b_addr,
    input eret,
    input[31:0] eret_addr,
    output[31:0] ex_pcnext
);
    reg [31:0] iftoid_pcnext, idtoex_pcnext;
    reg iftoid_bubble, idtoex_bubble;
    always@(posedge clk) begin
        if(clr) begin
            iftoid_bubble <= 32'b0;
            idtoex_pcnext <= 32'b0;
            iftoid_bubble <= 1'b0;
            idtoex_bubble <= 1'b0;
        end
        else begin
            if(bubble1) iftoid_bubble <= 1'b1;
            else begin
                iftoid_bubble <= 1'b0;
                iftoid_pcnext <= if_pcn;
            end

            // Now eret in ID.
            // Corner case : int comes soon after eret from last int.
            // So we need to maintain the nextpc for eret.
            if(eret) idtoex_pcnext <= eret_addr;
            else if(bubble2) idtoex_bubble <= 1'b1;
            else begin
                idtoex_bubble <= iftoid_bubble;
                if(j_id | jr_id | jal_id)
                    idtoex_pcnext <= j_addr;
                else
                    idtoex_pcnext <= iftoid_pcnext;
            end
        end
    end
    assign ex_pcnext = (!idtoex_bubble) ? (branchen_ex ? b_addr : idtoex_pcnext) : ex_pcnext;

endmodule


module INTM(
    input clk,
    input clr,
    input ir1,
    input ir2,
    input ir3,
    input eret, 
    input[31:0] if_pcn, // pc+1
    input bubble1,
    input bubble2,
    input j_id,
    input jr_id,
    input jal_id,
    input j_addr,
    input branchen_ex,
    input b_addr,
    output reg intaddr_to_pc,
    output reg[31:0] int_addr,
    output reg eretaddr_to_pc,
    output reg[31:0] eret_addr,
    // bubble# contains eret_bubble#
    output reg eret_bubble1,
    output reg eret_bubble2
);
    reg[31:0] pc_next;
    wire[31:0] ex_pcnext;
    wire ex_bubble;
    wire ie;
    wire[3:0] cur_ir;
    PCNEXT PCNEXT1(clk, clr, if_pcn, bubble1, bubble2, j_id, jr_id, jal_id, j_addr, branchen_ex, b_addr, eret, eret_addr, ex_pcnext);
    INT_ARB INT_ARB1(clk, clr, ir1, ir2, ir3, eret, ie, cur_ir);
    // When ie negedge comes, sync & wait for one cycle.
    reg int_come;
    // When eret posedge comes, sync & wait for one cycle.
    reg eret_come;
    always@(negedge ie, posedge intaddr_to_pc) begin
        int_come <= clr ? (1'b0 : (intaddr_to_pc ? 1'b0 : ((!ie) ? 1'b1 : 1'b0)));
    end
    always@(posedge eret, posedge eretaddr_to_pc) begin
        eret_come <= clr ? (1'b0 : eretaddr_to_pc ? (1'b0) : (eret ? 1'b1 : 1'b0));
    end
    always@(posedge clk) begin
        if(clr) begin
            intaddr_to_pc <= 1'b0;
            eretaddr_to_pc <= 1'b0;
            eret_bubble1 <= 1'b0;
            eret_bubble2 <= 1'b0;
            int_addr <= 32'b0;
            eret_addr <= 32'b0;
        end
        else begin
            if(int_come) begin
                // Last instruction in MEM, first instruction for int in IF.
                intaddr_to_pc <= 1'b1;
                eret_addr <= ex_pcnext; // save ret addr
                case(cur_ir)
                    `IR1: int_addr <= `IR1_ADDR;
                    `IR2: int_addr <= `IR2_ADDR;
                    `IR3: int_addr <= `IR3_ADDR;
                    default: int_addr <= 32'b0;
                endcase
            end
            else if(intaddr_to_pc) intaddr_to_pc <= 1'b0; // so intaddr_to_pc lasts for one cycle

            if(eret_come)begin 
                // Now eret in EX
                // Insert bubble into IF/ID, ID/EX
                eretaddr_to_pc <= 1'b1;
                eret_bubble1 <= 1'b1;
                eret_bubble2 <= 1'b1;
            end
            else if(eretaddr_to_pc) begin
                // Now eret in MEM, eret_addr in IF
                eretaddr_to_pc <= 1'b0;
                eret_bubble1 <= 1'b0;
                eret_bubble2 <= 1'b0;
            end
        end
    end
endmodule
