//Verilog module.
module segment7(
    input [3:0] bcd,
    output reg [0:6] seg
    );
     

//always block for converting bcd digit into 7 segment format
    always @(bcd)
    begin
        case (bcd) //case statement
            0 : seg = 7'b0000001;
            1 : seg = 7'b1001111;
            2 : seg = 7'b0010010;
            3 : seg = 7'b0000110;
            4 : seg = 7'b1001100;
            5 : seg = 7'b0100100;
            6 : seg = 7'b0100000;
            7 : seg = 7'b0001111;
            8 : seg = 7'b0000000;
            9 : seg = 7'b0000100;
				10: seg = 7'b0001000; //a
				11: seg = 7'b1100000; //b
				12: seg = 7'b0110001; //c
				13: seg = 7'b1000010; //d
				14: seg = 7'b0110000; //e
				15: seg = 7'b0111000; //f
			
            //switch off 7 segment character when the bcd digit is not a decimal number.
            default : seg = 7'b1111111; 
        endcase
    end
    
endmodule