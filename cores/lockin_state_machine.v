
module lockin_state_machine

	#(parameter Q_in = 14,	  
	  parameter Q_out = 32,
	  parameter Q_ref = 16,
	  parameter N = 16,
	  parameter M = 16)
	
	( input clk,
	  input reset_n,
	
	  input signed [Q_in-1:0] x,
	  input x_valid,
	  
		
	  output signed [Q_out-1:0] data_out_fase,
	  output signed [Q_out-1:0] data_out_cuad,
	  output data_out_valid
	);

localparam ref_mean_value = 32768;
localparam interval = 2048/M; // Para poder cambiar el largo de la secuencia sin tener que leer otro archivo


reg [15:0] ref_sen [0:2047];
reg [15:0] ref_cos [0:2047];
	
	initial
	begin
		$readmemh("LU_Tables/x2048_16b.mem",ref_sen);
		$readmemh("LU_Tables/y2048_16b.mem",ref_cos);	
	end



reg signed [Q_out-1:0] ref_sen_actual,ref_sen_actual_raw;
reg signed [Q_out-1:0] ref_cos_actual,ref_cos_actual_raw;

reg [7:0] state;
localparam clean=0,idle=1,fetch_old_sample=2,fetch_ref=3,acommodate_ref=4,calc_product=5,save_product=6,acum_substract=7,acum_sum=8,update_index=9;


reg signed [Q_out-1:0] buffer_fase [0:M*N-1];
reg signed [Q_out-1:0] buffer_cuad [0:M*N-1];
reg signed [Q_out-1:0] old_sample_fase,old_sample_cuad;
reg signed [Q_out-1:0] prod_fase,prod_cuad;
reg signed [Q_out-1:0] acum_fase,acum_cuad;
reg signed [Q_out-1:0] salida_fase_reg,salida_cuad_reg;

reg signed [31:0] index_ref,index_signal;
reg signed data_out_valid_reg;

reg signed [Q_out-1:0] x_reg; 



always @ (posedge clk or negedge reset_n)
begin
	
	if(!reset_n)
	begin
		state <= clean;
		index_ref <= 0;
		index_signal <= 0;
		acum_fase <= 0;
		acum_cuad <= 0;	
		data_out_valid_reg <= 0;
	end
	else
	begin
		
		case (state)
		
			clean:
			begin
				buffer_fase[index_signal] <= 0;
				buffer_cuad[index_signal] <= 0;				
				
				if(index_signal == N*M-1)
				begin
					state <= idle;
					index_signal <= 0;
				end			
				else
					index_signal <= index_signal + 1;
			end			
		
			idle:
			begin	
				data_out_valid_reg <= 0;
				if(x_valid)
				begin
					state <= fetch_old_sample;
					x_reg <= x;
				end
				else
				begin
					state <= idle;
				end
			end
	
			fetch_old_sample:
			begin
				old_sample_fase <= buffer_fase[index_signal];
				old_sample_cuad <= buffer_cuad[index_signal];
				
				state <= fetch_ref;
			end		
			
			
			fetch_ref:
			begin
				ref_sen_actual_raw <= ref_sen [index_ref*interval];
				ref_cos_actual_raw <= ref_cos [index_ref*interval];
				
				state <= acommodate_ref;
			end
			
			acommodate_ref:
			begin
				ref_sen_actual <= (ref_sen_actual_raw >>> (16-Q_ref) ) - (ref_mean_value >>> (16-Q_ref) );
				ref_cos_actual <= (ref_cos_actual_raw >>> (16-Q_ref) ) - (ref_mean_value >>> (16-Q_ref) );
				
				state <= calc_product;
			
			end		
	
			calc_product:
			begin
				prod_fase <= x_reg * ref_sen_actual;
				prod_cuad <= x_reg * ref_cos_actual;
			
				state <= save_product;
			end
			
			save_product:
			begin
				buffer_fase[index_signal] <= prod_fase;
				buffer_cuad[index_signal] <= prod_cuad;
				
				state <= acum_substract;
			
			end
	
			acum_substract:
			begin
				acum_fase <= acum_fase - old_sample_fase;
				acum_cuad <= acum_cuad - old_sample_cuad;
				
				state <= acum_sum;
			end
			
			acum_sum:
			begin
				acum_fase <= acum_fase + prod_fase;
				acum_cuad <= acum_cuad + prod_cuad;		
			
				state <= update_index;
			end
			
			update_index:
			begin

				index_signal <= (index_signal == (M*N-1))? 0 : (index_signal+1);
				index_ref <= (index_signal == M-1)? 0: index_ref+1;
				
				
				data_out_valid_reg <= 1;		
				salida_fase_reg <= acum_fase;	
				salida_cuad_reg <= acum_cuad;
				
				state <= idle;
			end
			
			default:
				state <= idle;
	
		endcase
	end
end	

assign data_out_fase = salida_fase_reg;
assign data_out_cuad = salida_cuad_reg;
assign data_out_valid = data_out_valid_reg;


endmodule
