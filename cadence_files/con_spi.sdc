# Timing constraints for Wishbone SPI Master Controller
create_clock -name wb_clk_i -period 10.0 [get_ports wb_clk_i]
set_clock_transition -rise 0.1 [get_clocks wb_clk_i]
set_clock_transition -fall 0.1 [get_clocks wb_clk_i]
set_clock_uncertainty 0.01 [get_ports wb_clk_i]

set_input_delay -max 2.0 [remove_from_collection [all_inputs] [get_ports wb_clk_i]] -clock [get_clocks wb_clk_i]
set_output_delay -max 2.0 [all_outputs] -clock [get_clocks wb_clk_i]

group_path -name I2R -from [all_inputs] -to [all_registers]
group_path -name R2O -from [all_registers] -to [all_outputs]
group_path -name R2R -from [all_registers] -to [all_registers]
group_path -name I2O -from [all_inputs] -to [all_outputs]
