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

  logic      [3:0][OBI_ADDRW-1:0] core_obi_addr_i;
  logic      [3:0]                core_obi_we_i;
  logic      [3:0][OBI_DATAW-1:0] core_obi_wdata_i;
  logic      [3:0][OBI_STRBW-1:0] core_obi_be_i;
  logic      [3:0]                core_obi_req_i;
  logic      [3:0]                core_obi_gnt_o;
  logic      [3:0]                core_obi_rvalid_o;
  logic      [3:0][OBI_DATAW-1:0] core_obi_rdata_o;
  axi_req_t  [3:0]                core_obi_axi_req_o;
  axi_resp_t [3:0]                core_obi_axi_resp_i;

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
      .boot_addr_i(32'h40000000),  // TODO
      .mtvec_addr_i('0),  // TODO
      .dm_halt_addr_i('0),
      .hart_id_i(1),  // TODO - PAURUTI
      .dm_exception_addr_i('0),
      .instr_req_o(),  // TODO
      .instr_gnt_i(),  // TODO
      .instr_rvalid_i(),  // TODO
      .instr_addr_o(),  // TODO
      .instr_rdata_i(),  // TODO
      .data_req_o(),  // TODO
      .data_gnt_i(),  // TODO
      .data_rvalid_i(),  // TODO
      .data_we_o(),  // TODO
      .data_be_o(),  // TODO
      .data_addr_o(),  // TODO
      .data_wdata_o(),  // TODO
      .data_rdata_i(),  // TODO
      .irq_i('0),  // TODO
      .irq_ack_o(),  // TODO
      .irq_id_o(),  // TODO
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
      .boot_addr_i(32'h40020000),  // TODO
      .mtvec_addr_i('0),  // TODO
      .dm_halt_addr_i('0),
      .hart_id_i(2),  // TODO - PAURUTI
      .dm_exception_addr_i('0),
      .instr_req_o(),  // TODO
      .instr_gnt_i(),  // TODO
      .instr_rvalid_i(),  // TODO
      .instr_addr_o(),  // TODO
      .instr_rdata_i(),  // TODO
      .data_req_o(),  // TODO
      .data_gnt_i(),  // TODO
      .data_rvalid_i(),  // TODO
      .data_we_o(),  // TODO
      .data_be_o(),  // TODO
      .data_addr_o(),  // TODO
      .data_wdata_o(),  // TODO
      .data_rdata_i(),  // TODO
      .irq_i('0),  // TODO
      .irq_ack_o(),  // TODO
      .irq_id_o(),  // TODO
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
      .axi_req_o(core_obi_axi_req_o[0]),
      .axi_resp_i(core_obi_axi_resp_i[0])
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
      .axi_req_o(core_obi_axi_req_o[1]),
      .axi_resp_i(core_obi_axi_resp_i[1])
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
      .axi_req_o(core_obi_axi_req_o[2]),
      .axi_resp_i(core_obi_axi_resp_i[2])
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
      .axi_req_o(core_obi_axi_req_o[3]),
      .axi_resp_i(core_obi_axi_resp_i[3])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Core Link Interconnect
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_xbar#(
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
  ) (
      .clk_i(corel_clk_i),
      .rst_ni(corel_arst_ni),
      .test_i('0),
      .slv_ports_req_i(core_obi_axi_req_o),
      .slv_ports_resp_o(core_obi_axi_resp_i),
      .mst_ports_req_o(corel_cdc_axi_req_i),
      .mst_ports_resp_i(corel_cdc_axi_resp_o),
      .addr_map_i(dual_helix_pkg::CoreLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('0)
  );

endmodule
