# OpenROAD-flow-scripts (ORFS) Configuration for Wishbone SPI Master Controller

export DESIGN_NAME    = spi_top
export PLATFORM       = nangate45

# Design paths
export DESIGN_HOME   ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

export VERILOG_FILES  = $(DESIGN_HOME)/rtl/spi_defines.v \
                        $(DESIGN_HOME)/rtl/spi_clgen.v \
                        $(DESIGN_HOME)/rtl/spi_shift.v \
                        $(DESIGN_HOME)/rtl/spi_top.v

export SDC_FILE       = $(DESIGN_HOME)/constraints/spi.sdc

# Target clock period (ns) -> 100 MHz
export CLOCK_PERIOD   = 10.0

# Physical constraints
# 40% target core utilization gives optimal routability and timing closure
export CORE_UTILIZATION = 40
export CORE_ASPECT_RATIO = 1.0
export CORE_MARGIN      = 3.0

# Placement density
export PLACE_DENSITY  = 0.50

# Fast route / global route options
export TIE_SEPARATION = 5.0
