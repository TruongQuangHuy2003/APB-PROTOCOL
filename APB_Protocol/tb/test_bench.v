`timescale 1ns/1ps
module test_bench;
	reg clk;
    	reg rst_n;
	reg [4:0] paddr;
	reg [31:0] pwdata;
	reg pwrite_in;
	wire [31:0] data;
	wire pready;

	top dut(.*);

	integer i;
	reg [31:0] rad_data;

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	task verify;
		input [31:0] exp_data;
		begin
			$display("At time: %t,rst_n = 1'b%b, paddr = 5'h%h, pwdata = 32'h%h, pwrite_in = 1'b%b", $time, rst_n, paddr, pwdata, pwrite_in);
			if(data == exp_data) begin
				$display("-------------------------------------------------------------------------------------------------------------------------------");
				$display("PASSED: Expected data: 32'h%h, Got data: 32'h%h", exp_data, data); 
				$display("-------------------------------------------------------------------------------------------------------------------------------");
			end else begin
				$display("-------------------------------------------------------------------------------------------------------------------------------");
				$display("FAILED: Expected data: 32'h%h, Got data: 32'h%h", exp_data, data); 
				$display("-------------------------------------------------------------------------------------------------------------------------------");
			end
		end
	endtask

	task setup;
		input [4:0] exp_paddr;
		input [31:0] exp_pwdata;
		input exp_pwrite_in;
		begin
			paddr = exp_paddr;
			pwdata = exp_pwdata;
			pwrite_in = exp_pwrite_in;
			wait(pready);
			wait(!pready);
		end
	endtask

	initial begin
		$dumpfile("test_bench.vcd");
		$dumpvars(0, test_bench);

		$display("-------------------------------------------------------------------------------------------------------------------------------");
		$display("-------------------------------------------TESTBENCH FOR APB PROTOCOL----------------------------------------------------------"); 
		$display("-------------------------------------------------------------------------------------------------------------------------------");

		rst_n = 0;
		@(posedge clk);
		verify(32'h00000000);
		
		rst_n = 1;
		@(posedge clk);
		setup(5'h0f, 32'hffff0000, 1);
		verify(32'h00000000);
		setup(5'h0f, 32'hffff0000,0);
		verify(32'hffff0000);
		@(posedge clk);
		setup(5'h04, 32'hffffffff, 1);
		verify(32'h00000000);
		setup(5'h04, 32'hffffffff,0);
		verify(32'hffffffff);
		for (i = 0; i < 32; i = i + 1) begin
			rad_data = $urandom % 10000;
			setup(i, rad_data, 1);
			setup(i, rad_data, 0);
			verify(rad_data);
		end
		#100;
		$finish;

	end
endmodule

