module DataConflict_ctrl(
    input r1_used_id,
    input r2_used_id,
    input hi_used_id,
    input lo_used_id,
    input cp0_used_id,
    input[4:0] r1,
    input[4:0] r2,
    input[4:0] cp0num,
    input CP0toReg_ex,
    input CP0toReg_mem,
    input CP0toReg_wb,
    
    input cp0write_ex,
    input[4:0] cp0num_ex,
    input cp0write_mem,
    input[4:0] cp0num_mem,
    input cp0write_wb,
    input[4:0] cp0num_wb,

    input regwrite_ex,
    input[4:0] wbregnum_ex,
    input regwrite_mem,
    input[4:0] wbregnum_mem,
    input hiwrite_ex,
    input lowrite_ex,
    input hiwrite_mem,
    input lowrite_mem,
    input [31:0] ZDX_HI,
    input [31:0] ZDX_ALURES,
    input ZDX_JAL,
    input [31:0] ZDX_ADDR,
    input MEM_load,
    input [31:0]ZDX_id_Mem,
    input ZDX_JAL_MEM,
    input [31:0] ZDX_ADDR_MEM,
    input [31:0] ZDX_Hi_MEM,
    input [31:0] ZDX_ALURES_MEM,
    input EX_load,

    output R1_EX,
    output R2_EX,
    output R1_MEM,
    output R2_MEM,
    output Hi_EX,
    output Lo_EX,
    output Hi_MEM,
    output Lo_MEM,

    output R2_CP0_EX,
    output R2_CP0_MEM,
//    output R2_CP0_WB,
    output CP0_EX,
    output CP0_MEM,
    output CP0_WB,

    output [31:0] ZDX_EX,
    output [31:0] ZDX_MEM,
    output LOAD_USE
);
    wire EX_MULDIV = hiwrite_ex & lowrite_ex;
    wire MEM_MULDIV = hiwrite_mem & lowrite_mem;
    assign R1_EX  = r1_used_id & regwrite_ex & (wbregnum_ex == r1) & (r1 != 0);
    assign R1_MEM = r1_used_id & regwrite_mem & (wbregnum_mem == r1) & (r1 != 0) & (!R1_EX);
    assign R2_EX  = r2_used_id & regwrite_ex & (wbregnum_ex == r2) & (r2 != 0);
    assign R2_MEM = r2_used_id & regwrite_mem & (wbregnum_mem == r2) & (r2 != 0) & (!R2_EX);
    assign Hi_EX  = hi_used_id & hiwrite_ex;
    assign Hi_MEM = hi_used_id & hiwrite_mem & (!Hi_EX);
    assign Lo_EX  = lo_used_id & lowrite_ex;
    assign Lo_MEM = lo_used_id & lowrite_mem & (Lo_EX); 
    assign R2_CP0_EX = CP0toReg_ex & (r2 == wbregnum_ex);
    assign R2_CP0_MEM = CP0toReg_mem & (r2 == wbregnum_mem);
//    assign R2_CP0_WB = CP0toReg_wb & (r2 == wbregnum_mem);
    assign CP0_EX = cp0_used_id & cp0write_ex & (cp0num == cp0num_ex);
    assign CP0_MEM= cp0_used_id & cp0write_mem & (cp0num == cp0num_mem);
    assign CP0_WB = cp0_used_id & cp0write_wb & (cp0num == cp0num_wb);
    assign ZDX_EX = EX_MULDIV ? (Hi_EX ? ZDX_HI : ZDX_ALURES) : (ZDX_JAL ? ZDX_ADDR :ZDX_ALURES);
    assign ZDX_MEM= MEM_load ? ZDX_id_Mem :(ZDX_JAL_MEM ? ZDX_ADDR_MEM : (MEM_MULDIV ? (Hi_MEM ? ZDX_Hi_MEM : ZDX_ALURES_MEM) : ZDX_ALURES_MEM));
    assign LOAD_USE = (R1_EX || R2_EX) && EX_load;
endmodule

