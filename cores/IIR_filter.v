
module IIR_filter

	#(
		// Parametros de optimizacion
		parameter enable_pipeline = 1,
		parameter full_input = 0,
		parameter coef_manuales = 0
	 )
(

	// Entradas de control
	input clock,
	input reset,
	input enable,
	input bypass,
		
	// Interfaz avalon streaming de entrada
	input data_valid,
	input signed [63:0] data,	
	
	// Interfaz avalon streaming de salida
	output signed [63:0] data_out,
	output data_out_valid,

	// Coeficientes del filtro (cuantizados a 16 bits, con A1=2^16):
	input signed [31:0] B1_in,
	input signed [31:0] B2_in,
	input signed [31:0] A2_in,	
	
	// Señales auxiliares
	output ready,
	output fifo_lleno

);




// Parametros de un filtro IIR para wn = 0.00125, cuantizados a 16 bits
// Sino pueden ingresarse mientras enable no este en 1:
localparam A1 = 65536; 
	localparam log2A1 = 16;
	
localparam A2_default = -65279;
localparam B1_default = 128;
localparam B2_default = 128;

reg signed [63:0] B1,B2,A2;

initial begin
	B1 <= B1_default;
	B2 <= B2_default;
	A2 <= A2_default;
end

always @ (posedge clock )
begin
	if(!enable && coef_manuales)
	begin
		B1 <= B1_in;
		B2 <= B2_in;
		A2 <= A2_in;		
	end
end


// Parametros para controlar que datos mando a los FIFO
parameter FIFO_DEPTH = 8192;
parameter START_SENDING = 0;

// Como trunco 16 bits para la division y la señal esta cuantizada en 14 tengo que agregar algunos bits para
// no tener errores despues... antes de salir le saco esos bits...
parameter Q_extra = 16;


// Estados de la ecuacion en diferencias
wire signed [63:0] data_in; 
	assign data_in = (data <<< Q_extra);	// Aca agrego esa cuantizacion que decia

reg signed [63:0] x_n;
reg signed [63:0] x_n_1;
reg signed [63:0] y_n;

reg signed [63:0] MB1,MB2,MA2; 

// Contador auxiliar para saber cuando se termina la operacion
reg [15:0] counter;

always @ (posedge clock or negedge reset)
begin

	if(!reset)
	begin	
		x_n <= 0;
		x_n_1 <= 0;
		y_n <= 0;		
		counter <= 0;
		
		MB1 <= 0;
		MB2 <= 0;
		MA2 <= 0;

	end
	else if (enable)
	begin				
		if(data_valid)
		begin
			if(enable_pipeline)
			begin
				x_n   <= data_in;	
				x_n_1 <= x_n;		
				
				MB1 <= x_n * B1;
				MB2 <= x_n_1 * B2; 
				
				// Salida. Si el que instancia esto me asegura que no entra una muestra en cada ciclo
				// de reloj se puede optimizar sino no...
				if(!full_input)
					y_n <= (  MB1 + MB2 - MA2 ) >>> log2A1;
				else
					y_n <= (  MB1 + MB2 - A2*y_n ) >>> log2A1;
			end
			else
			begin
				x_n_1 <= data_in;		
				y_n <= (  B1 * data_in + B2 * x_n_1 - A2 * y_n ) >>> log2A1;		
				counter <= (counter == FIFO_DEPTH + START_SENDING )? counter: counter+1;
			end
	
			counter <= (counter == FIFO_DEPTH + START_SENDING )? counter: counter+1;
					
		end
		if(enable_pipeline && !full_input)
			MA2 <= A2*y_n;	
			
	end
end

// Salidas:
assign data_out = (bypass)? data :  (y_n >>> Q_extra) ;
assign data_out_valid = (bypass)? data_valid : (data_valid && (counter > START_SENDING) );

// Salidas auxiliares
assign ready = reset; // El unico momento en que no puede calcular es cuando reset = 0
assign fifo_lleno = (counter == FIFO_DEPTH + START_SENDING);

endmodule
