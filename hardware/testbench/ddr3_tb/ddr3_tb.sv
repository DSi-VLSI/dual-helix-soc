// verilog_format: off
//-----------------------------------------------------------------
// CLOCK_GEN
//-----------------------------------------------------------------
`define CLOCK_GEN(NAME, CYCLE)     \
    // initial \
    begin \
       ``NAME <= 0; \
       forever # (``CYCLE / 2) ``NAME <= ~``NAME; \
    end

`define CLOCK_GEN_90(NAME, CYCLE)     \
    // initial \
    begin \
       ``NAME <= 0; \
       # (``CYCLE / 4); \
       forever # (``CYCLE / 2) ``NAME <= ~``NAME; \
    end

//-----------------------------------------------------------------
// RESET_GEN
//-----------------------------------------------------------------
`define RESET_GEN(NAME, DELAY)     \
    // initial \
    begin \
       ``NAME <= 1; \
       # ``DELAY    \
       ``NAME <= 0; \
    end

//-----------------------------------------------------------------
// TB_VCD
//-----------------------------------------------------------------
`define TB_VCD(TOP, NAME)     \
    initial \
    begin \
       $dumpfile(``NAME);  \
       $dumpvars(0,``TOP); \
    end

// verilog_format: on

module ddr3_tb;

  `include "axi/typedef.svh"
  `include "simple_axi_m_driver.svh"

  //-----------------------------------------------------------------
  // Clock / Reset
  //-----------------------------------------------------------------
  logic        rst;
  logic        clk;
  logic        clk_ddr;
  logic        clk_ref;
  logic        clk_ddr_dqs;
  event        clk_rst_done;
  logic        cfg_valid;
  logic [31:0] cfg;

  //-----------------------------------------------------------------
  // Misc
  //-----------------------------------------------------------------
  `TB_VCD(ddr3_tb, "waveform.vcd")


  `AXI_TYPEDEF_ALL(axi, logic [31:0], logic [ 3:0], logic [31:0], logic [3:0], logic)

  axi_req_t  axi_req;
  axi_resp_t axi_resp;

  `SIMPLE_AXI_M_DRIVER(axi_dvr, clk, ~rst, axi_req, axi_resp)

  logic        awvalid;
  logic [31:0] awaddr;
  logic [ 3:0] awid;
  logic [ 7:0] awlen;
  logic [ 1:0] awburst;
  logic        wvalid;
  logic [31:0] wdata;
  logic [ 3:0] wstrb;
  logic        wlast;
  logic        bready;
  logic        arvalid;
  logic [31:0] araddr;
  logic [ 3:0] arid;
  logic [ 7:0] arlen;
  logic [ 1:0] arburst;
  logic        rready;
  logic        awready;
  logic        wready;
  logic        bvalid;
  logic [ 1:0] bresp;
  logic [ 3:0] bid;
  logic        arready;
  logic        rvalid;
  logic [31:0] rdata;
  logic [ 1:0] rresp;
  logic [ 3:0] rid;
  logic        rlast;

  wire  [14:0] dfi_address;
  wire  [ 2:0] dfi_bank;
  wire         dfi_cas_n;
  wire         dfi_cke;
  wire         dfi_cs_n;
  wire         dfi_odt;
  wire         dfi_ras_n;
  wire         dfi_reset_n;
  wire         dfi_we_n;
  wire  [31:0] dfi_wrdata;
  wire         dfi_wrdata_en;
  wire  [ 3:0] dfi_wrdata_mask;
  wire         dfi_rddata_en;
  wire  [31:0] dfi_rddata;
  wire         dfi_rddata_valid;

  wire         ddr3_clk_w;
  wire         ddr3_cke_w;
  wire         ddr3_reset_n_w;
  wire         ddr3_ras_n_w;
  wire         ddr3_cas_n_w;
  wire         ddr3_we_n_w;
  wire         ddr3_cs_n_w;
  wire  [ 2:0] ddr3_ba_w;
  wire  [13:0] ddr3_addr_w;
  wire         ddr3_odt_w;
  wire  [ 1:0] ddr3_dm_w;
  wire  [ 1:0] ddr3_dqs_w;
  wire  [15:0] ddr3_dq_w;

  wire         ddr3_ck_p_w;
  wire         ddr3_ck_n_w;
  wire  [ 1:0] ddr3_dqs_p_w;
  wire  [ 1:0] ddr3_dqs_n_w;

  ddr3_axi #(
      .DDR_MHZ          (100),
      .DDR_WRITE_LATENCY(4),
      .DDR_READ_LATENCY (4)
  ) u_ddr3_axi (
      .clk_i             (clk),
      .rst_i             (rst),
      .inport_awvalid_i  (awvalid),
      .inport_awaddr_i   (awaddr),
      .inport_awid_i     (awid),
      .inport_awlen_i    (awlen),
      .inport_awburst_i  (awburst),
      .inport_wvalid_i   (wvalid),
      .inport_wdata_i    (wdata),
      .inport_wstrb_i    (wstrb),
      .inport_wlast_i    (wlast),
      .inport_bready_i   (bready),
      .inport_arvalid_i  (arvalid),
      .inport_araddr_i   (araddr),
      .inport_arid_i     (arid),
      .inport_arlen_i    (arlen),
      .inport_arburst_i  (arburst),
      .inport_rready_i   (rready),
      .inport_awready_o  (awready),
      .inport_wready_o   (wready),
      .inport_bvalid_o   (bvalid),
      .inport_bresp_o    (bresp),
      .inport_bid_o      (bid),
      .inport_arready_o  (arready),
      .inport_rvalid_o   (rvalid),
      .inport_rdata_o    (rdata),
      .inport_rresp_o    (rresp),
      .inport_rid_o      (rid),
      .inport_rlast_o    (rlast),
      .dfi_address_o     (dfi_address),
      .dfi_bank_o        (dfi_bank),
      .dfi_cas_n_o       (dfi_cas_n),
      .dfi_cke_o         (dfi_cke),
      .dfi_cs_n_o        (dfi_cs_n),
      .dfi_odt_o         (dfi_odt),
      .dfi_ras_n_o       (dfi_ras_n),
      .dfi_reset_n_o     (dfi_reset_n),
      .dfi_we_n_o        (dfi_we_n),
      .dfi_wrdata_o      (dfi_wrdata),
      .dfi_wrdata_en_o   (dfi_wrdata_en),
      .dfi_wrdata_mask_o (dfi_wrdata_mask),
      .dfi_rddata_en_o   (dfi_rddata_en),
      .dfi_rddata_i      (dfi_rddata),
      .dfi_rddata_valid_i(dfi_rddata_valid),
      .dfi_rddata_dnv_i  ('0)                 // TODO
  );

  ddr3_dfi_phy #(
      .DQS_TAP_DELAY_INIT(27)
      , .DQ_TAP_DELAY_INIT(0)
      , .TPHY_RDLAT(5)
  ) u_phy (
      .clk_i(clk)
      , .clk_ddr_i(clk_ddr)
      , .clk_ddr90_i(clk_ddr_dqs)
      , .clk_ref_i(clk_ref)
      , .rst_i(rst)
      , .cfg_valid_i(cfg_valid)
      , .cfg_i(cfg)
      , .dfi_address_i(dfi_address)
      , .dfi_bank_i(dfi_bank)
      , .dfi_cas_n_i(dfi_cas_n)
      , .dfi_cke_i(dfi_cke)
      , .dfi_cs_n_i(dfi_cs_n)
      , .dfi_odt_i(dfi_odt)
      , .dfi_ras_n_i(dfi_ras_n)
      , .dfi_reset_n_i(dfi_reset_n)
      , .dfi_we_n_i(dfi_we_n)
      , .dfi_wrdata_i(dfi_wrdata)
      , .dfi_wrdata_en_i(dfi_wrdata_en)
      , .dfi_wrdata_mask_i(dfi_wrdata_mask)
      , .dfi_rddata_en_i(dfi_rddata_en)
      , .dfi_rddata_o(dfi_rddata)
      , .dfi_rddata_valid_o(dfi_rddata_valid)
      , .dfi_rddata_dnv_o()
      , .ddr3_ck_p_o(ddr3_ck_p_w)
      , .ddr3_ck_n_o(ddr3_ck_n_w)
      , .ddr3_cke_o(ddr3_cke_w)
      , .ddr3_reset_n_o(ddr3_reset_n_w)
      , .ddr3_ras_n_o(ddr3_ras_n_w)
      , .ddr3_cas_n_o(ddr3_cas_n_w)
      , .ddr3_we_n_o(ddr3_we_n_w)
      , .ddr3_cs_n_o(ddr3_cs_n_w)
      , .ddr3_ba_o(ddr3_ba_w)
      , .ddr3_addr_o(ddr3_addr_w)
      , .ddr3_odt_o(ddr3_odt_w)
      , .ddr3_dm_o(ddr3_dm_w)
      , .ddr3_dqs_p_io(ddr3_dqs_p_w)
      , .ddr3_dqs_n_io(ddr3_dqs_n_w)
      , .ddr3_dq_io(ddr3_dq_w)
  );

  ddr3 u_ram (
      .rst_n(ddr3_reset_n_w)
      , .ck(ddr3_ck_p_w)
      , .ck_n(ddr3_ck_n_w)
      , .cke(ddr3_cke_w)
      , .cs_n(ddr3_cs_n_w)
      , .ras_n(ddr3_ras_n_w)
      , .cas_n(ddr3_cas_n_w)
      , .we_n(ddr3_we_n_w)
      , .dm_tdqs(ddr3_dm_w)
      , .ba(ddr3_ba_w)
      , .addr(ddr3_addr_w)
      , .dq(ddr3_dq_w)
      , .dqs(ddr3_dqs_p_w)
      , .dqs_n(ddr3_dqs_n_w)
      , .tdqs_n()
      , .odt(ddr3_odt_w)
  );

  always_comb begin
    axi_resp          = '0;

    awid              = axi_req.aw.id;
    awaddr            = axi_req.aw.addr;
    awlen             = axi_req.aw.len;
    awburst           = axi_req.aw.burst;
    awvalid           = axi_req.aw_valid;
    axi_resp.aw_ready = awready;

    wdata             = axi_req.w.data;
    wstrb             = axi_req.w.strb;
    wlast             = axi_req.w.last;
    wvalid            = axi_req.w_valid;
    axi_resp.w_ready  = wready;

    axi_resp.b.id     = bid;
    axi_resp.b.resp   = bresp;
    axi_resp.b_valid  = bvalid;
    bready            = axi_req.b_ready;

    araddr            = axi_req.ar.addr;
    arid              = axi_req.ar.id;
    arlen             = axi_req.ar.len;
    arburst           = axi_req.ar.burst;
    arvalid           = axi_req.ar_valid;
    axi_resp.ar_ready = arready;

    axi_resp.r.data   = rdata;
    axi_resp.r.resp   = rresp;
    axi_resp.r.id     = rid;
    axi_resp.r.last   = rlast;
    axi_resp.r_valid  = rvalid;
    rready            = axi_req.r_ready;
  end

  initial begin
    cfg_valid <= '0;
    cfg <= '0;
    axi_req <= '0;
    rst <= '0;
    fork
      `CLOCK_GEN(clk, 20)
      `CLOCK_GEN(clk_ddr, (20 / 4))
      `CLOCK_GEN(clk_ref, (20 / 2))
      `CLOCK_GEN_90(clk_ddr_dqs, (20 / 4))
    join_none
    #100ns;
    `RESET_GEN(rst, 1000)
    repeat (20) @(posedge clk);
    ->clk_rst_done;
  end

  initial begin
    automatic int addr, data;
    automatic logic [1:0] resp;
    automatic semaphore sem1 = new(1);
    @clk_rst_done;
    $display("CLK RST DONE. COMMENCING TEST");
    @(posedge clk);
    fork
      begin
        sem1.get();
        addr = 'h00000000;
        data = 'hDA;
        fork
          axi_dvr_write_32(addr, data, resp);
          // repeat (20000) begin
          //   @(posedge clk);
          // end
        join_any
        sem1.put();
      end
      begin
        sem1.get();
        addr = 'h00000000;
        repeat (1000) begin
          @(posedge clk);
        end
        fork
          axi_dvr_read_32(addr, data, resp);
          // repeat (20000) begin
          //   @(posedge clk);
          // end
        join_any
        sem1.put();
      end
    join
  end

  initial begin

    #5000ns;
    $finish;

  end

endmodule
