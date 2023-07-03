
`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps


module ssvep_lockin_tb;

reg clk;
reg reset;
reg enable;

wire [31:0] data;
wire data_valid;

wire [31:0] acond_signal;
wire [31:0] amplitud_salida;
wire estimulo_visual;

// Pongo un ratito en bajo el reset
initial
begin
	reset=1;
	#40
	reset=0;
	#40
	reset=1;
	#40
	enable=1;
end

// Esto genera un clock de periodo=20ns (50 MHz)
always 
begin
    clk = 1'b0; 
    #10; // high for 20 * timescale = 20 ns

    clk = 1'b1;
    #10; // low for 20 * timescale = 20 ns
end

// Data source
data_source data_source_inst(

	// Entradas de control
	.clk(clk),
	.reset_n(reset),
	.enable(enable),
	
	
	// Salida avalon streaming
	.data_valid(data_valid),
	.data(data)
	
);


// Lockin SSVEP
lockin_wrapper lockin( 
	
	.clk(clk),
	.reset_n(reset),
	
	.x(data),
	.x_valid(data_valid),
	  
	.display_0(),
	.display_1(),
	.display_2(),
	.display_3(),
	.display_4(),
	.display_5(),
	  
	.signal_out(acond_signal),	
	.amplitud_salida(amplitud_salida),
	.estimulo_signal(estimulo_visual)

);

defparam lockin.Q_in = 32;
defparam lockin.N_filtro_ma = 32;
defparam lockin.fs = 256;
defparam lockin.f_lockin = 16;
defparam lockin.N_filtro_iir = 0;

endmodule
