module top(
	input wire clk,
	input wire rst_n,
	input wire [4:0] paddr,
	input wire [31:0] pwdata,
	input wire pwrite_in,
	output reg [31:0] data,
	output reg pready
);

wire psel, penable, pwrite, pready_internal;
wire [4:0] paddr_internal;
wire [31:0] pwdata_internal, data_out;

master ic1 (
	.clk(clk),
	.rst_n(rst_n),
	.paddr(paddr),
	.pwdata(pwdata),
	.pwrite_in(pwrite_in),
	.pready(pready_internal),
	.psel(psel),
	.penable(penable),
	.pwrite(pwrite),
	.paddr_out(paddr_internal),
	.pwdata_out(pwdata_internal)
);

slave ic2 (
	.clk(clk),
	.rst_n(rst_n),
	.psel(psel),
	.penable(penable),
	.pwrite(pwrite),
	.paddr(paddr_internal),
	.pwdata(pwdata_internal),
	.pready(pready_internal),
	.data(data_out)
);

always @(*) begin
	pready <= pready_internal;
	data <= data_out;
end

endmodule

