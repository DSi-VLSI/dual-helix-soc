module soc_ctrl_top_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INCLUDES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  `include "tb_dpd.svh"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  import dual_helix_pkg::dhs_axil_req_t;
  import dual_helix_pkg::dhs_axil_resp_t;

  import soc_ctrl_pkg::SC_BOOT_ADDR_CORE_0_ADDR;
  import soc_ctrl_pkg::SC_BOOT_ADDR_CORE_1_ADDR;
  import soc_ctrl_pkg::SC_HARD_ID_CORE_0_ADDR;
  import soc_ctrl_pkg::SC_HARD_ID_CORE_1_ADDR;
  import soc_ctrl_pkg::SC_MTVEC_ADDR_CORE_0_ADDR;
  import soc_ctrl_pkg::SC_MTVEC_ADDR_CORE_1_ADDR;
  import soc_ctrl_pkg::SC_CLK_RST_CORE_0_ADDR;
  import soc_ctrl_pkg::SC_CLK_RST_CORE_1_ADDR;
  import soc_ctrl_pkg::SC_CLK_RST_CORE_LINK_ADDR;
  import soc_ctrl_pkg::SC_CLK_RST_SYS_LINK_ADDR;
  import soc_ctrl_pkg::SC_CLK_RST_PERIPH_LINK_ADDR;
  import soc_ctrl_pkg::SC_PLL_CONFIG_CORE_0_ADDR;
  import soc_ctrl_pkg::SC_PLL_CONFIG_CORE_1_ADDR;
  import soc_ctrl_pkg::SC_PLL_CONFIG_SYS_LINK_ADDR;
  import soc_ctrl_pkg::SC_GPR_0_ADDR;
  import soc_ctrl_pkg::SC_GPR_1_ADDR;
  import soc_ctrl_pkg::SC_BOOT_MODE_ADDR;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PARAMETERS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  parameter int MEM_BASE = dual_helix_pkg::SOC_CTRL_BASE;
  parameter int MEM_SIZE = dual_helix_pkg::DHS_ADDRW;
  parameter int ADDR_WIDTH = dual_helix_pkg::DHS_ADDRW;
  parameter int DATA_WIDTH = dual_helix_pkg::DHS_DATAW;
  parameter int REF_DIV_BW = soc_ctrl_pkg::REF_DIV_BW;
  parameter int FB_DIV_BW = soc_ctrl_pkg::FB_DIV_BW;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                            ref_clk;
  logic                            glb_arst_n;
  dhs_axil_req_t                   axil_req;
  dhs_axil_resp_t                  axil_resp;
  logic           [DATA_WIDTH-1:0] core_0_boot_addr;
  logic           [DATA_WIDTH-1:0] core_1_boot_addr;
  logic           [DATA_WIDTH-1:0] core_0_hart_id;
  logic           [DATA_WIDTH-1:0] core_1_hart_id;
  logic           [DATA_WIDTH-1:0] core_0_mtvec;
  logic           [DATA_WIDTH-1:0] core_1_mtvec;
  logic                            boot_mode;
  logic           [DATA_WIDTH-1:0] gpr0;
  logic           [DATA_WIDTH-1:0] gpr1;
  logic                            core_0_clk;
  logic                            core_0_arst_n;
  logic                            core_0_clk_en;
  logic                            core_1_clk;
  logic                            core_1_arst_n;
  logic                            core_1_clk_en;
  logic                            core_link_clk;
  logic                            core_link_arst_n;
  logic                            core_link_clk_en;
  logic                            sys_link_clk;
  logic                            sys_link_arst_n;
  logic                            sys_link_clk_en;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // WIRES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // REGISTERS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  semaphore                        write_arbiter = new(1);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DUT INSTANTIATION
  //////////////////////////////////////////////////////////////////////////////////////////////////

  soc_ctrl_top #(
      .req_t(dhs_axil_req_t),
      .resp_t(dhs_axil_resp_t),
      .MEM_BASE(MEM_BASE),
      .MEM_SIZE(MEM_SIZE),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      .REF_DIV_BW(REF_DIV_BW),
      .FB_DIV_BW(FB_DIV_BW)
  ) u_dut (
      .ref_clk_i(ref_clk),
      .glb_arst_ni(glb_arst_n),
      .axil_req_i(axil_req),
      .axil_resp_o(axil_resp),
      .core_0_boot_addr_o(core_0_boot_addr),
      .core_1_boot_addr_o(core_1_boot_addr),
      .core_0_hart_id_o(core_0_hart_id),
      .core_1_hart_id_o(core_1_hart_id),
      .core_0_mtvec_o(core_0_mtvec),
      .core_1_mtvec_o(core_1_mtvec),
      .boot_mode_i(boot_mode),
      .gpr0_o(gpr0),
      .gpr1_o(gpr1),
      .core_0_clk_o(core_0_clk),
      .core_0_arst_n_o(core_0_arst_n),
      .core_0_clk_en_o(core_0_clk_en),
      .core_1_clk_o(core_1_clk),
      .core_1_arst_n_o(core_1_arst_n),
      .core_1_clk_en_o(core_1_clk_en),
      .core_link_clk_o(core_link_clk),
      .core_link_arst_n_o(core_link_arst_n),
      .core_link_clk_en_o(core_link_clk_en),
      .sys_link_clk_o(sys_link_clk),
      .sys_link_arst_n_o(sys_link_arst_n),
      .sys_link_clk_en_o(sys_link_clk_en),
      .periph_link_arst_n_o(),  // TODO - Why not tie to global??
      .periph_link_clk_en_o()  // TODO - Why not tie to global??
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // MACROS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic apply_global_reset();
    `APPLY_RST(glb_arst_n, 100, axil_req <= '0;)
  endtask

  task automatic soc_ctrl_write_32(logic [ADDR_WIDTH-1:0] t_addr, logic [DATA_WIDTH-1:0] t_data,
                                   logic [1:0] t_resp);
    write_arbiter.get(1);
    fork
      begin
        axil_req.aw_valid <= '1;
        axil_req.aw.addr  <= t_addr;

        do @(posedge ref_clk); while (~axil_resp.aw_ready);
        axil_req.aw_valid <= '0;
      end
      begin
        axil_req.w_valid <= '1;
        axil_req.w.data  <= t_data;

        do @(posedge ref_clk); while (~axil_resp.w_ready);
        axil_req.w_valid <= '0;
      end
      begin
        axil_req.b_ready <= '1;

        do @(posedge ref_clk); while (~axil_resp.b_valid);
        t_resp = axil_resp.b.resp;
        axil_req.b_ready <= '0;
      end
    join
    write_arbiter.put(1);
  endtask

  task automatic enable_sys_link();
    logic [ADDR_WIDTH-1:0] t_addr;
    logic [DATA_WIDTH-1:0] t_data;
    logic [1:0] t_resp;

    t_addr = SC_PLL_CONFIG_SYS_LINK_ADDR;
    t_data = {'0, 12'h140, 4'hA};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_SYS_LINK_ADDR;
    t_data = {'0, 1'b0, 1'b1};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_SYS_LINK_ADDR;
    t_data = '0;
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_SYS_LINK_ADDR;
    t_data = {'0, 1'b1, 1'b1};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

  endtask

  task automatic enable_core_0(int fb_div);
    logic [ADDR_WIDTH-1:0] t_addr;
    logic [DATA_WIDTH-1:0] t_data;
    logic [1:0] t_resp;

    t_addr = SC_PLL_CONFIG_CORE_0_ADDR;
    t_data = {'0, fb_div[11:0], 4'hA};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    // t_addr = SC_CLK_RST_CORE_0_ADDR;
    // t_data = {'0, 1'b0, 1'b1};
    // soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_CORE_0_ADDR;
    t_data = '0;
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_CORE_0_ADDR;
    t_data = {'0, 1'b1, 1'b1};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

  endtask

  task automatic enable_core_1(int fb_div);
    logic [ADDR_WIDTH-1:0] t_addr;
    logic [DATA_WIDTH-1:0] t_data;
    logic [1:0] t_resp;

    t_addr = SC_PLL_CONFIG_CORE_1_ADDR;
    t_data = {'0, fb_div[11:0], 4'hA};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    // t_addr = SC_CLK_RST_CORE_1_ADDR;
    // t_data = {'0, 1'b0, 1'b1};
    // soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_CORE_1_ADDR;
    t_data = '0;
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_CORE_1_ADDR;
    t_data = {'0, 1'b1, 1'b1};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

  endtask

  task automatic enable_core_link();
    logic [ADDR_WIDTH-1:0] t_addr;
    logic [DATA_WIDTH-1:0] t_data;
    logic [1:0] t_resp;

    t_addr = SC_CLK_RST_CORE_LINK_ADDR;
    t_data = {'0, 1'b0, 1'b0};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

    t_addr = SC_CLK_RST_CORE_LINK_ADDR;
    t_data = {'0, 1'b1, 1'b1};
    soc_ctrl_write_32(t_addr, t_data, t_resp);

  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    fork
      apply_global_reset();
      `START_CLK(ref_clk, 100)
    join
    enable_core_0(500);
    enable_core_1(400);
    enable_core_link();
    #3us;
    @(posedge ref_clk);
    enable_core_0(300);
    enable_core_1(400);
    enable_core_link();
    #10us;
    $finish;
  end

endmodule
