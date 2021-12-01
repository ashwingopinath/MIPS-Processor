`timescale 1ns / 1ps

module Processor(clk,instr,reg_check,data_mem_check,PC,beq_offset,branch);

	input clk;
	output [31:0] instr;
	output reg [31:0] reg_check;
	output reg [31:0] data_mem_check;
	 wire [31:0] Rc;
	output reg [31:0] PC;
	output wire [15:0] beq_offset;
	 wire zero;
	output wire branch;

	reg [7:0] instr_mem [0:127];
	reg [31:0] data_memory [0:31];
	reg [31:0] reg_memory [0:31];

	reg [31:0] pipeline_reg;

	// INSTRUCTION MEMORY AND INITIALIZATION
	initial begin
	
	//ADD R2 R0 R0
instr_mem[0] = 8'b00100000;
instr_mem[1] = 8'b00010000;
instr_mem[2] = 8'b00000000;
instr_mem[3] = 8'b00000000;
//ADD R2 R2 R1
instr_mem[4] = 8'b00100000;
instr_mem[5] = 8'b00010000;
instr_mem[6] = 8'b01000001;    
instr_mem[7] = 8'b00000000;
//ADDI R1 R1 -1
instr_mem[8] = 8'b11111111;
instr_mem[9] = 8'b11111111;
instr_mem[10] = 8'b00100001;
instr_mem[11] = 8'b00100000;
//BEQ R1 R0 label
instr_mem[12] = 8'b00000011;
instr_mem[13] = 8'b00000000;
instr_mem[14] = 8'b00100000;
instr_mem[15] = 8'b00010000;
// NO OP
instr_mem[16] = 8'b00100000;
instr_mem[17] = 8'b00000000;
instr_mem[18] = 8'b00000000;
instr_mem[19] = 8'b00000000;
//jump to instruction 1
instr_mem[20] = 8'b00000001;
instr_mem[21] = 8'b00000000;
instr_mem[22] = 8'b00000000;    
instr_mem[23] = 8'b00001000;
// NO OP
instr_mem[24] = 8'b00100000;
instr_mem[25] = 8'b00000000;
instr_mem[26] = 8'b00000000;
instr_mem[27] = 8'b00000000;    
//SW R2
	instr_mem[28] = 8'b00000000;
	instr_mem[29] = 8'b00000000;
	instr_mem[30] = 8'b01000010;
	instr_mem[31] = 8'b10101100;

	/*instr_mem[0] = 8'b00100000;
	instr_mem[1] = 8'b00100000;
	instr_mem[2] = 8'b01000011;
	instr_mem[3] = 8'b00000000;

	instr_mem[4] = 8'b00100010;
	instr_mem[5] = 8'b00100000;
	instr_mem[6] = 8'b01000011;    
	instr_mem[7] = 8'b00000000;

	instr_mem[8] = 8'b00100100;
	instr_mem[9] = 8'b00100000;
	instr_mem[10] = 8'b01000011;
	instr_mem[11] = 8'b00000000;

	instr_mem[12] = 8'b00100101;
	instr_mem[13] = 8'b00100000;
	instr_mem[14] = 8'b01000011;
	instr_mem[15] = 8'b00000000;

	instr_mem[16] = 8'b00101010;
	instr_mem[17] = 8'b00100000;
	instr_mem[18] = 8'b01000011;
	instr_mem[19] = 8'b00000000;

	instr_mem[20] = 8'b00111110;
	instr_mem[21] = 8'b00000000;
	instr_mem[22] = 8'b01000011;
	instr_mem[23] = 8'b00100000;

	instr_mem[24] = 8'b00111110;
	instr_mem[25] = 8'b00000000;
	instr_mem[26] = 8'b01000011;
	instr_mem[27] = 8'b00101000;			

	instr_mem[28] = 8'b00000001;
	instr_mem[29] = 8'b00000000;
	instr_mem[30] = 8'b01000011;
	instr_mem[31] = 8'b10001100;	
			

	instr_mem[32] = 8'b00000001;
	instr_mem[33] = 8'b00000000;
	instr_mem[34] = 8'b01000011;
	instr_mem[35] = 8'b10101100;	


	instr_mem[36] = 8'b00111110;
	instr_mem[37] = 8'b00000000;
	instr_mem[38] = 8'b01000011;
	instr_mem[39] = 8'b00101000;				
			

	instr_mem[40] = 8'b00111110;
	instr_mem[41] = 8'b00000000;
	instr_mem[42] = 8'b01000011;
	instr_mem[43] = 8'b00010000;

	instr_mem[44] = 8'b00111110;
	instr_mem[45] = 8'b00000000;
	instr_mem[46] = 8'b01000011;
	instr_mem[47] = 8'b00001000;
*/
	reg_memory[0] = 0;
	reg_memory[1] = 10;
	reg_memory[2] = 0;
	reg_memory[3] = 3;
	reg_memory[4] = 4;
	reg_memory[5] = 5;

	data_memory[0] = 0;
	data_memory[1] = 10;
	data_memory[2] = 20;
	data_memory[3] = 30;
	data_memory[4] = 40;
	
	

	pipeline_reg = 32'bx;

	PC = 32'b0;

	end

	wire [29:0] PC_add,PC_jump;
	reg [29:0] PC_1,PC_2;
	wire /*zero,branch,*/jump;
	wire [25:0] target_addr;
	//wire [15:0] beq_offset;

	//FETCH UNIT
	assign PC_jump = {PC[31:28],target_addr[25:0]};
	assign PC_add = PC[31:2] + 30'd1;

	always @(PC_add or branch or zero)
	begin
	if(branch == 1'b1 & zero == 1'b1)
	begin
	PC_1 = PC_add + {{14{beq_offset[15]}},beq_offset[15:0]}-30'd1;
	end
	else
	begin
	PC_1 = PC_add;
	end
	end

	always @(PC_jump or PC_1 or jump)
	begin
	if(jump==1'b1)
	begin
	PC_2=PC_jump;
	end
	else
	begin
	PC_2=PC_1;
	end
	end

	always @(negedge clk)
	begin
	pipeline_reg<={instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC]};
	PC [31:0] <={PC_2,{2{1'b0}}};
	end

	assign instr = pipeline_reg;

	wire reg_mem_wren;
	wire data_mem_wren;
	wire mem_to_reg;
	wire [3:0] ALU_op;
	wire [4:0] rs,rt,rd;
	wire [31:0] imm;
	wire alu_src,regdst;
	wire [4:0] shift;
	wire shift_ctrl;
	wire sign_ctrl;
	wire overflow;
	wire [31:0] Rx;
	reg [31:0] Ra,Rb;
	reg [4:0] Rp;
	reg [31:0] Rm;
	//wire [31:0] Rc;
	wire [31:0] temp_Ra;
	wire [31:0] temp_Rb;
	wire save_PC;
	
	Control_Unit C1(instr,branch,jump,data_mem_wren,reg_mem_wren,
	mem_to_reg,ALU_op,rs,rt,rd,imm,
	alu_src,regdst,shift,beq_offset,target_addr,shift_ctrl,sign_ctrl,save_PC);
							
	assign temp_Ra = reg_memory[rs];
	assign temp_Rb = reg_memory[rt];
	
	always @(temp_Rb or imm or alu_src)
		begin
			Rb = 32'bz;
			if(alu_src)
				begin
					Rb = imm;
				end
			else if(alu_src==1'b0)
				Rb = temp_Rb;
			end
		
	always@(shift or shift_ctrl or temp_Ra)
		begin
			if(shift_ctrl==1'b1)
				begin
					Ra[31:5] = 27'd0;
					Ra[4:0] = shift;
				end
			else
				begin
					Ra = temp_Ra;
				end
			end
					
	ALU A1(Ra,Rb,shift,ALU_op,Rc,zero,overflow);
	
	assign Rx = data_memory[Rc];
	
	always @(mem_to_reg or Rx or Rc)
		begin
			Rm=32'dz;
			if(mem_to_reg)
				Rm=Rx;
			else
				Rm=Rc;
		end
		
	always @(regdst or rt or rd)
		begin
			Rp=5'dz;
			if(regdst)
				Rp =rd;
			else
				Rp=rt;
		end
	
	
	always@(negedge clk)
		begin
			if((reg_mem_wren==1'b1)&((overflow==1'b0 | alu_src==1'b1)))
				begin
					reg_memory[Rp] <= Rm;
					reg_check <= Rm;
				end
			else if(jump==1'b1 && save_PC==1'b1)
				begin
					reg_memory[31] <= PC+8;
					reg_check <= PC+8;
				end
			if(data_mem_wren==1'b1)
				begin
					data_memory[Rc] <= temp_Rb;
					data_mem_check <= temp_Rb;
				end
		end 

endmodule
