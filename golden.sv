package golden;

//------------ Fetch Block ------------------//
	class fetch;
	
		//Inputs

		//bit clock;    //Can do logic here too 
		logic reset;
		logic br_taken;
		logic [15:0] taddr;
		logic enable_updatePC;
		logic enable_fetch;
		logic [15:0] pcBuffer;
		logic enableBuffer;
		//logic [15:0] first_mux;
		
		//Outputs

		logic instrmem_rd;
		logic [15:0] pc;
		logic [15:0] npc;

		logic [15:0] first_mux,second_mux;
	
		virtual fetchProbe fetchInter;

		bit flag;

		function new(virtual fetchProbe fetchInter);
			this.fetchInter = fetchInter;
			npc = 16'h3001;
			pc = 16'h3000;
			flag = 0;
		endfunction:new

		task run();
			if(fetchInter.reset)
			begin
				npc = 16'h3001;
				pc = 16'h3000;
			end
			else
			begin
				//if (flag == 0) begin
				//	pc = npc;
				//	flag = 1;
				//end

				if(fetchInter.br_taken == 1) begin
					first_mux = fetchInter.taddr;
				end
				else	begin
					first_mux = npc;
				end

				if (fetchInter.enable_updatePC == 1) begin
					second_mux = first_mux;

				end
				else begin
					second_mux = pc;
				end
				pc = second_mux;
				npc = pc + 1;

				/*if (fetchInter.enable_updatePC == 1) begin
					pc = npc;
					//flag = 1;
				end

				npc = pc + 1;

				if(fetchInter.br_taken == 1 )
				begin
					pc = fetchInter.taddr;		
				end
				*/
				
			end
			if(fetchInter.enable_fetch == 1)
				begin
					instrmem_rd = 1'b1;
				end
				else
				begin
					instrmem_rd = 1'b0;
				end
		endtask:run

		task print();
			$display("Signal	Class	Interface",$time);
			//$display("%h Reset", reset);
			$display("PC	%h	%h",pcBuffer, fetchInter.pc);
			$display("NPC	%h	%h",npc,fetchInter.npc_out);
			$display("Update	%h	%h",enable_updatePC, fetchInter.enable_updatePC);
			$display("Br	%h	%h",br_taken,fetchInter.br_taken);
			//$display("%h Instrmem_rd",instrmem_rd);
			//$display("%h TADDR",taddr);
			//$display("%h First MUX",first_mux);
			//$display("%h br_taken",br_taken);
			//$display("%h enable PC", enable_updatePC);
			//$display("%h enable PC from DUT", fetchInter.enable_updatePC);
			$display("----------------------------------\n");
			
		endtask:print

		task runPC;
			pcBuffer = pc;
		endtask:runPC

		task setup();
			taddr = fetchInter.taddr;
			br_taken = fetchInter.br_taken;
			enable_fetch = fetchInter.enable_fetch;
			reset = fetchInter.reset;
			//enableBuffer = fetchInter.enable_updatePC;
			enable_updatePC = fetchInter.enable_updatePC;
		endtask:setup			
		
		task monitor_async();
			if(instrmem_rd != fetchInter.instrmem_rd)
				$display($time, " Fail instrmem_rd DUT [%h] testBench [%h]", fetchInter.instrmem_rd, instrmem_rd);
			
		endtask:monitor_async;
		
		task monitor_sync();
			//$display("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
			//if (fetchInter.enable_updatePC == 1) begin
				if(pc != fetchInter.pc) begin
					$display($time, " Fail pc DUT [%h] testBench [%h]",fetchInter.pc,pc);
				end
				if(npc != fetchInter.npc_out)begin
					$display($time, " Fail npc_out DUT [%h] testBench [%h]",fetchInter.npc_out,npc);
				end
				//else 
					//$display("PASS pc DUT [%h] testBench [%h]",fetchInter.pc,pcBuffer);
				//$display("------------------------------------------------------------------");
				//if((pcBuffer+1) != fetchInter.npc_out)begin
				//	$display("Fail npc_out DUT [%h] testBench [%h]",fetchInter.npc_out,npc);
				//end
				//			$display("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");

				//if(instrmem_rd != fetchInter.instrmem_rd)
				//	$display("Fail instrmem_rd");
			//end

		endtask: monitor_sync	

	endclass:fetch

//-------------- Decode Block ----------------//
	class decode;
		
		logic decode_Buffer;

	// Input Pins
		bit          reset;
		logic [15:0] npc_in;
		logic        enable_decode;
		logic [15:0] Instr_dout;
		logic [2:0]  psr;

	// Output Pins
		logic [15:0] IR;
		logic [5:0]  E_control;
		logic [15:0] npc_out;
		logic        Mem_control;
		logic [1:0]  W_control;

	// Reg pins
		logic [15:0] IR_reg;
		logic [5:0]  E_control_reg;
		logic [15:0] npc_out_reg;
		logic        Mem_control_reg;
		logic [1:0]  W_control_reg;
	

		virtual decProbe decInter;
	
		function new(virtual decProbe decInter);
			this.decInter = decInter;
				IR = 16'h0;
				E_control = 6'h0;
				npc_out = 16'h0;
				Mem_control = 1'h0;
				W_control = 2'h0;
		endfunction:new

		task setup;
			reset = decInter.reset;
			npc_in = decInter.npc_in;
			//enable_decode = decInter.enable_decode;
			Instr_dout = decInter.Instr_dout;
			enable_decode = decInter.enable_decode;
		endtask:setup
		
		/*task setup_en;
			enable_decode = decInter.enable_decode;
		endtask:setup_en*/

		task printInput;
			$display("Reset:				%0h",reset);
			$display("npc_in:				%0h",npc_in);
			$display("enable_decode:		%0h",enable_decode);
			$display("Instr_dout:			%0h",Instr_dout);
		endtask:printInput

		task printOutput;
			$display("IR:					%0h",IR);
			$display("npc_out				%0h",npc_out);
			$display("Mem_control			%0h",Mem_control);
			$display("E_control				%0h",E_control);
			$display("W_control				%0h",W_control);

		endtask:printOutput
	
		task monitor;

			//$display("//--------------- Decode Block ----------------//\n");			
			if (IR != decInter.IR)begin
				$display($time, " Failed at Decode IR testBench [%0h] DUT [%0h]", IR, decInter.IR);
			end
			//else	begin
			//	$display("Passed at Decode IR testBench [%0h] DUT [%0h]", IR, decInter.IR);
			//end

			if (E_control != decInter.E_control)begin
				$display($time, " Failed at Decode E_control testBench [%0h] DUT [%0h]", E_control, decInter.E_control);
			end
			//else	begin
			//	$display("Passed at Decode E_control testBench [%0h] DUT [%0h]", E_control, decInter.E_control);
			//end

			if (npc_out != decInter.npc_out)begin
				$display($time, " Failed at Decode npc_out testBench [%0h] DUT [%0h]", npc_out, decInter.npc_out);
			end
			//else	begin
			//	$display("Passed at Decode npc_out testBench [%0h] DUT [%0h]", npc_out, decInter.npc_out);
			//end

			if (Mem_control != decInter.Mem_control)begin
				$display($time, " Failed at Decode Mem_control testBench [%0h] DUT [%0h]", Mem_control, decInter.Mem_control);
			end
			//else	begin
			//	$display("Passed at Decode Mem_control testBench [%0h] DUT [%0h]", Mem_control, decInter.Mem_control);
			//end

			if (W_control != decInter.W_control)begin
				$display($time, " Failed at Decode W_control testBench [%0h] DUT [%0h]", W_control, decInter.W_control);
			end
			//else	begin
			//	$display("Passed at Decode W_control testBench [%0h] DUT [%0h]", W_control, decInter.W_control);
			//end
			//$display("//---------------------------------------------------//\n");


		endtask:monitor

		task register;
			IR_reg = IR;
			E_control_reg = E_control;
			npc_out_reg = npc_out;
			Mem_control_reg = Mem_control;
			W_control_reg = W_control;
			decode_Buffer = enable_decode;
		endtask:register

		task run;

			// All outputs created when enable_decode is one
			if (decInter.reset == 1) begin
				IR = 16'h0;
				E_control = 6'h0;
				npc_out = 16'h0;
				Mem_control = 1'h0;
				W_control = 2'h0;
			end

			else begin
				if (decInter.enable_decode == 1'b1) begin

					//npc_out = npc_in;
					IR = decInter.Instr_dout;
					npc_out = decInter.npc_in;
					//--------------W_control E_control Mem_control SIGNAL -------------//
					// ADD with reg
					if ((decInter.Instr_dout [15:12] == 4'b0001) && (decInter.Instr_dout [5] == 1'b0)) begin
						W_control = 2'd0;

						E_control [5:4] = 2'd0;
						E_control [3:2] = 2'h0;
						E_control [1] = 1'h0;
						E_control [0] = 1'd1;

						Mem_control = 1'h0;
					end

					// ADD with imm
					if ((decInter.Instr_dout [15:12] == 4'b0001) && (decInter.Instr_dout [5] == 1'b1)) begin
						W_control = 2'd0;				
	
						E_control [5:4] = 2'd0;
						E_control [3:2] = 2'h0;
						E_control [1] = 1'h0;
						E_control [0] = 1'd0;

						Mem_control = 1'h0;
					end

					// AND with reg
					if ((decInter.Instr_dout [15:12] == 4'b0101) && (decInter.Instr_dout [5] == 1'b0)) begin
						W_control = 2'd0;				
	
						E_control [5:4] = 2'd1;
						E_control [3:2] = 2'h0;
						E_control [1] = 1'h0;
						E_control [0] = 1'd1;

						Mem_control = 1'h0;
					end

					// AND with imm
					if ((decInter.Instr_dout [15:12] == 4'b0101) && (decInter.Instr_dout [5] == 1'b1)) begin
						W_control = 2'd0;

						E_control [5:4] = 2'd1;
						E_control [3:2] = 2'h0;
						E_control [1] = 1'h0;
						E_control [0] = 1'd0;

						Mem_control = 1'h0;
					end
	
					// NOT 
					if ( decInter.Instr_dout [15:12] == 4'b1001 ) begin
						W_control = 2'd0;				
	
						E_control [5:4] = 2'd2;
						E_control [3:2] = 2'h0;
						E_control [1] = 1'h0;
						E_control [0] = 1'h0;

						Mem_control = 1'h0;
					end

					// Br
					if ( decInter.Instr_dout [15:12] == 4'b0000 ) begin
						W_control = 2'd0;				

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'h0;
					end

					//JMP
					if ( decInter.Instr_dout [15:12] == 4'b1100 ) begin
						W_control = 2'd0;				
	
						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd3;
						E_control [1] = 1'd0;
						E_control [0] = 1'h0;

						Mem_control = 1'h0;
					end

					//LD
					if ( decInter.Instr_dout [15:12] == 4'b0010 ) begin
						W_control = 2'd1;

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'd0;
					end

					//LDR
					if ( decInter.Instr_dout [15:12] == 4'b0110 ) begin
						W_control = 2'd1;

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd2;
						E_control [1] = 1'd0;
						E_control [0] = 1'h0;

						Mem_control = 1'd0;
					end

					//LDI
					if ( decInter.Instr_dout [15:12] == 4'b1010 ) begin
						W_control = 2'd1;				
		
						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'd1;
					end

					//LEA
					if ( decInter.Instr_dout [15:12] == 4'b1110 ) begin
						W_control = 2'd2;			
	
						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'h0;
					end

					//ST
					if ( decInter.Instr_dout [15:12] == 4'b0011 ) begin
						W_control = 2'd0;

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'd0;
					end

					//STR
					if ( decInter.Instr_dout [15:12] == 4'b0111 ) begin
						W_control = 2'd0;

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd2;
						E_control [1] = 1'd0;
						E_control [0] = 1'h0;

						Mem_control = 1'd0;
					end

					//STI
					if (decInter.Instr_dout [15:12] == 4'b1011 ) begin
						W_control = 2'd0;

						E_control [5:4] = 2'h0;
						E_control [3:2] = 2'd1;
						E_control [1] = 1'd1;
						E_control [0] = 1'h0;

						Mem_control = 1'd1;
					end

			
				end
			//	if (enable_decode == 1'b1) begin

			//		npc_out = npc_in;
					//IR = Instr_dout;
			//	end

			end		

		endtask:run
	

	endclass:decode

//---------------------Writeback Block---------------------//
class writeback;
		
		//Inputs

		bit          reset;
		logic [15:0] npc_in;
		logic [1:0]  W_control_in;
		logic [15:0] aluout;
		logic [15:0] pcout;
		logic [15:0] memout;
		logic enable_writeback;
		logic [2:0] src1,src2;
		logic [2:0] dr, dr_reg;

		//Outputs
		
		logic [15:0] vsr1, vsr2;
		logic [2:0]  psr;

		//Register File
		logic [15:0] regfile [0:7];
		logic [15:0] DR_in, DR_in_reg;

		logic [2:0] psr_reg;

		int i;

		bit flag;
	
		virtual wbProbe wbInter;
	
		function new(virtual wbProbe wbInter);
			this.wbInter = wbInter;
				//vsr1 = 16'h0;
				//vsr2 = 16'h0;
				psr = 3'b0;
				foreach (regfile[i]);
					regfile[i] = 16'hx;
		endfunction:new

		task setup;
			reset = wbInter.reset;
			npc_in = wbInter.npc_in;
			W_control_in = wbInter.W_control_in;		
			enable_writeback = wbInter.enable_writeback;
			aluout = wbInter.aluout;
			pcout = wbInter.pcout;
			memout = wbInter.memout;
			src1 = wbInter.src1;
			src2 = wbInter.src2;
			dr = wbInter.dr;			
		endtask:setup
		

		task run;

			// All outputs created when enable_decode is one
			if (wbInter.reset == 1) begin
				//Commented because TA said not to init in reset because it is asynchronous				
				//vsr1 = 16'h0;
				//vsr2 = 16'h0;
				psr = 3'b0;
			end 
			else
			begin
				vsr1 = regfile[wbInter.src1];
				vsr2 = regfile[wbInter.src2];	


				if(wbInter.W_control_in == 2'b00)
					DR_in = wbInter.aluout;
				else if (wbInter.W_control_in == 2'b01)
					DR_in = wbInter.memout;
				else if (wbInter.W_control_in == 2'b10)
					DR_in = wbInter.pcout;
			
				/*if (wbInter.enable_writeback == 1)
				begin
				
				end*/
				
				if (wbInter.enable_writeback == 1) begin
					flag = $isunknown(DR_in);
					if (flag == 1'b1)	begin
						if (DR_in[15] == 1'b1)
							psr = 3'd4;
						else if ((DR_in[15] == 1'b0 && DR_in != 16'h0) && (DR_in[15:12] == 1'b1 || DR_in[11:8] == 1'b1 || DR_in[7:4] == 1'b1) || DR_in[3:0] == 1'b1)
							psr = 3'd1;
						else
							psr = 3'd2;

					end
					else begin
						//if (DR_in[15] !== 1'bx) begin
							if (DR_in[15] == 1'b1)
								psr = 3'd4;
							if (DR_in[15] == 1'b0 && DR_in != 16'h0)
								psr = 3'd1;
							if (DR_in == 16'h0)
								psr = 3'd2;
						//end
					end
					regfile[wbInter.dr] = DR_in;
				end



			end
		endtask: run
	

		task run_sync;
			if (wbInter.reset == 0) begin
				if (wbInter.enable_writeback == 1)
					begin
						regfile[wbInter.dr] = DR_in;				
					end
			end
		endtask: run_sync
		
		task monitor_sync;
			if (psr != wbInter.psr)begin
				$display($time," Failed at Writeback psr testBench [%0h] DUT [%0h]", psr, wbInter.psr);
			end
			//else
			//	$display($time,"Passed at Writeback psr testBench [%0h] DUT [%0h]", psr, wbInter.psr);
		endtask: monitor_sync

		task monitor;
		//$display("//--------------- Writeback Block ----------------//\n");			
			if ( vsr1 != wbInter.vsr1)begin
				$display($time," Failed at Writeback vsr1 testBench [%0h] DUT [%0h]", vsr1, wbInter.vsr1);
				$display($time, " WB SR1 TB [%0h] REGFILE [%0h]  ",wbInter.src2,regfile[wbInter.src2]);
			end
			//else
			//	$display("Passed at Writeback vsr1 testBench [%0h] DUT [%0h]", vsr1, wbInter.vsr1);

			if (vsr2 != wbInter.vsr2)begin
				$display($time," Failed at Writeback vsr2 testBench [%0h] DUT [%0h]", vsr2, wbInter.vsr2);
			end
			//else
			//	$display($time,"Passed at Writeback vsr2 testBench [%0h] DUT [%0h]", vsr2, wbInter.vsr2);
						//$display("//---------------------------------------------------//\n");

		endtask:monitor

		task register;
			psr_reg = psr;
			DR_in_reg = DR_in;
			dr_reg = dr;
		endtask:register

			
endclass: writeback


//----------MEMACESS---BLOCK---------------

	class memaccess;

		logic reset;

	// Input PINS

		logic [15:0] M_data;
		logic [15:0] M_addr;
		logic M_control;
		logic [1:0] mem_state;
		logic [15:0] Dmem_dout;
	
	// Output PINS
		logic [15:0] Dmem_addr;
		logic [15:0] Dmem_din;
		logic Dmem_rd;
		logic [15:0] memout;

		virtual memaccessProbe memaccessInter;
	
		function new(virtual memaccessProbe memaccessInter);
			this.memaccessInter = memaccessInter;
				Dmem_rd = 1'bz;
				Dmem_din = 16'bz;
				Dmem_addr = 16'bz;
				memout = 16'bz;
		endfunction:new

		task setup;
				M_data = memaccessInter.M_data;
				M_addr = memaccessInter.M_addr;
				M_control = memaccessInter.M_control;
				mem_state = memaccessInter.mem_state;
				Dmem_dout = memaccessInter.Dmem_dout;
				reset = memaccessInter.reset;
		endtask:setup

		task monitor;

			//$display("//--------------- MemAccess Block ----------------//\n");			
			if (Dmem_rd != memaccessInter.Dmem_rd)begin
				$display($time," Failed at Memaccess Dmem_rd testBench [%0h] DUT [%0h]", Dmem_rd, memaccessInter.Dmem_rd);
			end
			//else 
			//	$display("Passed at Memaccess Dmem_rd testBench [%0h] DUT [%0h]", Dmem_rd, memaccessInter.Dmem_rd);

			if (Dmem_din != memaccessInter.Dmem_din)begin
				$display($time," Failed at Memaccess Dmem_din testBench [%0h] DUT [%0h]",  Dmem_din, memaccessInter.Dmem_din);
			end
			//else
			//	$display("Passed at Memaccess Dmem_din testBench [%0h] DUT [%0h]",  Dmem_din, memaccessInter.Dmem_din);

			if (Dmem_addr != memaccessInter.Dmem_addr)begin
				$display($time," Failed at Memaccess Dmem_addr testBench [%0h] DUT [%0h]",  Dmem_addr, memaccessInter.Dmem_addr);
			end
			//else
			//	$display("Passed at Memaccess Dmem_addr testBench [%0h] DUT [%0h]",  Dmem_addr, memaccessInter.Dmem_addr);
				
			if (memout != memaccessInter.memout)begin
				$display($time," Failed at Memaccess memout testBench [%0h] DUT [%0h]",  memout, memaccessInter.memout);
			end
			//else
			//	$display("Passed at Memaccess memout testBench [%0h] DUT [%0h]",  memout, memaccessInter.memout);
			//$display("//---------------------------------------------------//\n");


		endtask:monitor

		task run;
		   /*if(memaccessInter.reset == 1'b1)	begin
				Dmem_rd = 1'bz;
				Dmem_din = 16'bz;
				Dmem_addr = 16'bz;
				memout = 16'bz;
		   end	
		   else begin*/		
				if(memaccessInter.mem_state == 2'd3) begin
					Dmem_rd = 1'bz;
					Dmem_din = 16'bz;
					Dmem_addr = 16'bz;
					memout = memaccessInter.Dmem_dout;
				end

				if(memaccessInter.mem_state == 2'd2) begin
					Dmem_rd = 1'b0;
					Dmem_din = memaccessInter.M_data;
					if(memaccessInter.M_control == 1'b1)	begin
						Dmem_addr = memaccessInter.Dmem_dout;
					end
					else	begin
						Dmem_addr = memaccessInter.M_addr;
					end
					memout = memaccessInter.Dmem_dout;
			
				end

				if(memaccessInter.mem_state == 2'd1) begin
					Dmem_rd = 1'b1;
					Dmem_din = 16'b0;
					Dmem_addr = memaccessInter.M_addr;
					memout = memaccessInter.Dmem_dout;
				end

				if(memaccessInter.mem_state == 2'd0) begin
					Dmem_rd = 1'b1;
					Dmem_din = 16'b0;
					memout = memaccessInter.Dmem_dout;
					if(memaccessInter.M_control == 1'b1)	begin
						Dmem_addr = memaccessInter.Dmem_dout;
					end
					else	begin
						Dmem_addr = memaccessInter.M_addr;
					end
				end
		 //end
		endtask

	endclass:memaccess

//------------------- Execute Block ------------------//
	class execute;

	//Outputs
	logic [1:0] W_Control_out;
	logic 	    Mem_Control_out;
	logic [15:0] aluout;
	logic [15:0] pcout;
	logic [2:0] dr;
	logic [2:0] sr1, sr2;
	logic [15:0] IR_Exec;
	logic [2:0] NZP;
	logic [15:0] M_Data;

	// temp Variable
	logic [15:0] aluIn1, aluIn2;
	logic [15:0] pcIn1, pcIn2;

	virtual execProbe execInter;
	
	function new (virtual execProbe execInter);
		this.execInter = execInter;
	endfunction:new

	task run();
		if (execInter.reset == 1'b1) begin
			W_Control_out = 2'd0;
			Mem_Control_out = 1'd0;
			aluout = 16'd0;
			pcout = 16'd0;
			dr = 3'd0;
			sr1 = 3'd0;
			sr2 = 3'd0;
			IR_Exec = 16'd0;
			NZP = 3'd0;
			M_Data = 16'd0;
			//$display("HERE NEW");
		end

		else begin

			sr1 = execInter.IR[8:6];
			if (execInter.IR[15:12] == 4'd3 || execInter.IR[15:12] == 4'd7 || execInter.IR[15:12] == 4'd11)
					sr2 = execInter.IR[11:9];

			else if (execInter.IR[15:12] == 4'd1) //&& execInter.IR[5] == 1'b0)
				sr2 = execInter.IR[2:0];

			else if (execInter.IR[15:12] == 4'd5 )//&& execInter.IR[5] == 1'b0)
				sr2 = execInter.IR[2:0];
			else if (execInter.IR[15:12] == 4'd9)
				sr2 = execInter.IR[2:0];
			else
				sr2 = 3'd0;

			if (execInter.enable_execute == 1'b1) begin
		//----------------------- aluIn1 -----------------------------//	
				if (execInter.bypass_alu_1 == 1'b1)
					aluIn1 =  execInter.aluout;

				else if (execInter.bypass_mem_1 == 1'b1)
					aluIn1 = execInter.Mem_Bypass_Val;

				else 
					aluIn1 = execInter.VSR1;
						

		//----------------------- aluIn2 -----------------------------//
				if (execInter.bypass_alu_2 == 1'b1)
					aluIn2 = execInter.aluout;

				else if (execInter.bypass_mem_2 == 1'b1)
					aluIn2 = execInter.Mem_Bypass_Val;

				else if (execInter.IR[5] == 1'b0)
					aluIn2 = execInter.VSR2;

				else if (execInter.IR[5] == 1'b1)
					aluIn2 = {{11{execInter.IR[4]}}, execInter.IR[4:0]};

		//------------------- pcIn1 ------------------------//
				if (execInter.E_control[3:2] == 2'b11)
					pcIn1 = 16'h0;

				else if (execInter.E_control[3:2] == 2'b10)
					pcIn1 = {{10{execInter.IR[5]}}, execInter.IR[5:0]};

				else if (execInter.E_control[3:2] == 2'b01)
					pcIn1 = {{7{execInter.IR[8]}}, execInter.IR[8:0]};

				else if (execInter.E_control[3:2] == 2'b00)
					pcIn1 = {{5{execInter.IR}}, execInter.IR[10:0]};

		//------------------ pcIn2 -------------------------//
				if (execInter.E_control[1] == 1'b1)
					pcIn2 = execInter.npc_in;
				else if (execInter.E_control[1] == 1'b0)
					pcIn2 = aluIn1;			


		



				
				if(execInter.IR[15:12] == 4'd0 || execInter.IR[15:12] == 4'd12 || execInter.IR[15:12] == 4'd2 ||  execInter.IR[15:12] == 4'd6 || execInter.IR[15:12] == 4'd10 || execInter.IR[15:12] == 4'd14 || execInter.IR[15:12] == 4'd3 || execInter.IR[15:12] == 4'd7 || execInter.IR[15:12] == 4'd11)	begin
					//------------------- pcOut -----------------------//
					if (execInter.IR[15:12] == 4'b0110 || execInter.IR[15:12] == 4'b0111 || execInter.IR[15:12] == 4'b1100)
						pcout = pcIn1 + pcIn2;

					//else if (execInter.IR[15:12] == 4'd1 || execInter.IR[15:12] == 4'd5 || execInter.IR[15:12] == 4'd9) // Not Sure .........
					//	pcout = aluout;

					else
						pcout = pcIn1 + pcIn2 - 1;
					aluout = pcout;
				end
				else begin			
						//------------------- aluOut -------------------------//
								if (execInter.E_control[5:4] == 2'b00)
									aluout = aluIn1 + aluIn2;

								else if (execInter.E_control[5:4] == 2'b01)
									aluout = aluIn1 & aluIn2;

								else if (execInter.E_control[5:4] == 2'b10)
									aluout = ~aluIn1;
								if (execInter.IR[15:12] == 4'd1 || execInter.IR[15:12] == 4'd5 || execInter.IR[15:12] == 4'd9) // Not Sure .........
									pcout = aluout;
								
				end

		//----------------- sr1, sr2, dr ------------------//
			//	sr1 = execInter.IR[8:6];
			
				if (execInter.IR[15:12] == 4'd0 || execInter.IR[15:12] == 4'd12 || execInter.IR[15:12] == 4'd3 || execInter.IR[15:12] == 4'd7 || execInter.IR[15:12] == 4'd11)
					dr = 3'd0;
				else
					dr = execInter.IR[11:9];

			/*	if (execInter.IR[15:12] == 4'd3 || execInter.IR[15:12] == 4'd7 || execInter.IR[15:12] == 4'd11)
					sr2 = execInter.IR[11:9];

				else if (execInter.IR[15:12] == 4'd1 && execInter.IR[5] == 1'b0)
					sr2 = execInter.IR[2:0];

				else if (execInter.IR[15:12] == 4'd5 && execInter.IR[5] == 1'b0)
					sr2 = execInter.IR[2:0];
				else
					sr2 = 3'd0;*/

		//--------------- Misc -------------------------//
				W_Control_out = execInter.W_Control_in;
				Mem_Control_out = execInter.Mem_Control_in;
				M_Data = execInter.VSR2;

				if (execInter.bypass_alu_2 == 1'b1)
					M_Data = aluIn2;

				IR_Exec = execInter.IR;


				if (execInter.IR[15:12] == 4'd0)
					NZP = execInter.IR[11:9];

				else if (execInter.IR[15:12] == 4'd12)
					NZP = 3'b111;

				else
					NZP = 3'b000;
			
			end
			else	begin
				NZP = 3'd0;
			end
		end			

	endtask:run

	task monitor_async();
		
		if (sr1 != execInter.sr1)
			$display($time," Failed at Execute sr1 testBench [%0h] DUT [%0h]", sr1, execInter.sr1);

		if (sr2 != execInter.sr2)
			$display($time," Failed at Execute sr2 testBench [%0h] DUT [%0h]", sr2, execInter.sr2);

			
		
	endtask:monitor_async

	task monitor_sync();

		if (aluout != execInter.aluout)
			$display($time," Failed at Execute aluout testBench [%0h] DUT [%0h]", aluout, execInter.aluout);

		if (pcout != execInter.pcout)
			$display($time," Failed at Execute pcout testBench [%0h] DUT [%0h]", pcout, execInter.pcout);

		if (dr != execInter.dr)
			$display($time," Failed at Execute dr testBench [%0h] DUT [%0h]", dr, execInter.dr);

		if (IR_Exec != execInter.IR_Exec)
			$display($time," Failed at Execute IR_Exec testBench [%0h] DUT [%0h]", IR_Exec, execInter.IR_Exec);

		if (NZP != execInter.NZP)
			$display($time," Failed at Execute NZP testBench [%0h] DUT [%0h]", NZP, execInter.NZP);

		if (M_Data != execInter.M_Data)
			$display($time," Failed at Execute M_Data testBench [%0h] DUT [%0h]", M_Data, execInter.M_Data);

		if (W_Control_out != execInter.W_Control_out)
			$display($time," Failed at Execute W_Control_out testBench [%0h] DUT [%0h]", W_Control_out, execInter.W_Control_out);

		if (Mem_Control_out != execInter.Mem_Control_out)
			$display($time," Failed at Execute Mem_Control_out testBench [%0h] DUT [%0h]", Mem_Control_out, execInter.Mem_Control_out);	

	endtask:monitor_sync




	endclass:execute 


	
	class control;

		//Outputs
		logic enable_updatePC;
		logic enable_fetch;
		logic enable_decode;
		logic enable_execute;
		logic enable_writeback;
		logic bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2;
		logic [1:0] mem_state;
		logic br_taken;


		virtual ctrlProbe ctrlInter;
	
		logic [1:0] mem_hold;

		/** counters **/
		logic flag,flag2;
		logic [2:0] rst_cntr;
		logic [2:0] LD_cntr;
		logic [2:0] ST_cntr;
		logic [2:0] LDI_cntr;
		int STI_cntr;
		logic [3:0] BR_cntr;	
		int check;

		function new (virtual ctrlProbe ctrlInter);
			this.ctrlInter = ctrlInter;
			/*rst_cntr = 3'b0;
			LD_cntr = 0;
			flag = 1'b0;
			ST_cntr = 0;
			LDI_cntr = 3'd0;
			STI_cntr = 0;
			BR_cntr = 0 ;	
			enable_updatePC = 1'b1;
			enable_fetch = 1'b1;
			enable_decode = 1'b0;
			enable_execute = 1'b0;
			enable_writeback = 1'b0;
			mem_state = 2'd3;*/
		endfunction:new

		task run();
	
			if(ctrlInter.reset == 1'b1)
			begin
				rst_cntr = 3'b0;
				LD_cntr = 3'd0;
				ST_cntr = 0;
				LDI_cntr = 3'd0;
				STI_cntr = 0;
				BR_cntr = 4'b0 ;	
				flag = 1'b0;
				flag2 = 1'b0;
				enable_updatePC = 1'b1;
				enable_fetch = 1'b1;
				enable_decode = 1'b0;
				enable_execute = 1'b0;
				enable_writeback = 1'b0;
				bypass_alu_1 = 1'b0;
				bypass_alu_2 = 1'b0;
				bypass_mem_1 = 1'b0;
				bypass_mem_2 = 1'b0;
				mem_state = 2'd3;
				mem_hold = 2'd3;
				br_taken = 3'b0;
			end
		else
		begin

				/***Modelling Init behavior*****/
				if(flag == 1'b0)
					rst_cntr = rst_cntr + 3'b01;	
				if(rst_cntr == 3'd2)	
					enable_decode = 1'b1;
				if(rst_cntr == 3'd3 )
					enable_execute = 1'b1;
				if(rst_cntr == 3'd4 )	begin
					enable_writeback = 1'b1;
					flag = 1'b1;
					rst_cntr = 3'd0;
				end

				/*******************************Enable**********************************/
				
			
	
				/**  Case for LD/LDR **/

				if(LD_cntr == 3'd1)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b1;	
					LD_cntr = 3'd2;
				end

				if((ctrlInter.IR_Exec[15:12] == 4'd2 || ctrlInter.IR_Exec[15:12] == 4'd6) && (LD_cntr == 3'd0)) 	//LD or LDR
				begin	
	
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					enable_decode = 1'b0;
					enable_execute = 1'b0;
					enable_writeback = 1'b0;	
					LD_cntr = LD_cntr + 3'd1;

				end
			
				if(LD_cntr == 3'd2)
					LD_cntr = 3'd0;

	
				/** Case for ST/STR **/

				if(ST_cntr == 3'd2)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b1;	
					ST_cntr = ST_cntr + 3'd1;
				end
	

				if(ST_cntr == 3'd1)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b0;	
					ST_cntr = ST_cntr + 3'd1;
				end

				if((ctrlInter.IR_Exec[15:12] == 4'd3 || ctrlInter.IR_Exec[15:12] == 4'd7) && (ST_cntr == 3'd0)) 	//ST or STR
				begin	
	
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					enable_decode = 1'b0;
					enable_execute = 1'b0;
					enable_writeback = 1'b0;	
					ST_cntr = ST_cntr +  3'd1;

				end

				
				if(ST_cntr == 3'd3)
					ST_cntr = 3'd0;

				/***  LDI ***/

				if(LDI_cntr == 3'd2)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b1;	
					LDI_cntr = 3'd3;
				end

				if(LDI_cntr == 3'd1)
				begin
		
					LDI_cntr = 3'd2;
				end


				if(ctrlInter.IR_Exec[15:12] == 4'd10 && (LDI_cntr == 3'd0)) 	//LDI
				begin	
	
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					enable_decode = 1'b0;
					enable_execute = 1'b0;
					enable_writeback = 1'b0;	
					LDI_cntr = 3'd1;

				end

				if(LDI_cntr == 3'd3)
					LDI_cntr = 3'd0;

				/******   STI *********/

				if(STI_cntr == 3)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b1;	
					STI_cntr = 4;
				end

				if(STI_cntr == 2)
				begin
					enable_updatePC = 1'b1;
					enable_fetch = 1'b1;
					enable_decode = 1'b1;
					enable_execute = 1'b1;
					enable_writeback = 1'b0;	
					STI_cntr = 3;
				end

				if(STI_cntr == 1)
				begin	
					STI_cntr = 2;
				end


				if(ctrlInter.IR_Exec[15:12] == 4'd11 && (STI_cntr == 0)) 	//STI
				begin	
	
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					enable_decode = 1'b0;
					enable_execute = 1'b0;
					enable_writeback = 1'b0;	
					STI_cntr = 1;

				end

				if(STI_cntr == 4)
					STI_cntr = 0;

				/******** BR or JMP **************/
				if(BR_cntr == 4'd7)
				begin
					enable_writeback = 1'b1;
					BR_cntr = 4'd8;
					//enable_execute = 1'b1;
				end

				if(BR_cntr == 4'd6)
				begin
					//enable_writeback = 1'b1;
					BR_cntr = 4'd7;
					enable_execute = 1'b1;
				end

				if(BR_cntr == 4'd5)
				begin
					
					BR_cntr = 4'd6;
					enable_decode = 1'b1;
				end

				if(BR_cntr == 4'd4)
				begin
					
					BR_cntr = 4'd5;
					enable_fetch = 1'b1;
					enable_updatePC = 1'b1;
				end

				if(BR_cntr == 4'd3)
				begin
					
					BR_cntr = 4'd4;
					
					enable_execute = 1'b0;
					enable_writeback = 1'b0;
				end

				if(BR_cntr == 4'd2)
				begin
						
					BR_cntr = 4'd3;
					enable_decode = 1'b0;
				end

				if(BR_cntr == 4'd1)
				begin
					
					BR_cntr = BR_cntr + 3'd1;
					//enable_updatePC = 1'b0;
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					
				end


				if((ctrlInter.IMem_dout[15:12] == 4'd0 || ctrlInter.IMem_dout[15:12] == 4'd12) && (BR_cntr == 4'd0) && (flag2 == 1'd1))
				begin
					
					BR_cntr = BR_cntr + 3'd1;	
				end

				if((ctrlInter.IMem_dout[15:12] == 4'd0 || ctrlInter.IMem_dout[15:12] == 4'd12) && (BR_cntr == 4'd0) && (flag2 == 1'd0))
				begin
					enable_updatePC = 1'b0;
					enable_fetch = 1'b0;
					BR_cntr = 4'd2;
					flag2 = 1'b1;	
				end

				if(BR_cntr == 4'd8)
					BR_cntr = 3'd0;
			



				/****branch taken******/

				br_taken = 1'b0;
				if(ctrlInter.enable_updatePC == 1'b1)
					br_taken = |(ctrlInter.psr & ctrlInter.NZP);
					
				if(br_taken == 3'd1)
					enable_updatePC = 1'b1;
	

					/***====================== Bypass out signals based on Dependencies =============================================================================****/
					bypass_alu_1 = 1'b0;
					bypass_alu_2 = 1'b0;
					bypass_mem_1 = 1'b0;
					bypass_mem_2 = 1'b0;

					if(ctrlInter.IR[15:12] == 4'd1 || ctrlInter.IR[15:12] == 4'd5 || ctrlInter.IR[15:12] == 4'd9) //arithmetic operations
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd1 || ctrlInter.IR_Exec[15:12] == 4'd5 || ctrlInter.IR_Exec[15:12] == 4'd9 || ctrlInter.IR_Exec[15:12] == 4'd14) //Arith or LEA
						begin
							if(ctrlInter.IR_Exec[11:9] == ctrlInter.IR[8:6])
							bypass_alu_1 = 1'b1;
							if((ctrlInter.IR_Exec[11:9] == ctrlInter.IR[2:0]) && (ctrlInter.IR[5] == 1'b0))
							bypass_alu_2 = 1'b1;	
						end
						if(ctrlInter.IR_Exec[15:12] == 4'd2 || ctrlInter.IR_Exec[15:12] == 4'd6 || ctrlInter.IR_Exec[15:12] == 4'd10) //LD or LDR or LDI
						begin
							if(ctrlInter.IR_Exec[11:9] == ctrlInter.IR[8:6])
							bypass_mem_1 = 1'b1;
							if((ctrlInter.IR_Exec[11:9] == ctrlInter.IR[2:0]) && (ctrlInter.IR[5] == 1'b0))
							bypass_mem_2 = 1'b1;	
						end  
					end
	
					if(ctrlInter.IR[15:12] == 4'd6) //LDR 	
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd1 || ctrlInter.IR_Exec[15:12] == 4'd5 || ctrlInter.IR_Exec[15:12] == 4'd9|| ctrlInter.IR_Exec[15:12] == 4'd14) //arith
						begin
						if(ctrlInter.IR_Exec[11:9] ==  ctrlInter.IR[8:6])
						bypass_alu_1 = 1'b1;	
						end	
					end

	
					if(ctrlInter.IR[15:12] == 4'd7) //STR 	
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd1 || ctrlInter.IR_Exec[15:12] == 4'd5 || ctrlInter.IR_Exec[15:12] == 4'd9|| ctrlInter.IR_Exec[15:12] == 4'd14) //arith
						begin
							if(ctrlInter.IR_Exec[11:9] ==  ctrlInter.IR[8:6])
							bypass_alu_1 = 1'b1;
							if((ctrlInter.IR_Exec[11:9] == ctrlInter.IR[11:9]))	
							bypass_alu_2 = 1'b1;	
						end	
					end
	
					if(ctrlInter.IR[15:12] == 4'd3 || ctrlInter.IR[15:12] == 4'd11) //ST or STI 	
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd1 || ctrlInter.IR_Exec[15:12] == 4'd5 || ctrlInter.IR_Exec[15:12] == 4'd9|| ctrlInter.IR_Exec[15:12] == 4'd14) //arith
						begin
							if((ctrlInter.IR_Exec[11:9] ==  ctrlInter.IR[11:9]))
							bypass_alu_2 = 1'b1;	
						end	
					end

	
					if(ctrlInter.IR[15:12] == 4'd12) //JMP 	
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd1 || ctrlInter.IR_Exec[15:12] == 4'd5 || ctrlInter.IR_Exec[15:12] == 4'd9|| ctrlInter.IR_Exec[15:12] == 4'd14) //arith
						begin
						if(ctrlInter.IR_Exec[11:9] ==  ctrlInter.IR[8:6])
						bypass_alu_1 = 1'b1;	
						end	
					end

				/********==================================Mem_State=======================================================*******/
	
				if(ctrlInter.complete_data == 1'b1)
				begin
					/*MEM State 1*/
					if(mem_state == 2'd1)
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd2 || ctrlInter.IR_Exec[15:12] == 4'd6 || ctrlInter.IR_Exec[15:12] == 4'd10) //LD or LDR or LDI
						mem_hold = 2'd0;
						if(ctrlInter.IR_Exec[15:12] == 4'd3 || ctrlInter.IR_Exec[15:12] == 4'd7 || ctrlInter.IR_Exec[15:12] == 4'd11) //ST or STR or STI
						mem_hold = 2'd2;
					end	

					/*MEM State 2*/
					if(mem_state == 2'd2)
						mem_hold = 2'd3;

					/*MEM State 0*/
					if(mem_state == 2'd0)
						mem_hold = 2'd3;

					/*MEM State 3*/
					if(mem_state == 2'd3)
					begin
						if(ctrlInter.IR_Exec[15:12] == 4'd2 || ctrlInter.IR_Exec[15:12] == 4'd6 ) //LD or LDR 
						mem_hold = 2'd0;
						if(ctrlInter.IR_Exec[15:12] == 4'd3 || ctrlInter.IR_Exec[15:12] == 4'd7 ) //ST or STR 
						mem_hold = 2'd2;
						if(ctrlInter.IR_Exec[15:12] == 4'd10 || ctrlInter.IR_Exec[15:12] == 4'd11) //LDI or STI //might need another approach
						mem_hold = 2'd1;
					end	

					mem_state = mem_hold;

				end 


			end
		endtask: run

		task monitor_async;

			//$display("//--------------- Control Block ----------------//\n");	
	
			if (bypass_alu_1 != ctrlInter.bypass_alu_1)begin
			$display($time," Failed at Control bypass_alu_1 testBench [%0h] DUT [%0h]", bypass_alu_1, ctrlInter.bypass_alu_1);
			end

			if (bypass_alu_2 != ctrlInter.bypass_alu_2)begin
			$display($time," Failed at Control bypass_alu_2 testBench [%0h] DUT [%0h]", bypass_alu_2, ctrlInter.bypass_alu_2);
			end
	
			if (bypass_mem_1 != ctrlInter.bypass_mem_1)begin
			$display($time," Failed at Control bypass_mem_1 testBench [%0h] DUT [%0h]", bypass_mem_1, ctrlInter.bypass_mem_1);
			end

			if (bypass_mem_2 != ctrlInter.bypass_mem_2)begin
			$display($time, " Failed at Control bypass_mem_2 testBench [%0h] DUT [%0h]", bypass_mem_2, ctrlInter.bypass_mem_2);
			end
	
			if(mem_state != ctrlInter.mem_state) begin
			$display($time, " Failed at Control mem_state testBench [%0h] DUT [%0h]", mem_state, ctrlInter.mem_state);
			end
			if(br_taken != ctrlInter.br_taken) begin
			$display($time, " Failed at Control br_taken testBench [%0h] DUT [%0h]", br_taken, ctrlInter.br_taken);
			end

		


			//$display("//---------------------------------------------------//\n");


		endtask:monitor_async


		task monitor_sync;
	

		//	$display("UNDER CONSTRUCTION");
			if(enable_updatePC != ctrlInter.enable_updatePC) begin
			$display($time, " Failed at Control enable_updatePC testBench [%0h] DUT [%0h]", enable_updatePC, ctrlInter.enable_updatePC);
			end
			if(enable_fetch != ctrlInter.enable_fetch) begin
			$display($time, " Failed at Control enable_fetchn testBench [%0h] DUT [%0h]", enable_fetch, ctrlInter.enable_fetch);
			end
			if(enable_decode != ctrlInter.enable_decode) begin
			$display($time, " Failed at Control enable_decode testBench [%0h] DUT [%0h]", enable_decode, ctrlInter.enable_decode);
			end
			if(enable_execute != ctrlInter.enable_execute) begin
			$display($time, " Failed at Control enable_execute testBench [%0h] DUT [%0h]", enable_execute, ctrlInter.enable_execute);
			end
			if(enable_writeback	!= ctrlInter.enable_writeback) begin
			$display($time, " Failed at Control enable_writeback testBench [%0h] DUT [%0h]", enable_writeback, ctrlInter.enable_writeback);
			end

		endtask: monitor_sync

	endclass: control
	
		

endpackage:golden
