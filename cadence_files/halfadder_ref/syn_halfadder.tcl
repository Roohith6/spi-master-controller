set_db use_scan_seqs_for_non_dft false
set_db init_lib_search_path /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/
set_db init_hdl_search_path .
read_libs typical.lib
read_hdl ./top_halfadder.v
elaborate top_halfadder
read_sdc ./con_halfadder.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
#set_db / .lp_insert_clock_gating true
#set_db / .leakage_power_effort high
#set_db / .lp_power_analysis_effort high
#set_db / .design_power_effort high

syn_generic
syn_map
syn_opt

write_hdl > top_halfadder_netlist_typical.v
write_sdc > top_halfadder_typical.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > top_halfadders_netlist_typical.sdf
write_do_lec -revised_design ./top_halfadder_netlist_typical.v > top_halfadder_typical_dofile

report_timing > timing_typical.rpt
report_timing -max_paths 10 > timing_all_typical.rpt
report_area > area_typical.rpt
report_power > power_typical.rpt
report_gates > gate_typical.rpt
