
module processor (
	clk_clk,
	datos_muestreados_in_valid,
	datos_muestreados_in_data,
	datos_muestreados_in_ready,
	fifo_1_in_valid,
	fifo_1_in_data,
	fifo_1_in_ready,
	fifo_2_in_valid,
	fifo_2_in_data,
	fifo_2_in_ready,
	fifo_3_in_valid,
	fifo_3_in_data,
	fifo_3_in_ready,
	reset_reset_n,
	fifo_4_in_valid,
	fifo_4_in_data,
	fifo_4_in_ready);	

	input		clk_clk;
	input		datos_muestreados_in_valid;
	input	[31:0]	datos_muestreados_in_data;
	output		datos_muestreados_in_ready;
	input		fifo_1_in_valid;
	input	[31:0]	fifo_1_in_data;
	output		fifo_1_in_ready;
	input		fifo_2_in_valid;
	input	[31:0]	fifo_2_in_data;
	output		fifo_2_in_ready;
	input		fifo_3_in_valid;
	input	[31:0]	fifo_3_in_data;
	output		fifo_3_in_ready;
	input		reset_reset_n;
	input		fifo_4_in_valid;
	input	[31:0]	fifo_4_in_data;
	output		fifo_4_in_ready;
endmodule
