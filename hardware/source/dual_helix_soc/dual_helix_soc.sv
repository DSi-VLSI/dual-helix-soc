module dual_helix_soc
  import axi_pkg::xbar_rule_32_t;
  import axi_pkg::xbar_cfg_t;

  import dual_helix_pkg::BOOT_ROM_BASE;
  import dual_helix_pkg::CoreLinkConfig;
  import dual_helix_pkg::CoreLinkRule;
  import dual_helix_pkg::dhs_addr_t;
  import dual_helix_pkg::DHS_ADDRW;
  import dual_helix_pkg::dhs_apb_req_t;
  import dual_helix_pkg::dhs_apb_resp_t;
  import dual_helix_pkg::dhs_axil_ar_chan_t;
  import dual_helix_pkg::dhs_axil_aw_chan_t;
  import dual_helix_pkg::dhs_axil_b_chan_t;
  import dual_helix_pkg::dhs_axil_r_chan_t;
  import dual_helix_pkg::dhs_axil_req_t;
  import dual_helix_pkg::dhs_axil_resp_t;
  import dual_helix_pkg::dhs_axil_w_chan_t;
  import dual_helix_pkg::dhs_cl_mp_axi_ar_chan_t;
  import dual_helix_pkg::dhs_cl_mp_axi_aw_chan_t;
  import dual_helix_pkg::dhs_cl_mp_axi_b_chan_t;
  import dual_helix_pkg::dhs_cl_mp_axi_r_chan_t;
  import dual_helix_pkg::dhs_cl_mp_axi_req_t;
  import dual_helix_pkg::dhs_cl_mp_axi_resp_t;
  import dual_helix_pkg::dhs_cl_mp_axi_w_chan_t;
  import dual_helix_pkg::dhs_cl_sp_axi_ar_chan_t;
  import dual_helix_pkg::dhs_cl_sp_axi_aw_chan_t;
  import dual_helix_pkg::dhs_cl_sp_axi_b_chan_t;
  import dual_helix_pkg::dhs_cl_sp_axi_r_chan_t;
  import dual_helix_pkg::dhs_cl_sp_axi_req_t;
  import dual_helix_pkg::dhs_cl_sp_axi_resp_t;
  import dual_helix_pkg::dhs_cl_sp_axi_w_chan_t;
  import dual_helix_pkg::dhs_data_t;
  import dual_helix_pkg::DHS_DATAW;
  import dual_helix_pkg::dhs_sl_mp_axi_ar_chan_t;
  import dual_helix_pkg::dhs_sl_mp_axi_aw_chan_t;
  import dual_helix_pkg::dhs_sl_mp_axi_b_chan_t;
  import dual_helix_pkg::dhs_sl_mp_axi_r_chan_t;
  import dual_helix_pkg::dhs_sl_mp_axi_req_t;
  import dual_helix_pkg::dhs_sl_mp_axi_resp_t;
  import dual_helix_pkg::DHS_SL_MP_IDW;
  import dual_helix_pkg::dhs_sl_sp_axi_ar_chan_t;
  import dual_helix_pkg::dhs_sl_sp_axi_aw_chan_t;
  import dual_helix_pkg::dhs_sl_sp_axi_b_chan_t;
  import dual_helix_pkg::dhs_sl_sp_axi_r_chan_t;
  import dual_helix_pkg::dhs_sl_sp_axi_req_t;
  import dual_helix_pkg::dhs_sl_sp_axi_resp_t;
  import dual_helix_pkg::dhs_sl_sp_axi_w_chan_t;
  import dual_helix_pkg::DHS_SL_SP_IDW;
  import dual_helix_pkg::dhs_strb_t;
  import dual_helix_pkg::DHS_STRBW;
  import dual_helix_pkg::dhs_user_t;
  import dual_helix_pkg::DHS_USERW;
  import dual_helix_pkg::PeripheralLinkConfig;
  import dual_helix_pkg::PeripheralLinkRule;
  import dual_helix_pkg::SystemLinkConfig;
  import dual_helix_pkg::SystemLinkRule;
  import dual_helix_pkg::UART_BASE;
(
    input logic core1_clk_i,   // TODO -  internal pll
    input logic core2_clk_i,   // TODO -  internal pll
    input logic corel_clk_i,   // TODO -  internal pll
    input logic sysl_clk_i,    // TODO -  internal pll
    input logic periphl_clk_i, // TODO -  internal pll

    input logic core1_arst_ni,   // TODO - glb_arst_ni
    input logic core2_arst_ni,   // TODO - glb_arst_ni
    input logic corel_arst_ni,   // TODO - glb_arst_ni
    input logic sysl_arst_ni,    // TODO - glb_arst_ni
    input logic periphl_arst_ni, // TODO - glb_arst_ni

    input dhs_addr_t core_1_boot_addr_i,  // TODO - SoC Controller
    input dhs_data_t core_1_hart_id_i,    // TODO - SoC Controller
    input dhs_addr_t core_2_boot_addr_i,  // TODO - SoC Controller
    input dhs_data_t core_2_hart_id_i,    // TODO - SoC Controller

    // General I/O pins
    input logic ref_clk_i,
    input logic glb_arst_ni,
    input logic boot_mode_i,

    // PLIC signals
    input logic [3:0] ext_int_i,

    // APB slave interface for APB master
    input logic apb_slv_clk_i,
    input logic apb_slv_arst_ni,
    input dhs_apb_req_t apb_slv_req_i,
    output dhs_apb_resp_t apb_slv_resp_o,

    // External AXI RAM interface
    output logic ext_ram_clk_o,
    output logic ext_ram_arst_no,
    output dhs_sl_mp_axi_req_t  ext_ram_axi_req_o,
    input  dhs_sl_mp_axi_resp_t ext_ram_axi_resp_i,

    // UART interface
    input  logic uart_rx_i,
    output logic uart_tx_o,

    // Quad SPI Interface
    output logic cs_o,
    output logic sclk_o,
    inout  logic io0_io,
    inout  logic io1_io,
    inout  logic io2_io,
    inout  logic io3_io
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Internal Signals
  //////////////////////////////////////////////////////////////////////////////////////////////////

//   logic                                     core1_clk_i;  // TODO -  internal pll
//   logic                                     core2_clk_i;  // TODO -  internal pll
//   logic                                     corel_clk_i;  // TODO -  internal pll
//   logic                                     sysl_clk_i;  // TODO -  internal pll
//   logic                                     periphl_clk_i;  // TODO -  internal pll

//   logic                                     core1_arst_ni;  // TODO - glb_arst_ni
//   logic                                     core2_arst_ni;  // TODO - glb_arst_ni
//   logic                                     corel_arst_ni;  // TODO - glb_arst_ni
//   logic                                     sysl_arst_ni;  // TODO - glb_arst_ni
//   logic                                     periphl_arst_ni;  // TODO - glb_arst_ni

//   dhs_addr_t                                core_1_boot_addr_i;  // TODO - SoC Controller
//   dhs_data_t                                core_1_hart_id_i;  // TODO - SoC Controller
//   dhs_addr_t                                core_2_boot_addr_i;  // TODO - SoC Controller
//   dhs_data_t                                core_2_hart_id_i;  // TODO - SoC Controller

  logic                [3:0][DHS_ADDRW-1:0] core_obi_addr_i;
  logic                [3:0]                core_obi_we_i;
  logic                [3:0][DHS_DATAW-1:0] core_obi_wdata_i;
  logic                [3:0][DHS_STRBW-1:0] core_obi_be_i;
  logic                [3:0]                core_obi_req_i;
  logic                [3:0]                core_obi_gnt_o;
  logic                [3:0]                core_obi_rvalid_o;
  logic                [3:0][DHS_DATAW-1:0] core_obi_rdata_o;

  dhs_cl_sp_axi_req_t  [3:0]                core_obi_axi_req;
  dhs_cl_sp_axi_resp_t [3:0]                core_obi_axi_resp;

  dhs_cl_mp_axi_req_t                       corel_cdc_axi_req;
  dhs_cl_mp_axi_resp_t                      corel_cdc_axi_resp;

  dhs_sl_sp_axi_req_t  [2:0]                sysl_mstr_device_axi_req;
  dhs_sl_sp_axi_resp_t [2:0]                sysl_mstr_device_axi_resp;

  dhs_sl_mp_axi_req_t  [3:0]                sysl_slv_device_axi_req;
  dhs_sl_mp_axi_resp_t [3:0]                sysl_slv_device_axi_resp;

  dhs_axil_req_t                            sysl_to_periphl_axil_req;
  dhs_axil_resp_t                           sysl_to_periphl_axil_resp;

  dhs_axil_req_t                            periphl_to_sysl_axil_req;
  dhs_axil_resp_t                           periphl_to_sysl_axil_resp;

  dhs_axil_req_t       [1:0]                periphl_mstr_device_axil_req;
  dhs_axil_resp_t      [1:0]                periphl_mstr_device_axil_resp;

  dhs_axil_req_t       [5:0]                periphl_slv_device_axil_req;
  dhs_axil_resp_t      [5:0]                periphl_slv_device_axil_resp;

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
      .boot_addr_i(core_1_boot_addr_i),
      .mtvec_addr_i('0),
      .dm_halt_addr_i('0),
      .hart_id_i(core_1_hart_id_i),
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
      .boot_addr_i(core_2_boot_addr_i),
      .mtvec_addr_i('0),
      .dm_halt_addr_i('0),
      .hart_id_i(core_2_hart_id_i),
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
      .OBI_ADDRW(DHS_ADDRW),
      .OBI_DATAW(DHS_DATAW),
      .OBI_STRBW(DHS_STRBW),
      .aw_chan_t(dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dhs_cl_sp_axi_req_t),
      .axi_resp_t(dhs_cl_sp_axi_resp_t)
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
      .OBI_ADDRW(DHS_ADDRW),
      .OBI_DATAW(DHS_DATAW),
      .OBI_STRBW(DHS_STRBW),
      .aw_chan_t(dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dhs_cl_sp_axi_req_t),
      .axi_resp_t(dhs_cl_sp_axi_resp_t)
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
      .OBI_ADDRW(DHS_ADDRW),
      .OBI_DATAW(DHS_DATAW),
      .OBI_STRBW(DHS_STRBW),
      .aw_chan_t(dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dhs_cl_sp_axi_req_t),
      .axi_resp_t(dhs_cl_sp_axi_resp_t)
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
      .OBI_ADDRW(DHS_ADDRW),
      .OBI_DATAW(DHS_DATAW),
      .OBI_STRBW(DHS_STRBW),
      .aw_chan_t(dhs_cl_sp_axi_aw_chan_t),
      .w_chan_t(dhs_cl_sp_axi_w_chan_t),
      .b_chan_t(dhs_cl_sp_axi_b_chan_t),
      .ar_chan_t(dhs_cl_sp_axi_ar_chan_t),
      .r_chan_t(dhs_cl_sp_axi_r_chan_t),
      .axi_req_t(dhs_cl_sp_axi_req_t),
      .axi_resp_t(dhs_cl_sp_axi_resp_t)
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
      .Cfg(CoreLinkConfig),
      .ATOPs('0),
      .Connectivity('1),
      .slv_aw_chan_t(dhs_cl_sp_axi_aw_chan_t),
      .mst_aw_chan_t(dhs_cl_mp_axi_aw_chan_t),
      .w_chan_t(dhs_cl_sp_axi_w_chan_t),
      .slv_b_chan_t(dhs_cl_sp_axi_b_chan_t),
      .mst_b_chan_t(dhs_cl_mp_axi_b_chan_t),
      .slv_ar_chan_t(dhs_cl_sp_axi_ar_chan_t),
      .mst_ar_chan_t(dhs_cl_mp_axi_ar_chan_t),
      .slv_r_chan_t(dhs_cl_sp_axi_r_chan_t),
      .mst_r_chan_t(dhs_cl_mp_axi_r_chan_t),
      .slv_req_t(dhs_cl_sp_axi_req_t),
      .slv_resp_t(dhs_cl_sp_axi_resp_t),
      .mst_req_t(dhs_cl_mp_axi_req_t),
      .mst_resp_t(dhs_cl_mp_axi_resp_t),
      .rule_t(axi_pkg::xbar_rule_32_t)
  ) core_link (
      .clk_i(corel_clk_i),
      .rst_ni(corel_arst_ni),
      .test_i('0),
      .slv_ports_req_i(core_obi_axi_req),
      .slv_ports_resp_o(core_obi_axi_resp),
      .mst_ports_req_o(corel_cdc_axi_req),
      .mst_ports_resp_i(corel_cdc_axi_resp),
      .addr_map_i(CoreLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('0)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Core-2-System AXI CDC
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_cdc #(
      .aw_chan_t (dhs_cl_mp_axi_aw_chan_t),
      .w_chan_t  (dhs_cl_mp_axi_w_chan_t),
      .b_chan_t  (dhs_cl_mp_axi_b_chan_t),
      .ar_chan_t (dhs_cl_mp_axi_ar_chan_t),
      .r_chan_t  (dhs_cl_mp_axi_r_chan_t),
      .axi_req_t (dhs_cl_mp_axi_req_t),
      .axi_resp_t(dhs_cl_mp_axi_resp_t),
      .LogDepth  (2),
      .SyncStages(2)
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
      .MEM_BASE    (BOOT_ROM_BASE),
      .MEM_SIZE    (16),
      .ALLOW_WRITES('0),
      .req_t       (dhs_sl_mp_axi_req_t),
      .resp_t      (dhs_sl_mp_axi_resp_t)
  ) soc_rom (
      .clk_i  (sysl_clk_i),
      .arst_ni(sysl_arst_ni),
      .req_i  (sysl_slv_device_axi_req[0]),
      .resp_o (sysl_slv_device_axi_resp[0])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI RAM
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign ext_ram_clk_o = sysl_clk_i;
  assign ext_ram_arst_no = sysl_arst_ni;
  assign ext_ram_axi_req_o = sysl_slv_device_axi_req[1];
  assign sysl_slv_device_axi_resp[1] = ext_ram_axi_resp_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// DMA
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TODO: DMA instance
  //sysl_slv_device_axi_req[2]
  assign sysl_slv_device_axi_resp[2] = '0;
  assign sysl_mstr_device_axi_req[1] = '0;
  //sysl_mstr_device_axi_resp[1]

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// System Link
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_xbar #(
      .Cfg(SystemLinkConfig),
      .ATOPs('0),
      .Connectivity('1),
      .slv_aw_chan_t(dhs_sl_sp_axi_aw_chan_t),
      .mst_aw_chan_t(dhs_sl_mp_axi_aw_chan_t),
      .w_chan_t(dhs_sl_sp_axi_w_chan_t),
      .slv_b_chan_t(dhs_sl_sp_axi_b_chan_t),
      .mst_b_chan_t(dhs_sl_mp_axi_b_chan_t),
      .slv_ar_chan_t(dhs_sl_sp_axi_ar_chan_t),
      .mst_ar_chan_t(dhs_sl_mp_axi_ar_chan_t),
      .slv_r_chan_t(dhs_sl_sp_axi_r_chan_t),
      .mst_r_chan_t(dhs_sl_mp_axi_r_chan_t),
      .slv_req_t(dhs_sl_sp_axi_req_t),
      .slv_resp_t(dhs_sl_sp_axi_resp_t),
      .mst_req_t(dhs_sl_mp_axi_req_t),
      .mst_resp_t(dhs_sl_mp_axi_resp_t),
      .rule_t(axi_pkg::xbar_rule_32_t)
  ) system_link (
      .clk_i(sysl_clk_i),
      .rst_ni(sysl_arst_ni),
      .test_i('0),
      .slv_ports_req_i(sysl_mstr_device_axi_req),
      .slv_ports_resp_o(sysl_mstr_device_axi_resp),
      .mst_ports_req_o(sysl_slv_device_axi_req),
      .mst_ports_resp_i(sysl_slv_device_axi_resp),
      .addr_map_i(SystemLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('b010101)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// AXI-TO-AXI-LITE Bridge
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_to_axi_lite #(
      .AxiAddrWidth   (DHS_ADDRW),
      .AxiDataWidth   (DHS_DATAW),
      .AxiIdWidth     (DHS_SL_MP_IDW),
      .AxiUserWidth   (DHS_USERW),
      .AxiMaxWriteTxns(1),
      .AxiMaxReadTxns (1),
      .FullBW         (1),
      .FallThrough    (0),
      .full_req_t     (dhs_sl_mp_axi_req_t),
      .full_resp_t    (dhs_sl_mp_axi_resp_t),
      .lite_req_t     (dhs_axil_req_t),
      .lite_resp_t    (dhs_axil_resp_t)
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
      .aw_chan_t (dhs_axil_aw_chan_t),
      .w_chan_t  (dhs_axil_w_chan_t),
      .b_chan_t  (dhs_axil_b_chan_t),
      .ar_chan_t (dhs_axil_ar_chan_t),
      .r_chan_t  (dhs_axil_r_chan_t),
      .axi_req_t (dhs_axil_req_t),
      .axi_resp_t(dhs_axil_resp_t),
      .LogDepth  (2),
      .SyncStages(2)
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
      .aw_chan_t (dhs_axil_aw_chan_t),
      .w_chan_t  (dhs_axil_w_chan_t),
      .b_chan_t  (dhs_axil_b_chan_t),
      .ar_chan_t (dhs_axil_ar_chan_t),
      .r_chan_t  (dhs_axil_r_chan_t),
      .axi_req_t (dhs_axil_req_t),
      .axi_resp_t(dhs_axil_resp_t),
      .LogDepth  (2),
      .SyncStages(2)
  ) pl2sl_axi_cdc (
      .src_clk_i (periphl_clk_i),
      .src_rst_ni(periphl_arst_ni),
      .src_req_i (periphl_slv_device_axil_req[5]),
      .src_resp_o(periphl_slv_device_axil_resp[5]),
      .dst_clk_i (sysl_clk_i),
      .dst_rst_ni(sysl_arst_ni),
      .dst_req_o (periphl_to_sysl_axil_req),
      .dst_resp_i(periphl_to_sysl_axil_resp)
  );

  always_comb begin
    sysl_mstr_device_axi_req[2] = '0;

    sysl_mstr_device_axi_req[2].aw.addr = periphl_to_sysl_axil_req.aw.addr;
    sysl_mstr_device_axi_req[2].aw.size = 2;
    sysl_mstr_device_axi_req[2].aw.burst = 1;
    sysl_mstr_device_axi_req[2].aw.prot = periphl_to_sysl_axil_req.aw.prot;
    sysl_mstr_device_axi_req[2].aw_valid = periphl_to_sysl_axil_req.aw_valid;

    sysl_mstr_device_axi_req[2].w.data = periphl_to_sysl_axil_req.w.data;
    sysl_mstr_device_axi_req[2].w.strb = periphl_to_sysl_axil_req.w.strb;
    sysl_mstr_device_axi_req[2].w.last = '1;
    sysl_mstr_device_axi_req[2].w_valid = periphl_to_sysl_axil_req.w_valid;

    sysl_mstr_device_axi_req[2].b_ready = periphl_to_sysl_axil_req.b_ready;

    sysl_mstr_device_axi_req[2].ar.addr = periphl_to_sysl_axil_req.ar.addr;
    sysl_mstr_device_axi_req[2].ar.size = 2;
    sysl_mstr_device_axi_req[2].ar.burst = 1;
    sysl_mstr_device_axi_req[2].ar.prot = periphl_to_sysl_axil_req.ar.prot;
    sysl_mstr_device_axi_req[2].ar_valid = periphl_to_sysl_axil_req.ar_valid;

    sysl_mstr_device_axi_req[2].r_ready = periphl_to_sysl_axil_req.r_ready;
  end

  always_comb begin
    periphl_to_sysl_axil_resp = '0;

    periphl_to_sysl_axil_resp.aw_ready = sysl_mstr_device_axi_resp[2].aw_ready;

    periphl_to_sysl_axil_resp.w_ready = sysl_mstr_device_axi_resp[2].w_ready;

    periphl_to_sysl_axil_resp.b.resp = sysl_mstr_device_axi_resp[2].b.resp;
    periphl_to_sysl_axil_resp.b_valid = sysl_mstr_device_axi_resp[2].b_valid;

    periphl_to_sysl_axil_resp.ar_ready = sysl_mstr_device_axi_resp[2].ar_ready;

    periphl_to_sysl_axil_resp.r.data = sysl_mstr_device_axi_resp[2].r.data;
    periphl_to_sysl_axil_resp.r.resp = sysl_mstr_device_axi_resp[2].r.resp;
    periphl_to_sysl_axil_resp.r_valid = sysl_mstr_device_axi_resp[2].r_valid;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Peripheral Link
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_lite_xbar #(
      .Cfg(PeripheralLinkConfig),
      .aw_chan_t(dhs_axil_aw_chan_t),
      .w_chan_t(dhs_axil_w_chan_t),
      .b_chan_t(dhs_axil_b_chan_t),
      .ar_chan_t(dhs_axil_ar_chan_t),
      .r_chan_t(dhs_axil_r_chan_t),
      .axi_req_t(dhs_axil_req_t),
      .axi_resp_t(dhs_axil_resp_t),
      .rule_t(xbar_rule_32_t)
  ) peripheral_link (
      .clk_i(periphl_clk_i),
      .rst_ni(periphl_arst_ni),
      .test_i('0),
      .slv_ports_req_i(periphl_mstr_device_axil_req),
      .slv_ports_resp_o(periphl_mstr_device_axil_resp),
      .mst_ports_req_o(periphl_slv_device_axil_req),
      .mst_ports_resp_i(periphl_slv_device_axil_resp),
      .addr_map_i(PeripheralLinkRule),
      .en_default_mst_port_i('1),
      .default_mst_port_i('b101101)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// APB Slave Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  apb_2_axil #(
      .ADDR_WIDTH(DHS_ADDRW),
      .DATA_WIDTH(DHS_DATAW),
      .apb_req_t (),
      .apb_resp_t(),
      .axi_req_t (),
      .axi_resp_t()
  ) apb_slave (
      .apb_clk_i  (apb_slv_clk_i),
      .apb_arst_ni(apb_slv_arst_ni),
      .apb_req_i  (apb_slv_req_i),
      .apb_resp_o (apb_slv_resp_o),
      .axi_clk_i  (periphl_clk_i),
      .axi_arst_ni(periphl_arst_ni),
      .axi_req_o  (periphl_mstr_device_axil_req[1]),
      .axi_resp_i (periphl_mstr_device_axil_resp[1])
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// System Controller
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[0]
  assign periphl_slv_device_axil_resp[0] = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// SPI Master Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[1]
  assign periphl_slv_device_axil_resp[1] = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// UART Interface
  //////////////////////////////////////////////////////////////////////////////////////////////////

  uart_top #(
      .req_t(dhs_axil_req_t),
      .resp_t(dhs_axil_resp_t),
      .MEM_BASE(UART_BASE),
      .MEM_SIZE(DHS_ADDRW),
      .DATA_WIDTH(DHS_DATAW)
  ) uart_device (

      .arst_ni(periphl_arst_ni),
      .clk_i(periphl_clk_i),
      .req_i(periphl_slv_device_axil_req[2]),
      .resp_o(periphl_slv_device_axil_resp[2]),
      .tx_o(uart_tx_o),
      .rx_i(uart_rx_i),
      .irq_o()  // TODO
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// CLINT - Core Local Interruptor
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[3]
  assign periphl_slv_device_axil_resp[3] = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// PLIC - Platform Level Interrupt Controller
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // periphl_slv_device_axil_req[4]
  assign periphl_slv_device_axil_resp[4] = '0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //// Timers
  //////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
