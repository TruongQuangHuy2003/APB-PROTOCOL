module slave (
	input wire clk,
	input wire rst_n,
	input wire psel,
	input wire penable,
	input wire pwrite,
	input wire [4:0] paddr,
	input wire [31:0] pwdata,
	output reg pready,
	output reg [31:0] data
);

reg [1:0] state, next_state;
reg [31:0] memory[31:0];
integer i;
reg [2:0] slave_time;

localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ACCESS = 2'b10;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end

always @(*) begin
	case (state) 
		IDLE: next_state <= (psel) ? SETUP : IDLE; 
		SETUP: next_state <= (psel && penable) ? ACCESS : SETUP;
		ACCESS: next_state <= IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pready <= 1'b0;
		data <= 32'h00000000;
		for(i = 0; i < 32; i = i + 1) begin
			memory[i] <= 32'h00000000;
		end
		slave_time <= 3'b000;
	end else begin
		if(state == ACCESS) begin
			if(slave_time == 3'b100) begin
				if(pwrite) begin
					memory[paddr] <= pwdata;
					pready <= 1'b1;
					data <= 32'h00000000;
				end else begin
					data <= memory[paddr];
					pready <= 1'b1;
				end
				slave_time <= 3'b000;
			end else begin
				slave_time <= slave_time + 1'b1;
			end
		end else begin
			pready <= 1'b0;
		end
	end
end
endmodule

