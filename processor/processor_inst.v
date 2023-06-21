	processor u0 (
		.clk_clk                    (<connected-to-clk_clk>),                    //                  clk.clk
		.datos_muestreados_in_valid (<connected-to-datos_muestreados_in_valid>), // datos_muestreados_in.valid
		.datos_muestreados_in_data  (<connected-to-datos_muestreados_in_data>),  //                     .data
		.datos_muestreados_in_ready (<connected-to-datos_muestreados_in_ready>), //                     .ready
		.fifo_1_in_valid            (<connected-to-fifo_1_in_valid>),            //            fifo_1_in.valid
		.fifo_1_in_data             (<connected-to-fifo_1_in_data>),             //                     .data
		.fifo_1_in_ready            (<connected-to-fifo_1_in_ready>),            //                     .ready
		.fifo_2_in_valid            (<connected-to-fifo_2_in_valid>),            //            fifo_2_in.valid
		.fifo_2_in_data             (<connected-to-fifo_2_in_data>),             //                     .data
		.fifo_2_in_ready            (<connected-to-fifo_2_in_ready>),            //                     .ready
		.fifo_3_in_valid            (<connected-to-fifo_3_in_valid>),            //            fifo_3_in.valid
		.fifo_3_in_data             (<connected-to-fifo_3_in_data>),             //                     .data
		.fifo_3_in_ready            (<connected-to-fifo_3_in_ready>),            //                     .ready
		.reset_reset_n              (<connected-to-reset_reset_n>),              //                reset.reset_n
		.fifo_4_in_valid            (<connected-to-fifo_4_in_valid>),            //            fifo_4_in.valid
		.fifo_4_in_data             (<connected-to-fifo_4_in_data>),             //                     .data
		.fifo_4_in_ready            (<connected-to-fifo_4_in_ready>)             //                     .ready
	);

