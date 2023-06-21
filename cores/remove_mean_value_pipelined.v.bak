
module remove_mean_value_pipelined(
	input clock,
	input reset,

	input signed [31:0] data_in,
	input data_in_valid,

	output reg signed [31:0] data_out,
	output reg data_out_valid
);

parameter M=32; 

reg signed [31:0] data_etapa2,data_in_etapa3,data_out_etapa3,data_aux;

reg [15:0] index,i; initial index=0;
reg [15:0] index_retrasado;

reg signed [31:0] data_mem [0:M-1];

reg clear;

reg signed [31:0] acumulador; initial acumulador=0;


//Estos son para atrasar el data_out_valid... Hacerlo asi es mas rapido!
reg data_valid_aux1,data_valid_aux2,data_valid_aux3,data_valid_aux4; 
initial data_valid_aux1=0;

always @ (posedge clock or negedge reset)
begin
	
	
	if(!reset)
	begin
		acumulador <= 0;
		index <= 0;index_retrasado<=0;
		i <= 0;
		
		data_out_valid <= 0;
		
		data_valid_aux1 <= 0;
		data_valid_aux2 <= 0;
		data_valid_aux3 <= 0;
		data_valid_aux4 <= 0;
		
		data_aux <= 0;
		data_etapa2 <= 0;
		data_in_etapa3<=0;
		data_out_etapa3<=0;
		
		clear <= 1;		
		
	end

	else if(data_in_valid && reset)
	begin
	
		index <= (index== (M-1))? 0: index+1;
		index_retrasado <= index;
		data_valid_aux1 <= ((index == (M-1))? 1:0 ) || data_valid_aux1;	
		
		// Registrar dato entrante (1 etapa)
		data_etapa2 <= data_in;
		data_valid_aux2 <= data_valid_aux1;
		
		// Guardar dato en arreglo (2 etapa)
		data_mem[index_retrasado] <= data_etapa2;		
		
		data_in_etapa3 <= data_etapa2;
		data_out_etapa3 <= data_mem[index_retrasado];
		
		data_valid_aux3 <= data_valid_aux2;
				
		// Actualizar acumulador (3 etapa)	
		acumulador <= acumulador + data_in_etapa3 - data_out_etapa3;
		data_aux <= data_in_etapa3;
		
		data_valid_aux4 <= data_valid_aux3;
		
		// Actualizar salida (4 etapa)
		data_out <= data_aux - (acumulador >> 5);
		
		data_out_valid <= data_valid_aux4;
				
	end 	
	
	else if(clear)	// Clear arrays		
	begin
		i<=i+1;
		data_mem[i] <= 0;
		clear<=(i==M)? 0:1;
	end
	
	else	
		data_out_valid<=0;	
	
end

endmodule