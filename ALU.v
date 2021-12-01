`timescale 1ns / 1ps

module ALU(A,B,sign_ctrl,ALU_op,OUT,zero,overflow);
	input [31:0] A;
	input [31:0] B;
	input sign_ctrl;
	input [3:0] ALU_op;
	output reg [31:0] OUT;
	output reg zero;
	output reg overflow;
	
	//wire [31:0] A1,B1;
	
	//assign A1=A;
	//assign B1=B;
	
	always @(*)
		begin
			overflow = 1'b0;
			zero = 1'b0;
			case(ALU_op)
			4'b0000 : {overflow,OUT} = A+ B;//ADD,ADDI
			4'b0001 :
				begin
				OUT=A-B;
				if(!(OUT))
					zero=1'b1;
				end
			4'b0010 : OUT = A&B;//AND
			4'b0011 : OUT = A|B;//OR
			4'b0100 : OUT = A^B;//XOR
			4'b0101 : OUT = ~(A&B);
			4'b0110 : OUT = ~(A|B);
			4'b0111 : OUT = ~(A^B);
			4'b1000 :
			begin
				OUT = $signed(A) <= $signed(B);
				if(OUT)
					zero=1'b1;
				end
			4'b1001 : OUT = B>>>A;
			4'b1010 : 
			begin
			if(sign_ctrl == 1'b1)
				OUT = $signed(A) < $signed(B);
			else
				OUT = A<B;
			end
			4'b1011 : 
			begin
			OUT = $signed(A) > $signed(B);
			if(OUT)
				zero=1'b1;
			end
			4'b1100 : OUT = (B<<A);
			4'b1101 : OUT = (B>>A);
			4'b1110 :
			begin
			if(A!==B)
				zero=1'b1;
			end
			default : OUT=32'bz;
			endcase
		end
endmodule
