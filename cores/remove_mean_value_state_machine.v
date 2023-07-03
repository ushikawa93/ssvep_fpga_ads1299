
module remove_mean_value_state_machine
#(
	parameter M=32,
	parameter Q_in=32
)
(

	input clock,
	input reset,

	input signed [Q_in-1:0] data_in,
	input data_in_valid,

	output reg signed [Q_in-1:0] data_out,
	output reg data_out_valid
);



reg signed [Q_in-1:0] data_reg,old_data;

reg [15:0] index;

reg signed [Q_in-1:0] data_mem [0:M-1];

reg signed [Q_in-1:0] acumulador,valor_medio;

reg [3:0] state;
localparam clean=0,idle=1,register_data=2,fetch_old_data=3,save_data=4,actualizar_acumulador=5,actualizar_indice=6,actualizar_salida=7;


always @ (posedge clock or negedge reset)
begin
	
	
	if(!reset)
	begin
		acumulador <= 0;
		index <= 0;
		data_reg <=0; 
		old_data <=0;
		data_out <= 0;
		
		valor_medio <=0;
		data_out_valid<= 0;		
		state <= clean;		
		
	end
	
	else
	begin
		
		case (state)
		
			clean:
			begin
				data_mem[index] <= 0;
				index <= (index == M-1)? 0: index+1;
				state <= (index == M-1)? idle:clean;
			end
			
			idle:
			begin
				data_out_valid <= 0;
				state <= (data_in_valid)? register_data : idle;		
			end
			
			register_data:
			begin
				// Registrar dato entrante (1 etapa)
				data_reg <= data_in;
				state <= fetch_old_data;
			end
			
			fetch_old_data:
			begin
				old_data <= data_mem[index];
				state <= save_data;
			end
			
			save_data:
			begin
				data_mem[index] <= data_reg;		
				state <= actualizar_acumulador;
			end
			
			actualizar_acumulador:
			begin
				acumulador <= acumulador + data_reg - old_data;
				state <= actualizar_indice;
			end
			
			actualizar_indice:
			begin
				index <= (index== (M-1))? 0: index+1;
				valor_medio <= acumulador / M;			
				state <= actualizar_salida;
			end
			
			actualizar_salida:
			begin
				data_out <= data_reg - valor_medio;
				data_out_valid <= 1;
				state <= idle;
			end
			
			default:
				state <= idle;
			
		endcase	
	
	end
		
end

endmodule
