module soc_ctrl_reg_if
  import dual_helix_pkg::DHS_ADDRW;
  import dual_helix_pkg::DHS_DATAW;

  import soc_ctrl_pkg::REG_BOOT_ADDR_CORE_0_ADDR;
  import soc_ctrl_pkg::REG_BOOT_ADDR_CORE_1_ADDR;
  import soc_ctrl_pkg::REG_HARD_ID_CORE_0_ADDR;
  import soc_ctrl_pkg::REG_HARD_ID_CORE_1_ADDR;
  import soc_ctrl_pkg::REG_MTVEC_ADDR_CORE_0_ADDR;
  import soc_ctrl_pkg::REG_MTVEC_ADDR_CORE_1_ADDR;
  import soc_ctrl_pkg::REG_CLK_RST_CORE_0_ADDR;
  import soc_ctrl_pkg::REG_CLK_RST_CORE_1_ADDR;
  import soc_ctrl_pkg::REG_CLK_RST_CORE_LINK_ADDR;
  import soc_ctrl_pkg::REG_CLK_RST_SYS_LINK_ADDR;
  import soc_ctrl_pkg::REG_CLK_RST_PERIPH_LINK_ADDR;
  import soc_ctrl_pkg::REG_PLL_CONFIG_CORE_0_ADDR;
  import soc_ctrl_pkg::REG_PLL_CONFIG_CORE_1_ADDR;
  import soc_ctrl_pkg::REG_PLL_CONFIG_SYS_LINK_ADDR;
  import soc_ctrl_pkg::REG_GPR_0_ADDR;
  import soc_ctrl_pkg::REG_GPR_1_ADDR;
  import soc_ctrl_pkg::REG_BOOT_MODE_ADDR;
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

    output logic [REF_DIV_BW-1:0] core_0_pll_ref_div_o,
    output logic [ FB_DIV_BW-1:0] core_0_pll_fb_div_o,
    input  logic                  core_0_pll_locked_i,

    // ========================================================================
    // Core 1 Pll Config
    // ========================================================================

    output logic [REF_DIV_BW-1:0] core_1_pll_ref_div_o,
    output logic [ FB_DIV_BW-1:0] core_1_pll_fb_div_o,
    input  logic                  core_1_pll_locked_i,

    // ========================================================================
    // System Link PLL Config
    // ========================================================================

    output logic [REF_DIV_BW-1:0] sys_link_pll_ref_div_o,
    output logic [ FB_DIV_BW-1:0] sys_link_pll_fb_div_o,
    input  logic                  sys_link_pll_locked_i,

    // ========================================================================
    // General Purpose Register 0
    // ========================================================================

    output logic [DATA_WIDTH-1:0] gpr0_o,

    // ========================================================================
    // General Purpose Register 1
    // ========================================================================

    output logic [DATA_WIDTH-1:0] gpr1_o,

    // ========================================================================
    // Boot Mode
    // ========================================================================

    input logic boot_mode_i

);

  // ========================================================================
  // Write Logic (Combinational)
  // ========================================================================

  always_comb begin
    mem_wresp_o = 'b10;

    if (mem_we_i) begin
      case (mem_waddr_i)
        REG_BOOT_ADDR_CORE_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_BOOT_ADDR_CORE_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_HARD_ID_CORE_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_HARD_ID_CORE_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_MTVEC_ADDR_CORE_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_MTVEC_ADDR_CORE_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_CLK_RST_CORE_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_CLK_RST_CORE_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_CLK_RST_CORE_LINK_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_CLK_RST_SYS_LINK_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_CLK_RST_PERIPH_LINK_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_PLL_CONFIG_CORE_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_PLL_CONFIG_CORE_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_PLL_CONFIG_SYS_LINK_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_GPR_0_ADDR: begin
          mem_wresp_o = 'b00;
        end
        REG_GPR_1_ADDR: begin
          mem_wresp_o = 'b00;
        end
        default: ;
      endcase
    end
  end

  // ========================================================================
  // Read Logic (Combinational)
  // ========================================================================

  always_comb begin
    mem_rresp_o = 'b10;
    mem_rdata_o = '0;

    if (mem_re_i) begin
      case (mem_raddr_i)
        REG_BOOT_ADDR_CORE_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_0_boot_addr_o;
        end
        REG_BOOT_ADDR_CORE_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_1_boot_addr_o;
        end
        REG_HARD_ID_CORE_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_0_hart_id_o;
        end
        REG_HARD_ID_CORE_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_1_hart_id_o;
        end
        REG_MTVEC_ADDR_CORE_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_0_mtvec_o;
        end
        REG_MTVEC_ADDR_CORE_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = core_1_mtvec_o;
        end
        REG_CLK_RST_CORE_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, core_0_clk_en_o, core_0_arst_n_o};
        end
        REG_CLK_RST_CORE_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, core_1_clk_en_o, core_1_arst_n_o};
        end
        REG_CLK_RST_CORE_LINK_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, core_link_clk_mux_sel_o, core_link_clk_en_o, core_link_arst_n_o};
        end
        REG_CLK_RST_SYS_LINK_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, sys_link_clk_en_o, sys_link_arst_n_o};
        end
        REG_CLK_RST_PERIPH_LINK_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, periph_link_clk_en_o, periph_link_arst_n_o};
        end
        REG_PLL_CONFIG_CORE_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, core_0_pll_locked_i, core_0_pll_fb_div_o, core_0_pll_ref_div_o};
        end
        REG_PLL_CONFIG_CORE_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, core_1_pll_locked_i, core_1_pll_fb_div_o, core_1_pll_ref_div_o};
        end
        REG_PLL_CONFIG_SYS_LINK_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = {'0, sys_link_pll_locked_i, sys_link_pll_fb_div_o, sys_link_pll_ref_div_o};
        end
        REG_GPR_0_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = gpr0_o;
        end
        REG_GPR_1_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = gpr1_o;
        end
        REG_BOOT_MODE_ADDR: begin
          mem_rresp_o = 'b00;
          mem_rdata_o = boot_mode_i;
        end
        default: ;
      endcase
    end
  end

  // ========================================================================
  // Write Logic (Sequential)
  // ========================================================================

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      core_0_boot_addr_o      <= '0;  // TODO
      core_1_boot_addr_o      <= '0;  // TODO
      core_0_hart_id_o        <= '0;  // TODO
      core_1_hart_id_o        <= '0;  // TODO
      core_0_mtvec_o          <= '0;  // TODO
      core_1_mtvec_o          <= '0;  // TODO
      core_0_arst_n_o         <= '1;  // TODO
      core_0_clk_en_o         <= '0;  // TODO
      core_1_arst_n_o         <= '1;  // TODO
      core_1_clk_en_o         <= '0;  // TODO
      core_link_arst_n_o      <= '1;  // TODO
      core_link_clk_en_o      <= '0;  // TODO
      core_link_clk_mux_sel_o <= '0;  // TODO
      sys_link_arst_n_o       <= '1;  // TODO
      sys_link_clk_en_o       <= '0;  // TODO
      periph_link_arst_n_o    <= '1;  // TODO
      periph_link_clk_en_o    <= '0;  // TODO
      core_0_pll_ref_div_o    <= '0;  // TODO
      core_0_pll_fb_div_o     <= '0;  // TODO
      core_1_pll_ref_div_o    <= '0;  // TODO
      core_1_pll_fb_div_o     <= '0;  // TODO
      sys_link_pll_ref_div_o  <= '0;  // TODO
      sys_link_pll_fb_div_o   <= '0;  // TODO
      gpr0_o                  <= '0;  // TODO
      gpr1_o                  <= '0;  // TODO
    end else begin
      if (mem_wresp_o === 'b00) begin
        unique case (mem_waddr_i)
          REG_BOOT_ADDR_CORE_0_ADDR: begin
            core_0_boot_addr_o <= mem_wdata_i;
          end
          REG_BOOT_ADDR_CORE_1_ADDR: begin
            core_1_boot_addr_o <= mem_wdata_i;
          end
          REG_HARD_ID_CORE_0_ADDR: begin
            core_0_hart_id_o <= mem_wdata_i;
          end
          REG_HARD_ID_CORE_1_ADDR: begin
            core_1_hart_id_o <= mem_wdata_i;
          end
          REG_MTVEC_ADDR_CORE_0_ADDR: begin
            core_0_mtvec_o <= mem_wdata_i;
          end
          REG_MTVEC_ADDR_CORE_1_ADDR: begin
            core_1_mtvec_o <= mem_wdata_i;
          end
          REG_CLK_RST_CORE_0_ADDR: begin
            core_0_arst_n_o <= mem_wdata_i[0];
            core_0_clk_en_o <= mem_wdata_i[1];
          end
          REG_CLK_RST_CORE_1_ADDR: begin
            core_1_arst_n_o <= mem_wdata_i[0];
            core_1_clk_en_o <= mem_wdata_i[1];
          end
          REG_CLK_RST_CORE_LINK_ADDR: begin
            core_link_arst_n_o      <= mem_wdata_i[0];
            core_link_clk_en_o      <= mem_wdata_i[1];
            core_link_clk_mux_sel_o <= mem_wdata_i[2];
          end
          REG_CLK_RST_SYS_LINK_ADDR: begin
            sys_link_arst_n_o <= mem_wdata_i[0];
            sys_link_clk_en_o <= mem_wdata_i[1];
          end
          REG_CLK_RST_PERIPH_LINK_ADDR: begin
            periph_link_arst_n_o <= mem_wdata_i[0];
            periph_link_clk_en_o <= mem_wdata_i[1];
          end
          REG_PLL_CONFIG_CORE_0_ADDR: begin
            core_0_pll_ref_div_o <= mem_wdata_i[3:0];
            core_0_pll_fb_div_o  <= mem_wdata_i[15:4];
          end
          REG_PLL_CONFIG_CORE_1_ADDR: begin
            core_1_pll_ref_div_o <= mem_wdata_i[3:0];
            core_1_pll_fb_div_o  <= mem_wdata_i[15:4];
          end
          REG_PLL_CONFIG_SYS_LINK_ADDR: begin
            sys_link_pll_ref_div_o <= mem_wdata_i[3:0];
            sys_link_pll_fb_div_o  <= mem_wdata_i[15:4];
          end
          REG_GPR_0_ADDR: begin
            gpr0_o <= mem_wdata_i;
          end
          REG_GPR_1_ADDR: begin
            gpr1_o <= mem_wdata_i;
          end
        endcase
      end
    end
  end
endmodule
