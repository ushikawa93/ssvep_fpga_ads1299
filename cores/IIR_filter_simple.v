
module IIR_filter_simple

#( parameter Q_in = 64)

(

	// Entradas de control
	input clock,
	input reset,

	// Interfaz avalon streaming de entrada
	input data_valid,
	input signed [Q_in-1:0] data,	
	
	// Interfaz avalon streaming de salida
	output signed [Q_in-1:0] data_out,
	output data_out_valid

);

// Parametros de un filtro IIR para wn = 0.00125, cuantizados a 16 bits

localparam Q_coeff = 16;

localparam A1 = 65536; 	
localparam A2 = -65279;
localparam B1 = 128;
localparam B2 = 128;



// Estados de la ecuacion en diferencias
wire signed [Q_in+Q_coeff-1:0] data_in; 
	assign data_in = data;	

reg signed [Q_in+Q_coeff-1:0] x_n;
reg signed [Q_in+Q_coeff-1:0] x_n_1;
reg signed [Q_in+Q_coeff-1:0] y_n;

reg signed [Q_in+Q_coeff-1:0] MB1,MB2,MA2; 

reg signed [Q_in-1:0] data_out_reg;
reg data_out_valid_reg;


// Maquina de estados:
reg [3:0] state;
localparam idle=0,save_old_data=1,register_data=2,calculate_products=3,calculate_y=4,divide_y=5,update_output=6;


always @ (posedge clock or negedge reset)
begin

	if(!reset)
	begin	
		x_n <= 0;
		x_n_1 <= 0;
		y_n <= 0;		
		
		MB1 <= 0;
		MB2 <= 0;
		MA2 <= 0;
		
		data_out_valid_reg <= 0;
		
		state <= idle;
		
	end
	else
	begin
		case (state)
		
			idle:
			begin
				data_out_valid_reg <= 0;
				if(data_valid)
					state <= save_old_data;			
			end
			save_old_data:
			begin
				x_n_1 <= x_n;
				state <= register_data;	
			end
			register_data:
			begin
				x_n <= data_in;
				state <= calculate_products;
			end
			calculate_products:
			begin
				MB1 <= x_n * B1;
				MB2 <= x_n_1 * B2;
				MA2 <= y_n * A2;	
				state <= calculate_y;
			end
			calculate_y:
			begin
				y_n <= (  MB1 + MB2 - MA2 );
				state <= divide_y;
			end
			divide_y:
			begin
				y_n <= y_n / A1;
				state <= update_output;
			end
			update_output:
			begin
				data_out_reg <=  y_n;
				data_out_valid_reg <= 1;
				state <= idle;
			end
		endcase
	end
end

// Salidas:
assign data_out = data_out_reg;
assign data_out_valid = data_out_valid_reg ;

endmodule
