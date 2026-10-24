// SPI SystemVerilog Interface
`ifndef SPI_IF_SV
`define SPI_IF_SV

interface spi_if;
  logic        sclk;
  logic        mosi;
  logic        miso;
  logic [31:0] ss_n;

  // Monitor clocking (sampled on changes or sclk edges)
  modport slave (
    input  sclk,
    input  mosi,
    input  ss_n,
    output miso
  );

  modport monitor (
    input sclk,
    input mosi,
    input miso,
    input ss_n
  );

endinterface

`endif
