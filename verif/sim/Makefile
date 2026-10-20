# Simulation Makefile for Wishbone SPI Master Controller
# Supports: Icarus Verilog (iverilog + vvp) and GTKWave

SIM_SRC_DIR = ../../spi_openroad/rtl
VIP_DIR     = ../vip
TB_DIR      = ../tb

RTL_SRCS    = $(SIM_SRC_DIR)/spi_defines.v \
              $(SIM_SRC_DIR)/spi_clgen.v \
              $(SIM_SRC_DIR)/spi_shift.v \
              $(SIM_SRC_DIR)/spi_top.v

TB_SRCS     = $(TB_DIR)/tb_top.sv

OUT_BIN     = sim_spi
VCD_FILE    = spi_tb.vcd

.PHONY: all sim wave clean

all: sim

$(OUT_BIN): $(RTL_SRCS) $(TB_SRCS) $(VIP_DIR)/wb_if.sv $(VIP_DIR)/spi_if.sv $(VIP_DIR)/spi_scoreboard.sv
	iverilog -g2012 -I $(SIM_SRC_DIR) -I $(VIP_DIR) -o $(OUT_BIN) $(RTL_SRCS) $(TB_SRCS)

sim: $(OUT_BIN)
	vvp $(OUT_BIN)

wave: sim
	gtkwave $(VCD_FILE) &

clean:
	rm -f $(OUT_BIN) $(VCD_FILE)
