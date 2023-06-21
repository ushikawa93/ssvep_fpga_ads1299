
module generador_estimulo

#(
		parameter M = 64
)
(
	input reset_n,
	input clk,
	input data_valid,
	
	output sinc_output
	
);

reg [31:0] counter;


always @ (posedge clk)
begin

	if(!reset_n)
	begin
		
		counter <= 0;
		
	end
	
	else if(data_valid)
	
	begin
	
		counter <= counter +1 ;
		
		if(counter == M-1)
		begin
			counter <= 0;
		end
	
	end
end

assign sinc_output = (counter < (M >> 1))? 1:0 ;



endmodule 
