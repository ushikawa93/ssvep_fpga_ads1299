//Synthesisable Design for Finding Square root of a number.
module lockin_amplitude

    #(parameter N = 64, parameter N_lockin = 2, parameter M = 32, parameter ref_mean_value = 32767)
    (   input Clock,  //Clock
        input reset_n,  //Asynchronous active high reset.      
        input signed [N-1:0] res_fase,   //this is the number for which we want to find square root.
		  input signed [N-1:0] res_cuad,
		  input data_in_valid,
        output reg done,     //This signal goes high when output is ready
        output reg [N-1:0] amplitud  //square root of 'num_in'
    );
	 
	 
	 
	 reg [N-1:0] num_in;
	 reg [N-1:0] sq_root;
	 parameter div = N_lockin * M;
	 
	 reg data_in_valid_reg,data_in_valid_reg_1;
	 
	 reg signed [N-1:0] res_fase_reg,res_cuad_reg;
	 
	 always @ (posedge Clock)
		amplitud <= 2 * sq_root / ref_mean_value;
	 
	 always @ (posedge Clock or negedge reset_n)
	 begin
		if(reset_n == 0)
		begin
			res_fase_reg <= 0;
			res_cuad_reg <= 0;		 
			num_in <=  0;
			data_in_valid_reg <= 0;
			data_in_valid_reg_1 <= 0;
		end
	 
		else if(data_in_valid)
		begin
			res_fase_reg <= res_fase;
			res_cuad_reg <= res_cuad;		 
			data_in_valid_reg <= data_in_valid;
			
			num_in <=  (res_fase_reg/div) * (res_fase_reg/div) + (res_cuad_reg/div) * (res_cuad_reg/div);			
			data_in_valid_reg_1 <= data_in_valid_reg;			
		end
		
			
		
	 end
	   

    reg [N-1:0] a;   //original input.
    reg [N/2+1:0] left,right;     //input to adder/sub.r-remainder.
    reg signed [N/2+1:0] r;
    reg [N/2-1:0] q;    //result.
    integer i;   //index of the loop. 

    always @(posedge Clock or negedge reset_n) 
    begin
        if (reset_n == 0) begin   //reset the variables.
            done <= 0;
            sq_root <= 0;
            i = 0;
            a = 0;
            left = 0;
            right = 0;
            r = 0;
            q = 0;
        end    
        else if (data_in_valid_reg_1)
		  begin
            //Before we start the first clock cycle get the 'input' to the variable 'a'.
            if(i == 0) begin  
                a = num_in;
                done <= 0;    //reset 'done' signal.
                i = i+1;   //increment the loop index.
            end
            else if(i < N/2) begin //keep incrementing the loop index.
                i = i+1;  
            end
            //These statements below are derived from the block diagram.
            right = {q,r[N/2+1],1'b1};
            left = {r[N/2-1:0], a[N-1:N-2]};
            a = {a[N-3:0], 2'b0};  //shifting left by 2 bit.
            if ( r[N/2+1] == 1)    //add or subtract as per this bit.
                r = left + right;
            else
                r = left - right;
            q = {q[N/2-2:0], ~r[N/2+1]};
            if(i == N/2) begin    //This means the max value of loop index has reached. 
                done <= 1;    //make 'done' high because output is ready.
                i = 0; //reset loop index for beginning the next cycle.
                sq_root <= q;   //assign 'q' to the output port.
                //reset other signals for using in the next cycle.
                left = 0;
                right = 0;
                r = 0;
                q = 0;
            end
        end    
    end

endmodule