`include "axi/typedef.svh"
`include "o2a_dpd.svh"

module obi_2_axi_core_tb;

  // PARAMETERS
  parameter int OBI_ADDRW = 32;  // Address width
  parameter int OBI_DATAW = 32;  // Data Width
  parameter int OBI_STRBW = (OBI_DATAW / 8);  // Strobe width

  parameter int OBI_CLK_SPEED = 5000;  // Clock speed range in MHz

  // TYPEDEFS
  typedef struct packed {
    logic [OBI_ADDRW-1:0] addr;
    logic we;
    logic [OBI_DATAW-1:0] wdata;
    logic [OBI_STRBW-1:0] be;
  } obi_req_info_t;

  // WIRES AND SIGNALS
  `AXI_TYPEDEF_ALL(o2a_tb, logic [OBI_ADDRW-1:0], logic [3:0], logic [OBI_DATAW-1:0],
                   logic [OBI_STRBW-1:0], logic [7:0])

  logic                         clk_i;  // OBI Clock
  logic                         arst_ni;  // Async Global Reset
  logic         [OBI_ADDRW-1:0] addr_i;  // OBI request address
  logic                         we_i;  // OBI write enable
  logic         [OBI_DATAW-1:0] wdata_i;  // OBI write data
  logic         [OBI_STRBW-1:0] be_i;  // OBI byte enable
  logic                         req_i;  // OBI Request
  logic                         gnt_o;  // OBI Grant
  logic                         rvalid_o;  // OBI rvalid
  logic         [OBI_DATAW-1:0] rdata_o;  // OBI read data
  o2a_tb_req_t                  axi_req_o;  // AXI Request
  o2a_tb_resp_t                 axi_resp_i;  // AXI Response

  // REGISTERS
  logic         [OBI_DATAW-1:0] local_data_reg;
  int                           fail_count;

  // FLAGS
  logic                         initialization_failed;
  logic                         obi_to_axi_cnv_failed;


  // DUT INSTANTIATION
  obi_2_axi_core #(
      .OBI_ADDRW (OBI_ADDRW),
      .OBI_DATAW (OBI_DATAW),
      .OBI_STRBW (OBI_STRBW),
      .axi_req_t (o2a_tb_req_t),
      .axi_resp_t(o2a_tb_resp_t)
  ) u_dut (
      .clk_i(clk_i),
      .arst_ni(arst_ni),
      .addr_i(addr_i),
      .we_i(we_i),
      .wdata_i(wdata_i),
      .be_i(be_i),
      .req_i(req_i),
      .gnt_o(gnt_o),
      .rvalid_o(rvalid_o),
      .rdata_o(rdata_o),
      .axi_req_o(axi_req_o),
      .axi_resp_i(axi_resp_i)
  );

  // MACROS AND AUTOMATA
  `START_CLK(clk_i, OBI_CLK_SPEED)

  // TASKS AND FUNCTIONS
  task automatic apply_global_reset();
    arst_ni <= '1;
    #200ns;
    arst_ni <= '0;
    req_i <= '0;
    axi_resp_i <= '0;
    #700ns;
    arst_ni <= '1;
  endtask

  task automatic check_initialization();
    logic rst_gnt_o_high = '0;
    logic rst_aw_valid_high = '0;
    logic rst_w_valid_high = '0;
    logic rst_ar_valid_high = '0;
    logic rst_release_gnt_o_high = '0;
    logic rst_release_aw_valid_high = '0;
    logic rst_release_w_valid_high = '0;
    logic rst_release_ar_valid_high = '0;

    initialization_failed = '0;

    @(negedge arst_ni);
    if (gnt_o) begin
      rst_gnt_o_high = '1;
      `ERROR_MSG("gnt_o was found asserted on reset")
    end else begin
      `HIGHLIGHT_MSG("gnt_o was found de-asserted on reset")
    end

    if (axi_req_o.aw_valid) begin
      rst_aw_valid_high = '1;
      `ERROR_MSG("axi aw_valid was found asserted on reset")
    end
    begin
      `HIGHLIGHT_MSG("axi aw_valid was found de-asserted on reset")
    end

    if (axi_req_o.w_valid) begin
      rst_w_valid_high = '1;
      `ERROR_MSG("axi w_valid was found asserted on reset")
    end
    begin
      `HIGHLIGHT_MSG("axi w_valid was found de-asserted on reset")
    end

    if (axi_req_o.ar_valid) begin
      rst_ar_valid_high = '1;
      `ERROR_MSG("axi ar_valid was found asserted on reset")
    end
    begin
      `HIGHLIGHT_MSG("axi ar_valid was found de-asserted on reset")
    end

    @(posedge arst_ni);
    if (gnt_o) begin
      rst_release_gnt_o_high = '1;
      `ERROR_MSG("gnt_o was found asserted on reset release")
    end else begin
      `HIGHLIGHT_MSG("gnt_o was found de-asserted on reset release")
    end

    if (axi_req_o.aw_valid) begin
      rst_release_aw_valid_high = '1;
      `ERROR_MSG("axi aw_valid was found asserted on reset release")
    end
    begin
      `HIGHLIGHT_MSG("axi aw_valid was found de-asserted on reset release")
    end

    if (axi_req_o.w_valid) begin
      rst_release_w_valid_high = '1;
      `ERROR_MSG("axi w_valid was found asserted on reset release")
    end
    begin
      `HIGHLIGHT_MSG("axi w_valid was found de-asserted on reset release")
    end

    if (axi_req_o.ar_valid) begin
      rst_release_ar_valid_high = '1;
      `ERROR_MSG("axi ar_valid was found asserted on reset release")
    end
    begin
      `HIGHLIGHT_MSG("axi ar_valid was found de-asserted on reset release")
    end

    if (rst_gnt_o_high |
      rst_aw_valid_high |
      rst_w_valid_high |
      rst_ar_valid_high |
      rst_release_gnt_o_high |
      rst_release_aw_valid_high |
      rst_release_w_valid_high |
      rst_release_ar_valid_high) begin
      initialization_failed = '1;
    end
  endtask

  task automatic check_and_service_xactn_conversion();
    obi_req_info_t current_req_info;

    logic req_ar_addr_mismatch = '0;
    logic req_ar_len_unsupported = '0;

    logic req_aw_addr_mismatch = '0;
    logic req_aw_len_unsupported = '0;

    logic req_wdata_mismatch = '0;
    logic req_wstrb_mismatch = '0;
    logic req_wlast_not_found = '0;

    logic resp_arready_not_found = '0;
    logic obi_grant_not_propagated = '0;
    logic obi_rvalid_not_propagated = '0;
    logic obi_rdata_mismatch = '0;

    logic [OBI_DATAW-1:0] prev_local_data_reg;

    obi_to_axi_cnv_failed = '0;
    prev_local_data_reg   = local_data_reg;

    @(posedge req_i);

    current_req_info.addr = addr_i;
    current_req_info.we = we_i;
    current_req_info.wdata = wdata_i;
    current_req_info.be = be_i;

    @(posedge clk_i);
    axi_resp_i.ar_ready <= '1;

    do @(posedge clk_i); while (axi_req_o.ar_valid);

    if (axi_req_o.ar.addr !== current_req_info.addr) begin
      `ERROR_MSG("AXI Read request address did not match that of OBI request")
      req_ar_addr_mismatch = '1;
    end else `HIGHLIGHT_MSG("AXI Read request address matched that of OBI request")
    if (axi_req_o.ar.len !== 0) begin
      `ERROR_MSG("AXI Read request unsupported length")
      req_ar_len_unsupported = '1;
    end else `HIGHLIGHT_MSG("AXI Read request supported length")

    axi_resp_i.ar_ready <= '0;

    axi_resp_i.r_valid  <= '1;
    axi_resp_i.r.data   <= local_data_reg;
    axi_resp_i.r.last   <= '1;


    if (current_req_info.we) begin
      @(posedge clk_i);
      axi_resp_i.aw_ready <= '1;

      do @(posedge clk_i); while (axi_req_o.aw_valid);

      if (axi_req_o.aw.addr !== current_req_info.addr) begin
        `ERROR_MSG("AXI write request address did not match that of OBI request")
        req_aw_addr_mismatch = '1;
      end else `HIGHLIGHT_MSG("AXI write request address matched that of OBI request")
      if (axi_req_o.aw.len !== 0) begin
        `ERROR_MSG("AXI write request unsupported length")
        req_aw_len_unsupported = '1;
      end else `HIGHLIGHT_MSG("AXI write request supported length")

      axi_resp_i.aw_ready <= '0;

      axi_resp_i.w_ready  <= '1;

      do @(posedge clk_i); while (axi_req_o.w_valid);

      if (axi_req_o.w.data !== current_req_info.wdata) begin
        `ERROR_MSG("AXI write request data did not match that of OBI request")
        req_wdata_mismatch = '1;
      end else `HIGHLIGHT_MSG("AXI write request data matched that of OBI request")
      if (axi_req_o.w.strb !== current_req_info.be) begin
        `ERROR_MSG("AXI write request data strb did not match that of OBI request")
        req_wstrb_mismatch = '1;
      end else `HIGHLIGHT_MSG("AXI write request data strb matched that of OBI request")
      if (axi_req_o.w.last !== '1) begin
        `ERROR_MSG("AXI write request data last was not found")
        req_wlast_not_found = '1;
      end else `HIGHLIGHT_MSG("AXI write request data last was found")

      axi_resp_i.w_ready <= '0;
      local_data_reg <= current_req_info.wdata;

      axi_resp_i.b_valid <= '1;

      do @(posedge clk_i); while (axi_req_o.b_ready);

      // @(posedge clk_i);
      axi_resp_i.b_valid <= '0;
    end else begin
      @(posedge axi_req_o.r_ready);
    end

    if (~axi_req_o.r_ready) begin
      `ERROR_MSG("R ready is out of sync")
      resp_arready_not_found = '1;
    end else `HIGHLIGHT_MSG("R ready is in sync")
    if (~gnt_o) begin
      `ERROR_MSG("Grant signal not forwarded through OBI")
      obi_grant_not_propagated = '1;
    end else `HIGHLIGHT_MSG("Grant signal forwarded through OBI")
    if (~rvalid_o) begin
      `ERROR_MSG("Rvalid signal not forwarded through OBI")
      obi_rvalid_not_propagated = '1;
    end else `HIGHLIGHT_MSG("Rvalid signal forwarded through OBI")
    if (rdata_o !== prev_local_data_reg) begin
      `ERROR_MSG("Expected read data was not found")
      obi_rvalid_not_propagated = '1;
    end else `HIGHLIGHT_MSG("Expected read data was found")

    @(posedge clk_i);
    axi_resp_i.r_valid <= '0;

    if ( req_ar_addr_mismatch |
     req_ar_len_unsupported |
     req_aw_addr_mismatch |
     req_aw_len_unsupported |
     req_wdata_mismatch |
     req_wstrb_mismatch |
     req_wlast_not_found |
     resp_arready_not_found |
     obi_grant_not_propagated |
     obi_rvalid_not_propagated |
     obi_rdata_mismatch ) begin
      obi_to_axi_cnv_failed = '1;
    end

  endtask

  // TEST DRIVE
  initial begin
    local_data_reg = 32'h45;

    apply_global_reset();

    #10ns;
    @(posedge clk_i);
    req_i  <= '1;
    addr_i <= 32'hab;
    we_i   <= '0;
    @(posedge clk_i);
    req_i <= '0;

    #10ns;
    @(posedge clk_i);
    req_i <= '1;
    addr_i <= 32'hab;
    we_i <= '1;
    wdata_i <= 32'h69;
    be_i <= '1;
    @(posedge clk_i);
    req_i <= '0;

    #10ns;
    @(posedge clk_i);
    req_i  <= '1;
    addr_i <= 32'hab;
    we_i   <= '0;
    @(posedge clk_i);
    req_i <= '0;
  end

  // TEST WATCH
  initial begin
    fork
      begin
        check_initialization();
        if (~initialization_failed) `PASS_MSG("Initialization success")
        else begin
          `ERROR_MSG("Inappropriate initialization detected")
          fail_count += 1;
        end
      end
      forever begin
        check_and_service_xactn_conversion();
        if (~obi_to_axi_cnv_failed) `PASS_MSG("Transaction conversion success")
        else begin
          `ERROR_MSG("OBI to AXI request convertion failed")
          fail_count += 1;
        end
      end
    join
  end

  // FINISH
  initial begin
    #10000ns;
    if (fail_count) `ERROR_MSG($sformatf("Testing failed. Errors occured: %d\n", fail_count))
    else `PASS_MSG ("Testing passed. No errors occured")
    $finish;
  end

endmodule
