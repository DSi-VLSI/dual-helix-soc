`include "axi/typedef.svh"
`include "o2a_dpd.svh"

module obi_2_axi_tb;

  // PARAMETERS
  parameter int OBI_FIFO_DEPTH = 4;
  parameter int AXI_FIFO_DEPTH = 4;

  parameter int OBI_ADDRW = 32;  // Address width
  parameter int OBI_DATAW = 32;  // Data Width
  parameter int OBI_STRBW = (OBI_DATAW / 8);  // Strobe width

  parameter int OBI_CLK_SPEED = 5000;  // Clock speed range in MHz
  parameter int AXI_CLK_SPEED = 3200;  // Clock speed range in MHz

  // TYPEDEFS
  typedef struct packed {
    logic [OBI_ADDRW-1:0] addr;
    logic we;
    logic [OBI_DATAW-1:0] wdata;
    logic [OBI_STRBW-1:0] be;
  } obi_req_info_t;

  typedef logic [OBI_DATAW-1:0] reg_data_t;

  typedef logic [OBI_ADDRW-1:0] addr_t;
  typedef logic [OBI_DATAW-1:0] data_t;

  // WIRES AND SIGNALS
  `AXI_TYPEDEF_ALL(o2a_tb, logic [OBI_ADDRW-1:0], logic [3:0], logic [OBI_DATAW-1:0],
                   logic [OBI_STRBW-1:0], logic [7:0])

  logic                         clk_obi_i;  // OBI Clock
  logic                         clk_axi_i;  // AXI clock
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
  reg_data_t                    local_data_reg;

  // FLAGS
  logic                         initialization_failed = 0;  // TODO

  logic                         rst_gnt_o_high = 0;  // TODO
  logic                         rst_aw_valid_high = 0;  //  TODO
  logic                         rst_w_valid_high = 0;  // TODO
  logic                         rst_ar_valid_high = 0;  //  TODO

  // logic                         obi_to_axi_cnv_failed = 0; //  TODO

  // logic                         req_ar_addr_mismatch = 0; // TODO
  // logic                         req_ar_len_unsupported = 0; // TODO
  // logic                         req_aw_addr_mismatch = 0; // TODO
  // logic                         req_aw_len_unsupported = 0; // TODO
  // logic                         req_wdata_mismatch = 0; // TODO
  // logic                         req_wstrb_mismatch = 0; // TODO
  // logic                         req_wlast_not_found = 0; //  TODO
  // logic                         obi_grant_not_propagated = 0; // TODO
  // logic                         obi_rvalid_not_propagated = 0; //  TODO
  // logic                         obi_rdata_mismatch = 0; // TODO

  // DUT INSTANTIATION
  obi_2_axi #(
      .OBI_FIFO_DEPTH(OBI_FIFO_DEPTH),
      .AXI_FIFO_DEPTH(AXI_FIFO_DEPTH),
      .OBI_ADDRW(OBI_ADDRW),
      .OBI_DATAW(OBI_DATAW),
      .OBI_STRBW(OBI_STRBW),
      .aw_chan_t(o2a_tb_aw_chan_t),
      .w_chan_t(o2a_tb_w_chan_t),
      .b_chan_t(o2a_tb_b_chan_t),
      .ar_chan_t(o2a_tb_ar_chan_t),
      .r_chan_t(o2a_tb_r_chan_t),
      .axi_req_t(o2a_tb_req_t),
      .axi_resp_t(o2a_tb_resp_t)
  ) u_dut (
      .clk_obi_i(clk_obi_i),
      .clk_axi_i(clk_axi_i),
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
  `START_CLK(clk_obi_i, OBI_CLK_SPEED)
  `START_CLK(clk_axi_i, AXI_CLK_SPEED)

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


  task automatic assert_arready();
    axi_resp_i.ar_ready <= '1;
  endtask
  task automatic deassert_arready();
    axi_resp_i.ar_ready <= '0;
  endtask

  task automatic send_rchannel(input logic [OBI_DATAW-1:0] rdata);
    axi_resp_i.r_valid <= '1;
    axi_resp_i.r.data  <= rdata;
    axi_resp_i.r.last  <= '1;
  endtask
  task automatic deassert_rvalid();
    axi_resp_i.r_valid <= '0;
  endtask

  task automatic assert_awready();
    axi_resp_i.aw_ready <= '1;
  endtask
  task automatic deassert_awready();
    axi_resp_i.aw_ready <= '0;
  endtask

  task automatic assert_wready();
    axi_resp_i.w_ready <= '1;
  endtask
  task automatic recv_wchannel(output logic [OBI_DATAW-1:0] wdata);
    axi_resp_i.w_ready <= '0;
    wdata = axi_req_o.w.data;
  endtask

  task automatic assert_bvalid();
    axi_resp_i.b_valid <= '1;
  endtask
  task automatic deassert_bvalid();
    axi_resp_i.b_valid <= '0;
  endtask

  task automatic send_request(logic [OBI_ADDRW-1:0] addr, logic we, logic [OBI_DATAW-1:0] wdata,
                              logic [OBI_STRBW-1:0] be);
    @(posedge clk_obi_i);
    req_i <= '1;
    addr_i <= addr;
    we_i <= we;
    wdata_i <= wdata;
    be_i <= be;

    do @(posedge clk_obi_i); while (~gnt_o);
    req_i <= '0;
  endtask

  task automatic service_request();
    obi_req_info_t current_req;
    reg_data_t current_local_reg_value = local_data_reg;

    @(posedge req_i);

    `HIGHLIGHT_MSG($sformatf("[%0t] KICK STARTING SERVICE REQWEST", $realtime))
    // store the incoming request as current request
    current_req.addr = addr_i;
    current_req.we = we_i;
    current_req.wdata = wdata_i;
    current_req.be = be_i;

    fork

      begin
        assert_arready();
        do @(posedge clk_axi_i); while (~axi_req_o.ar_valid);
        deassert_arready();

        send_rchannel(current_local_reg_value);
        do @(posedge clk_axi_i); while (~axi_req_o.r_ready);
        deassert_rvalid();
      end

      if (current_req.we) begin
        fork
          begin
            assert_awready();
            do @(posedge clk_axi_i); while (~axi_req_o.aw_valid);
            deassert_awready();
          end
          begin
            assert_wready();
            do @(posedge clk_axi_i); while (~axi_req_o.w_valid);
            recv_wchannel(local_data_reg);
          end
        join
        assert_bvalid();
        do @(posedge clk_axi_i); while (~axi_req_o.b_ready);
        deassert_bvalid();
      end

    join

  endtask

  task automatic check_initialization();

    initialization_failed = '0;

    rst_gnt_o_high = '0;
    rst_aw_valid_high = '0;
    rst_w_valid_high = '0;
    rst_ar_valid_high = '0;

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

    if (rst_gnt_o_high | rst_aw_valid_high | rst_w_valid_high | rst_ar_valid_high) begin
      initialization_failed = '1;
      `ERROR_MSG("Inappropriate initialization detected")
    end else begin
      `PASS_MSG("Initialization success")
    end
  endtask

  // task automatic check_xactn_conversion();
  //   forever begin
  //     @(posedge obi_to_axi_cnv_failed);
  //     `ERROR_MSG("OBI to AXI request convertion failed")
  //   end
  // endtask

  // SIGNAL MANIPULATION
  initial begin
    fork
      forever begin
        service_request();
      end
      begin
        apply_global_reset();
        #10ns;
        send_request(32'hAB, '0, 32'hBC, '1);
        #10ns;
        send_request(32'hAB, '1, $urandom, '1);
        #10ns;
        send_request(32'hAB, '0, $urandom, '1);
        #10ns;
        send_request(32'hAB, '1, $urandom, '1);
        #10ns;
        send_request(32'hAB, '1, $urandom, '1);
        #10ns;
        send_request(32'hAB, '0, $urandom, '1);
        `HIGHLIGHT_MSG("TEST SEQUENCE COMPLETE")
      end
    join
  end

  // TEST WATCH
  initial begin
    fork
      check_initialization();
    join
  end

  // TIMEOUT AND FINISH
  initial begin
    #10000ns;
    `HIGHLIGHT_MSG("Test timed out: NON-FATAL")
    $finish;
  end

endmodule
