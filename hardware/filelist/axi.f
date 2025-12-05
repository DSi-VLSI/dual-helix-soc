-i ${AXI_DIR}/include
-i ${COMMON_CELLS_DIR}/include

${AXI_DIR}/src/axi_pkg.sv
${COMMON_CELLS_DIR}/src/cf_math_pkg.sv
${SOC_DIR}/package/ariane_axi_pkg.sv
${SOC_DIR}/package/soc_pkg.sv

${COMMON_CELLS_DIR}/src/stream_register.sv
${AXI_DIR}/src/axi_atop_filter.sv
${COMMON_CELLS_DIR}/src/spill_register_flushable.sv
${COMMON_CELLS_DIR}/src/spill_register.sv
${COMMON_CELLS_DIR}/src/delta_counter.sv
${AXI_DIR}/src/axi_demux_simple.sv
${COMMON_CELLS_DIR}/src/counter.sv
${COMMON_CELLS_DIR}/src/lzc.sv
${COMMON_CELLS_DIR}/src/rr_arb_tree.sv
${AXI_DIR}/src/axi_demux.sv
${COMMON_CELLS_DIR}/src/fifo_v3.sv
${AXI_DIR}/src/axi_err_slv.sv
${COMMON_CELLS_DIR}/src/onehot_to_bin.sv
${COMMON_CELLS_DIR}/src/id_queue.sv
${SOC_DIR}/source/axi_burst_splitter_counters.sv
${SOC_DIR}/source/axi_burst_splitter_ax_chan.sv
${AXI_DIR}/src/axi_burst_splitter.sv
${AXI_DIR}/src/axi_to_axi_lite.sv
${AXI_DIR}/src/axi_fifo.sv
${AXI_DIR}/src/axi_xbar_unmuxed.sv
${AXI_DIR}/src/axi_xbar.sv
${SOC_DIR}/source/axi_to_simple_if.sv
${SOC_DIR}/source/axi_ram.sv
