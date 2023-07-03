
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
// Bitshift de 15 lugares!


/////////////////////////////////////////////////
// ========== Señales generales  =============
/////////////////////////////////////////////////

reg signed [Q_in-1:0] data_in_fase_reg_fast,data_in_cuad_reg_fast,data_in_fase_reg,data_in_cuad_reg;

reg [Q_out*2-1:0] data_in_fase_2,data_in_cuad_2;

reg [Q_out*2-1:0] amplitud_pre_sqrt_reg;

wire [Q_out-1:0] salida_sqrt;

reg [Q_out/2-1:0] amplitud_final_reg,amplitud_final_slow_reg;


reg [31:0] counter;

/////////////////////////////////////////////////
// === Clock lento para las cosas exigentes  =====
/////////////////////////////////////////////////

wire clock_lento;
parameter divisor_clock = 2;

clock_divider div_clock(
	.clock_in(clk),
	.divisor(divisor_clock),
	.clock_out(clock_lento)
);


/////////////////////////////////////////////////
// ========== R^2 = X^2 + Y^2  =============
/////////////////////////////////////////////////


// Voy a hacerlo con un clock mas lento asique necesito adaptar el data_valid
// este cambia con clk rapido, yo quiero mantenerlo en alto hasta que lo consuma el clock mas lento
// Lo hago con una pequeña maquina de estados
localparam idle = 0, notify=1,register=2,multiply=3,sum=4;

reg [3:0] state;

reg d_valid_recibido,d_valid_consumido;


always @ (posedge clk)
begin

	if(!reset_n)
	begin
		d_valid_recibido <= 0;
	end
	else
	begin
		d_valid_recibido <= (data_in_valid || d_valid_recibido) && !d_valid_consumido ;
		
		if(data_in_valid)
		begin
			data_in_fase_reg_fast <= data_in_fase;
			data_in_cuad_reg_fast <= data_in_cuad;		
		end
		
	end

end

always @ (posedge clock_lento)
begin
	
	if(!reset_n)
	begin
		amplitud_pre_sqrt_reg <= 0;
		data_in_fase_reg <= 0;
		data_in_cuad_reg <=0;
		d_valid_consumido <= 0;
		state <= idle;
	end

	else 
	begin		
	
		case (state)
			
			idle:
				begin
					d_valid_consumido <= 0;
					state <= (d_valid_recibido) ? notify : idle;
				end
			notify:
				begin
					d_valid_consumido <= 1;
					state <= register;
				end
			register:
				begin						
					data_in_fase_reg <= data_in_fase_reg_fast;
					data_in_cuad_reg <= data_in_cuad_reg_fast;
					state <= multiply;				
				end
			multiply:
				begin
					data_in_fase_2 <= data_in_fase_reg * data_in_fase_reg;
					data_in_cuad_2 <= data_in_cuad_reg * data_in_cuad_reg;
					state <= sum;
				end
			sum:
				begin
					amplitud_pre_sqrt_reg <= data_in_fase_2 + data_in_cuad_2 ;	
					state <= idle;
				end
		endcase
	end
end



/////////////////////////////////////////////////
// =============== R = sqrt (R)	 ===============
/////////////////////////////////////////////////




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

parameter divisor = (M*N*ref_mean_value / 2);

// Esta cuenta usa muchisimas celdas logicas -> mejorar
// Por ahora cambie el /ref_mean_value por un >> 15 
// Y puse el divisor_reg como un parameter (total no cambia nunca)

always @ (posedge clk)
begin		

	if(!reset_n)
		amplitud_final_reg <=0;
	else	
		amplitud_final_reg <= salida_sqrt / divisor;

end


/////////////////////////////////////////////////
// ===  Actualizacion (mas)lenta para dispay	 =====
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
