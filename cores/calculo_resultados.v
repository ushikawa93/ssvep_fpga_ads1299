
module calculo_resultados
#(
		parameter Q_in = 64,
		parameter Q_out = 64,
		parameter Q_ref = 16,
		parameter M =16,
		parameter N = 8
	)

(

	input clk,
	input reset_n,
	
	input signed [Q_in-1:0] data_in_fase,
	input signed [Q_in-1:0] data_in_cuad,
	input 			  data_in_valid,
	
	output [Q_out-1:0] amplitud_final,
	output [Q_out-1:0] amplitud_final_lenta


);

localparam ref_mean_value = 32768 >> (16-Q_ref);


/////////////////////////////////////////////////
// ========== Señales generales  =============
/////////////////////////////////////////////////

reg [Q_out*2-1:0] data_in_fase_2,data_in_cuad_2;

reg [Q_out*2-1:0] amplitud_pre_sqrt_reg;

wire [Q_out-1:0] salida_sqrt;

reg [Q_out/2-1:0] amplitud_final_reg,amplitud_final_slow_reg;


reg [31:0] counter;

/////////////////////////////////////////////////
// ========== R^2 = X^2 + Y^2  =============
/////////////////////////////////////////////////

always @ (posedge clk)
begin
	
	if(!reset_n)
	begin
		amplitud_pre_sqrt_reg <= 0;
	end

	else if(data_in_valid)
	begin		
		data_in_fase_2 <= data_in_fase * data_in_fase;
		data_in_cuad_2 <= data_in_cuad * data_in_cuad;
		
		amplitud_pre_sqrt_reg <= data_in_fase_2 + data_in_cuad_2 ;	
		
	end
end

/////////////////////////////////////////////////
// =============== R = sqrt (R)	 ===============
/////////////////////////////////////////////////


wire clock_lento;
parameter divisor_clock = 2;

clock_divider div_clock(
	.clock_in(clk),
	.divisor(divisor_clock),
	.clock_out(clock_lento)
);


sqrt raiz_cuadrada (
	.aclr(!reset_n),
	.clk(clock_lento),
	.ena(1),
	.radical(amplitud_pre_sqrt_reg),
	.q(salida_sqrt),
	.remainder()
);

/////////////////////////////////////////////////
// =========  A = (R)*2/(M*N*As)	 ===============
/////////////////////////////////////////////////

reg [63:0] divisor_reg;


always @ (posedge clk)
begin		
	
	divisor_reg <= (M*N*ref_mean_value);
	amplitud_final_reg <= 2* salida_sqrt / divisor_reg;

end


/////////////////////////////////////////////////
// ===  Actualizacion lenta para dispay	 =====
/////////////////////////////////////////////////

	
	
localparam counter_reset_value = 50000000; // 50000000 -> Para 1 segundo de actualizacion de la raiz cuadrada

always @ (posedge clk)
begin

	if(!reset_n)
	begin
		counter <= 0;
	end
	
	else
	begin	
		counter <= counter + 1;
		if (counter == counter_reset_value)
		begin			
			amplitud_final_slow_reg <= amplitud_final_reg;
			counter <= 0;
		end	
	end
	
end


/////////////////////////////////////////////////
// ================= Salidas	 ====================
/////////////////////////////////////////////////
	
	

assign amplitud_final = amplitud_final_reg;
assign amplitud_final_lenta = amplitud_final_slow_reg;

endmodule
