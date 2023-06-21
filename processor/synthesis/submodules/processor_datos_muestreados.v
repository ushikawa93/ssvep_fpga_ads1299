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

module processor_datos_muestreados_single_clock_fifo (
                                                       // inputs:
                                                        aclr,
                                                        clock,
                                                        data,
                                                        rdreq,
                                                        wrreq,

                                                       // outputs:
                                                        empty,
                                                        full,
                                                        q,
                                                        usedw
                                                     )
;

  output           empty;
  output           full;
  output  [ 31: 0] q;
  output  [  9: 0] usedw;
  input            aclr;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            wrreq;


wire             empty;
wire             full;
wire    [ 31: 0] q;
wire    [  9: 0] usedw;
  scfifo single_clock_fifo
    (
      .aclr (aclr),
      .clock (clock),
      .data (data),
      .empty (empty),
      .full (full),
      .q (q),
      .rdreq (rdreq),
      .usedw (usedw),
      .wrreq (wrreq)
    );

  defparam single_clock_fifo.add_ram_output_register = "OFF",
           single_clock_fifo.intended_device_family = "MAX10",
           single_clock_fifo.lpm_numwords = 1024,
           single_clock_fifo.lpm_showahead = "OFF",
           single_clock_fifo.lpm_type = "scfifo",
           single_clock_fifo.lpm_width = 32,
           single_clock_fifo.lpm_widthu = 10,
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

module processor_datos_muestreados_scfifo_with_controls (
                                                          // inputs:
                                                           clock,
                                                           data,
                                                           rdreq,
                                                           reset_n,
                                                           wrreq,

                                                          // outputs:
                                                           empty,
                                                           full,
                                                           level,
                                                           q
                                                        )
;

  output           empty;
  output           full;
  output  [ 10: 0] level;
  output  [ 31: 0] q;
  input            clock;
  input   [ 31: 0] data;
  input            rdreq;
  input            reset_n;
  input            wrreq;


wire             empty;
wire             full;
wire    [ 10: 0] level;
wire    [ 31: 0] q;
wire    [  9: 0] usedw;
wire             wrreq_valid;
  //the_scfifo, which is an e_instance
  processor_datos_muestreados_single_clock_fifo the_scfifo
    (
      .aclr  (~reset_n),
      .clock (clock),
      .data  (data),
      .empty (empty),
      .full  (full),
      .q     (q),
      .rdreq (rdreq),
      .usedw (usedw),
      .wrreq (wrreq_valid)
    );

  assign level = {full,
    usedw};

  assign wrreq_valid = wrreq & ~full;

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module processor_datos_muestreados_map_avalonst_to_avalonmm (
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

module processor_datos_muestreados (
                                     // inputs:
                                      avalonmm_read_slave_address,
                                      avalonmm_read_slave_read,
                                      avalonst_sink_data,
                                      avalonst_sink_valid,
                                      reset_n,
                                      wrclock,

                                     // outputs:
                                      avalonmm_read_slave_readdata,
                                      avalonmm_read_slave_waitrequest,
                                      avalonst_sink_ready
                                   )
;

  output  [ 31: 0] avalonmm_read_slave_readdata;
  output           avalonmm_read_slave_waitrequest;
  output           avalonst_sink_ready;
  input            avalonmm_read_slave_address;
  input            avalonmm_read_slave_read;
  input   [ 31: 0] avalonst_sink_data;
  input            avalonst_sink_valid;
  input            reset_n;
  input            wrclock;


wire    [ 31: 0] avalonmm_map_data_out;
wire    [ 31: 0] avalonmm_read_slave_readdata;
wire             avalonmm_read_slave_waitrequest;
wire    [ 31: 0] avalonst_map_data_in;
wire             avalonst_sink_ready;
wire             clock;
wire    [ 31: 0] data;
wire             deassert_waitrequest;
wire             empty;
wire             full;
wire    [ 10: 0] level;
wire             no_stop_write;
reg              no_stop_write_d1;
wire    [ 31: 0] q;
wire             rdreq;
wire             rdreq_driver;
wire             ready_1;
wire             ready_selector;
wire             wrreq;
  //the_scfifo_with_controls, which is an e_instance
  processor_datos_muestreados_scfifo_with_controls the_scfifo_with_controls
    (
      .clock   (clock),
      .data    (data),
      .empty   (empty),
      .full    (full),
      .level   (level),
      .q       (q),
      .rdreq   (rdreq),
      .reset_n (reset_n),
      .wrreq   (wrreq)
    );

  //out, which is an e_avalon_slave
  assign deassert_waitrequest = avalonmm_read_slave_address & avalonmm_read_slave_read;
  assign avalonmm_read_slave_waitrequest = !deassert_waitrequest & empty;
  //the_map_avalonst_to_avalonmm, which is an e_instance
  processor_datos_muestreados_map_avalonst_to_avalonmm the_map_avalonst_to_avalonmm
    (
      .avalonmm_data (avalonmm_map_data_out),
      .avalonst_data (avalonst_map_data_in)
    );

  assign clock = wrclock;
  assign rdreq_driver = (avalonmm_read_slave_address == 0) & avalonmm_read_slave_read;
  assign avalonst_map_data_in = q;
  assign rdreq = rdreq_driver;
  assign data = avalonst_sink_data;
  assign wrreq = avalonst_sink_valid & no_stop_write_d1;
  assign no_stop_write = ready_selector & ready_1;
  assign ready_1 = !full;
  assign ready_selector = level < 1023;
  always @(posedge clock or negedge reset_n)
    begin
      if (reset_n == 0)
          no_stop_write_d1 <= 0;
      else 
        no_stop_write_d1 <= no_stop_write;
    end


  assign avalonst_sink_ready = (reset_n == 0) ? 1'b0 : (no_stop_write & no_stop_write_d1);
  assign avalonmm_read_slave_readdata = avalonmm_map_data_out;
  //in, which is an e_atlantic_slave

endmodule

