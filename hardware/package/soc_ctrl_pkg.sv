package soc_ctrl_pkg;

  parameter int REF_DIV_BW = 4;
  parameter int FB_DIV_BW = 12;

  // verilog_format: off
  parameter int REG_BOOT_ADDR_CORE_0_ADDR    = 'h000;
  parameter int REG_BOOT_ADDR_CORE_1_ADDR    = 'h040;
  parameter int REG_HARD_ID_CORE_0_ADDR      = 'h080;
  parameter int REG_HARD_ID_CORE_1_ADDR      = 'h0C0;
  parameter int REG_MTVEC_ADDR_CORE_0_ADDR   = 'h100;
  parameter int REG_MTVEC_ADDR_CORE_1_ADDR   = 'h140;
  parameter int REG_CLK_RST_CORE_0_ADDR      = 'h180;
  parameter int REG_CLK_RST_CORE_1_ADDR      = 'h1C0;
  parameter int REG_CLK_RST_CORE_LINK_ADDR   = 'h200;
  parameter int REG_CLK_RST_SYS_LINK_ADDR    = 'h240;
  parameter int REG_CLK_RST_PERIPH_LINK_ADDR = 'h280;
  parameter int REG_PLL_CONFIG_CORE_0_ADDR   = 'h2C0;
  parameter int REG_PLL_CONFIG_CORE_1_ADDR   = 'h300;
  parameter int REG_PLL_CONFIG_SYS_LINK_ADDR = 'h340;
  parameter int REG_GPR_0_ADDR               = 'h380;
  parameter int REG_GPR_1_ADDR               = 'h3C0;
  parameter int REG_BOOT_MODE_ADDR           = 'h400;
  // verilog_format: on

endpackage
