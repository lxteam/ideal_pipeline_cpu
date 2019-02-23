`timescale 1ns / 1ps
module ALU(
	input [31:0] X,
	input [31:0] Y,
	input [3:0] ALU_OP,	
    input [4:0] shamt,
	
	output reg [31:0] Result,
	output reg [31:0] Result2,	
	output reg OF,
	output reg UOF,
	output Equal
	);

	wire signed [31:0] shift_x;
	wire signed [31:0] shift_y;
	
	initial begin
		Result <= 0;
		Result2 <= 0;
        OF <= 0;
        UOF <= 0;
    end

	assign shift_y = {27'b0000_0000_0000_0000_0000_0000_000,shamt};
	assign shift_x = $signed(Y) >>> shift_y;
	assign Equal = (X == Y); 
always@(*)
begin 
	case(ALU_OP)
	4'h0:
		begin            
			Result <= Y << shamt;
			Result2 <= 0; OF <= 0; UOF <= 0;
		end
	4'h1:
		begin            
			Result <= shift_x;
			Result2 <= 0;OF <= 0; UOF <= 0;
		end
	4'h2:
		begin            
			Result <= Y >> shamt;
			Result2 <= 0;OF <= 0; UOF <= 0;
		end
	4'h3:
		begin	
			{Result2, Result} <= $signed(X) * $signed(Y);
			OF <= 0; UOF <= 0;
		end
	4'h4:
		begin            
			Result <= X / Y;
			Result2 <= X % Y;
			OF <= 0; UOF <= 0;
		end
	4'h5:
		begin            
			Result <= X + Y;
			OF <= (X[31] & Y[31] & ~Result[31]) || (~X[31] & ~Y[31] & Result[31]);
			UOF <= (Result < X) || (Result < Y);
			Result2 <= 0;
		end
	4'h6:
		begin            
			Result <= X - Y;
			OF <= (X[31] & Y[31] & ~Result[31]) || (~X[31] & ~Y[31] & Result[31]);
			UOF <= Result > X;
			Result2 <= 0;
		end
	4'h7:
		begin            
			Result <= X & Y;
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	4'h8:
		begin            
			Result <= X | Y;
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	4'h9:
		begin            
			Result <= X ^ Y;
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	4'ha:
		begin            
			Result <= ~(X | Y);
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	4'hb:
		begin
			Result <= {31'h0,($signed(X) < $signed(Y))};
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	4'hc:
		begin            
			Result <= (X < Y)? 1 : 0;
			Result2 <= 0;
			OF <= 0; UOF <= 0;
		end
	default:
	    begin
	       Result <= 0;
	       Result2 <= 0;
	       OF <= 0; UOF <= 0;
        end
	endcase
end
endmodule