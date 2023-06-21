//Legal Notice: (C)2023 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module processor_amplitud_salida_single_clock_fifo (
                                                     // inputs:
                                                      aclr,
                                                      clock,
                                                      data,
                                                      rdreq,
                                                      wrreq,

                                                     // outputs:
                                                      empty,
                                                      full,
                                                      q
                                                   )
;

  output           empty;
  output           full;
  output  [ 31: 0] q;
  input            aclr;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            wrreq;


wire             empty;
wire             full;
wire    [ 31: 0] q;
  scfifo single_clock_fifo
    (
      .aclr (aclr),
      .clock (clock),
      .data (data),
      .empty (empty),
      .full (full),
      .q (q),
      .rdreq (rdreq),
      .wrreq (wrreq)
    );

  defparam single_clock_fifo.add_ram_output_register = "OFF",
           single_clock_fifo.intended_device_family = "MAX10",
           single_clock_fifo.lpm_numwords = 16,
           single_clock_fifo.lpm_showahead = "OFF",
           single_clock_fifo.lpm_type = "scfifo",
           single_clock_fifo.lpm_width = 32,
           single_clock_fifo.lpm_widthu = 4,
           single_clock_fifo.overflow_checking = "ON",
           single_clock_fifo.underflow_checking = "ON",
           single_clock_fifo.use_eab = "ON";


endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module processor_amplitud_salida_scfifo_with_controls (
                                                        // inputs:
                                                         clock,
                                                         data,
                                                         rdreq,
                                                         reset_n,
                                                         wrreq,

                                                        // outputs:
                                                         empty,
                                                         full,
                                                         q
                                                      )
;

  output           empty;
  output           full;
  output  [ 31: 0] q;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            reset_n;
  input            wrreq;


wire             empty;
wire             full;
wire    [ 31: 0] q;
  //the_scfifo, which is an e_instance
  processor_amplitud_salida_single_clock_fifo the_scfifo
    (
      .aclr  (~reset_n),
      .clock (clock),
      .data  (data),
      .empty (empty),
      .full  (full),
      .q     (q),
      .rdreq (rdreq),
      .wrreq (wrreq)
    );


endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module processor_amplitud_salida_map_avalonst_to_avalonmm (
                                                            // inputs:
                                                             avalonst_data,

                                                            // outputs:
                                                             avalonmm_data
                                                          )
;

  output  [ 31: 0] avalonmm_data;
  input   [ 31: 0] avalonst_data;


wire    [ 31: 0] avalonmm_data;
  assign avalonmm_data[31 : 0] = avalonst_data[31 : 0];

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module processor_amplitud_salida (
                                   // inputs:
                                    avalonmm_read_slave_address,
                                    avalonmm_read_slave_read,
                                    avalonst_sink_data,
                                    avalonst_sink_valid,
                                    reset_n,
                                    wrclock,

                                   // outputs:
                                    avalonmm_read_slave_readdata
                                 )
;

  output  [ 31: 0] avalonmm_read_slave_readdata;
  input            avalonmm_read_slave_address;
  input            avalonmm_read_slave_read;
  input   [ 31: 0] avalonst_sink_data;
  input            avalonst_sink_valid;
  input            reset_n;
  input            wrclock;


wire    [ 31: 0] avalonmm_map_data_out;
wire    [ 31: 0] avalonmm_read_slave_readdata;
wire    [ 31: 0] avalonst_map_data_in;
wire             clock;
wire    [ 31: 0] data;
wire             empty;
wire             full;
wire    [ 31: 0] q;
wire             rdreq;
wire             rdreq_driver;
wire             wrreq;
  //the_scfifo_with_controls, which is an e_instance
  processor_amplitud_salida_scfifo_with_controls the_scfifo_with_controls
    (
      .clock   (clock),
      .data    (data),
      .empty   (empty),
      .full    (full),
      .q       (q),
      .rdreq   (rdreq),
      .reset_n (reset_n),
      .wrreq   (wrreq)
    );

  //out, which is an e_avalon_slave
  //the_map_avalonst_to_avalonmm, which is an e_instance
  processor_amplitud_salida_map_avalonst_to_avalonmm the_map_avalonst_to_avalonmm
    (
      .avalonmm_data (avalonmm_map_data_out),
      .avalonst_data (avalonst_map_data_in)
    );

  assign clock = wrclock;
  assign rdreq_driver = (avalonmm_read_slave_address == 0) & avalonmm_read_slave_read;
  assign avalonst_map_data_in = q;
  assign rdreq = rdreq_driver;
  assign data = avalonst_sink_data;
  assign wrreq = avalonst_sink_valid;
  assign avalonmm_read_slave_readdata = avalonmm_map_data_out;
  //in, which is an e_atlantic_slave

endmodule

