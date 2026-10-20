current_design spi_top

set clk_name wb_clk_i
set clk_port_name wb_clk_i
set clk_period 10.0
set clk_io_pct 0.2

create_clock -name $clk_name -period $clk_period [get_ports $clk_port_name]
set_clock_uncertainty 0.300 [get_clocks $clk_name]

set_input_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_inputs]
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
