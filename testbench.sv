`timescale 10 ns / 1 ps
`include "golden.sv"

import golden::*;
//--------------------- Transactor ---------------//
class transactor;

	// Outputs

	//logic reset;
	rand logic complete_instr;
	rand logic complete_data;
	randc logic [15:0] Instr_dout;
	rand logic [15:0] Data_dout;

	
	//Constraints Block

	constraint mainblock{
		complete_data == 1'b1;
		complete_instr == 1'b1;
		//Instr_dout[15:12] == 4'd5; 
		!(Instr_dout[15:12] inside {4,8,13,15});
		if((Instr_dout[5] == 1'b0) && (Instr_dout[15:12] == 4'd1))   //ADD
		{
			Instr_dout[4] == 1'b0;
			Instr_dout[3] == 1'b0;
		}
		
		if((Instr_dout[5] == 1'b0) && (Instr_dout[15:12] == 4'd5))   //AND
		{
			Instr_dout[4] == 1'b0;
			Instr_dout[3] == 1'b0;
		}
		if(Instr_dout[15:12] == 4'd9)   // NOT INSTRUCTION
		{
			Instr_dout[5:0] == 6'b111111;
		}
		if(Instr_dout[15:12] == 4'd0)      // Branch Instruction
		{
			Instr_dout[11:9] != 3'd0;
		}
		if(Instr_dout[15:12] == 4'd12)	//JMP Instruction
		{
			Instr_dout[11:9] == 3'd7;   // Maybe wrong HIGHLIGHTED AS RED ******
			Instr_dout[5:0] == 6'd0;
		}	
	}
	

endclass:transactor

//--------------------- Generator ---------------//
class generator;
	transactor t1;
        mailbox #(transactor) gen2driver;

	int numTest;

	int counter_control;
	int counter_mem;

	int counter_direct; 

	function new(mailbox gen2driver);
		this.gen2driver = gen2driver;
		counter_control = 0;
		counter_mem = 0;
		counter_direct = 0;
		numTest = 1000000; 
	endfunction:new



	task run();	
		t1 = new();
		if(t1.randomize())
		begin
			if (counter_direct < 21) begin // counter less than 17 

				if (counter_direct <= 4)
					t1.Instr_dout = 16'b0101000000000000;

				if (counter_direct == 5) begin
					t1.Instr_dout = 16'b0010010000000000;
					t1.Data_dout = 16'haaaa;
				end

				if (counter_direct >= 6) begin
					if (counter_direct < 13) 
						t1.Instr_dout = 16'b0101000000000000;	
						t1.Data_dout = 16'haaaa;
				end

				if (counter_direct == 13) begin
					t1.Instr_dout = 16'b0010011000000000;
					t1.Data_dout = 16'h5555;
				end

				if (counter_direct == 14)	begin
					t1.Instr_dout = 16'b0001111010000010;
					t1.Data_dout = 16'h5555;
				end

				if (counter_direct == 15)	begin
					t1.Instr_dout = 16'b0001001011000010;
					t1.Data_dout = 16'h5555;
				end

				if (counter_direct == 16)
					t1.Instr_dout = 16'b0001110010000011;
			
				if (counter_direct == 17)
					t1.Instr_dout = 16'b0101101011000011;			

				if (counter_direct >= 18)
					t1.Instr_dout = 16'b0101000000000000;

				gen2driver.put(t1);
						
				counter_direct ++;
			end
			
			else begin // normal operation
				if (counter_control > 0) begin
					counter_control--;
				end

						
				if (counter_mem > 0) begin
					counter_mem--;
				end
				//$display("Org Instr %b\n",t1.Instr_dout[15:12]);

				if(counter_control > 0 && counter_mem > 0 && (t1.Instr_dout[15:12] == 4'd2 || t1.Instr_dout[15:12] == 4'd6 || t1.Instr_dout[15:12] == 4'd10 || t1.Instr_dout[15:12] == 4'd3 || t1.Instr_dout[15:12] == 4'd7 || t1.Instr_dout[15:12] == 4'd11) ) begin
					t1.Instr_dout = 16'b1001101001111111;
				end
		
				if(counter_control > 0 && counter_mem > 0 && (t1.Instr_dout[15:12] == 4'd0 || t1.Instr_dout[15:12] == 4'd12)) begin 
					t1.Instr_dout = 16'b0101101001000001;
				end

				if((t1.Instr_dout[15:12] == 4'd0 || t1.Instr_dout[15:12] == 4'd12) && counter_control == 0) begin // Control Instruction
					counter_control = 7;
					counter_mem = 7;
				end

				if((t1.Instr_dout[15:12] == 4'd2 || t1.Instr_dout[15:12] == 4'd6 || t1.Instr_dout[15:12] == 4'd10 || t1.Instr_dout[15:12] == 4'd3 || t1.Instr_dout[15:12] == 4'd7 || t1.Instr_dout[15:12] == 4'd11) && counter_mem == 0) begin // Mem Instruction
		
					counter_mem = 7;
					counter_control = 7;
					//$display("Check 1 - %d", t1.Instr_dout[15:12]);
				end

				gen2driver.put(t1);

			//	if (t1.Instr_dout[15:12] == 4'b0000 || t1.Instr_dout[15:12] == 4'b1100)
			//		$display("Branch encountered");

			//	if(t1.Instr_dout[15:12] == 4'd2 || t1.Instr_dout[15:12] == 4'd6 || t1.Instr_dout[15:12] == 4'd10 || t1.Instr_dout[15:12] == 4'd14 || t1.Instr_dout[15:12] == 4'd3 || t1.Instr_dout[15:12] == 4'd7 || t1.Instr_dout[15:12] == 4'd11) begin // Mem Instruction
				//	$display("LD/STR Instr");
				//end

				//$display("Counter_mem:	%d  Counter_control: %d", counter_mem, counter_control);
				//$display("Changed Instr %b\n",t1.Instr_dout[15:12]);//,t1.Instr_dout[11:9],t1.Instr_dout[8:5],t1.Instr_dout[4:0]);
			end
		end
	endtask:run


endclass:generator 


//--------------------- Driver ---------------//
class driver;
	mailbox #(transactor) gen2driver;
	transactor t2;

	virtual LC3_io.TB inter;
	virtual wbProbe wbInter;

	

	function new(mailbox gen2driver, virtual LC3_io.TB inter, virtual wbProbe wbInter); 
		this.gen2driver = gen2driver;
		this.inter = inter;
		this.wbInter = wbInter;
	endfunction:new

	task run();
		t2 = new();
		gen2driver.get(t2);
		
		// Should send on posedge or not ??????
		//@(posedge inter.cb);
		inter.cb.Instr_dout <= t2.Instr_dout;
		inter.cb.Data_dout <= t2.Data_dout;
		inter.complete_data = t2.complete_data;
		inter.complete_instr = t2.complete_instr;		
	//	$display("Instr %b \n",t2.Instr_dout[15:12]);//,t2.Instr_dout[11:9],t2.Instr_dout[8:5],t2.Instr_dout[4:0]);
		//$display("\n");
	endtask:run

endclass:driver


//--------------------- Environment ---------------//
class environment;
	transactor t1;		
	mailbox #(transactor) m1;	
	generator g1;
	driver d1;

	decode decMonitor;
    	fetch fetchMonitor;
	writeback wbMonitor;
	memaccess memMonitor;
	execute execMonitor;
	control ctrlMonitor;

	int i;
	int n;

	virtual LC3_io.TB inter;
	virtual decProbe decInter;
	virtual fetchProbe fetchInter;
	virtual wbProbe wbInter;
	virtual memaccessProbe memInter;
	virtual execProbe execInter;
	virtual ctrlProbe ctrlInter;


	covergroup ALU_OPR_cg;

		Cov_alu_opcode: coverpoint decMonitor.IR[15:12] {
			bins ADD = {1};
			bins AND = {5};
			bins NOT = {9};
		}

		Cov_imm_en: coverpoint decMonitor.IR[5] iff ((decMonitor.IR[15:12] == 4'd1) || (decMonitor.IR[15:12] == 4'd5) || (decMonitor.IR[15:12] == 4'd9)) {
			bins Immediate_Enable = {1'd1};
		}	

		Cov_SR1: coverpoint decMonitor.IR[8:6] iff ((decMonitor.IR[15:12] == 4'd1) || (decMonitor.IR[15:12] == 4'd5) || (decMonitor.IR[15:12] == 4'd9));

		Cov_SR2: coverpoint decMonitor.IR[2:0] iff (((decMonitor.IR[15:12] == 4'd1) || (decMonitor.IR[15:12] == 4'd5)) && (decMonitor.IR[5] == 1'b0));

		Cov_DR: coverpoint decMonitor.IR[11:9] iff ((decMonitor.IR[15:12] == 4'd1) || (decMonitor.IR[15:12] == 4'd5) || (decMonitor.IR[15:12] == 4'd9));

		Cov_imm5: coverpoint decMonitor.IR[4:0] iff (((decMonitor.IR[15:12] == 4'd1) || (decMonitor.IR[15:12] == 4'd5)) && (decMonitor.IR[5] == 1'b1));

		Xc_opcode_imm_en: cross Cov_alu_opcode, Cov_imm_en;

		Xc_opcode_dr_sr1_imm5: cross Cov_alu_opcode, Cov_DR, Cov_SR1, Cov_imm5 {
			ignore_bins re = binsof (Cov_alu_opcode) intersect {4'd9};	
		}

		Xc_opcode_dr_sr1_sr2: cross Cov_alu_opcode, Cov_DR, Cov_SR1, Cov_SR2{
			ignore_bins re = binsof (Cov_alu_opcode) intersect {4'd9};	
		} 

		Cov_aluin1: coverpoint execMonitor.aluIn1  iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)) {
			option.auto_bin_max = 8;
		}

		Cov_aluin1_corner: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins allZero = {16'h0};
			bins allOne = {16'hffff};
			bins alt01 = {16'h5555};
			bins alt10 = {16'haaaa};
		}

		Cov_aluin2: coverpoint execMonitor.aluIn2 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			option.auto_bin_max = 8;
		}

		Cov_aluin2_corner: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins allZero = {16'h0};
			bins allOne = {16'hffff};
			bins alt01 = {16'h5555};
			bins alt10 = {16'haaaa};
		}

		Xc_opcode_aluin1: cross Cov_alu_opcode, Cov_aluin1_corner;

		Xc_opcode_aluin2: cross Cov_alu_opcode, Cov_aluin2_corner;

		Cov_aluin1_zero: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins all0 = {16'h0};		
		}
		
		Cov_aluin2_zero: coverpoint execMonitor.aluIn2 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins all0 = {16'h0};		
		}

		Cov_aluin1_all1: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins all1 = {16'hffff};		
		}
		
		Cov_aluin2_all1: coverpoint execMonitor.aluIn2 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins all1 = {16'hffff};		
		}

		Cov_aluin1_alt01: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins alt01 = {16'h5555};		
		}
		
		Cov_aluin2_alt01: coverpoint execMonitor.aluIn2 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins alt01 = {16'h5555};		
		}
		
		Cov_aluin1_alt10: coverpoint execMonitor.aluIn1 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins alt10 = {16'haaaa};		
		}
		
		Cov_aluin2_alt10: coverpoint execMonitor.aluIn2 iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			bins alt10 = {16'haaaa};		
		}


		Cov_opr_zero_zero: cross Cov_aluin1_zero,Cov_aluin2_zero {
			bins zero_zero = binsof(Cov_aluin1_zero) && binsof(Cov_aluin2_zero) ;	
		}

		Cov_opr_zero_all1: cross Cov_aluin1_zero,Cov_aluin2_all1 {
			bins zero_all1 = binsof(Cov_aluin1_zero) && binsof(Cov_aluin2_all1);		
		}  
	
		Cov_opr_all1_zero: cross Cov_aluin1_all1,Cov_aluin2_zero {
			bins all1_zero = binsof(Cov_aluin1_all1) && binsof(Cov_aluin2_zero);
		} 

		Cov_opr_all1_all1: cross Cov_aluin1_all1,Cov_aluin2_all1 {
			bins all1_all1 = binsof(Cov_aluin1_all1) && binsof(Cov_aluin2_all1);
		} 

		Cov_opr_alt01_alt01: cross Cov_aluin1_alt01,Cov_aluin2_alt01 {
			bins alt01_alt01 = binsof(Cov_aluin1_alt01) && binsof(Cov_aluin2_alt01);
		} 

		
		Cov_opr_alt01_alt10: cross Cov_aluin1_alt01,Cov_aluin2_alt10 {
			bins alt01_alt10 = binsof(Cov_aluin1_alt01) && binsof(Cov_aluin2_alt10) ;
		} 

		
		Cov_opr_alt10_alt01: cross Cov_aluin1_alt10,Cov_aluin2_alt01 {
			bins alt10_alt01 = binsof(Cov_aluin1_alt10) && binsof(Cov_aluin2_alt01) ;
		} 
		
		
		Cov_opr_alt10_alt10: cross Cov_aluin1_alt10,Cov_aluin2_alt10 {
			bins alt10_alt10 = binsof(Cov_aluin1_alt10) && binsof(Cov_aluin2_alt10) ;
		} 

		Cov_opr_aluin1_pos_neg: coverpoint execMonitor.aluIn1[15] iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			
			bins aluin1_pos = {1'b0};
			bins aluin1_neg = {1'b1}; 
		}

		Cov_opr_aluin2_pos_neg: coverpoint execMonitor.aluIn2[15] iff ((execInter.IR[15:12] == 4'd1) || (execInter.IR[15:12] == 4'd5) || (execInter.IR[15:12] == 4'd9)){
			
			bins aluin2_pos = {1'b0};
			bins aluin2_neg = {1'b1}; 
		}

		Cov_opr_pos_pos: cross Cov_opr_aluin1_pos_neg, Cov_opr_aluin2_pos_neg {
			
			bins pos_pos = binsof(Cov_opr_aluin1_pos_neg) intersect {1'b0} && binsof(Cov_opr_aluin2_pos_neg) intersect {1'b0}; 
		}   

		Cov_opr_pos_neg: cross Cov_opr_aluin1_pos_neg, Cov_opr_aluin2_pos_neg {
			
			bins pos_neg = binsof(Cov_opr_aluin1_pos_neg) intersect {1'b0} && binsof(Cov_opr_aluin2_pos_neg) intersect {1'b1}; 
		}   		

		Cov_opr_neg_pos: cross Cov_opr_aluin1_pos_neg, Cov_opr_aluin2_pos_neg {
			
			bins neg_pos = binsof(Cov_opr_aluin1_pos_neg) intersect {1'b1} && binsof(Cov_opr_aluin2_pos_neg) intersect {1'b0}; 
		}   		

		Cov_opr_neg_neg: cross Cov_opr_aluin1_pos_neg, Cov_opr_aluin2_pos_neg {
			
			bins neg_neg = binsof(Cov_opr_aluin1_pos_neg) intersect {1'b1} && binsof(Cov_opr_aluin2_pos_neg) intersect {1'b1}; 
		}  	
	
	endgroup:ALU_OPR_cg

	/*-------------------Control Covergroup----------------------*/
	covergroup CTRL_OPR_cg;

		Cov_ctrl_opcode:  coverpoint ctrlInter.IR_Exec[15:12] {
			bins BR = {0};
			bins JMP = {12};
		}

		Cov_BaseR : coverpoint ctrlInter.IR_Exec[8:6] iff ((ctrlInter.IR_Exec[15:12] == 4'd12)); // JMP

		Cov_NZP: coverpoint ctrlInter.NZP;

		Cov_PCoffset9: coverpoint ctrlInter.IR_Exec[8:0] iff((ctrlInter.IR_Exec[15:12] == 4'd0)); //BR
		
		Cov_PCoffset9_c: coverpoint ctrlInter.IR_Exec[8:0] iff((ctrlInter.IR_Exec[15:12] == 4'd0)){ //BR
			bins allzero = {9'h000};
			bins allone = {9'h1ff};
			bins alt01 = {9'h155};
			bins alt10 = {9'h0aa};	
		}		
		
		Cov_PSR: coverpoint ctrlInter.psr //iff ((ctrlInter.IR_Exec[15:12] == 4'd12))
		{
			ignore_bins NA = {0,3,5,6,7};
		}

		Xc_NZP_PSR: cross Cov_PSR, Cov_NZP ; 

	endgroup:CTRL_OPR_cg

/*------------------- Memory Covergroup --------------------*/	
	covergroup MEM_OPR_cg;

		Cov_mem_opcode: coverpoint ctrlInter.IMem_dout[15:12] {
			bins LD = {2};
			bins LDR = {6};
			bins LDI = {10};
			bins LEA = {14};
			bins ST = {3};	
			bins STR = {7};
			bins STI = {11};		
		}	

		Cov_BaseR : coverpoint ctrlInter.IMem_dout[8:6] iff ((ctrlInter.IMem_dout[15:12] == 4'd6) || (ctrlInter.IMem_dout[15:12] == 4'd7)); // LDR, STR

		Cov_SR : coverpoint ctrlInter.IMem_dout[11:9] iff ((ctrlInter.IMem_dout[15:12] == 4'd3) || (ctrlInter.IMem_dout[15:12] == 4'd7) || (ctrlInter.IMem_dout[15:12] == 4'd11)); // ST, STR, STI

		Cov_DR : coverpoint ctrlInter.IMem_dout[11:9] iff ((ctrlInter.IMem_dout[15:12] == 4'd2) || (ctrlInter.IMem_dout[15:12] == 4'd6) || (ctrlInter.IMem_dout[15:12] == 4'd10) || (ctrlInter.IMem_dout[15:12] == 4'd14)); // LD, LDI, LEA, LDR

		Cov_PCoffset9 : coverpoint ctrlInter.IMem_dout[8:0] iff ((ctrlInter.IMem_dout[15:12] == 4'd2) || (ctrlInter.IMem_dout[15:12] == 4'd3) || (ctrlInter.IMem_dout[15:12] == 4'd10) || (ctrlInter.IMem_dout[15:12] == 4'd14) || (ctrlInter.IMem_dout[15:12] == 4'd7))	{option.auto_bin_max = 8;} // LD, LDI, LEA, ST, STI

		Cov_PCoffset9_c : coverpoint ctrlInter.IMem_dout[8:0] iff ((ctrlInter.IMem_dout[15:12] == 4'd2) || (ctrlInter.IMem_dout[15:12] == 4'd3) || (ctrlInter.IMem_dout[15:12] == 4'd10) || (ctrlInter.IMem_dout[15:12] == 4'd14) || (ctrlInter.IMem_dout[15:12] == 4'd7)){ // LD, LDI, LEA, ST, STI
			bins allzero = {9'h000};
			bins allone = {9'h1ff};
			bins alt01 = {9'h155};
			bins alt10 = {9'h0aa};			
		}

		Cov_PCoffset6 : coverpoint ctrlInter.IMem_dout[5:0] iff ((ctrlInter.IMem_dout[15:12] == 4'd6) || (ctrlInter.IMem_dout[15:12] == 4'd7)){
			option.auto_bin_max = 8;
		} 					// LDR, STR

		Cov_PCoffset6_c : coverpoint ctrlInter.IMem_dout[5:0] iff ((ctrlInter.IMem_dout[15:12] == 4'd6) || (ctrlInter.IMem_dout[15:12] == 4'd7)){ // LDR, STR
			bins allzero = {6'h00};
			bins allone = {6'h3f};
			bins alt01 = {6'h15};
			bins alt10 = {6'h2a};	
		}

		Xc_BaseR_DR_offset6: cross Cov_BaseR, Cov_DR, Cov_PCoffset6;
	
		Xc_BaseR_SR_offset6: cross Cov_BaseR, Cov_SR, Cov_PCoffset6;

	endgroup: MEM_OPR_cg

/*-------------- Order of Instructions --------------*/

	covergroup OPR_SEQ_cg;

		Cov_inst_order: coverpoint ctrlInter.IMem_dout[15:12] {
			bins ALU_ALU = (1,5,9=>1,5,9);
			bins ALU_MEM = (1,5,9=>2,3,6,7,10,11,14);
			bins MEM_ALU = (2,3,6,7,10,11,14 => 1,5,9);
			bins ALU_CTRL = (1,5,9=>0,12);	
			bins CTRL_ALU = (0,12 => 1,5,9);
			
		}

	endgroup:OPR_SEQ_cg



	

	function new(virtual LC3_io.TB inter, virtual decProbe decInter, virtual fetchProbe fetchInter, virtual wbProbe wbInter, virtual memaccessProbe memInter, virtual execProbe execInter, virtual ctrlProbe ctrlInter);
		this.inter = inter;
		this.decInter = decInter;
		this.fetchInter = fetchInter;
		this.wbInter = wbInter;
		this.memInter = memInter;
		this.execInter = execInter;
		this.ctrlInter = ctrlInter;	

		ALU_OPR_cg = new();
		CTRL_OPR_cg = new();
		MEM_OPR_cg = new();
		OPR_SEQ_cg = new();
	endfunction:new

	task setup;
		t1 = new();
		m1 =  new(1);
		g1= new(m1);

		d1 = new(m1, inter, wbInter);

		decMonitor = new(decInter);
		fetchMonitor = new(fetchInter);
		wbMonitor = new(wbInter);
		memMonitor = new(memInter);
		execMonitor = new(execInter);
		ctrlMonitor = new(ctrlInter);	
	endtask:setup

	task run;
		g1.run();
		d1.run();	
	endtask:run

	task monitor_fetch;		
		//@(posedge inter.cb);
		//repeat (1) begin
			//fetchMonitor.setup();	
			//fetchMonitor.run();
			//fetchMonitor.print();
			//fetchMonitor.runPC();
			fetchMonitor.monitor_sync();
			//fetchMonitor.runPC();
		//end	
	endtask: monitor_fetch

	task debug;
		//$display("Values on wire\n");
		//$display("Instr %d %b %b %b\n",inter.cb.Instr_dout[15:12],inter.cb.Instr_dout[11:9],inter.cb.Instr_dout[8:5],inter.cb.Instr_dout[4:0]);
		//$display("\n");
		fetchMonitor.print();
	endtask:debug

	task monitor_decode;
		//decMonitor.setup_en();
		//@(posedge inter.cb)
		//repeat (1) begin
			//decMonitor.setup();
			//decMonitor.printInput();
			decMonitor.run();
			//decMonitor.printOutput();
			//decMonitor.monitor();
			//decMonitor.register();
		//end	

	endtask:monitor_decode

	task monitor_sync;
		decMonitor.monitor();
	endtask:monitor_sync

	task monitor_wb;
	//	wbMonitor.setup();
	//	wbMonitor.run();
		wbMonitor.run();
	//	wbMonitor.register();		
	endtask:monitor_wb

	task monitor_ma;
		//memMonitor.setup();
		//memMonitor.run();
		memMonitor.monitor();
	endtask:monitor_ma
		

endclass:environment

//-------------- TestBench -------------------//
program automatic testBench (LC3_io interTest, decProbe d1, fetchProbe f1, wbProbe wb1, memaccessProbe ma1, execProbe ex1, ctrlProbe c1);
	int n = 10;
	int i,count = 0;

	initial 
	begin
		//LC3_io interTest;
		environment e1;
		//transactor t1;
		//ALU_OPR_cg cg1;		
		//t1 = new();
		
		e1 = new (interTest.TB, d1, f1, wb1,ma1, ex1, c1);
		e1.n = n;
		e1.setup();
		//e1.g1.t1.ALU_OPR_cg cg1 = new();
		repeat(2)	begin
		interTest.reset = 1'b1;
		e1.monitor_fetch();
		repeat(10)	begin
			@(posedge interTest.cb) begin
				e1.fetchMonitor.run();
				e1.decMonitor.run();
				//e1.wbMonitor.setup(); //had to add because no data going to my golden model otherwise
				e1.wbMonitor.run();
				e1.memMonitor.run();
				e1.execMonitor.run();
				e1.ctrlMonitor.run();
			end
		end
		
		//#100 
		interTest.reset = 1'b0;
		e1.fetchMonitor.enable_updatePC = 1'b1;
		
		e1.run();

		//@(posedge interTest.cb); 
		repeat (e1.g1.numTest) begin
				//for (i=0;i<n;i++) 
				count = count + 1;
				if(interTest.instrmem_rd == 1'b1)	begin
					e1.run();
				end
				#1;
				//e1.d1.run();
				e1.fetchMonitor.run();
				e1.decMonitor.run();
				//e1.wbMonitor.setup(); //had to add because no data going to my golden model otherwise
				e1.wbMonitor.run();
				e1.memMonitor.run();
				e1.execMonitor.run();
				e1.ctrlMonitor.run();

				e1.ALU_OPR_cg.sample();
				e1.CTRL_OPR_cg.sample();
				e1.MEM_OPR_cg.sample();
				e1.OPR_SEQ_cg.sample();

				e1.fetchMonitor.monitor_async();
				//e1.monitor_ma();
				e1.memMonitor.monitor();
				e1.wbMonitor.monitor();	
				e1.execMonitor.monitor_async();
				e1.ctrlMonitor.monitor_async();
				e1.ctrlMonitor.monitor_sync(); 
				@(posedge interTest.cb);	
				begin
					e1.monitor_fetch();
					e1.decMonitor.monitor();

					//e1.wbMonitor.run_sync();					
					e1.wbMonitor.monitor_sync(); 
					e1.execMonitor.monitor_sync();
					
										
				end
				//#9;
			//e1.fetchMonitor.monitor();
		
				//e1.monitor_decode();
				//e1.monitor_wb();
				//e1.monitor_ma();
				//e1.debug();
			//join
				if(count == 10000) begin
					if((e1.ALU_OPR_cg.get_coverage() == 100) && (e1.CTRL_OPR_cg.get_coverage() == 100) && (e1.MEM_OPR_cg.get_coverage() == 100)) begin// && (e1.OPR_SEQ_cg.get_coverage() == 100))	begin				
						$display("COVERAGE MET !!");				
						$finish;
					end
					count = 0;
				end
		end
		end
		

	end
endprogram:testBench


//--------------- Top ------------------------//
module top;

	bit clock = 0;
	always #5 clock = ~clock;

	LC3_io interTest(clock);

	LC3 dut (.clock(clock), .reset(interTest.reset), .pc(interTest.pc), .instrmem_rd(interTest.instrmem_rd), .Instr_dout(interTest.Instr_dout), .Data_addr(interTest.Data_addr), .complete_instr(interTest.complete_instr), .complete_data(interTest.complete_data), .Data_din(interTest.Data_din), .Data_dout(interTest.Data_dout), .Data_rd(interTest.Data_rd));

	decProbe d1 ( .clock(clock), .Instr_dout(dut.Dec.dout), .npc_in(dut.Dec.npc_in), .enable_decode(dut.Dec.enable_decode), .IR(dut.Dec.IR), .npc_out(dut.Dec.npc_out), .E_control(dut.Dec.E_Control), .W_control(dut.Dec.W_Control), .Mem_control(dut.Dec.Mem_Control), .reset(dut.Dec.reset));

	fetchProbe f1 (.clock(clock), .enable_updatePC(dut.Fetch.enable_updatePC), .enable_fetch(dut.Fetch.enable_fetch), .br_taken(dut.Fetch.br_taken), .taddr(dut.Fetch.taddr), .instrmem_rd(dut.Fetch.instrmem_rd), .pc(dut.Fetch.pc), .npc_out(dut.Fetch.npc_out), .reset(dut.Fetch.reset));

	wbProbe wb1 ( .clock(clock),.reset(dut.WB.reset), .npc_in(dut.WB.npc), .W_control_in(dut.WB.W_Control), .aluout(dut.WB.aluout), .pcout(dut.WB.pcout), .memout(dut.WB.memout), .enable_writeback(dut.WB.enable_writeback), .src1(dut.WB.sr1), .src2(dut.WB.sr2), .dr(dut.WB.dr), .vsr1(dut.WB.d1), .vsr2(dut.WB.d2),  .psr(dut.WB.psr));

	memaccessProbe ma1 ( .reset(dut.reset), .M_data(dut.MemAccess.M_Data), .M_addr(dut.MemAccess.M_Addr), .M_control(dut.MemAccess.M_Control), .mem_state(dut.MemAccess.mem_state), .Dmem_dout(dut.MemAccess.Data_dout), .Dmem_addr(dut.MemAccess.Data_addr), .Dmem_din(dut.MemAccess.Data_din), .Dmem_rd(dut.MemAccess.Data_rd), .memout(dut.MemAccess.memout));

	execProbe ex1 ( .clock(clock), .reset(dut.Ex.reset), .E_control(dut.Ex.E_Control), .IR(dut.Ex.IR), .npc_in(dut.Ex.npc), .bypass_alu_1(dut.Ex.bypass_alu_1), .bypass_alu_2(dut.Ex.bypass_alu_2), .bypass_mem_1(dut.Ex.bypass_mem_1), .bypass_mem_2(dut.Ex.bypass_mem_2), .VSR1(dut.Ex.VSR1), .VSR2(dut.Ex.VSR2), .W_Control_in(dut.Ex.W_Control_in), .Mem_Control_in(dut.Ex.Mem_Control_in), .enable_execute(dut.Ex.enable_execute), .Mem_Bypass_Val(dut.Ex.Mem_Bypass_Val), .W_Control_out(dut.Ex.W_Control_out), .Mem_Control_out(dut.Ex.Mem_Control_out), .aluout(dut.Ex.aluout), .pcout(dut.Ex.pcout), .dr(dut.Ex.dr), .sr1(dut.Ex.sr1), .sr2(dut.Ex.sr2), .IR_Exec(dut.Ex.IR_Exec), .NZP(dut.Ex.NZP), .M_Data(dut.Ex.M_Data));


	ctrlProbe c1 (.clock(clock), .reset(dut.reset), .complete_data(dut.Ctrl.complete_data), .complete_instruction(dut.Ctrl.complete_instr), .IR(dut.Ctrl.IR), .psr(dut.Ctrl.psr), .IR_Exec(dut.Ctrl.IR_Exec), .IMem_dout(dut.Ctrl.Instr_dout),.NZP(dut.Ctrl.NZP) , .enable_updatePC(dut.Ctrl.enable_updatePC) , .enable_fetch (dut.Ctrl.enable_fetch) , .enable_decode(dut.Ctrl.enable_decode) , .enable_execute (dut.Ctrl.enable_execute) , .enable_writeback(dut.Ctrl.enable_writeback) , .bypass_alu_1(dut.Ctrl.bypass_alu_1) , .bypass_alu_2(dut.Ctrl.bypass_alu_2), .bypass_mem_1(dut.Ctrl.bypass_mem_1) , .bypass_mem_2(dut.Ctrl.bypass_mem_2) , .mem_state(dut.Ctrl.mem_state) , .br_taken(dut.Ctrl.br_taken));	


	testBench t1 (interTest, d1, f1, wb1, ma1, ex1, c1);

endmodule:top
