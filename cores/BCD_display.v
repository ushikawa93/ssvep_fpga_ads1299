
module BCD_display(

	input [3:0] bcd0,
	input [3:0] bcd1,
	input [3:0] bcd2,
	input [3:0] bcd3,
	input [3:0] bcd4,
	input [3:0] bcd5,
	
	output [0:6] HEX0,
	output [0:6] HEX1,
	output [0:6] HEX2,
	output [0:6] HEX3,
	output [0:6] HEX4,
	output [0:6] HEX5

);


segment7 hex0(
    .bcd(bcd0),
    .seg(HEX0)
);

segment7 hex1(
    .bcd(bcd1),
    .seg(HEX1)
);

segment7 hex2(
    .bcd(bcd2),
    .seg(HEX2)
);

segment7 hex3(
    .bcd(bcd3),
    .seg(HEX3)
);

segment7 hex4(
    .bcd(bcd4),
    .seg(HEX4)
);

segment7 hex5(
    .bcd(bcd5),
    .seg(HEX5)
);


endmodule