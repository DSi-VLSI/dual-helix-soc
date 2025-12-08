-i ${DUAL_HELIX_SOC_DIR}/hardware/include
-i ${APB_DIR}/include
-i ${AXI_DIR}/include

${APB_DIR}/src/apb_pkg.sv
${AXI_DIR}/src/axi_pkg.sv
${DUAL_HELIX_SOC_DIR}/hardware/package/dual_helix_pkg.sv
${DUAL_HELIX_SOC_DIR}/hardware/package/uart_pkg.sv

${COMMON_DIR}/rtl/dff.sv
${COMMON_DIR}/rtl/edge_detector.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/axil_to_simple_if.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/common/clk_div.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_reg_if.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_rx.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_top.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/uart_top/uart_tx.sv

${DUAL_HELIX_SOC_DIR}/hardware/source/obi_2_axi/obi_2_axi_core.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/obi_2_axi/obi_2_axi.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/apb_2_axil/apb_2_axil.sv
${DUAL_HELIX_SOC_DIR}/hardware/source/dual_helix_soc/dual_helix_soc.sv
