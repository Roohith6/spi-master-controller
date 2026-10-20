# Complete OpenROAD Physical Implementation Flow for Wishbone SPI Master Controller
# Platform: Nangate 45nm Open Cell Library

set design_name "spi_top"
set top_dir     "/home/roohith/spi_workspace/spi_openroad"
set plat_dir    "/home/roohith/OpenROAD-flow-scripts/flow/platforms/nangate45"
set rep_dir     "$top_dir/reports"
set obj_dir     "$top_dir/results"

file mkdir $rep_dir
file mkdir $obj_dir

puts "=========================================================="
puts "  STAGE 1: Load Technology & Design Netlist               "
puts "=========================================================="
read_liberty "$plat_dir/lib/NangateOpenCellLibrary_typical.lib"
read_lef     "$plat_dir/lef/NangateOpenCellLibrary.tech.lef"
read_lef     "$plat_dir/lef/NangateOpenCellLibrary.macro.mod.lef"

read_verilog "/home/roohith/OpenROAD-flow-scripts/flow/results/nangate45/spi_top/base/1_2_yosys.v"
link_design  $design_name

read_sdc     "$top_dir/constraints/spi.sdc"
source       "$plat_dir/setRC.tcl"

puts "\n=========================================================="
puts "  STAGE 2: Floorplanning & Track Creation                 "
puts "=========================================================="
# Utilization 40%, aspect ratio 1.0, core margin 2.0 um
initialize_floorplan -utilization 40 -aspect_ratio 1.0 -core_space 2.0 -site FreePDK45_38x28_10R_NP_162NW_34O
source "$plat_dir/make_tracks.tcl"

# Place IO Pins
place_pins -hor_layers metal3 -ver_layers metal2

# Insert Endcap and Tapcells
tapcell -endcap_cpp 1 -distance 14 -tapcell_master TAPCELL_X1

puts "\n=========================================================="
puts "  STAGE 3: Standard-Cell Placement                        "
puts "=========================================================="
global_placement -density 0.50
detailed_placement
check_placement

puts "\n=========================================================="
puts "  STAGE 4: Clock Tree Synthesis (CTS)                     "
puts "=========================================================="
estimate_parasitics -placement
clock_tree_synthesis -root_buf CLKBUF_X3 -buf_list "CLKBUF_X1 CLKBUF_X2 CLKBUF_X3"
detailed_placement

puts "\n=========================================================="
puts "  STAGE 5: Routing (Global & Detailed)                    "
puts "=========================================================="
set_routing_layers -signal metal2-metal10 -clock metal3-metal10
global_route -guide_file "$obj_dir/spi_top.guide"

detailed_route -guide "$obj_dir/spi_top.guide" \
               -output_drc "$rep_dir/drc_violations.rpt" \
               -droute_end_iter 40

puts "\n=========================================================="
puts "  STAGE 6: Layout Export & Final Sign-off Reports         "
puts "=========================================================="
write_def "$obj_dir/spi_top.def"

# Timing Sign-off Reports
tee -o "$rep_dir/timing_setup_wns.rpt" report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded
tee -o "$rep_dir/timing_hold_wns.rpt"  report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded
tee -o "$rep_dir/wns_tns_summary.rpt"  report_wns
tee -a "$rep_dir/wns_tns_summary.rpt"  report_tns
tee -o "$rep_dir/design_area.rpt"      report_design_area

puts "=========================================================="
puts "  PHYSICAL IMPLEMENTATION COMPLETED SUCCESSFULLY!         "
puts "=========================================================="
exit
