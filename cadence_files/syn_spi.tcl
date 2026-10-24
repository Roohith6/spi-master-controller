# Cadence Genus Synthesis Script for SPI Master Controller
# Follows Cadence 90nm Generic flow

set_db use_scan_seqs_for_non_dft false
set_db init_lib_search_path /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/
set_db init_hdl_search_path .
read_libs typical.lib

# Read RTL files
read_hdl -v2001 {./spi_defines.v ./spi_clgen.v ./spi_shift.v ./spi_top.v}

# Elaborate top level design
elaborate spi_top

# Read timing constraints
read_sdc ./con_spi.sdc

# Synthesis efforts
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# Run synthesis step-by-step
syn_generic
syn_map
syn_opt

# Write output files
write_hdl > spi_top_netlist_typical.v
write_sdc > spi_top_typical.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > spi_top_netlist_typical.sdf
write_do_lec -revised_design ./spi_top_netlist_typical.v > spi_top_typical_dofile

# Write reporting
report_timing > timing_typical.rpt
report_timing -max_paths 10 > timing_all_typical.rpt
report_area > area_typical.rpt
report_power > power_typical.rpt
report_gates > gate_typical.rpt
