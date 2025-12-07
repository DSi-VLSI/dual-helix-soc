`include "axi/typedef.svh"
`include "apb/typedef.svh"

package dual_helix_pkg;

  import axi_pkg::xbar_rule_32_t;
  import axi_pkg::xbar_cfg_t;

  parameter int DHS_CL_SP_IDW = 2;
  parameter int DHS_CL_MP_IDW = 4;
  parameter int DHS_SL_SP_IDW = 4;
  parameter int DHS_SL_MP_IDW = 6;

  parameter int DHS_ADDRW = 32;
  parameter int DHS_USERW = 8;
  parameter int DHS_DATAW = 32;
  parameter int DHS_STRBW = int'(DHS_DATAW / 8);

  typedef logic [DHS_CL_SP_IDW-1:0] dhs_cl_sp_id_t;
  typedef logic [DHS_CL_MP_IDW-1:0] dhs_cl_mp_id_t;
  typedef logic [DHS_SL_SP_IDW-1:0] dhs_sl_sp_id_t;
  typedef logic [DHS_SL_MP_IDW-1:0] dhs_sl_mp_id_t;

  typedef logic [DHS_ADDRW-1:0] dhs_addr_t;
  typedef logic [DHS_USERW-1:0] dhs_user_t;
  typedef logic [DHS_DATAW-1:0] dhs_data_t;
  typedef logic [DHS_STRBW-1:0] dhs_strb_t;

  parameter dhs_addr_t SOC_CTRL_BASE = 32'h20000000;
  parameter dhs_addr_t SOC_CTRL_END  = 32'h20000FFF;

  parameter dhs_addr_t UART_BASE     = 32'h20001000;
  parameter dhs_addr_t UART_END      = 32'h20001FFF;

  parameter dhs_addr_t SPI_CSR_BASE  = 32'h20002000;
  parameter dhs_addr_t SPI_CSR_END   = 32'h20002FFF;

  parameter dhs_addr_t PLIC_BASE     = 32'h20003000;
  parameter dhs_addr_t PLIC_END      = 32'h20003FFF;

  parameter dhs_addr_t CLINT_BASE    = 32'h20004000;
  parameter dhs_addr_t CLINT_END     = 32'h20004FFF;

  parameter dhs_addr_t DMA_BASE      = 32'h20005000;
  parameter dhs_addr_t DMA_END       = 32'h20005FFF;

  parameter dhs_addr_t SPI_MEM_BASE  = 32'h30000000;
  parameter dhs_addr_t SPI_MEM_END   = 32'h3FFFFFFF;

  parameter dhs_addr_t RAM_BASE      = 32'h40000000;
  parameter dhs_addr_t RAM_END       = 32'hFFFEFFFF;

  parameter dhs_addr_t BOOT_ROM_BASE = 32'hFFFF0000;
  parameter dhs_addr_t BOOT_ROM_END  = 32'hFFFFFFFF;

  `AXI_TYPEDEF_ALL(dhs_cl_sp_axi, dhs_addr_t, dhs_cl_sp_id_t, dhs_data_t, dhs_strb_t, dhs_user_t)
  `AXI_TYPEDEF_ALL(dhs_cl_mp_axi, dhs_addr_t, dhs_cl_mp_id_t, dhs_data_t, dhs_strb_t, dhs_user_t)
  `AXI_TYPEDEF_ALL(dhs_sl_sp_axi, dhs_addr_t, dhs_sl_sp_id_t, dhs_data_t, dhs_strb_t, dhs_user_t)
  `AXI_TYPEDEF_ALL(dhs_sl_mp_axi, dhs_addr_t, dhs_sl_mp_id_t, dhs_data_t, dhs_strb_t, dhs_user_t)

  `AXI_LITE_TYPEDEF_ALL(dhs_axil, dhs_addr_t, dhs_data_t, dhs_strb_t)
  `APB_TYPEDEF_ALL(dhs_apb, dhs_addr_t, dhs_data_t, dhs_strb_t)

  // Core Link
  localparam int NumCoreLinkRules = 1;
  localparam xbar_rule_32_t [NumCoreLinkRules-1:0] CoreLinkRule = '{
      '{idx: 0, start_addr: '0, end_addr: '1}
  };

  localparam xbar_cfg_t CoreLinkConfig = '{
      NoSlvPorts : 4,
      NoMstPorts : 1,
      MaxMstTrans: 1,
      MaxSlvTrans: 1,
      FallThrough: 0,
      LatencyMode: axi_pkg::CUT_ALL_PORTS,
      PipelineStages: 1,
      AxiIdWidthSlvPorts: DHS_CL_SP_IDW,
      AxiIdUsedSlvPorts: DHS_CL_SP_IDW,
      UniqueIds: 0,
      AxiAddrWidth: DHS_ADDRW,
      AxiDataWidth: DHS_DATAW,
      NoAddrRules: NumCoreLinkRules
  };


  // System Link
  localparam int NumSystemLinkRules = 5;
  localparam xbar_rule_32_t [NumSystemLinkRules-1:0] SystemLinkRule = '{
      '{idx: 0, start_addr: (BOOT_ROM_BASE), end_addr: (BOOT_ROM_END)},
      '{idx: 1, start_addr: (RAM_BASE), end_addr: (RAM_END)},
      '{idx: 2, start_addr: (DMA_BASE), end_addr: (DMA_END)},
      '{idx: 3, start_addr: (SOC_CTRL_BASE), end_addr: (CLINT_END)},
      '{idx: 3, start_addr: (SPI_MEM_BASE), end_addr: (SPI_MEM_END)}
  };

  localparam xbar_cfg_t SystemLinkConfig = '{
      NoSlvPorts : 3,
      NoMstPorts : 4,
      MaxMstTrans: 1,
      MaxSlvTrans: 1,
      FallThrough: 0,
      LatencyMode: axi_pkg::CUT_ALL_PORTS,
      PipelineStages: 1,
      AxiIdWidthSlvPorts: DHS_SL_SP_IDW,
      AxiIdUsedSlvPorts: DHS_SL_SP_IDW,
      UniqueIds: '0,
      AxiAddrWidth: DHS_ADDRW,
      AxiDataWidth: DHS_DATAW,
      NoAddrRules: NumSystemLinkRules
  };

  // Peripheral Link
  localparam int NumPeripheralLinkRules = 8;
  localparam xbar_rule_32_t [NumPeripheralLinkRules-1:0] PeripheralLinkRule = '{
      '{idx: 0, start_addr: (SOC_CTRL_BASE), end_addr: (SOC_CTRL_END)},
      '{idx: 1, start_addr: (SPI_CSR_BASE), end_addr: (SPI_CSR_END)},
      '{idx: 1, start_addr: (SPI_MEM_BASE), end_addr: (SPI_MEM_BASE)},
      '{idx: 2, start_addr: (UART_BASE), end_addr: (UART_END)},
      '{idx: 3, start_addr: (CLINT_BASE), end_addr: (CLINT_END)},
      '{idx: 4, start_addr: (PLIC_BASE), end_addr: (PLIC_END)},
      '{idx: 5, start_addr: (DMA_BASE), end_addr: (DMA_END)},
      '{idx: 5, start_addr: (RAM_BASE), end_addr: (BOOT_ROM_END)}
  };

  localparam xbar_cfg_t PeripheralLinkConfig = '{
      NoSlvPorts: 2,
      NoMstPorts: 6,
      MaxMstTrans: 1,
      MaxSlvTrans: 1,
      FallThrough: 1'b0,
      LatencyMode: axi_pkg::CUT_ALL_PORTS,
      AxiAddrWidth: DHS_ADDRW,
      AxiDataWidth: DHS_DATAW,
      NoAddrRules: NumPeripheralLinkRules,
      default: '0
  };

endpackage
