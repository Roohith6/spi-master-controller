export DESIGN_NAME = spi_top
export PLATFORM    = nangate45

export VERILOG_FILES = $(DESIGN_HOME)/src/$(DESIGN_NAME)/spi_defines.v \
                       $(DESIGN_HOME)/src/$(DESIGN_NAME)/spi_clgen.v \
                       $(DESIGN_HOME)/src/$(DESIGN_NAME)/spi_shift.v \
                       $(DESIGN_HOME)/src/$(DESIGN_NAME)/spi_top.v

export SDC_FILE      = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

# Target clock period (ns) -> 100 MHz
export CLOCK_PERIOD  = 10.0

export CORE_UTILIZATION ?= 40
export PLACE_DENSITY    ?= 0.50
export TNS_END_PERCENT  = 100
