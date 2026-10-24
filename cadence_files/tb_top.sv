// Top-Level SystemVerilog Testbench for Wishbone SPI Master Controller
`timescale 1ns/1ps

`include "spi_defines.v"
`include "wb_if.sv"
`include "spi_if.sv"
`include "spi_scoreboard.sv"

module tb_top;

  // 1. Clock and Reset generation
  logic wb_clk = 0;
  logic wb_rst = 1;

  always #5 wb_clk = ~wb_clk; // 100 MHz clock (10 ns period)

  // 2. Interface Instantiation
  wb_if  wb_bus(wb_clk, wb_rst);
  spi_if spi_bus();

  // 3. DUT (Device Under Test) Instantiation
  spi_top dut (
    // Wishbone signals
    .wb_clk_i(wb_clk),
    .wb_rst_i(wb_rst),
    .wb_adr_i(wb_bus.adr),
    .wb_dat_i(wb_bus.dat_m2s),
    .wb_dat_o(wb_bus.dat_s2m),
    .wb_sel_i(wb_bus.sel),
    .wb_we_i(wb_bus.we),
    .wb_stb_i(wb_bus.stb),
    .wb_cyc_i(wb_bus.cyc),
    .wb_ack_o(wb_bus.ack),
    .wb_err_o(wb_bus.err),
    .wb_int_o(wb_bus.inta),

    // SPI signals
    .ss_pad_o(spi_bus.ss_n),
    .sclk_pad_o(spi_bus.sclk),
    .mosi_pad_o(spi_bus.mosi),
    .miso_pad_i(spi_bus.miso)
  );

  // 4. Scoreboard Instance
  spi_scoreboard scb();

  // 5. Loopback / Slave model: Loop MOSI to MISO with configurable invert/delay
  bit loopback_enable = 1;
  assign spi_bus.miso = loopback_enable ? spi_bus.mosi : 1'b0;

  // 6. Test sequence tasks
  task automatic reset_sequence();
    $display("[TB] Applying Reset... wb_rst=%b wb_bus.rst=%b dut.wb_rst_i=%b dut.wb_ack_o=%b", wb_rst, wb_bus.rst, dut.wb_rst_i, dut.wb_ack_o);
    wb_rst = 1;
    repeat(10) @(posedge wb_clk);
    $display("[TB] Mid Reset: wb_rst=%b wb_bus.rst=%b dut.wb_rst_i=%b dut.wb_ack_o=%b", wb_rst, wb_bus.rst, dut.wb_rst_i, dut.wb_ack_o);
    @(posedge wb_clk);
    wb_rst = 0;
    repeat(5) @(posedge wb_clk);
    $display("[TB] Reset Released: wb_rst=%b wb_bus.rst=%b dut.wb_rst_i=%b dut.wb_ack_o=%b", wb_rst, wb_bus.rst, dut.wb_rst_i, dut.wb_ack_o);
  endtask

  // Register addresses: (offset << 2) for 32-bit word aligned bus
  localparam [4:0] ADDR_RX_0    = 5'd0 << 2;
  localparam [4:0] ADDR_RX_1    = 5'd1 << 2;
  localparam [4:0] ADDR_RX_2    = 5'd2 << 2;
  localparam [4:0] ADDR_RX_3    = 5'd3 << 2;
  localparam [4:0] ADDR_TX_0    = 5'd0 << 2;
  localparam [4:0] ADDR_TX_1    = 5'd1 << 2;
  localparam [4:0] ADDR_TX_2    = 5'd2 << 2;
  localparam [4:0] ADDR_TX_3    = 5'd3 << 2;
  localparam [4:0] ADDR_CTRL    = 5'd4 << 2;
  localparam [4:0] ADDR_DIVIDER = 5'd5 << 2;
  localparam [4:0] ADDR_SS      = 5'd6 << 2;

  // Test 1: Register Read/Write verification
  task automatic test_registers();
    logic [31:0] rdata;
    $display("\n--- Starting Test 1: Register Accessibility Test ---");

    // Test Divider Register
    wb_bus.write(ADDR_DIVIDER, 32'h0000_0004);
    wb_bus.read(ADDR_DIVIDER, rdata);
    if (rdata[15:0] === 16'h0004) begin
      $display("[PASS] Divider Register write/read match: 0x%04h", rdata[15:0]);
      scb.passed_transfers++;
    end else begin
      $display("[FAIL] Divider Register mismatch! Expected 0x0004, got 0x%04h", rdata[15:0]);
      scb.failed_transfers++;
    end
    scb.total_transfers++;

    // Test Slave-Select Register
    wb_bus.write(ADDR_SS, 32'h0000_0001);
    wb_bus.read(ADDR_SS, rdata);
    if (rdata === 32'h0000_0001) begin
      $display("[PASS] SS Register write/read match: 0x%08h", rdata);
      scb.passed_transfers++;
    end else begin
      $display("[FAIL] SS Register mismatch! Expected 0x00000001, got 0x%08h", rdata);
      scb.failed_transfers++;
    end
    scb.total_transfers++;
  endtask

  // Test 2: 8-bit SPI Transfer
  task automatic test_8bit_transfer();
    logic [31:0] rdata;
    $display("\n--- Starting Test 2: 8-Bit SPI Transfer Test ---");

    // Configure divider = 2 (fast clock for simulation)
    wb_bus.write(ADDR_DIVIDER, 32'h0000_0002);
    // Select slave 0
    wb_bus.write(ADDR_SS, 32'h0000_0001);
    // Write TX_0 = 8'hA5
    wb_bus.write(ADDR_TX_0, 32'h0000_00A5);

    scb.add_expected_miso(128'h0000_0000_0000_0000_0000_0000_0000_00A5);

    // Set CTRL: char_len = 8, Tx on posedge (tx_neg=0), Rx on negedge (rx_neg=1), ASS = 1, IE = 1, GO = 1
    // Bit 13: ASS=1, Bit 12: IE=1, Bit 11: LSB=0, Bit 10: Tx_neg=0, Bit 9: Rx_neg=1, Bit 8: GO=1, Bits 6:0: char_len=8
    // 0x3308 (bit 8 = 1 for GO)
    wb_bus.write(ADDR_CTRL, 32'h0000_3308);

    // Wait for transfer completion (poll GO bit or wait interrupt)
    do begin
      repeat(10) @(posedge wb_clk);
      wb_bus.read(ADDR_CTRL, rdata);
    end while (rdata[`SPI_CTRL_GO]);

    $display("[TB] 8-Bit SPI Transfer Complete. Reading RX_0...");
    wb_bus.read(ADDR_RX_0, rdata);
    scb.check_rx_register({96'b0, rdata}, 8);
  endtask

  // Test 3: 32-bit SPI Transfer
  task automatic test_32bit_transfer();
    logic [31:0] rdata;
    $display("\n--- Starting Test 3: 32-Bit SPI Transfer Test ---");

    wb_bus.write(ADDR_DIVIDER, 32'h0000_0002);
    wb_bus.write(ADDR_SS, 32'h0000_0002); // Slave 1
    wb_bus.write(ADDR_TX_0, 32'hDEAD_BEEF);

    scb.add_expected_miso(128'h0000_0000_0000_0000_0000_0000_DEAD_BEEF);

    // CTRL: char_len = 32 (7'd32 = 7'h20), ASS=1, IE=1, Tx_neg=0, Rx_neg=1, GO=1 -> 0x3320
    wb_bus.write(ADDR_CTRL, 32'h0000_3320);

    do begin
      repeat(10) @(posedge wb_clk);
      wb_bus.read(ADDR_CTRL, rdata);
    end while (rdata[`SPI_CTRL_GO]);

    $display("[TB] 32-Bit SPI Transfer Complete. Reading RX_0...");
    wb_bus.read(ADDR_RX_0, rdata);
    scb.check_rx_register({96'b0, rdata}, 32);
  endtask

  // Test 4: 128-bit Full SPI Transfer with Interrupt
  task automatic test_128bit_transfer();
    logic [31:0] r0, r1, r2, r3;
    logic [31:0] rdata;
    logic [127:0] rx_128;
    $display("\n--- Starting Test 4: 128-Bit Full-Word SPI Transfer & Interrupt Test ---");

    wb_bus.write(ADDR_DIVIDER, 32'h0000_0001); // High speed
    wb_bus.write(ADDR_SS, 32'h0000_0004);      // Slave 2

    // Load 128 bits into TX_0, TX_1, TX_2, TX_3
    wb_bus.write(ADDR_TX_0, 32'h1122_3344);
    wb_bus.write(ADDR_TX_1, 32'h5566_7788);
    wb_bus.write(ADDR_TX_2, 32'h99AA_BBCC);
    wb_bus.write(ADDR_TX_3, 32'hDDEE_FF00);

    scb.add_expected_miso({32'hDDEE_FF00, 32'h99AA_BBCC, 32'h5566_7788, 32'h1122_3344});

    // CTRL: char_len = 0 (means 128 in 128-bit mode), ASS=1, IE=1, Tx_neg=0, Rx_neg=1, GO=1 -> 0x3300
    wb_bus.write(ADDR_CTRL, 32'h0000_3300);

    // Wait for transfer completion by polling GO bit
    $display("[TB] Transfer in progress... Polling GO bit...");
    do begin
      repeat(10) @(posedge wb_clk);
      wb_bus.read(ADDR_CTRL, rdata);
    end while (rdata[`SPI_CTRL_GO]);
    $display("[TB] Transfer Completed. Reading all 128-bit RX registers...");

    wb_bus.read(ADDR_RX_0, r0);
    wb_bus.read(ADDR_RX_1, r1);
    wb_bus.read(ADDR_RX_2, r2);
    wb_bus.read(ADDR_RX_3, r3);

    rx_128 = {r3, r2, r1, r0};
    scb.check_rx_register(rx_128, 128);
  endtask

  // 7. Main simulation execution
  initial begin
    $dumpfile("spi_tb.vcd");
    $dumpvars(0, tb_top);

    reset_sequence();
    test_registers();
    test_8bit_transfer();
    test_32bit_transfer();
    test_128bit_transfer();

    #100;
    scb.report();
    $finish;
  end

endmodule
