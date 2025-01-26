module master (
	input wire clk,
	input wire rst_n,
	input wire [4:0] paddr,
	input wire [31:0] pwdata,
	input wire pwrite_in,
	input wire pready,
	output reg psel,
	output reg penable,
	output reg pwrite,
	output reg [4:0] paddr_out,
	output reg [31:0] pwdata_out
);

reg [1:0] state, next_state;
localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ACCESS = 2'b10;
localparam WAIT = 2'b11;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end

always @(*) begin
	case (state)
		IDLE: begin
			next_state <=  SETUP; 
		end
		SETUP: begin
			next_state <= ACCESS;
		end
		ACCESS: begin
			next_state <= (pready) ? IDLE : WAIT;
		end
		WAIT: begin
			next_state <= (pready) ? IDLE : WAIT;
		end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		psel <= 1'b0;
		penable <= 1'b0;
		pwrite <= 1'b0;
		paddr_out = 5'h00;
		pwdata_out = 32'h00000000;
	end else begin
		case (state) 
			IDLE: begin
				psel <= 1'b0;
				penable <= 1'b0;
				pwrite <= 1'b0;
			end
			SETUP: begin
				psel <= 1'b1;
				pwrite <= pwrite_in;
			end
			ACCESS: begin
				penable <= 1'b1;
				if(!pready) begin
					paddr_out <= paddr;
					pwdata_out <= pwdata;
				end 
			end
			WAIT: begin	
				if(!pready) begin
					paddr_out <= paddr;
					pwdata_out <= pwdata;
				end
			end
		endcase
	end
end	

endmodule

