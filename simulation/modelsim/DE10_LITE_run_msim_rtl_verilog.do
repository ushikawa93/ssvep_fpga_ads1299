transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/remove_mean_value_state_machine.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/clock_divider.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/segment7.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/descomponer_en_digitos.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/BCD_display.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/lockin_wrapper.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/sqrt.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/calculo_resultados.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/generador_estimulo.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/db {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/db/master_pll_altpll.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/data_source.v}
vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/lockin_state_machine.v}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/spi_master.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/master_pll.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/utilities.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/fsm_txpc.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/cores/ads1299.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/test_uart_m10.vhd}
vcom -93 -work work {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/parallel_sum.vhd}

vlog -vlog01compat -work work +incdir+G:/Mi\ unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/simulation/mySimulation {G:/Mi unidad/00-Doctorado/09-SSVEP_FPGA/test_uart_m10_v4/simulation/mySimulation/ssvep_lockin_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  ssvep_lockin_tb

add wave *
view structure
view signals
run -all
