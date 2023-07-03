
module data_source(

	// Entradas de control
	input clk,
	input reset_n,
	input enable,
	
	
	// Salida avalon streaming
	output data_valid,
	output [31:0] data
	
);

parameter M = 16;
parameter counter_max = 32;

/////////////////////////////////////////////////
// =============== Señal =================
/////////////////////////////////////////////////	

reg [31:0] buffer [0:M-1];
	initial	$readmemh("LU_tables/x16_12b.mem",buffer);

reg [15:0] n;
reg enable_reg;
reg [31:0] data_reg;
reg [7:0] counter;



always @ (posedge clk or negedge reset_n) enable_reg <= (!reset_n)? 0 : enable; 

always @ (posedge clk or negedge reset_n)
begin

	if(!reset_n)
	begin
		n <= 0;
		counter <= 0;
	end

	else if (enable_reg)
	begin
		counter <= (counter == counter_max)? 0 : counter +1;
		n <= (counter == counter_max)? ( (n == M-1) ? 0:n+1 ) : n;
	end
	
end

/////////////////////////////////////////////////
// =============== Salida =================
/////////////////////////////////////////////////	

assign data = buffer[n];
assign data_valid = enable_reg && (counter == counter_max);


endmodule
