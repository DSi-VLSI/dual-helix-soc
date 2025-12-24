${VIVADO_PATH}/data/verilog/src/xeclib/OBUFDS.v
${VIVADO_PATH}/data/verilog/src/xeclib/IOBUFDS.v
${VIVADO_PATH}/data/verilog/src/xeclib/OSERDESE2.v
${VIVADO_PATH}/data/verilog/src/xeclib/IOBUF.v
${VIVADO_PATH}/data/verilog/src/xeclib/IDELAYE2.v
${VIVADO_PATH}/data/verilog/src/xeclib/IDELAYCTRL.v
${VIVADO_PATH}/data/verilog/src/xeclib/ISERDESE2.v
${CORE_DDR3_CONTROLLER_DIR}/src_v/phy/xc7/ddr3_dfi_phy.v

${CORE_DDR3_CONTROLLER_DIR}/src_v/ddr3_dfi_seq.v
${CORE_DDR3_CONTROLLER_DIR}/src_v/ddr3_core.v

${DUAL_HELIX_SOC_DIR}/hardware/source/ddr3/ddr3_axi_pmem.v
${CORE_DDR3_CONTROLLER_DIR}/src_v/ddr3_axi_retime.v
${CORE_DDR3_CONTROLLER_DIR}/src_v/ddr3_axi.v


////////////////////////////////// TESTBENCH //////////////////////////////////

-i ${AXI_DIR}/include
${AXI_DIR}/src/axi_pkg.sv
${CORE_DDR3_CONTROLLER_DIR}/tb/ddr3_core_xc7/ddr3.v
${DUAL_HELIX_SOC_DIR}/hardware/testbench/ddr3_tb/ddr3_tb.sv
