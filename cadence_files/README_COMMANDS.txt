================================================================================
CADENCE TOOLS SUITE - STEP-BY-STEP EXECUTION GUIDE (SPI MASTER CONTROLLER)
================================================================================

Server Working Directory:
Upload/Copy this entire 'cadence_files' folder to your Cadence server:
Example: ~/PD_spi/

Switch to C-shell:
  csh

--------------------------------------------------------------------------------
STAGE 1: RTL Functional Simulation (Xcelium)
--------------------------------------------------------------------------------
Command:
  xrun spi_defines.v spi_clgen.v spi_shift.v spi_top.v tb_top.sv -access +rwc -gui

Note: 'tb_top.sv' includes wb_if.sv, spi_if.sv, spi_scoreboard.sv, and spi_defines.v
which are all in the current directory.

--------------------------------------------------------------------------------
STAGE 2: Logic Synthesis (Genus)
--------------------------------------------------------------------------------
Interactive Mode (Executing step-by-step without running a single batch tcl):
  genus -gui

Then inside the Genus prompt, type each command one by one:
  set_db use_scan_seqs_for_non_dft false
  set_db init_lib_search_path /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/
  set_db init_hdl_search_path .
  read_libs typical.lib
  read_hdl -v2001 {./spi_defines.v ./spi_clgen.v ./spi_shift.v ./spi_top.v}
  elaborate spi_top
  read_sdc ./con_spi.sdc

  set_db syn_generic_effort medium
  set_db syn_map_effort medium
  set_db syn_opt_effort medium

  syn_generic
  syn_map
  syn_opt

  write_hdl > spi_top_netlist_typical.v
  write_sdc > spi_top_typical.sdc
  write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > spi_top_netlist_typical.sdf
  write_do_lec -revised_design ./spi_top_netlist_typical.v > spi_top_typical_dofile

  report_timing > timing_typical.rpt
  report_timing -max_paths 10 > timing_all_typical.rpt
  report_area > area_typical.rpt
  report_power > power_typical.rpt
  report_gates > gate_typical.rpt

(Or to run via file: genus -f syn_spi.tcl -gui)

--------------------------------------------------------------------------------
STAGE 3: Gate-Level Simulation (GLS with Xcelium)
--------------------------------------------------------------------------------
Command:
  xrun spi_top_netlist_typical.v tb_top.sv /home/cadence/install/FOUNDRY/digital/90nm/dig/vlog/gsclib090.v -timescale 1ns/1ps -access +rwc -gui

--------------------------------------------------------------------------------
STAGE 4: Logic Equivalence Checking (Conformal / LEC)
--------------------------------------------------------------------------------
Command:
  lec -xl -gui

Then in LEC GUI or command line:
  dofile spi_top_typical_dofile
================================================================================
