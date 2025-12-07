module dual_helix_soc
  import dual_helix_pkg::*;
#(
    parameter type apb_req_t  = dual_helix_pkg::dhs_apb_req_t,
    parameter type apb_resp_t = dual_helix_pkg::dhs_apb_resp_t
) (
    input logic core1_clk_i,
    input logic core2_clk_i,
    input logic corel_clk_i,
    input logic sysl_clk_i,
    input logic periphl_clk_i,
    input logic apb_slv_clk_i,

    input logic core1_arst_ni,
    input logic core2_arst_ni,
    input logic corel_arst_ni,
    input logic sysl_arst_ni,
    input logic periphl_arst_ni,
    input logic apb_slv_arst_ni,

    input  apb_req_t  apb_slv_req,
    output apb_resp_t apb_slv_resp

    // TODO: more I/O pins
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Internal Signals
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                                [3:0][OBI_ADDRW-1:0] core_obi_addr_i;
  logic                                [3:0]                core_obi_we_i;
  logic                                [3:0][OBI_DATAW-1:0] core_obi_wdata_i;
  logic                                [3:0][OBI_STRBW-1:0] core_obi_be_i;
  logic                                [3:0]                core_obi_req_i;
  logic                                [3:0]                core_obi_gnt_o;
  logic                                [3:0]                core_obi_rvalid_o;
  logic                                [3:0][OBI_DATAW-1:0] core_obi_rdata_o;

  dual_helix_pkg::dhs_cl_sp_axi_req_t  [3:0]                core_obi_axi_req;
  dual_helix_pkg::dhs_cl_sp_axi_resp_t [3:0]                core_obi_axi_resp;

  dual_helix_pkg::dhs_cl_mp_axi_req_t                       corel_cdc_axi_req;
  dual_helix_pkg::dhs_cl_mp_axi_resp_t                      corel_cdc_axi_resp;

  dual_helix_pkg::dhs_sl_sp_axi_req_t  [2:0]                sysl_mstr_device_axi_req;
  dual_helix_pkg::dhs_sl_sp_axi_resp_t [2:0]                sysl_mstr_device_axi_resp;

  dual_helix_pkg::dhs_sl_mp_axi_req_t  [3:0]                sysl_slv_device_axi_req;
  dual_helix_pkg::dhs_sl_mp_axi_resp_t [3:0]                sysl_slv_device_axi_resp;

  dual_helix_pkg::dhs_axil_req_t                            sysl_to_periphl_axil_req;
  dual_helix_pkg::dhs_axil_resp_t                           sysl_to_periphl_axil_resp;

  dual_helix_pkg::dhs_axil_req_t       [1:0]                periphl_mstr_device_axil_req;
  dual_helix_pkg::dhs_axil_resp_t      [1:0]                periphl_mstr_device_axil_resp;

  dual_helix_pkg::dhs_axil_req_t       [5:0]                periphl_slv_device_axil_req;
  dual_helix_pkg::dhs_axil_resp_t      [5:0]                periphl_slv_device_axil_resp;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Core Instances
  //////////////////////////////////////////////////////////////////////////////////////////////////

  cv32e40p_top #(
      .COREV_PULP(0),
      .COREV_CLUSTER(0),
      .FPU(1),
      .FPU_ADDMUL_LAT(1),
      .FPU_OTHERS_LAT(1),
      .ZFINX(0),
      .NUM_MHPMCOUNTERS(0)
  ) core_1 (
      .clk_i(core1_clk_i),
      .rst_ni(core1_arst_ni),
      .pulp_clock_en_i('0),
      .scan_cg_en_i('0),
      .boot_addr_i(32'h40000000),
      .mtvec_addr_i('0),
      .dm_halt_addr_i('0),
      .hart_id_i(1),
      .dm_exception_addr_i('0),
      .instr_req_o(core_obi_req_i[0]),
      .instr_gnt_i(core_obi_gnt_o[0]),
      .instr_rvalid_i(core_obi_rvalid_o[0]),
      .instr_addr_o(core_obi_addr_i[0]),
      .instr_rdata_i(core_obi_rdata_o[0]),
      .data_req_o(core_obi_req_i[1]),
      .data_gnt_i(core_obi_gnt_o[1]),
      .data_rvalid_i(core_obi_rvalid_o[1]),
      .data_we_o(core_obi_we_i[1]),
      .data_be_o(core_obi_be_i[1]),
      .data_addr_o(core_obi_addr_i[1]),
      .data_wdata_o(core_obi_wdata_i[1]),
      .data_rdata_i(core_obi_rdata_o[1]),
      .irq_i('0),
      .irq_ack_o(),
      .irq_id_o(),
      .debug_req_i('0),
      .debug_havereset_o(),
      .debug_running_o(),
      .debug_halted_o(),
      .fetch_enable_i('1),
      .core_sleep_o()
  );

  cv32e40p_top #(
      .COREV_PULP(0),
      .COREV_CLUSTER(0),
      .FPU(1),
      .FPU_ADDMUL_LAT(1),
      .FPU_OTHERS_LAT(1),
      .ZFINX(0),
      .NUM_MHPMCOUNTERS(0)
  ) core_2 (
      .clk_i(core2_clk_i),
      .rst_ni(core2_arst_ni),
      .pulp_clock_en_i('0),
      .scan_cg_en_i('0),
      .boot_addr_i(32'h40020000),
      .mtvec_addr_i('0),
      .dm_halt_addr_i('0),
      .hart_id_i(2),
      .dm_exception_addr_i('0),
      .instr_req_o(core_obi_req_i[2]),
      .instr_gnt_i(core_obi_gnt_o[2]),
      .instr_rvalid_i(core_obi_rvalid_o[2]),
      .instr_addr_o(core_obi_addr_i[2]),
      .instr_rdata_i(core_obi_rdata_o[2]),
      .data_req_o(core_obi_req_i[3]),
      .data_gnt_i(core_obi_gnt_o[3]),
      .data_rvalid_i(core_obi_rvalid_o[3]),
      .data_we_o(core_obi_we_i[3]),
      .data_be_o(core_obi_be_i[3]),
      .data_addr_o(core_obi_addr_i[3]),
      .data_wdata_o(core_obi_wdata_i[3]),
      .data_rdata_i(core_obi_rdata_o[3]),
      .irq_i('0),
      .irq_ack_o(),
      .irq_id_o(),
      .debug_req_i('0),
      .debug_havereset_o(),
      .debug_running_o(),
      .debug_halted_o(),
      .fetch_enable_i('1),
      .core_sleep_o()
  );

  assign core_obi_we_i[0] = '0;
  assign core_obi_wdata_i[0] = '0;
  assign core_obi_be_i[0] = '0;

  assign core_obi_we_i[2] = '0;
  assign core_obi_wdata_i[2] = '0;
  assign core_obi_be_i[2] = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// OBI to AXI Bridges
  //////////////////////////////////////////////////////////////////////////////////////////////////

  obi_2_axi #(
      .OBI_FIFO_DEPTH(4),
      .AXI_FIFO_DEPTH(4),
      .OBI_ADDRW(dual_helix_pkg::DHS_ADDRW),
      .OBI_DATAW(dual_helix_pkg::DHS_DATAW),
      .OBI_STRBW(dual_helix_pkg::DHS_STRBW),
      .aw_chan_t(dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dual_helix_pkg::dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dual_helix_pkg::dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dual_helix_pkg::dhs_cl_sp_axi_req_t),
      .axi_resp_t(dual_helix_pkg::dhs_cl_sp_axi_resp_t)
  ) core1_instr_bridge (
      .clk_obi_i(core1_clk_i),
      .clk_axi_i(corel_clk_i),
      .arst_ni(core1_arst_ni),
      .addr_i(core_obi_addr_i[0]),
      .we_i(core_obi_we_i[0]),
      .wdata_i(core_obi_wdata_i[0]),
      .be_i(core_obi_be_i[0]),
      .req_i(core_obi_req_i[0]),
      .gnt_o(core_obi_gnt_o[0]),
      .rvalid_o(core_obi_rvalid_o[0]),
      .rdata_o(core_obi_rdata_o[0]),
      .axi_req_o(core_obi_axi_req[0]),
      .axi_resp_i(core_obi_axi_resp[0])
  );

  obi_2_axi #(
      .OBI_FIFO_DEPTH(4),
      .AXI_FIFO_DEPTH(4),
      .OBI_ADDRW(dual_helix_pkg::DHS_ADDRW),
      .OBI_DATAW(dual_helix_pkg::DHS_DATAW),
      .OBI_STRBW(dual_helix_pkg::DHS_STRBW),
      .aw_chan_t(dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dual_helix_pkg::dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dual_helix_pkg::dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dual_helix_pkg::dhs_cl_sp_axi_req_t),
      .axi_resp_t(dual_helix_pkg::dhs_cl_sp_axi_resp_t)
  ) core1_data_bridge (
      .clk_obi_i(core1_clk_i),
      .clk_axi_i(corel_clk_i),
      .arst_ni(core1_arst_ni),
      .addr_i(core_obi_addr_i[1]),
      .we_i(core_obi_we_i[1]),
      .wdata_i(core_obi_wdata_i[1]),
      .be_i(core_obi_be_i[1]),
      .req_i(core_obi_req_i[1]),
      .gnt_o(core_obi_gnt_o[1]),
      .rvalid_o(core_obi_rvalid_o[1]),
      .rdata_o(core_obi_rdata_o[1]),
      .axi_req_o(core_obi_axi_req[1]),
      .axi_resp_i(core_obi_axi_resp[1])
  );

  obi_2_axi #(
      .OBI_FIFO_DEPTH(4),
      .AXI_FIFO_DEPTH(4),
      .OBI_ADDRW(dual_helix_pkg::DHS_ADDRW),
      .OBI_DATAW(dual_helix_pkg::DHS_DATAW),
      .OBI_STRBW(dual_helix_pkg::DHS_STRBW),
      .aw_chan_t(dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dual_helix_pkg::dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dual_helix_pkg::dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dual_helix_pkg::dhs_cl_sp_axi_req_t),
      .axi_resp_t(dual_helix_pkg::dhs_cl_sp_axi_resp_t)
  ) core2_instr_bridge (
      .clk_obi_i(core2_clk_i),
      .clk_axi_i(corel_clk_i),
      .arst_ni(core2_arst_ni),
      .addr_i(core_obi_addr_i[2]),
      .we_i(core_obi_we_i[2]),
      .wdata_i(core_obi_wdata_i[2]),
      .be_i(core_obi_be_i[2]),
      .req_i(core_obi_req_i[2]),
      .gnt_o(core_obi_gnt_o[2]),
      .rvalid_o(core_obi_rvalid_o[2]),
      .rdata_o(core_obi_rdata_o[2]),
      .axi_req_o(core_obi_axi_req[2]),
      .axi_resp_i(core_obi_axi_resp[2])
  );

  obi_2_axi #(
      .OBI_FIFO_DEPTH(4),
      .AXI_FIFO_DEPTH(4),
      .OBI_ADDRW(dual_helix_pkg::DHS_ADDRW),
      .OBI_DATAW(dual_helix_pkg::DHS_DATAW),
      .OBI_STRBW(dual_helix_pkg::DHS_STRBW),
      .aw_chan_t(dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dual_helix_pkg::dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dual_helix_pkg::dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dual_helix_pkg::dhs_cl_sp_axi_req_t),
      .axi_resp_t(dual_helix_pkg::dhs_cl_sp_axi_resp_t)
  ) core2_data_bridge (
      .clk_obi_i(core2_clk_i),
      .clk_axi_i(corel_clk_i),
      .arst_ni(core2_arst_ni),
      .addr_i(core_obi_addr_i[3]),
      .we_i(core_obi_we_i[3]),
      .wdata_i(core_obi_wdata_i[3]),
      .be_i(core_obi_be_i[3]),
      .req_i(core_obi_req_i[3]),
      .gnt_o(core_obi_gnt_o[3]),
      .rvalid_o(core_obi_rvalid_o[3]),
      .rdata_o(core_obi_rdata_o[3]),
      .axi_req_o(core_obi_axi_req[3]),
      .axi_resp_i(core_obi_axi_resp[3])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Core Link Interconnect
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_xbar #(
      .Cfg(dual_helix_pkg::CoreLinkConfig),
      .ATOPs('0),
      .Connectivity('1),
      .slv_aw_chan_t(dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t),
      .mst_aw_chan_t(dual_helix_pkg::dhs_cl_mp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_cl_sp_axi_w_chan_t),
      .slv_b_chan_t(dual_helix_pkg::dhs_cl_sp_axi_b_chan_t),
      .mst_b_chan_t(dual_helix_pkg::dhs_cl_mp_axi_b_chan_t),
      .slv_ar_chan_t(dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t),
      .mst_ar_chan_t(dual_helix_pkg::dhs_cl_mp_axi_ar_chan_t),
      .slv_r_chan_t(dual_helix_pkg::dhs_cl_sp_axi_r_chan_t),
      .mst_r_chan_t(dual_helix_pkg::dhs_cl_mp_axi_r_chan_t),
      .slv_req_t(dual_helix_pkg::dhs_cl_sp_axi_req_t),
      .slv_resp_t(dual_helix_pkg::dhs_cl_sp_axi_resp_t),
      .mst_req_t(dual_helix_pkg::dhs_cl_mp_axi_req_t),
      .mst_resp_t(dual_helix_pkg::dhs_cl_mp_axi_resp_t),
      .rule_t(axi_pkg::xbar_rule_32_t)
  ) core_link (
      .clk_i(corel_clk_i),
      .rst_ni(corel_arst_ni),
      .test_i('0),
      .slv_ports_req_i(core_obi_axi_req),
      .slv_ports_resp_o(core_obi_axi_resp),
      .mst_ports_req_o(corel_cdc_axi_req),
      .mst_ports_resp_i(corel_cdc_axi_resp),
      .addr_map_i(dual_helix_pkg::CoreLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('0)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Core-2-System AXI CDC
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_cdc #(
      .aw_chan_t  (dual_helix_pkg::dhs_cl_mp_axi_aw_chan_t),
      .w_chan_t   (dual_helix_pkg::dhs_cl_mp_axi_w_chan_t),
      .b_chan_t   (dual_helix_pkg::dhs_cl_mp_axi_b_chan_t),
      .ar_chan_t  (dual_helix_pkg::dhs_cl_mp_axi_ar_chan_t),
      .r_chan_t   (dual_helix_pkg::dhs_cl_mp_axi_r_chan_t),
      .axi_req_t  (dual_helix_pkg::dhs_cl_mp_axi_req_t),
      .axi_resp_t (dual_helix_pkg::dhs_cl_mp_axi_resp_t),
      .LogDepth   (1), // TODO
      .SyncStages (2) // TODO
  ) cl2sl_axi_cdc (
      .src_clk_i (corel_clk_i),
      .src_rst_ni(corel_arst_ni),
      .src_req_i (corel_cdc_axi_req),
      .src_resp_o(corel_cdc_axi_resp),
      .dst_clk_i (sysl_clk_i),
      .dst_rst_ni(sysl_arst_ni),
      .dst_req_o (sysl_mstr_device_axi_req[0]),
      .dst_resp_i(sysl_mstr_device_axi_resp[0])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI ROM
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_ram #(
      .MEM_BASE    (dual_helix_pkg::BOOT_ROM_BASE),
      .MEM_SIZE    (),                                     // TODO
      .ALLOW_WRITES('0),
      .req_t       (dual_helix_pkg::dhs_sl_mp_axi_req_t),
      .resp_t      (dual_helix_pkg::dhs_sl_mp_axi_resp_t)
  ) soc_rom (
      .clk_i  (sysl_clk_i),
      .arst_ni(sysl_arst_ni),
      .req_i  (sysl_slv_device_axi_req[0]),
      .resp_o (sysl_slv_device_axi_resp[0])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI ROM
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO: AXI RAM connector instance
  //sysl_slv_device_axi_req[1]
  //sysl_slv_device_axi_resp[1]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// DMA
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO: DMA instance
  //sysl_slv_device_axi_req[2]
  //sysl_slv_device_axi_resp[2]
  //sysl_mstr_device_axi_req[1]
  //sysl_mstr_device_axi_resp[1]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// System Link
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_xbar #(
      .Cfg(dual_helix_pkg::SystemLinkConfig),
      .ATOPs('0),
      .Connectivity('1),
      .slv_aw_chan_t(dual_helix_pkg::dhs_sl_sp_axi_aw_chan_t),
      .mst_aw_chan_t(dual_helix_pkg::dhs_sl_mp_axi_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_sl_sp_axi_w_chan_t),
      .slv_b_chan_t(dual_helix_pkg::dhs_sl_sp_axi_b_chan_t),
      .mst_b_chan_t(dual_helix_pkg::dhs_sl_mp_axi_b_chan_t),
      .slv_ar_chan_t(dual_helix_pkg::dhs_sl_sp_axi_ar_chan_t),
      .mst_ar_chan_t(dual_helix_pkg::dhs_sl_mp_axi_ar_chan_t),
      .slv_r_chan_t(dual_helix_pkg::dhs_sl_sp_axi_r_chan_t),
      .mst_r_chan_t(dual_helix_pkg::dhs_sl_mp_axi_r_chan_t),
      .slv_req_t(dual_helix_pkg::dhs_sl_sp_axi_req_t),
      .slv_resp_t(dual_helix_pkg::dhs_sl_sp_axi_resp_t),
      .mst_req_t(dual_helix_pkg::dhs_sl_mp_axi_req_t),
      .mst_resp_t(dual_helix_pkg::dhs_sl_mp_axi_resp_t),
      .rule_t(axi_pkg::xbar_rule_32_t)
  ) system_link (
      .clk_i(sysl_clk_i),
      .rst_ni(sysl_arst_ni),
      .test_i('0),
      .slv_ports_req_i(sysl_mstr_device_axi_req),
      .slv_ports_resp_o(sysl_mstr_device_axi_resp),
      .mst_ports_req_o(sysl_slv_device_axi_req),
      .mst_ports_resp_i(sysl_slv_device_axi_resp),
      .addr_map_i(dual_helix_pkg::SystemLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('b010101)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI-TO-AXI-LITE Bridge
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_to_axi_lite #(
      .AxiAddrWidth   (dual_helix_pkg::DHS_ADDRW),
      .AxiDataWidth   (dual_helix_pkg::DHS_DATAW),
      .AxiIdWidth     (dual_helix_pkg::DHS_SL_SP_IDW),
      .AxiUserWidth   (dual_helix_pkg::DHS_USERW),
      .AxiMaxWriteTxns(1),
      .AxiMaxReadTxns (1),
      .FullBW         (),                                      // TODO
      .FallThrough    (),                                      // TODO
      .full_req_t     (dual_helix_pkg::dhs_sl_mp_axi_req_t),
      .full_resp_t    (dual_helix_pkg::dhs_sl_mp_axi_resp_t),
      .lite_req_t     (dual_helix_pkg::dhs_axil_req_t),
      .lite_resp_t    (dual_helix_pkg::dhs_axil_resp_t)
  ) sl2pl_axi2axil_cvtr (
      .clk_i(sysl_clk_i),
      .rst_ni(sysl_arst_ni),
      .test_i('0),
      .slv_req_i(sysl_slv_device_axi_req[3]),
      .slv_resp_o(sysl_slv_device_axi_resp[3]),
      .mst_req_o(sysl_to_periphl_axil_req),
      .mst_resp_i(sysl_to_periphl_axil_resp)
  );

  axi_cdc #(
      .aw_chan_t  (dhs_axil_aw_chan_t),
      .w_chan_t   (dhs_axil_w_chan_t),
      .b_chan_t   (dhs_axil_b_chan_t),
      .ar_chan_t  (dhs_axil_ar_chan_t),
      .r_chan_t   (dhs_axil_r_chan_t),
      .axi_req_t  (dhs_axil_req_t),
      .axi_resp_t (dhs_axil_resp_t),
      .LogDepth   (1), // TODO
      .SyncStages (2) // TODO
  ) sl2pl_axi_cdc (
      .src_clk_i (sysl_clk_i),
      .src_rst_ni(sysl_arst_ni),
      .src_req_i (sysl_to_periphl_axil_req),
      .src_resp_o(sysl_to_periphl_axil_resp),
      .dst_clk_i (periphl_clk_i),
      .dst_rst_ni(periphl_arst_ni),
      .dst_req_o (periphl_mstr_device_axil_req[0]),
      .dst_resp_i(periphl_mstr_device_axil_resp[0])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI-LITE-TO-AXI CDC
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_cdc #(
      .aw_chan_t  (dhs_axil_aw_chan_t),
      .w_chan_t   (dhs_axil_w_chan_t),
      .b_chan_t   (dhs_axil_b_chan_t),
      .ar_chan_t  (dhs_axil_ar_chan_t),
      .r_chan_t   (dhs_axil_r_chan_t),
      .axi_req_t  (dhs_axil_req_t),
      .axi_resp_t (dhs_axil_resp_t),
      .LogDepth   (1), // TODO
      .SyncStages (2) // TODO
  ) pl2sl_axi_cdc (
      .src_clk_i (periphl_clk_i),
      .src_rst_ni(periphl_arst_ni),
      .src_req_i (periphl_slv_device_axil_req[5]),
      .src_resp_o(periphl_slv_device_axil_resp[5]),
      .dst_clk_i (sysl_clk_i),
      .dst_rst_ni(sysl_arst_ni),
      .dst_req_o (sysl_mstr_device_axi_req[2]),
      .dst_resp_i(sysl_mstr_device_axi_resp[2])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Peripheral Link
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_lite_xbar #(
      .Cfg(PeripheralLinkCOnfig),
      .aw_chan_t(dual_helix_pkg::dhs_axil_aw_chan_t),
      .w_chan_t(dual_helix_pkg::dhs_axil_w_chan_t),
      .b_chan_t(dual_helix_pkg::dhs_axil_b_chan_t),
      .ar_chan_t(dual_helix_pkg::dhs_axil_ar_chan_t),
      .r_chan_t(dual_helix_pkg::dhs_axil_r_chan_t),
      .axi_req_t(dual_helix_pkg::dhs_axil_req_t),
      .axi_resp_t(dual_helix_pkg::dhs_axil_resp_t),
      .rule_t(xbar_rule_32_t)  // TODO
  ) peripheral_link (
      .clk_i(periphl_clk_i),
      .rst_ni(periphl_arst_ni),
      .test_i('0),
      .slv_ports_req_i(periphl_mstr_device_axil_req),
      .slv_ports_resp_o(periphl_mstr_device_axil_resp),
      .mst_ports_req_o(periphl_slv_device_axil_req),
      .mst_ports_resp_i(periphl_slv_device_axil_resp),
      .addr_map_i(PeripheralLinkRule),  // TODO
      .en_default_mst_port_i('1),
      .default_mst_port_i('b001000100010)  // TODO
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// APB Slave Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_mstr_device_axil_req[1]
  // periphl_mstr_device_axil_resp[1]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// System Controller
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[0]
  // periphl_slv_device_axil_resp[0]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// SPI Master Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[1]
  // periphl_slv_device_axil_resp[1]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// UART Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  uart_top #(
      .req_t(dual_helix_pkg::dhs_axil_req_t),
      .resp_t(dual_helix_pkg::dhs_axil_resp_t),
      .MEM_SIZE(),  // TODO
      .DATA_WIDTH()  // TODO
  ) uart_device (

      .arst_ni(periphl_arst_ni),
      .clk_i(periphl_clk_i),
      .req_i(periphl_slv_device_axil_req[2]),
      .resp_o(periphl_slv_device_axil_resp[2]),
      .tx_o(),  // TODO
      .rx_i(),  // TODO
      .irq_o()  // TODO
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// CLINT - Core Local Interruptor
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[3]
  // periphl_slv_device_axil_resp[3]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// PLIC - Platform Level Interrupt Controller
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[4]
  // periphl_slv_device_axil_resp[4]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Timers
  //////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
