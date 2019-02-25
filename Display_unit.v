`timescale 1ns / 1ps
module FPGA_ctrl(
    input clk_in,
    input [31:0] Todisplay,
    input [12:0] num_clcye,
    input [15:0] sw,
    input btnl,
    input btnr,
    input btnu,
    input btnc,
    input btnd,
    input [32*32-1:0] reg_content,
    input [256*8-1:0] ram_content,
    
    output ir1,
    output ir2,
    output ir3,
    output clk,
    output CLR,
    output GO,
    output reg pause,
    output [7:0] an,
    output [7:0] seg
    
);
//    assign CLR = btnl,GO = btnr;
    fangdou (clk_in, btnl, CLR);
    fangdou (clk_in, btnr, GO);
    fangdou (clk_in, btnu, ir1);
    fangdou (clk_in, btnc, ir2);
    fangdou (clk_in, btnd, ir3);
    wire Cycle = sw[15], Freq = sw[14], change_Freq = sw[13], Reg = sw[12], Ram = sw[11];
    wire [1:0] Byte = sw[1:0];
    wire [63:0] rom;
    reg [6:0] frq;
    reg [31:0] debug_reg[31:0];
    integer i;
    always @(*)begin
        for (i = 0; i<32; i = i+1)
            debug_reg[i] <= reg_content[i*32+31-:32];
    end
    wire [31:0] reg_window = debug_reg[sw[4:0]];
    wire [31:0] ram_window = ram_content[{sw[7:2],2'b00}*8+31-:32];
    always @(posedge clk_in) begin
        if (CLR)begin
            frq <= 1;
            pause <= 0;
        end
        else if (change_Freq)begin
            pause <= 1;
            frq <= sw[6:0];
        end
        else begin
            pause <= 0;
        end 
    end

    adj_frq main_freq(clk_in , frq, clk);
    makerom dis_mem(CLR, Cycle, Freq, Reg, Ram, Byte, Todisplay, num_clcye, frq, reg_window, ram_window, rom);
    dynamic_scan ds(clk_in, rom, an, seg);




endmodule 
module makerom(
    input CLR,
    input Cycle,
    input Freq, 
    input Reg,
    input Ram,
    input [1:0] Byte,
    input [31:0] num_print, 
    input [12:0] num_cycle, 
    input [6:0]num_frq, 
    input [31:0] reg_window,
    input [31:0] ram_window,
    
    output reg [63:0] rom
    );/*port*/
    //打印syscall——print，打印主频，MHz），打印周期数
    wire [3:0] n0 = num_frq%10, n1 = (num_frq/10)%10, n2 = (num_frq/100)%10;
    wire [7:0] pattf0,pattf1,pattf2;
    wire [7:0] patt0,patt1,patt2,patt3,patt4,patt5,patt6,patt7;
    wire [3:0] nc0 = num_cycle%10, nc1 = (num_cycle/10)%10, 
        nc2 = (num_cycle/100)%10, nc3 = (num_cycle/1000)%10, nc4 = (num_cycle/10000)%10;
    wire [7:0] pattc0, pattc1, pattc2, pattc3, pattc4;
    wire [63:0] patt64;
    wire [127:0] shift_patt64 = {64'hffffffffffffffff,patt64};
    always @(*) begin
        if(CLR) 
            rom<=64'hffff_ffff_ffff_ffff;
        else if (Cycle)begin
            rom[63:56]<=8'b11111111;
            rom[55:48]<=8'b11111111;
            rom[47:40]<=8'b11111111;
            rom[39:32]<=num_cycle < 10000? 8'b11111111 : pattc4;
            rom[31:24]<=num_cycle < 1000 ? 8'b11111111 : pattc3;
            rom[23:16]<=num_cycle < 100  ? 8'b11111111 : pattc2;
            rom[15:8] <=num_cycle < 10   ? 8'b11111111 : pattc1;
            rom[7:0]  <=pattc0;
        end
        else if (Freq) begin
            rom[63:56]<=8'b11111111;
            rom[55:48]<=8'b11111111;
            rom[47:40]<=8'b11111111;
            rom[39:32]<=8'b11111111;
            rom[31:24]<=8'b11111111;
            rom[23:16]<=num_frq < 100? 8'b11111111:pattf2;
            rom[15:8] <=num_frq < 10 ? 8'b11111111:pattf1;
            rom[7:0]  <=pattf0;
        end
        else if (Ram)
            rom[63:0] <= shift_patt64[Byte*16+63-:64];
        else
            rom[63:0] <= patt64;
    end
    
    SevenSeg_32 Code32( Reg ? reg_window : (Ram ? ram_window : num_print), patt64);
    pattern pf0(n0, pattf0), pf1(n1,pattf1), pf2(n2,pattf2);
    pattern pc0(nc0, pattc0), pc1(nc1, pattc1), pc2(nc2, pattc2), pc3(nc3, pattc3), pc4(nc4, pattc4);
endmodule
module SevenSeg_32(
    input [31:0] num_print,
    output [63:0] code
);
    wire [7:0] patt0,patt1,patt2,patt3,patt4,patt5,patt6,patt7;
    pattern p0(num_print[3:0],patt0), p1(num_print[7:4],patt1), p2(num_print[11:8],patt2), 
        p3(num_print[15:12],patt3), p4(num_print[19:16],patt4), p5(num_print[23:20],patt5), 
        p6(num_print[27:24],patt6), p7(num_print[31:28],patt7);
    assign code = {patt7,patt6,patt5,patt4,patt3,patt2,patt1,patt0};
endmodule 
module pattern(input [3:0] code, output reg [7:0] patt);   
    always @(code)
    begin
        case(code)
        0:patt = 8'b11000000;
        1:patt = 8'b11111001;
        2:patt = 8'b10100100;
        3:patt = 8'b10110000;
        4:patt = 8'b10011001;
        5:patt = 8'b10010010;
        6:patt = 8'b10000010;
        7:patt = 8'b11111000;
        8:patt = 8'b10000000;
        9:patt = 8'b10011000;
        10:patt = 8'b10001000;
        11:patt = 8'b10000011;
        12:patt = 8'b11000110;
        13:patt = 8'b10100001;
        14:patt = 8'b10000110;
        default:patt = 8'b10001110;
        endcase
    end     
endmodule
module dynamic_scan(input clk, input [63:0] rom,
    output reg [7:0] an, output reg [7:0] seg
);
    wire [63:0] sel;
    wire clk_d;
    divider div_ins2(clk, clk_d);
    reg [2:0] cnt=0;
    initial begin
        an=0; 
        seg=0;
    end
    assign sel = cnt*8+7;
    always @(posedge clk_d) begin
        seg <= rom[sel-:8];
        an <= ~(8'b00000001<<cnt);
        cnt <= cnt+1'b1;
    end
endmodule // dynamic_scan : 动态扫描输出数字
module fangdou(
    input clk,
    input pos,
    output reg neg
);
    reg [31:0] count;
    reg [31:0] count2;
    initial
    begin
        count<=0;
        neg<=0;
    end
    always @(posedge clk)
    begin
        if((pos==1)&&(count==0)&&(count2==0))begin
            neg<=1;
            count2<=32'h0100_0000;
        end
        else if((neg==1)&&(count<32'h0100_0000))
        begin
            count<=count+1;
            neg<=1;
        end
        else if((neg==1)&&(count2==32'h0100_0000))
        begin
            count<=0;
            neg<=0;
        end
        else if(count2!=0) begin
            neg<=0;
            count2<=count2-1;
        end
        else 
            neg<=0;
    end
endmodule

module adj_frq(input clk,input [6:0] frq, output reg clk_n);//frq M Hz
    wire [6:0] t = 100/frq;
//    wire [6:0] s = t < 2 ? 1 : t;
    reg [6:0] cnt = 0;
    initial clk_n=0;
    always@(posedge clk) begin
        cnt = cnt + 1;
        if(cnt >= t/2)begin
            clk_n = ~clk_n;
            cnt = 0;
        end
    end
endmodule // divider : 参数分时器

module divider(input clk, output reg clk_n);
    parameter s = 100_000_000/20_000;
    integer cnt = 0;
    initial clk_n=0;
    always@(posedge clk) begin
        cnt = cnt + 1;
        if(cnt == s/2)begin
            clk_n = ~clk_n;
            cnt = 0;
        end
    end
endmodule 
