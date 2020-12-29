`include "define.vh"


/**
 * MIPS 5-stage pipeline CPU Core, including data path and co-processors.
 * Author: Zhao, Hongyu  <power_zhy@foxmail.com>
 */
module mips_core (
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	input wire [6:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	// instruction interfaces
	output wire inst_ren,  // instruction read enable signal
	output wire [31:0] inst_addr,  // address of instruction needed
	input wire [31:0] inst_data,  // instruction fetched
	// memory interfaces
	output wire mem_ren,  // memory read enable signal
	output wire mem_wen,  // memory write enable signal
	output wire [31:0] mem_addr,  // address of memory
	output wire [31:0] mem_dout,  // data writing to memory
	input wire [31:0] mem_din  // data read from memory
	);
	
	// control signals
	wire [31:0] inst_data_ctrl;
	
	wire [2:0] pc_src_ctrl;
	wire imm_ext_ctrl;
	wire [1:0] exe_a_src_ctrl, exe_b_src_ctrl;
	wire [3:0] exe_alu_oper_ctrl;
	wire mem_ren_ctrl;
	wire mem_wen_ctrl;
	wire [1:0] wb_addr_src_ctrl;
	wire wb_data_src_ctrl;
	wire wb_wen_ctrl;
	
	wire cpu_rst, cpu_en;

	wire  if_rst;
	wire  if_en;
	wire  id_rst;
	wire  id_en;
	wire  exe_rst;
	wire  exe_en;
	wire  mem_rst;
	wire  mem_en;
	wire  wb_rst;
	wire  wb_en;
	wire  [4:0] ID_EX_regw_addr;
	wire  [4:0] EX_MEM_regw_addr;
	wire  ID_EX_wb_wen;
	wire  EX_MEM_wb_wen;
	wire  is_branch_exe;
	wire  is_branch_mem;
	
	//forward signals
	wire[1:0] fwd_rs,fwd_rt;
	wire is_load,is_load_exe,is_load_mem,fwd_mem_ctrl;

	// controller
	controller CONTROLLER (
		.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		`endif
		.inst(inst_data_ctrl),
		.pc_src(pc_src_ctrl),
		.imm_ext(imm_ext_ctrl),
		.exe_a_src(exe_a_src_ctrl),
		.exe_b_src(exe_b_src_ctrl),
		.exe_alu_oper(exe_alu_oper_ctrl),
		.mem_ren(mem_ren_ctrl),
		.mem_wen(mem_wen_ctrl),
		.wb_addr_src(wb_addr_src_ctrl),
		.wb_data_src(wb_data_src_ctrl),
		.wb_wen(wb_wen_ctrl),
		.unrecognized(),
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en),
		.if_rst(if_rst),
		.if_en(if_en),
		.id_rst(id_rst),
		.id_en(id_en),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.ID_EX_regw_addr(ID_EX_regw_addr),
		.EX_MEM_regw_addr(EX_MEM_regw_addr),
		.ID_EX_wb_wen(ID_EX_wb_wen),
		.EX_MEM_wb_wen(EX_MEM_wb_wen),

		.is_load(is_load),
		.is_load_exe(is_load_exe),
		.is_load_mem(is_load_mem),
		.fwd_mem_ctrl(fwd_mem_ctrl),
		.fwd_rs(fwd_rs),
		.fwd_rt(fwd_rt)
//		.is_branch_exe(is_branch_exe),
//		.is_branch_mem(is_branch_mem)
	);
	
	// data path
	datapath DATAPATH (
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr[5:0]),
		.debug_data(debug_data),
		`endif
		.inst_data_ctrl(inst_data_ctrl),
		.pc_src_ctrl(pc_src_ctrl),
		.imm_ext_ctrl(imm_ext_ctrl),
		.exe_a_src_ctrl(exe_a_src_ctrl),
		.exe_b_src_ctrl(exe_b_src_ctrl),
		.exe_alu_oper_ctrl(exe_alu_oper_ctrl),
		.mem_ren_ctrl(mem_ren_ctrl),
		.mem_wen_ctrl(mem_wen_ctrl),
		.wb_addr_src_ctrl(wb_addr_src_ctrl),
		.wb_data_src_ctrl(wb_data_src_ctrl),
		.wb_wen_ctrl(wb_wen_ctrl),
		.inst_ren(inst_ren),
		.inst_addr(inst_addr),
		.inst_data(inst_data),
		.mem_ren(mem_ren),
		.mem_wen(mem_wen),
		.mem_addr(mem_addr),
		.mem_dout(mem_dout),
		.mem_din(mem_din),
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en),
		.if_rst(if_rst),
		.if_en(if_en),
		.id_rst(id_rst),
		.id_en(id_en),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.ID_EX_regw_addr(ID_EX_regw_addr),
		.EX_MEM_regw_addr(EX_MEM_regw_addr),
		.ID_EX_wb_wen(ID_EX_wb_wen),
		.EX_MEM_wb_wen(EX_MEM_wb_wen),
//		.is_branch_exe(is_branch_exe),
//		.is_branch_mem(is_branch_mem)

		.is_load_ctrl(is_load),
		.fwd_rs(fwd_rs),
		.fwd_rt(fwd_rt),
		.ID_EX_is_load(is_load_exe),
		.EX_MEM_is_load(is_load_mem),
		.fwd_mem_ctrl(fwd_mem_ctrl)
	);
	
endmodule
