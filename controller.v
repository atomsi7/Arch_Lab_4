`include "define.vh"


/**
 * Controller for MIPS 5-stage pipelined CPU.
 * Author: Zhao, Hongyu  <power_zhy@foxmail.com>
 */
module controller (/*AUTOARG*/
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	`endif
	// instruction decode
	input wire [31:0] inst,  // instruction
	output reg [2:0] pc_src,  // how would PC change to next
	output reg imm_ext,  // whether using sign extended to immediate data
	output reg [1:0] exe_a_src,  // data source of operand A for ALU
	output reg [1:0] exe_b_src,  // data source of operand B for ALU
	output reg [3:0] exe_alu_oper,  // ALU operation type
	output reg mem_ren,  // memory read enable signal
	output reg mem_wen,  // memory write enable signal
	output reg [1:0] wb_addr_src,  // address source to write data back to registers
	output reg wb_data_src,  // data source of data being written back to registers
	output reg wb_wen,  // register write enable signal
	output reg unrecognized,  // whether current instruction can not be recognized
	// debug control
	output reg cpu_rst,  // cpu reset signal
	output reg cpu_en,  // cpu enable signal





	/* 	新添加的rst, en 信号*/

	output reg if_rst,
	output reg if_en,

	output reg id_rst,
	output reg id_en,

	output reg exe_rst,
	output reg exe_en,

	output reg mem_rst,
	output reg mem_en,

	output reg wb_rst,
	output reg wb_en,

	/*==================================*/
	input wire [4:0] ID_EX_regw_addr,
	input wire [4:0] EX_MEM_regw_addr,

	input wire ID_EX_wb_wen,
	input wire EX_MEM_wb_wen,

	//forward signals
	output reg[1:0] fwd_rs,
	output reg[1:0] fwd_rt,
	output reg fwd_mem_ctrl,
	output reg is_load,
	input wire is_load_exe,
	input wire is_load_mem

//	input wire is_branch_exe,
//	input wire is_branch_mem

	/*===================================*/
	);
	
	`include "mips_define.vh"

	/*===============================*/
	reg rs_used, rt_used, is_store;
	
	// instruction decode
	always @(*) begin
		pc_src = PC_NEXT;   // datapath:pc_src_ctrl
		imm_ext = 0;
		exe_a_src = EXE_A_RS;
		exe_b_src = EXE_B_RT;
		exe_alu_oper = EXE_ALU_ADD;
		mem_ren = 0;
		mem_wen = 0;
		wb_addr_src = WB_ADDR_RD;
		wb_data_src = WB_DATA_ALU;
		wb_wen = 0;
		unrecognized = 0;

		/*===========*/
		rs_used=0;
		rt_used=0;

		case (inst[31:26])	// opcode
			INST_R: begin
				case (inst[5:0])	// func
					R_FUNC_JR: begin
						pc_src = PC_JR;
						rs_used = 1;
					end
					R_FUNC_ADD: begin
						exe_alu_oper = EXE_ALU_ADD;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;

					end
					R_FUNC_SUB: begin
						exe_alu_oper = EXE_ALU_SUB;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						
					end
					R_FUNC_AND: begin
						exe_alu_oper = EXE_ALU_AND;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_OR: begin
						exe_alu_oper = EXE_ALU_OR;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SLT: begin
						exe_alu_oper = EXE_ALU_SLT;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SLL:begin
						exe_alu_oper = EXE_ALU_SLL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SRL:begin
						exe_alu_oper = EXE_ALU_SRL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					default: begin
						unrecognized = 1;
					end
				endcase
			end
			INST_J: begin
				pc_src = PC_JUMP;
			end
			INST_JAL: begin
				pc_src = PC_JUMP;
			 	exe_a_src = EXE_A_LINK;
			 	exe_b_src = EXE_B_LINK;
			 	exe_alu_oper = EXE_ALU_ADD;
			 	wb_addr_src = WB_ADDR_LINK;
			 	wb_data_src = WB_DATA_ALU;
			 	wb_wen = 1;
			end
			INST_BEQ: begin
				pc_src = PC_BEQ;
				exe_a_src = EXE_A_BRANCH;
				exe_b_src = EXE_B_BRANCH;
				exe_alu_oper = EXE_ALU_ADD;
				imm_ext = 1;

				rs_used = 1;
				rt_used = 1;
			

			end
			INST_BNE: begin
				pc_src = PC_BNE;
				exe_a_src = EXE_A_BRANCH;
				exe_b_src = EXE_B_BRANCH;
				exe_alu_oper = EXE_ALU_ADD;
				imm_ext = 1;

				rs_used = 1;
				rt_used = 1;
			end
			INST_ADDI: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_ADD;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;

				rs_used = 1;
			end
			INST_ANDI: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_AND;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;

				rs_used = 1;
			end
			INST_ORI: begin
				imm_ext = 0;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_OR;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;

				rs_used = 1;
			end
			INST_LW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_ADD;
				mem_ren = 1;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_MEM;
				wb_wen = 1;

				rs_used = 1;
				is_load = 1;
			end
			INST_SW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_ADD;
				mem_wen = 1;

				rs_used = 1;
				rt_used = 1;

				is_store = 1;
			end
			INST_SLTI:begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_SLT;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;

				rs_used = 1;
			end
			INST_LUI:begin
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_LUI;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
			end
			default: begin
				unrecognized = 1;
			end
		endcase
	end
	
	// debug control
	`ifdef DEBUG
	reg debug_step_prev;
	
	always @(posedge clk) begin
		debug_step_prev <= debug_step;
	end
	`endif
	
	always @(*) begin
		cpu_rst = 0;
		cpu_en = 1;
		if (rst) begin
			cpu_rst = 1;
		end
		`ifdef DEBUG
		// suspend and step execution
		else if ((debug_en) && ~(~debug_step_prev && debug_step)) begin
			cpu_en = 0;
		end
		`endif
	end


	reg reg_stall;
	reg branch_stall;
	wire [4:0] addr_rs, addr_rt;
	
	assign
		addr_rs = inst[25:21],
		addr_rt = inst[20:16];


	//data hazard detection and forwarding
	always @(*) begin
		reg_stall = 0;
		fwd_rs = 0;
		fwd_rt = 0;
		fwd_mem_ctrl = 0;
		if (rs_used && addr_rs != 0) begin
			if (ID_EX_regw_addr == addr_rs && ID_EX_wb_wen) begin
				if(is_load_exe)
					reg_stall = 1;
				else
					fwd_rs = 1;
			end
			else if (EX_MEM_regw_addr == addr_rs && EX_MEM_wb_wen) begin
				if(is_load_mem)
					fwd_rs = 3;
				else
					fwd_rs = 2;
			end
		end
		if (rt_used && addr_rt != 0) begin
			if (ID_EX_regw_addr == addr_rt && ID_EX_wb_wen) begin
				reg_stall = 1;
			end
			else if (EX_MEM_regw_addr == addr_rt && EX_MEM_wb_wen) begin
				if(is_load_exe) begin
					if(is_store)
						fwd_mem_ctrl = 1; 	//store after load
					else
						reg_stall = 1;
				end
				else
					fwd_rt = 1;
			end
			else if(EX_MEM_regw_addr == addr_rt && EX_MEM_wb_wen) begin
				if(is_load_mem)
					fwd_rt = 3;
				else
					fwd_rt = 2;
			end
		end
	end
	
	
	always @(*) begin
		branch_stall = 0;
		if(pc_src != PC_NEXT)
			branch_stall = 1;
	end

	always @(*) begin
		if_rst = 0;
		if_en = 1;
		id_rst = 0;
		id_en = 1;
		exe_rst = 0;
		exe_en = 1;
		mem_rst = 0;
		mem_en = 1;
		wb_rst = 0;
		wb_en = 1;
		if (rst) begin
			if_rst = 1;
			id_rst = 1;
			exe_rst = 1;
			mem_rst = 1;
			wb_rst = 1;
		end
		`ifdef DEBUG
		else if ((debug_en) && ~(~debug_step_prev && debug_step)) begin
			if_en = 0;
			id_en = 0;
			exe_en = 0;
			mem_en = 0;
			wb_en = 0;
		end
		`endif		
		else if (reg_stall) begin
			if_en = 0;
			id_en = 0;
			exe_rst = 1;
		end
		else if (branch_stall) begin
			id_rst = 1;
		end
	end



	
endmodule
