module DataConflict_ctrl(
    input r1_used_id,
    input r2_used_id,
    input hi_used_id,
    input lo_used_id,
    input[4:0] r1,
    input[4:0] r2,
    input regwrite_ex,
    input[4:0] wbregnum_ex,
    input regwrite_mem,
    input[4:0] wbregnum_mem,
    input hiwrite_ex,
    input lowrite_ex,
    input hiwrite_mem,
    input lowrite_mem,

    output bb_data
);
    assign bb_data = 
        (r1_used_id & regwrite_ex & wbregnum_ex == r1) |
        (r1_used_id & regwrite_mem & wbregnum_mem == r1) |
        (r2_used_id & regwrite_ex & wbregnum_ex == r2) |
        (r2_used_id & regwrite_mem & wbregnum_mem == r2) | 
        (hi_used_id & hiwrite_ex) |
        (hi_used_id & hiwrite_mem) |
        (lo_used_id & lowrite_ex) |
        (lo_used_id & lowrite_mem); 

endmodule

