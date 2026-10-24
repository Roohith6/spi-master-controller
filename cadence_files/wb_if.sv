// Wishbone SystemVerilog Interface (Broadly simulator-compatible)
`ifndef WB_IF_SV
`define WB_IF_SV

interface wb_if(input wire clk, input wire rst);
  logic [4:0]  adr;
  logic [31:0] dat_m2s; // Master to Slave (DUT dat_i)
  logic [31:0] dat_s2m; // Slave to Master (DUT dat_o)
  logic [3:0]  sel;
  logic        we;
  logic        stb;
  logic        cyc;
  logic        ack;
  logic        err;
  logic        inta;

  initial begin
    adr     = 5'b0;
    dat_m2s = 32'b0;
    sel     = 4'b0;
    we      = 1'b0;
    stb     = 1'b0;
    cyc     = 1'b0;
  end

  modport master (
    input  clk, rst, dat_s2m, ack, err, inta,
    output adr, dat_m2s, sel, we, stb, cyc
  );

  modport monitor (
    input clk, rst, adr, dat_m2s, dat_s2m, sel, we, stb, cyc, ack, err, inta
  );

  // Synchronous Master Single-Write Task
  task automatic write(input [4:0] target_addr, input [31:0] data, input [3:0] byte_en = 4'hF);
    @(posedge clk);
    #1;
    adr     <= target_addr;
    dat_m2s <= data;
    sel     <= byte_en;
    we      <= 1'b1;
    cyc     <= 1'b1;
    stb     <= 1'b1;

    // Wait for ack
    do begin
      @(posedge clk);
    end while (!ack);

    $display("[WB WRITE] time=%0t adr=0x%02h data=0x%08h ack=%b", $time, target_addr, data, ack);
    #1;
    cyc <= 1'b0;
    stb <= 1'b0;
    we  <= 1'b0;
  endtask

  // Synchronous Master Single-Read Task
  task automatic read(input [4:0] target_addr, output [31:0] data);
    @(posedge clk);
    #1;
    adr <= target_addr;
    sel <= 4'hF;
    we  <= 1'b0;
    cyc <= 1'b1;
    stb <= 1'b1;

    do begin
      @(posedge clk);
    end while (!ack);

    #2;
    data = dat_s2m;
    $display("[WB READ] time=%0t adr=0x%02h dat_s2m=0x%08h ack=%b", $time, target_addr, dat_s2m, ack);

    cyc <= 1'b0;
    stb <= 1'b0;
  endtask

  // Wait for interrupt
  task automatic wait_for_interrupt();
    while (!inta) @(posedge clk);
  endtask

endinterface

`endif
