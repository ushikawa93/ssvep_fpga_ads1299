
module lockin_wrapper

	#(
		parameter integer Q_in = 32,
		parameter integer N_filtro_ma = 8,
		parameter integer fs = 1000,
		parameter integer f_lockin = 16,
		parameter integer N_filtro_iir = 8
	 )
	
	( input clk,
	  input reset_n,
	
	  input [Q_in-1:0] x,
	  input x_valid,
	  
	  output [0:6] display_0,
	  output [0:6] display_1,
	  output [0:6] display_2,
	  output [0:6] display_3,
	  output [0:6] display_4,
	  output [0:6] display_5,
	  
	  output [31:0] signal_out,
	
	  output [31:0] amplitud_salida,
	  output estimulo_signal

);

/////////////////////////////////////////////////
// ========== Parametros locales ===========
/////////////////////////////////////////////////

// La entrada del ADC es de 24 bits, pero podemos trabajar con Q_input bits...
localparam integer Q_input = 24;

// La referencia usada en el lockin puede ser de 16 bits o menos
localparam integer Q_ref = 16;

localparam integer Q_calculos_internos = 64;
localparam integer simulate_data = 0;
localparam integer M = (simulate_data==1)? 16 : ( (fs/f_lockin <= 512 ) ? fs/f_lockin : 4 );


/////////////////////////////////////////////////
// ========== Datos simulados para testeo ===========
/////////////////////////////////////////////////

wire [31:0] data_sim;
wire data_sim_valid;

data_source data_source_inst(

	// Entradas de control
	.clk(clk),
	.reset_n(reset_n),
	.enable(x_valid),
	
	
	// Salida avalon streaming
	.data_valid(data_sim_valid),
	.data(data_sim)
	
);


/////////////////////////////////////////////////
// === Registro de entrada para desacoplar =======
/////////////////////////////////////////////////


reg x_valid_reg;
reg signed [Q_in-1:0] x_reg;			

always @ (posedge clk) 
begin

	x_reg <= (simulate_data==1)? data_sim : x >>> (24-Q_input);
	x_valid_reg <= (simulate_data==1)? data_sim_valid : x_valid;	
	
end

/////////////////////////////////////////////////////////////
// === Filtro pasa altos para remover el valor medio =======
//////////////////////////////////////////////////////////

wire x_pa_valid_reg;
wire signed [Q_in-1:0] x_pa_reg;

remove_mean_value_state_machine filtro_pa(
	.clock(clk),
	.reset(reset_n),

	.data_in(x_reg),
	.data_in_valid(x_valid_reg),

	.data_out(x_pa_reg),
	.data_out_valid(x_pa_valid_reg)
);

defparam filtro_pa.Q_in = Q_in;
defparam filtro_pa.M = 32;


/////////////////////////////////////////////////
// ================= Lockin 1  ================
/////////////////////////////////////////////////

// Salidas del lockin en fase y cuadratura con su data_valid
wire data_li_valid;
wire signed [Q_calculos_internos-1:0] data_li_fase;
wire signed [Q_calculos_internos-1:0] data_li_cuad;


lockin_state_machine lockin_inst(

	.clk(clk),
	.reset_n(reset_n ),
	
	.x(x_pa_reg),
	.x_valid(x_pa_valid_reg),
	
	.data_out_fase(data_li_fase),
	.data_out_cuad(data_li_cuad),
	.data_out_valid(data_li_valid)
);

defparam lockin_inst.Q_in = Q_in;
defparam lockin_inst.Q_out = Q_calculos_internos;
defparam lockin_inst.Q_ref = Q_ref;
defparam lockin_inst.M = M;
defparam lockin_inst.N = N_filtro_ma;

/////////////////////////////////////////////////
// ==== Filtros IIR extra (porque puedo)  =========
/////////////////////////////////////////////////

		
// Salidas del lockin en fase y cuadratura con su data_valid
wire data_iir_valid;
wire signed [Q_calculos_internos-1:0] data_iir_fase ;
wire signed [Q_calculos_internos-1:0] data_iir_cuad ;

genvar i;

generate 

if(N_filtro_iir > 0) begin: iir_generate

	// Salidas del lockin en fase y cuadratura con su data_valid
	wire data_iir_fase_in_valid [0:N_filtro_iir-1];
	wire data_iir_fase_out_valid [0:N_filtro_iir-1];

	wire data_iir_cuad_in_valid [0:N_filtro_iir-1];
	wire data_iir_cuad_out_valid [0:N_filtro_iir-1];

	wire signed [Q_calculos_internos-1:0] data_iir_fase_in [0:N_filtro_iir-1] ;
	wire signed [Q_calculos_internos-1:0] data_iir_fase_out [0:N_filtro_iir-1] ;

	wire signed [Q_calculos_internos-1:0] data_iir_cuad_in [0:N_filtro_iir-1] ;
	wire signed [Q_calculos_internos-1:0] data_iir_cuad_out [0:N_filtro_iir-1] ;

	assign data_iir_fase_in_valid[0] = data_li_valid;
	assign data_iir_cuad_in_valid[0] = data_li_valid;

	assign data_iir_fase_in[0] = data_li_fase;
	assign data_iir_cuad_in[0] = data_li_cuad;


	for (i = 0;i<N_filtro_iir;i=i+1)	begin: iir_for_loop

			IIR_filter_simple iir_filter_fase
			(

				// Entradas de control
				.clock(clk),
				.reset(reset_n),
					
				// Interfaz avalon streaming de entrada
				.data_valid(data_iir_fase_in_valid[i]),
				.data(data_iir_fase_in[i]),	
				
				// Interfaz avalon streaming de salida
				.data_out(data_iir_fase_out[i]),
				.data_out_valid(data_iir_fase_out_valid[i])

			);

			defparam iir_filter_fase.Q_in = Q_calculos_internos;

			IIR_filter_simple iir_filter_cuad
			(

				// Entradas de control
				.clock(clk),
				.reset(reset_n),
					
				// Interfaz avalon streaming de entrada
				.data_valid(data_iir_cuad_in_valid[i]),
				.data(data_iir_cuad_in[i]),	
				
				// Interfaz avalon streaming de salida
				.data_out(data_iir_cuad_out[i]),
				.data_out_valid(data_iir_cuad_out_valid[i])

			);
			
			if( i < N_filtro_iir-1 ) begin: iir_if_loop
			
				assign data_iir_fase_in_valid[i+1] = data_iir_fase_out_valid[i];
				assign data_iir_cuad_in_valid[i+1] = data_iir_cuad_out_valid[i];

				assign data_iir_fase_in[i+1] = data_iir_fase_out[i];
				assign data_iir_cuad_in[i+1] = data_iir_cuad_out[i];
			end

			defparam iir_filter_cuad.Q_in = Q_calculos_internos;
		end


	assign data_iir_valid = data_iir_fase_out_valid [N_filtro_iir-1] && data_iir_cuad_out_valid [N_filtro_iir-1];
	assign data_iir_fase = data_iir_fase_out [N_filtro_iir-1];
	assign data_iir_cuad = data_iir_cuad_out [N_filtro_iir-1];
	
end
else
begin
	
	assign data_iir_valid = data_li_valid;
	assign data_iir_fase = data_li_fase;
	assign data_iir_cuad = data_li_cuad;	

end
endgenerate




/////////////////////////////////////////////////
// ========== Calculo de resultados  =============
/////////////////////////////////////////////////


wire [31:0] amplitud_final;
wire [31:0] amplitud_final_lenta;


calculo_resultados resultados_inst
(

	.clk(clk),
	.reset_n(reset_n),
	
	.data_in_fase(data_iir_fase),
	.data_in_cuad(data_iir_cuad),
	.data_in_valid(data_iir_valid),
	
	.amplitud_final_lenta(amplitud_final_lenta),
	.amplitud_final(amplitud_final)

);

defparam resultados_inst.M = M;
defparam resultados_inst.N = N_filtro_ma;
defparam resultados_inst.Q_ref = Q_ref;
defparam resultados_inst.Q_in = Q_calculos_internos;
defparam resultados_inst.Q_out = Q_calculos_internos;

/////////////////////////////////////////////////
// ========== Display resultados ===========
/////////////////////////////////////////////////


localparam att_display = 8;

wire [31:0] numero_a_mostrar = amplitud_final_lenta >> att_display;
wire [3:0] bcd0,bcd1,bcd2,bcd3,bcd4,bcd5;

descomponer_en_digitos desc_li(

	.numero(numero_a_mostrar),
	
	.digit0(bcd0),	.digit1(bcd1),	.digit2(bcd2),	.digit3(bcd3),	.digit4(bcd4),	.digit5(bcd5)	
	
);

BCD_display display(

	.bcd0(bcd0),	.bcd1(bcd1),	.bcd2(bcd2),	.bcd3(bcd3),	.bcd4(bcd4),	.bcd5(bcd5),
	
	.HEX0(display_0),	.HEX1(display_1),	.HEX2(display_2),	.HEX3(display_3),	.HEX4(display_4),	.HEX5(display_5)
	
);



/////////////////////////////////////////////////
// ========== Estimulos visuales ===========
////////////////////////////////////////////////




generador_estimulo estimulo
(
	.reset_n(reset_n),
	.clk(clk),
	.data_valid(x_valid_reg),
	
	.sinc_output(estimulo_signal)
	
);

defparam estimulo.M = M;

/////////////////////////////////////////////////
// ================== Salidas ===================
/////////////////////////////////////////////////

assign amplitud_salida = amplitud_final;

assign signal_out = x_pa_reg;



endmodule 

