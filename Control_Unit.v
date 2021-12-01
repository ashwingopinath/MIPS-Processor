`timescale 1ns / 1ps

module Control_Unit(Instr,branch,jump,data_mem_wren,reg_mem_wren,mem_to_reg,ALU_op,rs,rt,rd,imm,
							alu_src,regdst,shamt,beq_off,target_addr
							,shift_ctrl,sign_ctrl,save_PC);
	input [31:0] Instr;
	output reg data_mem_wren;
   output reg reg_mem_wren;
	output reg mem_to_reg;
	output reg alu_src;
	output reg regdst;
	output reg [3:0] ALU_op;
   output reg [4:0] rs;
   output reg [4:0] rt;
	output reg [4:0] rd;
	output reg [31:0] imm;
	output reg branch;
	output reg jump;
	output reg [4:0] shamt;
   output reg [15:0] beq_off;
	output reg [25:0] target_addr;
	output reg shift_ctrl;
	output reg sign_ctrl;
	output reg save_PC;
	
	always @(Instr)
		begin
			data_mem_wren=1'b0;
			reg_mem_wren=1'b0;
			mem_to_reg=1'bz;
			alu_src=1'bz;
			regdst=1'bz;
			rs=5'd0;
			rt=5'd0;
			rd=5'd0;
			imm=32'd0;
			ALU_op=4'd15;
			branch=1'b0;
			jump=1'b0;
			shamt=5'd0;
			beq_off=16'd0;
			target_addr=26'd0;
			shift_ctrl = 1'b0;
			sign_ctrl =1'b0;
			save_PC = 1'b0;
			
		if(Instr[31:26] == 6'b000000)//R-TYPE
			begin
				alu_src=1'b0;
				data_mem_wren=1'b0;
				reg_mem_wren=1'b1;
				mem_to_reg=1'b0;
				regdst=1'b1;
				
				if(Instr[5:0]==6'b100000)//ADD
					begin
						ALU_op=4'b0000;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0]==6'b100010)//SUB
					begin
						ALU_op=4'b0001;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0]==6'b101010)//SLT
					begin
						ALU_op=4'b1010;
						rs=Instr[25:21];
						rt=Instr[20:16];
						sign_ctrl =1'b1;
					end
					
				if(Instr[5:0]==6'b101010)//SLTU
					begin
						ALU_op=4'b1010;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0]==6'b100100)//AND
					begin
						ALU_op=4'b0010;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0]==6'b100101)//OR
					begin
						ALU_op=4'b0011;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0] == 6'b100111)//NOR
					begin
						ALU_op=0110;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0] == 6'b100110)//XOR
					begin
						ALU_op=4'b0100;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0] == 6'b000000)//SLL
					begin
						ALU_op=4'b1100;
						rs=5'd0;
						rt=Instr[20:16];
						shamt=Instr[10:6];
						shift_ctrl=1'b1;
					end
					
				if(Instr[5:0] == 6'b000100)//SLLV
					begin
						ALU_op=4'b1100;
						rt=Instr[20:16];
						rs=Instr[25:21];
					end
					
				if(Instr[5:0] == 6'b000011)//SRA
					begin
						ALU_op=4'b1001;
						rs=5'd0;
						rt=Instr[20:16];
						shamt=Instr[10:6];
						shift_ctrl=1'b1;
					end
					
				if(Instr[5:0] == 6'b000111)//SRAV
					begin
						ALU_op=4'b1001;
						rs=Instr[25:21];
						rt=Instr[20:16];
					end
					
				if(Instr[5:0] == 6'b000010)//SRL
					begin
						ALU_op=4'b1101;
						rs=5'd0;
						shift_ctrl=1'b1;
						rt=Instr[20:16];
						shamt=Instr[10:6];
					end
					
				if(Instr[5:0] == 6'b000110)//SRLV
					begin
						ALU_op=4'b1000;
						rt=Instr[20:16];
						rs=Instr[25:21];
					end
					
					rd=Instr[15:11];
				end
				
				else if(Instr[31:26]==6'b001000)//ADDI
					begin
						regdst=1'b0;
						ALU_op=4'b0000;
						rs=Instr[25:21];
						imm={{16{Instr[15]}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
					end
				
				else if(Instr[31:26]==6'b001100)//ANDI
					begin
						regdst=1'b0;
						ALU_op=4'b0010;
						rs=Instr[25:21];
						imm={{16{1'b0}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
					end
				
				else if(Instr[31:26]==6'b001010)//SLTI
					begin
						regdst=1'b0;
						ALU_op=4'b1010;
						rs=Instr[25:21];
						imm={{16{Instr[15]}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
						sign_ctrl=1'b1;
					end
					
				else if(Instr[31:26]==6'b001011)//SLTIU
					begin
						regdst=1'b0;
						ALU_op=4'b1010;
						rs=Instr[25:21];
						imm={{16{Instr[15]}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
					end
					
				else if(Instr[31:26]==6'b001101)//ORI
					begin
						regdst=1'b0;
						ALU_op=4'b0011;
						rs=Instr[25:21];
						imm={{16{1'b0}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
					end
					
				else if(Instr[31:26]==6'b001101)//XORI
					begin
						regdst=1'b0;
						ALU_op=4'b0100;
						rs=Instr[25:21];
						imm={{16{1'b0}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b0;
					end
					
				else if(Instr[31:26] == 6'b000111)//BGTZ
					begin
						rs=Instr[25:21];
						rt=Instr[20:16];
						branch=1'b1;
						beq_off[15:0]=Instr[15:0];
						ALU_op=4'b1011;
						alu_src = 1'b0;
					end
					
				else if(Instr[31:26] == 6'b000110)//BLEZ
					begin
						rs=Instr[25:21];
						rt=Instr[20:16];
						branch=1'b1;
						beq_off[15:0]=Instr[15:0];
						ALU_op=4'b1000;
						alu_src = 1'b0;
					end
					
				else if(Instr[31:26] == 6'b000101)//BNE
					begin
						rs=Instr[25:21];
						rt=Instr[20:16];
						branch=1'b1;
						beq_off[15:0]=Instr[15:0];
						ALU_op=4'b1110;
						alu_src = 1'b0;
					end
					
				else if(Instr[31:26]==6'b100011)//LW
					begin
						regdst=1'b0;
						ALU_op=4'b0000;
						rs=Instr[25:21];
						imm={{16{Instr[15]}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b0;
						reg_mem_wren=1'b1;
						mem_to_reg=1'b1;
					end
					
				else if(Instr[31:26]==6'b101011)//SW
					begin
						regdst=1'bz;
						ALU_op=4'b0000;
						rs=Instr[25:21];
						imm={{16{Instr[15]}},Instr[15:0]};
						rt=Instr[20:16];
						alu_src=1'b1;
						data_mem_wren=1'b1;
						reg_mem_wren=1'b0;
						mem_to_reg=1'bz;
					end
				
				else if(Instr[31:26]==6'b000100)//BEQ
					begin
						rs=Instr[25:21];
						rt=Instr[20:16];
						branch=1'b1;
						beq_off[15:0]=Instr[15:0];
						ALU_op=4'b0001;
						alu_src = 1'b0;
					end
					
				else if(Instr[31:26]==6'b000010)//JUMP
					begin
						jump=1'b1;
						target_addr[25:0] = Instr[25:0];
					end
					
				else if(Instr[31:26] == 6'b000011)
					begin
						save_PC=1'b1;
						jump=1'b1;
						target_addr[25:0]=Instr[25:0];
					end
			end
endmodule
