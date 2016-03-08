 `timescale 10 ns / 1 ps

//--------------- Interface DUT ---------------------//
interface LC3_io (input bit clock);

	logic reset, instrmem_rd, complete_instr, complete_data, Data_rd;
	logic [15:0] pc, Instr_dout, Data_addr, Data_dout, Data_din;

	clocking cb @(posedge clock);
 	default input #1 output #0;
		// instruction memory side
		input	pc; 
   		input	instrmem_rd;  
   		output Instr_dout;

		// data memory side
		input Data_din;
		input Data_rd;
		input Data_addr;		
		output Data_dout;
		
		//output reset;				
  	endclocking

  	modport TB(clocking cb, output complete_data, output complete_instr, output reset);   	 	

endinterface:LC3_io


//---------- Interface Fetch--------------------//
interface fetchProbe(	
	// fetch block interface signals
	input   logic 				clock,
	input   logic 				enable_updatePC,
	input   logic				enable_fetch,
	input   logic				br_taken, 
	input   logic 		[15:0] 		taddr,
	input   logic 				instrmem_rd,
	input   logic		[15:0]		pc,
	input   logic		[15:0]		npc_out,
	input 	logic 				reset
	);
	property reset_prop;
		@ (posedge clock)
		reset |-> (	npc_out == 16'h3001 &&
				pc == 16'h3000);
	endproperty
	FETCH_rst: cover property(reset_prop);

endinterface
	
//-------------- Interface Decode ---------------//
interface decProbe (
	input logic clock,
	input logic [15:0] Instr_dout, npc_in,
	input logic [2:0]  psr,
	input logic	   reset,
	input logic        enable_decode,
	input logic [15:0] IR, npc_out,
	input logic [5:0]  E_control,
	input logic [1:0]  W_control,
	input logic        Mem_control);
	
	property reset_prop;
		@ (posedge clock)
		reset	|->(	IR == 16'h0 &&
				E_control == 6'h0 &&
				npc_out == 16'h0 &&
				Mem_control == 1'h0 &&
				W_control == 2'h0);
	endproperty
	DEC_rst: cover property(reset_prop);	
	
endinterface:decProbe

//-------------- Interface Writeback ---------------//
interface wbProbe (
	input   logic 	     clock,
	input	logic        reset,
	input	logic [15:0] npc_in,
	input	logic [1:0]  W_control_in,
	input	logic [15:0] aluout,
	input	logic [15:0] pcout,
	input	logic [15:0] memout,
	input	logic enable_writeback,
	input	logic [2:0]  src1,src2,
	input	logic [2:0]  dr,
	input	logic [15:0] vsr1, vsr2,
	input	logic [2:0]  psr);
	
	property reset_prop;
		@ (posedge clock)
		reset |-> (psr == 3'b0);
	endproperty
	WB_rst: cover property (reset_prop);
endinterface: wbProbe


//--------------- Interface Memaccess------------//
interface memaccessProbe (input logic [15:0] M_data,
	input logic reset,
	input logic [15:0]  M_addr,
	input logic	   M_control,
	input logic [1:0]  mem_state,
	input logic [15:0] Dmem_dout,
	input logic [15:0] Dmem_addr,
	input logic [15:0] Dmem_din,
	input logic Dmem_rd,
	input logic [15:0] memout);
endinterface:memaccessProbe

//------------- Interface Execute --------------//
interface execProbe (
	input logic 	   clock,
	input logic	   reset,
	input logic [5:0]  E_control,
	input logic [15:0] IR, npc_in,
	input logic        bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2,
	input logic [15:0] VSR1, VSR2,
	input logic [1:0]  W_Control_in,
	input logic        Mem_Control_in,
	input logic	   enable_execute,
	input logic [15:0] Mem_Bypass_Val,
	input logic [1:0]  W_Control_out,
	input logic 	   Mem_Control_out,
	input logic [15:0] aluout,
	input logic [15:0] pcout,
	input logic [2:0]  dr,
	input logic [2:0]  sr1, sr2,
	input logic [15:0] IR_Exec,
	input logic [2:0]  NZP,
	input logic [15:0] M_Data);
 
	property reset_prop;
		@ (posedge clock)
		reset |-> (	W_Control_out == 2'd0 &&
				Mem_Control_out == 1'd0 &&
				aluout == 16'd0 &&
				pcout == 16'd0 &&
				dr == 3'd0 &&
				IR_Exec == 16'd0 &&
				NZP == 3'd0 &&
				M_Data == 16'd0 );
	endproperty
	EXEC_rst: cover property (reset_prop);

endinterface:execProbe

//------------- Interface Control --------------//
interface ctrlProbe (
	input logic clock,
	input logic reset,	
	input logic complete_data,
	input logic complete_instruction,
	input logic [15:0] IR,
	input logic [2:0] psr,
	input logic [15:0] IR_Exec,
	input logic [15:0] IMem_dout,
	input logic [2:0] NZP,
	input logic enable_updatePC,
	input logic enable_fetch,
	input logic enable_decode,
	input logic enable_execute,
	input logic enable_writeback,
	input logic bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2,
	input logic [1:0] mem_state,
	input logic br_taken);


	/*property reset_prop;
		@ (posedge clock)
		reset |-> (enable_decode == 1'b0);		
	endproperty:reset_prop
	*/
	
	property br_prop;
		@ (posedge clock)
		|NZP |-> (br_taken == 1'b1); 
	endproperty:br_prop

	property mem_prop31;
		@ (posedge clock)
		(mem_state == 2'd3) |=> (mem_state == 2'd1);
	endproperty

	property mem_prop30;
		@ (posedge clock)
		(mem_state == 2'd3) |=> (mem_state == 2'd0);
	endproperty

	property mem_prop32;
		@ (posedge clock)
		(mem_state == 2'd3) |=> (mem_state == 2'd2);
	endproperty

	property mem_prop23;
		@ (posedge clock)
		(mem_state == 2'd2) |=> (mem_state == 2'd3);
	endproperty

	property mem_prop10;
		@ (posedge clock)
		(mem_state == 2'd1) |=> (mem_state == 2'd0);
	endproperty

	property mem_prop12;
		@ (posedge clock)
		(mem_state == 2'd1) |=> (mem_state == 2'd2);
	endproperty

	property mem_prop03;
		@ (posedge clock)
		(mem_state == 2'd0) |=> (mem_state == 2'd3);
	endproperty

	property wbLD_prop;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd2) |=> (enable_writeback == 1'b1) ;
	endproperty
	
	property wbST_prop;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd3) |=> (enable_writeback == 1'b0) |=> (enable_writeback == 1'b1);
	endproperty

	property bypalu1AA_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd1 || IR[15:12] == 4'd5 || IR[15:12] == 4'd9) && (IR_Exec[15:12] == 4'd1 || IR_Exec[15:12] == 4'd5 || IR_Exec[15:12] == 4'd9) && (IR_Exec[11:9] == IR[8:6])) |=> (bypass_alu_1 == 1'b1);
	endproperty
	
	property bypalu2AA_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd1 || IR[15:12] == 4'd5 || IR[15:12] == 4'd9) && (IR_Exec[15:12] == 4'd1 || IR_Exec[15:12] == 4'd5 || IR_Exec[15:12] == 4'd9) && (IR_Exec[11:9] == IR[2:0]) && (IR[5] == 1'b0)) |=> (bypass_alu_2 == 1'b1);
	endproperty

	property bypalu1AS_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd7) && (IR_Exec[15:12] == 4'd1 || IR_Exec[15:12] == 4'd5 || IR_Exec[15:12] == 4'd9) && (IR_Exec[11:9] == IR[8:6])) |-> (bypass_alu_1 == 1'b1);
	endproperty
	
	property bypalu2AS_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd7 || IR[15:12] == 4'd3 || IR[15:12] == 4'd11) && (IR_Exec[15:12] == 4'd1 || IR_Exec[15:12] == 4'd5 || IR_Exec[15:12] == 4'd9) && (IR_Exec[11:9] == IR[11:9])) |-> (bypass_alu_2 == 1'b1);
	endproperty
	
	property bypmem1LA_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd1 || IR[15:12] == 4'd5 || IR[15:12] == 4'd9) && (IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd6 || IR_Exec[15:12] == 4'd10) && (IR_Exec[11:9] == IR[8:6])) |=> (bypass_mem_1 == 1'b1);
	endproperty

	property bypmem2LA_prop;
		@ (posedge clock)
		((IR[15:12] == 4'd1 || IR[15:12] == 4'd5 || IR[15:12] == 4'd9) && (IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd6 || IR_Exec[15:12] == 4'd10) && (IR_Exec[11:9] == IR[2:0]) && (IR[5] == 1'b0)) |=> (bypass_mem_2 == 1'b1);
	endproperty

	property memLDI_prop;
		@ (posedge clock)
		((mem_state == 2'd3) && (IR[15:12] == 4'd10)) |=> ((mem_state == 2'd1)) |=> (mem_state == 2'd0) |=> (mem_state == 2'd3);
	endproperty

	property memSTI_prop;
		@ (posedge clock)
		((mem_state == 2'd3) && (IR[15:12] == 4'd11)) |=> (mem_state == 2'd1) |=> (mem_state == 2'd2) |=> (mem_state == 2'd3);
	endproperty


	//Enable Fetch Check
	property enfetch_propLD_ST;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd3 || IR_Exec[15:12] == 4'd6 || IR_Exec[15:12] == 4'd7) |-> (enable_fetch == 1'b1);
	endproperty

	property enfetch_propLDI_STI;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd10 || IR_Exec[15:12] == 4'd11) |-> (enable_fetch == 1'b0) |-> (enable_fetch == 1'b1);
	endproperty	

	property enfetch_propBR;
		@ (posedge clock)
		(IMem_dout[15:12] == 4'd0 || IMem_dout[15:12] == 4'd12) |-> (enable_fetch == 1'b0) |-> (enable_fetch == 1'b0) |-> (enable_fetch == 1'b0) |-> (enable_fetch == 1'b1);
	endproperty

	property enfetch_prop;
		enfetch_propLD_ST and enfetch_propLDI_STI and enfetch_propBR;
	endproperty

	
	//Enable Decode Check
	property endecode_propLD_ST;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd3 || IR_Exec[15:12] == 4'd6 || IR_Exec[15:12] == 4'd7) |-> (enable_decode == 1'b1);
	endproperty

	property endecode_propLDI_STI;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd10 || IR_Exec[15:12] == 4'd11) |-> (enable_decode == 1'b0) |-> (enable_decode == 1'b1);
	endproperty	

	property endecode_propBR;
		@ (posedge clock)
		(IMem_dout[15:12] == 4'd0 || IMem_dout[15:12] == 4'd12)|-> (enable_decode == 1'b1) |-> (enable_decode == 1'b0) |-> (enable_decode == 1'b0) |-> (enable_decode == 1'b0) |-> (enable_decode == 1'b1);
	endproperty

	property endecode_prop;
		endecode_propLD_ST and endecode_propLDI_STI and endecode_propBR;
	endproperty

	//Enable Execute Check
	property enexecute_propLD_ST;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd3 || IR_Exec[15:12] == 4'd6 || IR_Exec[15:12] == 4'd7) |-> (enable_execute == 1'b1);
	endproperty

	property enexecute_propLDI_STI;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd10 || IR_Exec[15:12] == 4'd11) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b1);
	endproperty	

	property enexecute_propBR;
		@ (posedge clock)
		(IMem_dout[15:12] == 4'd0 || IMem_dout[15:12] == 4'd12) |-> (enable_execute == 1'b1) |-> (enable_execute == 1'b1) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b1);
	endproperty

	property enexecute_prop;
		enexecute_propLD_ST and enexecute_propLDI_STI and enexecute_propBR;
	endproperty


	//Enable Writeback Check
	property enwriteback_propLD_LDR;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd6) |-> (enable_writeback == 1'b1);
	endproperty

	property enwriteback_propST_STR_LDI;
		@ (posedge clock)
		(IR_Exec[15:12] == 4'd3 || IR_Exec[15:12] == 4'd7 || IR_Exec[15:12] == 4'd10) |-> (enable_writeback == 1'b0) |->  (enable_writeback == 1'b1);
	endproperty

	property enwriteback_propSTI;
		@ (posedge clock)
		( IR_Exec[15:12] == 4'd11) |-> (enable_writeback == 1'b0) |-> (enable_writeback == 1'b0) |-> (enable_writeback == 1'b1);
	endproperty	

	property enwriteback_propBR;
		@ (posedge clock)
		(IMem_dout[15:12] == 4'd0 || IMem_dout[15:12] == 4'd12)|-> (enable_execute == 1'b1) |-> (enable_execute == 1'b1) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b0) |-> (enable_execute == 1'b1);
	endproperty

	property enwriteback_prop;
		enwriteback_propLD_LDR and enwriteback_propST_STR_LDI and enwriteback_propSTI and enwriteback_propBR;
	endproperty

	//Enable Update PC

	property enupdatePC_propLD_LDR;
		@(posedge clock)
		(IR_Exec[15:12] == 4'd2 || IR_Exec[15:12] == 4'd6) |-> (enable_updatePC == 1'b1);
	endproperty

	property enupdatePC_propST_STR;
		@(posedge clock)
		(IR_Exec[15:12] == 4'd3 || IR_Exec[15:12] == 4'd7) |->(enable_updatePC == 1'b1) |-> (enable_updatePC == 1'b1);
	endproperty

	property enupdatePC_propLDI;
		@(posedge clock)
		(IR_Exec[15:12] == 4'd10 ) |->(enable_updatePC == 1'b0) |-> (enable_updatePC == 1'b1);
	endproperty
	
	property enupdatePC_propSTI;
		@(posedge clock)
		(IR_Exec[15:12] == 4'd11 ) |-> (enable_updatePC == 1'b0) |-> (enable_updatePC == 1'b1) |-> (enable_updatePC == 1'b1);
	endproperty

	property enupdatePC_propBR;
		@(posedge clock)
		(IMem_dout[15:12] == 4'd0 || IMem_dout[15:12] == 4'd12) |-> (enable_updatePC == 1'b0) |-> (enable_updatePC == 1'b0) |-> (enable_updatePC == 1'b0) |-> (enable_updatePC == 1'b1) |-> (enable_updatePC == 1'b1) |-> (enable_updatePC == 1'b1) |-> (enable_updatePC == 1'b1);
	endproperty

	property enupdatePC_prop;
		enupdatePC_propLD_LDR and enupdatePC_propST_STR and enupdatePC_propLDI and enupdatePC_propSTI and enupdatePC_propBR;
	endproperty

	
	//CTRL_rst: cover property (reset_prop);
	CTRL_br_taken_jmp : cover property (br_prop);
	CTRL_mem_state_3_1 : cover property (mem_prop31); 
	CTRL_mem_state_3_2 : cover property (mem_prop32); 
	CTRL_mem_state_3_0 : cover property (mem_prop30);
	CTRL_mem_state_2_3 : cover property (mem_prop23); 
	CTRL_mem_state_1_0 : cover property (mem_prop10); 
	CTRL_mem_state_1_2 : cover property (mem_prop12);
	CTRL_mem_state_0_3 : cover property (mem_prop03);
	CTRL_enable_wb_ST : cover property (wbST_prop);
	CRTL_enable_wb_LD : cover property (wbLD_prop); 
	CTRL_bypass_alu_1_AA: cover property (bypalu1AA_prop);
	CTRL_bypass_alu_2_AA: cover property (bypalu2AA_prop);
	CTRL_bypass_alu_1_AS: cover property (bypalu1AS_prop);
	CTRL_bypass_alu_2_AS: cover property (bypalu2AS_prop); 
	CTRL_bypass_mem_1_LA: cover property (bypmem1LA_prop);  
	CTRL_bypass_mem_2_LA: cover property (bypmem2LA_prop);
	CTRL_mem_state_STI : cover property (memLDI_prop);
	CTRL_mem_state_LDI : cover property (memSTI_prop);
	CTRL_enable_fetch : cover property (enfetch_prop);
	CTRL_enable_decode : cover property (endecode_prop);
	CTRL_enable_execute : cover property (enexecute_prop);
	CTRL_enable_writeback : cover property (enwriteback_prop);
	CTRL_enable_updatePC : cover property (enupdatePC_prop);

endinterface: ctrlProbe

























