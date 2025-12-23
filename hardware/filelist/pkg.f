-i ${APB_DIR}/include
-i ${AXI_DIR}/include
-i ${COMMON_CELLS_DIR}/include
-i ${DUAL_HELIX_SOC_DIR}/hardware/include

${COMMON_CELLS_DIR}/src/cf_math_pkg.sv
${APB_DIR}/src/apb_pkg.sv
${AXI_DIR}/src/axi_pkg.sv
${SOC_DIR}/package/ariane_axi_pkg.sv
${SOC_DIR}/package/soc_pkg.sv
${CV32E40P_DIR}/rtl/include/cv32e40p_pkg.sv
${CV32E40P_DIR}/rtl/include/cv32e40p_fpu_pkg.sv
${CV32E40P_DIR}/rtl/include/cv32e40p_apu_core_pkg.sv
${CVFPU_DIR}/src/fpnew_pkg.sv
${DUAL_HELIX_SOC_DIR}/hardware/package/dual_helix_pkg.sv
${DUAL_HELIX_SOC_DIR}/hardware/package/soc_ctrl_pkg.sv
${DUAL_HELIX_SOC_DIR}/hardware/package/uart_pkg.sv