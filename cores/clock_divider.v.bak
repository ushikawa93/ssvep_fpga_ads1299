
module Clock_divider
(
input clock_in,
input [15:0] divisor,
output clock_out
);

reg [15:0] divisor_reg;
	always @ (posedge clock_in)	divisor_reg <= divisor ;
	
reg clock_generado,bypass;

always @ (posedge clock_in)
	bypass <= (divisor_reg > 1)? 1'b0 : 1'b1 ;
		
assign clock_out = (bypass == 1'b1) ? clock_in : clock_generado;

reg[15:0] counter=16'd0;


always @(posedge clock_in)
begin

 counter <= counter + 16'd1;
 
 if(counter >= (divisor_reg-1))
	counter <= 16'd0;

	clock_generado <= (counter < (divisor_reg >> 1))? 1'b0 : 1'b1 ;

end
endmodule