package soc_ctrl_pkg;

  parameter int REF_DIV_BW = 4;
  parameter int FB_DIV_BW = 12;

  // verilog_format: off
  parameter int REG_BOOT_ADDR_CORE_0_ADDR    = 'h00;
  parameter int REG_BOOT_ADDR_CORE_1_ADDR    = 'h04;
  parameter int REG_HARD_ID_CORE_0_ADDR      = 'h08;
  parameter int REG_HARD_ID_CORE_1_ADDR      = 'h0C;
  parameter int REG_MTVEC_ADDR_CORE_0_ADDR   = 'h10;
  parameter int REG_MTVEC_ADDR_CORE_1_ADDR   = 'h14;
  parameter int REG_CLK_RST_CORE_0_ADDR      = 'h18;
  parameter int REG_CLK_RST_CORE_1_ADDR      = 'h1C;
  parameter int REG_CLK_RST_CORE_LINK_ADDR   = 'h20;
  parameter int REG_CLK_RST_SYS_LINK_ADDR    = 'h24;
  parameter int REG_CLK_RST_PERIPH_LINK_ADDR = 'h28;
  parameter int REG_PLL_CONFIG_CORE_0_ADDR   = 'h2C;
  parameter int REG_PLL_CONFIG_CORE_1_ADDR   = 'h30;
  parameter int REG_PLL_CONFIG_SYS_LINK_ADDR = 'h34;
  parameter int REG_GPR_0_ADDR               = 'h38;
  parameter int REG_GPR_1_ADDR               = 'h3C;
  parameter int REG_BOOT_MODE_ADDR           = 'h40;
  // verilog_format: on

endpackage
