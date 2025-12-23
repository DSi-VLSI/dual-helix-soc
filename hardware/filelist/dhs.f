-i ${DUAL_HELIX_SOC_DIR}/hardware/include
-i ${APB_DIR}/include
-i ${AXI_DIR}/include

# TODO
${DUAL_HELIX_SOC_DIR}/hardware/source/stubby-wubby/axi_master_stub.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/stubby-wubby/axi_slave_stub.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/stubby-wubby/axil_master_stub.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/stubby-wubby/axil_slave_stub.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/stubby-wubby/clk_rst_gen_stub.sv

${COMMON_DIR}/rtl/dff.sv
${COMMON_DIR}/rtl/edge_detector.sv
${COMMON_DIR}/rtl/fifo.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/clk_gate.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/dual_flop_sync.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/axil_to_simple_if.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/clk_div.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_reg_if.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_rx.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_top.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_tx.sv

${DUAL_HELIX_SOC_DIR}/hardware/source/soc_ctrl/soc_ctrl_counter.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/soc_ctrl/soc_ctrl_clk_rst_delay_gen.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/soc_ctrl/soc_ctrl_reg_if.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/soc_ctrl/soc_ctrl_top.sv

${DUAL_HELIX_SOC_DIR}/hardware/source/obi_2_axi/obi_2_axi_core.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/obi_2_axi/obi_2_axi.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/apb_2_axil/apb_2_axil.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/dual_helix_soc/dual_helix_soc.sv
