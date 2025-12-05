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

  cv32e40p_top #(
      .COREV_PULP(0),
      .COREV_CLUSTER(0),
      .FPU(1),
      .FPU_ADDMUL_LAT(1),
      .FPU_OTHERS_LAT(1),
      .ZFINX(1),
      .NUM_MHPMCOUNTERS(1)
  ) core_1 (
      .clk_i(core1_clk_i),
      .rst_ni(core1_arst_ni),
      .pulp_clock_en_i('0),
      .scan_cg_en_i(),
      .boot_addr_i(),
      .mtvec_addr_i(),
      .dm_halt_addr_i(),
      .hart_id_i(),
      .dm_exception_addr_i(),
      .instr_req_o(),
      .instr_gnt_i(),
      .instr_rvalid_i(),
      .instr_addr_o(),
      .instr_rdata_i(),
      .data_req_o(),
      .data_gnt_i(),
      .data_rvalid_i(),
      .data_we_o(),
      .data_be_o(),
      .data_addr_o(),
      .data_wdata_o(),
      .data_rdata_i(),
      .irq_i(),
      .irq_ack_o(),
      .irq_id_o(),
      .debug_req_i(),
      .debug_havereset_o(),
      .debug_running_o(),
      .debug_halted_o(),
      .fetch_enable_i(),
      .core_sleep_o()
  );

  cv32e40p_top #(
      .COREV_PULP(0),
      .COREV_CLUSTER(0),
      .FPU(1),
      .FPU_ADDMUL_LAT(1),
      .FPU_OTHERS_LAT(1),
      .ZFINX(1),
      .NUM_MHPMCOUNTERS(1)
  ) core_2 (
      .clk_i(core2_clk_i),
      .rst_ni(core2_arst_ni),
      .pulp_clock_en_i('0),
      .scan_cg_en_i(),
      .boot_addr_i(),
      .mtvec_addr_i(),
      .dm_halt_addr_i(),
      .hart_id_i(),
      .dm_exception_addr_i(),
      .instr_req_o(),
      .instr_gnt_i(),
      .instr_rvalid_i(),
      .instr_addr_o(),
      .instr_rdata_i(),
      .data_req_o(),
      .data_gnt_i(),
      .data_rvalid_i(),
      .data_we_o(),
      .data_be_o(),
      .data_addr_o(),
      .data_wdata_o(),
      .data_rdata_i(),
      .irq_i(),
      .irq_ack_o(),
      .irq_id_o(),
      .debug_req_i(),
      .debug_havereset_o(),
      .debug_running_o(),
      .debug_halted_o(),
      .fetch_enable_i(),
      .core_sleep_o()
  );

endmodule
