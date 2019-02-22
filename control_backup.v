`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/02/19 19:56:26
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control_unit(
        input wire[31:0] ir,
        output syscall,
        output regdst,
        output reg[3:0] aluop,
        output alusrc,
        output lui,
        output regtoshamt,
        output loalusrc,
        output hialusrc,
        output memwrite,
        output byte,
        output half,
        output regwrite,
        output lowrite,
        output hiwrite,
        output memtoreg,
        output unsignedext_imm,
        output unsignedext_mem,
        output b,
        output eq,
        output less,
        output reverse,
        output bgez,
        output jr,
        output jmp,
        output jal,
        // Data conflict.
        output r1_used,
        output r2_used,
        output hi_used,
        output lo_used
    );
     // Normal
        wire[5:0] opt;
        wire[4:0] rs;
        wire[4:0] rt;
        // R
        wire[4:0] rd;
        wire[4:0] shamt;
        wire[5:0] func;
        // I
        wire[15:0] immi;
        // J
        wire[25:0] immj;
        assign opt = ir[31:26];
        assign rs = ir[25:21];
        assign rt = ir[20:16];
        assign rd = ir[15:11];
        assign shamt = ir[10:6];
        assign func = ir[5:0];
        assign immi = ir[15:0];
        assign immj = ir[25:0];
        
        // instruction code
        parameter R_OPT =  6'b000000;
        parameter SP_OPT = 6'b000000;
        parameter SYSCALL_FUNC = 6'b001100;
        parameter ADD_FUNC = 6'b100000;
        parameter ADDU_FUNC = 6'b100001;
        parameter AND_FUNC = 6'b100100;
        parameter SLL_FUNC = 6'b000000;
        parameter SRA_FUNC = 6'b000011;
        parameter SRL_FUNC = 6'b000010;
        parameter SUB_FUNC = 6'b100010;
        parameter OR_FUNC = 6'b100101;
        parameter NOR_FUNC = 6'b100111;
        parameter SLLV_FUNC = 6'b000100;
        parameter SRLV_FUNC = 6'b000110;
        parameter SRAV_FUNC = 6'b000111;
        parameter SUBU_FUNC = 6'b100011;
        parameter XOR_FUNC = 6'b100110;
        parameter MULTU_FUNC = 6'b011001;
        parameter DIVU_FUNC = 6'b011011;
        parameter MFLO_FUNC = 6'b010010;
        parameter SLT_FUNC = 6'b101010;
        parameter SLTU_FUNC = 6'b101011;
        parameter MFHI_FUNC = 6'b010000;
        
        parameter JR_FUNC = 6'b001000;
        parameter ERET_FUNC = 6'b011000;
        
        // instruction type
        wire R = (opt == R_OPT);
        wire SP = (opt == SP_OPT);
        parameter ADDI_OPT = 6'b001000;
        parameter ADDIU_OPT = 6'b001001;
        parameter SLTI_OPT = 6'b001010;
        parameter SLTIU_OPT = 6'b001011;
        parameter ANDI_OPT = 6'b001100;
        parameter ORI_OPT = 6'b001101;
        parameter XORI_OPT = 6'b001110;
        parameter LUI_OPT = 6'b001111;
        parameter LB_OPT = 6'b100000;
        parameter LH_OPT = 6'b100001;
        parameter LW_OPT = 6'b100011;
        parameter LBU_OPT = 6'b100100;
        parameter LHU_OPT = 6'b100101;
        parameter SB_OPT = 6'b101000;
        parameter SH_OPT = 6'b101001;
        parameter SW_OPT = 6'b101011;

        parameter J_OPT = 6'b000010;
        parameter JAL_OPT = 6'b000011;
        parameter REGIMM_OPT = 6'b000001;
        parameter BEQ_OPT = 6'b000100;
        parameter BNE_OPT = 6'b000101;
        parameter BLEZ_OPT = 6'b000110;
        parameter BGTZ_OPT = 6'b000111;
        

        wire ADD = (SP & (func == ADD_FUNC));
        wire ADDU = (SP & (func == ADDU_FUNC));
        wire AND = (SP & (func == AND_FUNC));
        wire SLL = (SP & (rs == 6'b000000) & (func == SLL_FUNC));
        wire SRA = (SP & (rs == 6'b000000) & (func == SRA_FUNC));
        wire SRL = (SP & (rs == 6'b000000) & (func == SRL_FUNC));
        wire SUB = (SP & (shamt == 6'b000000) & (func == SUB_FUNC));
        wire OR = (SP & (shamt == 6'b000000) & (func == OR_FUNC));
        wire NOR = (SP & (shamt == 6'b000000) & (func == NOR_FUNC));
        wire SLLV = (SP & (shamt == 6'b000000) & (func == SLLV_FUNC));
        wire SRLV = (SP & (shamt == 6'b000000) & (func == SRLV_FUNC));
        wire SRAV = (SP & (shamt == 6'b000000) & (func == SRAV_FUNC));
        wire SUBU = (SP & (shamt == 6'b000000) & (func == SUBU_FUNC));
        wire XOR = (SP & (shamt == 6'b000000) & (func == XOR_FUNC));
        wire MULTU = (SP & (ir[15:6] == 6'b000000) & (func == MULTU_FUNC));
        wire DIVU = (SP & (ir[15:6] == 6'b000000) & (func == DIVU_FUNC));
        wire MFLO = (SP & (ir[25:16] == 6'b000000) & (shamt == 5'b00000) & (func == MFLO_FUNC));
        wire SLT = (SP & (shamt == 5'b00000) & (func == SLT_FUNC));
        wire SLTU = (SP & (shamt == 5'b00000) & (func == SLTU_FUNC));
        wire SYSCALL = (R & (func == SYSCALL_FUNC));
        wire ADDI = (opt == ADDI_OPT);
        wire ADDIU = (opt == ADDIU_OPT);
        wire SLTI = (opt == SLTI_OPT);
        wire SLTIU = (opt == SLTIU_OPT);
        wire ANDI = (opt == ANDI_OPT);
        wire ORI = (opt == ORI_OPT);
        wire XORI = (opt == XORI_OPT);
        wire LUI = ((opt == LUI_OPT) & (rs == 5'b00000));
        wire LB = (opt == LB_OPT);
        wire LH = (opt == LH_OPT);
        wire LW = (opt == LW_OPT);
        wire LBU = (opt == LBU_OPT);
        wire LHU = (opt == LHU_OPT);
        wire SB = (opt == SB_OPT);
        wire SH = (opt == SH_OPT);
        wire SW = (opt == SW_OPT);
        wire MFHI = ((ir[31:16] == {16{1'b0}}) & (shamt == 5'b00000) & (func == MFHI_FUNC));

        wire JR = ((opt == 6'b000000) & (ir[20:11] == 10'b0000000000) & (func == JR_FUNC));
        wire J = (opt == J_OPT);
        wire JAL = (opt == JAL_OPT);
        wire BLTZ = ((opt == REGIMM_OPT) & (rt == 5'b00000));
        wire BGEZ = ((opt == REGIMM_OPT) & (rt == 5'b00001));
        wire BEQ = (opt == BEQ_OPT);
        wire BNE = (opt == BNE_OPT);
        wire BLEZ = ((opt == BLEZ_OPT) & (rt == 5'b00000));
        wire BGTZ = ((opt == BGTZ_OPT) & (rt == 5'b00000));
        wire ERET = ((opt == 6'b010000) & ir[25] & (ir[24:6] == 19'b0) & (func == ERET_FUNC));


        //wire NOP = (ir == {32{1'b0}});
        // instruction
        /* TODO:
            MFC0
            MTC0
        */
        
        
        // output
        assign syscall = SYSCALL;
        assign regdst = (((ADD | (ADDU | AND)) | ((SLL | SRA) | (SRL | SUB))) | (((OR | NOR) | (SLLV | 
            SRLV)) | ((SRAV | SUBU) | (XOR | MULTU)))) | ((DIVU | MFLO) | (SLT | SLTU));
        assign alusrc = ((((ADDI | ADDIU) | (SLTI | SLTI)) | ((ANDI | ORI) | (XORI | LUI))) | (((LB | LH) | (LW | LBU)) | ((LHU | SB) | (SH | SW)))) | MFHI;
        assign lui = LUI;
        assign regtoshamt = SLLV | SRLV | SRAV;
        assign loalusrc = MFLO;
        assign hialusrc = MFHI;
        assign memwrite = SB | SH | SW;
        assign byte = LB | LBU | SB;
        assign half = LH | LHU | SH;
        assign regwrite = (JAL | regdst) | ((((ADDI | ADDIU) | (SLTI | SLTI)) | ((ANDI | ORI) | (XORI | LUI))) | ( ( (LB | LH) | (LW | LBU) ) | (LHU | MFHI))) ;
        assign lowrite = MULTU | DIVU;
        assign hiwrite = lowrite;
        assign memtoreg = LB | LH | LW | LBU | LHU;
        assign unsignedext_imm = ADDIU | ANDI | XORI | ORI;
        assign unsignedext_mem = LBU | LHU;
        assign b = (BLTZ | BGEZ) | (BEQ | BNE) | (BLEZ | BGTZ);
        assign eq = (BEQ | BNE) | (BLEZ | BGTZ);
        assign less = (BLTZ | BGEZ) | (BLEZ | BGTZ); 
        assign reverse = BNE | BGTZ ;
        assign bgez = BLTZ | BGEZ;
        assign jr = JR;
        assign jmp = J;
        assign jal = JAL;
        // Data confilict
        assign r1_used = ADD | ADDU | AND | SUB | OR | NOR | SLLV | SRLV | SRAV | 
            SUBU | XOR | MULTU | DIVU | SLT | SLTU | JR | SYSCALL | BLTZ | BGEZ | 
            BEQ | BNE | BLEZ | BGTZ | ADDI | ADDIU | SLTIU | ANDI | ORI | XORI | 
            LB | LH | LW | LBU | LHU | SB | SH | SW;
        assign r2_used = ADD | ADDU | AND | SLL | SRA | SUB | OR | NOR | SLLV | 
            SRLV | SRAV | SUBU | XOR | MULTU | DIVU | SLT | SLTU | SYSCALL | BEQ | 
            BNE | SB | SH | SW ;
        assign hi_used = MFHI;
        assign lo_used = MFLO; 

        `define IALU 40
        always@(*) begin
            case( {BGTZ, BLEZ, BGEZ, BLTZ, MFHI,
             SW, SH, SB, LHU, LBU,
             LW, LH, LB, LUI, XORI,
             ORI, ANDI, SLTIU, SLTI, ADDIU,
             ADDI, DIVU, MFLO, SLT, SLTU,
             MULTU, XOR, SUBU, SRAV, SRLV, 
             SLLV, NOR, OR, SUB, SRL, 
             SRA, SLL, AND, ADDU, ADD})
                `IALU'b0000000000000000000000000000000000000001: aluop <= 5;
                `IALU'b0000000000000000000000000000000000000010: aluop <= 5;
                `IALU'b0000000000000000000000000000000000000100: aluop <= 7;
                `IALU'b0000000000000000000000000000000000001000: aluop <= 0;
                `IALU'b0000000000000000000000000000000000010000: aluop <= 1;
                
                `IALU'b0000000000000000000000000000000000100000: aluop <= 2;
                `IALU'b0000000000000000000000000000000001000000: aluop <= 6;
                `IALU'b0000000000000000000000000000000010000000: aluop <= 8;
                `IALU'b0000000000000000000000000000000100000000: aluop <= 10;
                `IALU'b0000000000000000000000000000001000000000: aluop <= 0;
                
                `IALU'b0000000000000000000000000000010000000000: aluop <= 2;
                `IALU'b0000000000000000000000000000100000000000: aluop <= 1;
                `IALU'b0000000000000000000000000001000000000000: aluop <= 6;
                `IALU'b0000000000000000000000000010000000000000: aluop <= 9;
                `IALU'b0000000000000000000000000100000000000000: aluop <= 3;
                
                `IALU'b0000000000000000000000001000000000000000: aluop <= 11;
                `IALU'b0000000000000000000000010000000000000000: aluop <= 11;
                `IALU'b0000000000000000000000100000000000000000: aluop <= 5;
                `IALU'b0000000000000000000001000000000000000000: aluop <= 4;
                `IALU'b0000000000000000000010000000000000000000: aluop <= 5;
                
                `IALU'b0000000000000000000100000000000000000000: aluop <= 5;
                `IALU'b0000000000000000001000000000000000000000: aluop <= 11;
                `IALU'b0000000000000000010000000000000000000000: aluop <= 12;
                `IALU'b0000000000000000100000000000000000000000: aluop <= 7;
                `IALU'b0000000000000001000000000000000000000000: aluop <= 8;
                
                `IALU'b0000000000000010000000000000000000000000: aluop <= 9;
                `IALU'b0000000000000100000000000000000000000000: aluop <= 0;
                `IALU'b0000000000001000000000000000000000000000: aluop <= 5;
                `IALU'b0000000000010000000000000000000000000000: aluop <= 5;
                `IALU'b0000000000100000000000000000000000000000: aluop <= 5;
                
                `IALU'b0000000001000000000000000000000000000000: aluop <= 5;
                `IALU'b0000000010000000000000000000000000000000: aluop <= 5;
                `IALU'b0000000100000000000000000000000000000000: aluop <= 5;
                `IALU'b0000001000000000000000000000000000000000: aluop <= 5;
                `IALU'b0000010000000000000000000000000000000000: aluop <= 5;
                
                `IALU'b0000100000000000000000000000000000000000: aluop <= 5;
                `IALU'b0001000000000000000000000000000000000000: aluop <= 11;
                `IALU'b0010000000000000000000000000000000000000: aluop <= 11;
                `IALU'b0100000000000000000000000000000000000000: aluop <= 11;
                `IALU'b1000000000000000000000000000000000000000: aluop <= 11;
                default: aluop <= 5;
                
            endcase
        
        end
        
       
       
endmodule
