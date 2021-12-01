`timescale 1ns / 1ps

module Processor_tb;
/*
	// Inputs
	reg clk;

	// Outputs
	wire [31:0] instr;
	wire [31:0] reg_check;
	wire [31:0] data_mem_check;
	wire [31:0] PC;

	// Instantiate the Unit Under Test (UUT)
	Processor uut (
		.clk(clk), 
		.instr(instr), 
		.reg_check(reg_check), 
		.data_mem_check(data_mem_check),
		.PC(PC)
	);
	*/
	

	reg clk;
	wire [31:0] inst;
	wire [31:0] register;
	wire [31:0] memory;
	//wire [31:0] Rc;
	wire [31:0] PC;
   wire [15:0] beq_offset;
	//wire zero;
	wire branch;
	
	
	Processor uut(
		.clk(clk),
		.instr(inst),
		.reg_check(register),
		.data_mem_check(memory),
	//	.Rc(Rc),
		.PC(PC),
		.beq_offset(beq_offset),
		.branch(branch)
		//.zero(zero)
		);
		
	initial begin
		// Initialize Inputs
		clk = 1;

	end
      always #5 clk=~clk;
endmodule

