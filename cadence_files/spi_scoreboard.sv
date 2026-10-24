// SPI Verification Scoreboard & Self-Checking Monitor
// Compatible with all simulators: Icarus Verilog, Verilator, Questa, ModelSim, VCS
`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

module spi_scoreboard;

  integer total_transfers;
  integer passed_transfers;
  integer failed_transfers;

  // Fixed-size FIFO array for queueing expected transfers
  reg [127:0] expected_mosi_fifo [0:255];
  integer mosi_wr_ptr;
  integer mosi_rd_ptr;
  integer mosi_count;

  reg [127:0] expected_miso_fifo [0:255];
  integer miso_wr_ptr;
  integer miso_rd_ptr;
  integer miso_count;

  initial begin
    total_transfers  = 0;
    passed_transfers = 0;
    failed_transfers = 0;
    mosi_wr_ptr      = 0;
    mosi_rd_ptr      = 0;
    mosi_count       = 0;
    miso_wr_ptr      = 0;
    miso_rd_ptr      = 0;
    miso_count       = 0;
  end

  // Add expected transmit word
  task automatic add_expected_mosi(input [127:0] data);
    begin
      expected_mosi_fifo[mosi_wr_ptr] = data;
      mosi_wr_ptr = (mosi_wr_ptr + 1) % 256;
      mosi_count = mosi_count + 1;
    end
  endtask

  // Add expected receive word
  task automatic add_expected_miso(input [127:0] data);
    begin
      expected_miso_fifo[miso_wr_ptr] = data;
      miso_wr_ptr = (miso_wr_ptr + 1) % 256;
      miso_count = miso_count + 1;
    end
  endtask

  // Check MOSI captured word against expected
  task automatic check_mosi(input [127:0] actual, input integer num_bits);
    reg [127:0] exp;
    reg [127:0] mask;
    begin
      total_transfers = total_transfers + 1;
      if (num_bits >= 128)
        mask = {128{1'b1}};
      else
        mask = (128'b1 << num_bits) - 1'b1;

      if (mosi_count == 0) begin
        $display("[SCOREBOARD ERROR] Unexpected MOSI transfer observed! Actual=0x%032h", actual & mask);
        failed_transfers = failed_transfers + 1;
      end else begin
        exp = expected_mosi_fifo[mosi_rd_ptr] & mask;
        mosi_rd_ptr = (mosi_rd_ptr + 1) % 256;
        mosi_count = mosi_count - 1;

        actual = actual & mask;

        if (actual === exp) begin
          $display("[SCOREBOARD PASS] MOSI Match (%0d bits): 0x%0h", num_bits, actual);
          passed_transfers = passed_transfers + 1;
        end else begin
          $display("[SCOREBOARD FAIL] MOSI Mismatch (%0d bits)! Expected: 0x%0h, Actual: 0x%0h", num_bits, exp, actual);
          failed_transfers = failed_transfers + 1;
        end
      end
    end
  endtask

  // Check Wishbone read RX word against expected MISO
  task automatic check_rx_register(input [127:0] actual, input integer num_bits);
    reg [127:0] exp;
    reg [127:0] mask;
    begin
      total_transfers = total_transfers + 1;
      if (num_bits >= 128)
        mask = {128{1'b1}};
      else
        mask = (128'b1 << num_bits) - 1'b1;

      if (miso_count == 0) begin
        $display("[SCOREBOARD ERROR] Unexpected RX register read! Actual=0x%032h", actual & mask);
        failed_transfers = failed_transfers + 1;
      end else begin
        exp = expected_miso_fifo[miso_rd_ptr] & mask;
        miso_rd_ptr = (miso_rd_ptr + 1) % 256;
        miso_count = miso_count - 1;

        actual = actual & mask;

        if (actual === exp) begin
          $display("[SCOREBOARD PASS] RX Register Match (%0d bits): 0x%0h", num_bits, actual);
          passed_transfers = passed_transfers + 1;
        end else begin
          $display("[SCOREBOARD FAIL] RX Register Mismatch (%0d bits)! Expected: 0x%0h, Actual: 0x%0h", num_bits, exp, actual);
          failed_transfers = failed_transfers + 1;
        end
      end
    end
  endtask

  // Print final test summary
  task automatic report();
    begin
      $display("\n=================================================");
      $display("           VERIFICATION SUMMARY REPORT           ");
      $display("=================================================");
      $display("  Total Checks:  %0d", total_transfers);
      $display("  Passed:        %0d", passed_transfers);
      $display("  Failed:        %0d", failed_transfers);
      if (failed_transfers == 0 && total_transfers > 0) begin
        $display("  STATUS: *** ALL TESTS PASSED SUCCESSFULLY ***");
      end else begin
        $display("  STATUS: *** TEST FAILED WITH %0d ERRORS ***", failed_transfers);
      end
      $display("=================================================\n");
    end
  endtask

endmodule

`endif
