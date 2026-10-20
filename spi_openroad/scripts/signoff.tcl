# Sign-off Timing & Area Reporting for Wishbone SPI Master Controller
# Platform: Nangate 45nm Open Cell Library

set design_name "spi_top"
set top_dir     "/home/roohith/spi_workspace/spi_openroad"
set plat_dir    "/home/roohith/OpenROAD-flow-scripts/flow/platforms/nangate45"
set rep_dir     "$top_dir/reports"
set obj_dir     "$top_dir/results"

read_liberty "$plat_dir/lib/NangateOpenCellLibrary_typical.lib"
read_lef     "$plat_dir/lef/NangateOpenCellLibrary.tech.lef"
read_lef     "$plat_dir/lef/NangateOpenCellLibrary.macro.mod.lef"
read_def     "$obj_dir/spi_top.def"
read_sdc     "$top_dir/constraints/spi.sdc"
source       "$plat_dir/setRC.tcl"

# Parasitics estimation
estimate_parasitics -placement

puts "\n=========================================================="
puts "  GENERATING SIGN-OFF REPORTS                             "
puts "=========================================================="

set f_setup "$rep_dir/timing_setup_wns.rpt"
set f_hold  "$rep_dir/timing_hold_wns.rpt"
set f_wns   "$rep_dir/wns_tns_summary.rpt"
set f_area  "$rep_dir/design_area.rpt"

set fp [open $f_setup w]; close $fp
set fp [open $f_hold w]; close $fp
set fp [open $f_wns w]; close $fp
set fp [open $f_area w]; close $fp

report_checks -path_delay max -fields {slew cap input net fanout} -format full_clock_expanded >> $f_setup
report_checks -path_delay min -fields {slew cap input net fanout} -format full_clock_expanded >> $f_hold

set fp [open $f_wns w]
puts $fp "=== WNS / TNS SUMMARY ==="
close $fp
report_wns >> $f_wns
report_tns >> $f_wns
report_worst_slack -max >> $f_wns
report_worst_slack -min >> $f_wns

report_design_area >> $f_area

set cells [get_cells *]
set num_instances [llength $cells]
set fp [open "$rep_dir/cell_count.rpt" w]
puts $fp "Total Standard-Cell Instances: $num_instances"
close $fp

puts "\n=========================================================="
puts "  SIGN-OFF COMPLETED SUCCESSFULLY                         "
puts "  Total Instances: $num_instances                         "
puts "=========================================================="
exit
