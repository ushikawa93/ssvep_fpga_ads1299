
module descomponer_en_digitos(
	input [15:0] numero,
	output [4:0] digit0,
	output [4:0] digit1,
	output [4:0] digit2,
	output [4:0] digit3,
	output [4:0] digit4,
	output [4:0] digit5
	
);

assign digit0 = numero % 10;
assign digit1 = (numero/10) % 10;
assign digit2 = (numero/100) % 10;
assign digit3 = (numero/1000) % 10;
assign digit4 = (numero/10000) % 10;
assign digit5 = (numero/100000) % 10;

endmodule


