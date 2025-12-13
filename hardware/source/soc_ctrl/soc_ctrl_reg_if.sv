module soc_ctrl_reg_if
  import dual_helix_pkg::DHS_ADDRW;
  import dual_helix_pkg::DHS_DATAW;

  import soc_ctrl_pkg::REF_DIV_BW;
  import soc_ctrl_pkg::FB_DIV_BW;
#(
    parameter int ADDR_WIDTH = DHS_ADDRW,
    parameter int DATA_WIDTH = DHS_DATAW
) (
    // ========================================================================
    // Global Signals
    // ========================================================================
    input logic arst_ni,  // Active-low asynchronous reset
    input logic clk_i,    // System clock

    // ========================================================================
    // Memory Write Interface
    // ========================================================================
    input  logic                    mem_we_i,     // Write enable
    input  logic [  ADDR_WIDTH-1:0] mem_waddr_i,  // Write address
    input  logic [  DATA_WIDTH-1:0] mem_wdata_i,  // Write data
    input  logic [DATA_WIDTH/8-1:0] mem_wstrb_i,  // Write strobe (byte enables)
    output logic [             1:0] mem_wresp_o,  // Write response (00: OKAY, 10: SLVERR)

    // ========================================================================
    // Memory Read Interface
    // ========================================================================
    input  logic                  mem_re_i,     // Read enable
    input  logic [ADDR_WIDTH-1:0] mem_raddr_i,  // Read address
    output logic [DATA_WIDTH-1:0] mem_rdata_o,  // Read data
    output logic [           1:0] mem_rresp_o,  // Read response (00: OKAY, 10: SLVERR)

    // ========================================================================
    // BOOT ADDR CORE 0
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_0_boot_addr_o,

    // ========================================================================
    // BOOT ADDR CORE 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_1_boot_addr_o,

    // ========================================================================
    // Hart ID Core 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_0_hart_id_o,

    // ========================================================================
    // Hart ID Core 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_1_hart_id_o,

    // ========================================================================
    // mtvec address core 0
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_0_mtvec_o,

    // ========================================================================
    // mtvec address core 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] core_1_mtvec_o,

    // ========================================================================
    // Core 0 Clk Rst
    // ========================================================================

    output logic core_0_arst_n_o,
    output logic core_0_clk_en_o,

    // ========================================================================
    // Core 1 Clk Rst
    // ========================================================================

    output logic core_1_arst_n_o,
    output logic core_1_clk_en_o,

    // ========================================================================
    // Core Link Clk Rst
    // ========================================================================

    output logic core_link_arst_n_o,
    output logic core_link_clk_en_o,
    output logic core_link_clk_mux_sel_o,

    // ========================================================================
    // System Link Clk Rst
    // ========================================================================

    output logic sys_link_arst_n_o,
    output logic sys_link_clk_en_o,

    // ========================================================================
    // Peripheral Link Clk Rst
    // ========================================================================

    output logic periph_link_arst_n_o,
    output logic periph_link_clk_en_o,

    // ========================================================================
    // Core 0 PLL Config
    // ========================================================================

    output logic [REF_DIV_BW-1:0] core_0_pll_ref_div,
    output logic [ FB_DIV_BW-1:0] core_0_pll_fb_div,
    output logic                  core_0_pll_locked,

    // ========================================================================
    // Core 1 Pll Config
    // ========================================================================

    output logic [REF_DIV_BW-1:0] core_1_pll_ref_div,
    output logic [ FB_DIV_BW-1:0] core_1_pll_fb_div,
    output logic                  core_1_pll_locked,

    // ========================================================================
    // System Link PLL Config
    // ========================================================================

    output logic [REF_DIV_BW-1:0] sys_link_pll_ref_div,
    output logic [ FB_DIV_BW-1:0] sys_link_pll_fb_div,
    output logic                  sys_link_pll_locked,

    // ========================================================================
    // General Purpose Register 0
    // ========================================================================

    output logic [DATA_WIDTH-1:0] gpr0,

    // ========================================================================
    // General Purpose Register 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] gpr1

);



endmodule
