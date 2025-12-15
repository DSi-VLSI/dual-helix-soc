module soc_ctrl_top
  import dual_helix_pkg::dhs_axil_req_t;
  import dual_helix_pkg::dhs_axil_resp_t;
#(
    parameter type req_t = dhs_axil_req_t,
    parameter type resp_t = dhs_axil_resp_t,
    parameter int MEM_BASE = '0,
    parameter int MEM_SIZE = 32,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int REF_DIV_BW = 4,
    parameter int FB_DIV_BW = 12
) (
    input logic clk_i,
    input logic arst_ni,

    input  req_t  axil_req_i,
    output resp_t axil_resp_o,

    output logic [DATA_WIDTH-1:0] core_0_boot_addr_o,
    output logic [DATA_WIDTH-1:0] core_1_boot_addr_o,

    output logic [DATA_WIDTH-1:0] core_0_hart_id_o,
    output logic [DATA_WIDTH-1:0] core_1_hart_id_o,

    output logic [DATA_WIDTH-1:0] core_0_mtvec_o,
    output logic [DATA_WIDTH-1:0] core_1_mtvec_o,

    input boot_mode_i,

    output logic [DATA_WIDTH-1:0] gpr0_o,
    output logic [DATA_WIDTH-1:0] gpr1_o,


    output logic core_0_clk_o,
    output logic core_0_arst_n_o,
    output logic core_0_clk_en_o,

    output logic core_1_clk_o,
    output logic core_1_arst_n_o,
    output logic core_1_clk_en_o,

    output logic core_link_clk_o,
    output logic core_link_arst_n_o,
    output logic core_link_clk_en_o,

    output logic sys_link_clk_o,
    output logic sys_link_arst_n_o,
    output logic sys_link_clk_en_o,

    output logic periph_link_arst_n_o,
    output logic periph_link_clk_en_o
);

  logic                    intr_mem_we;
  logic [  ADDR_WIDTH-1:0] intr_mem_waddr;
  logic [  DATA_WIDTH-1:0] intr_mem_wdata;
  logic [DATA_WIDTH/8-1:0] intr_mem_wstrb;
  logic [             1:0] intr_mem_wresp;
  logic                    intr_mem_re;
  logic [  ADDR_WIDTH-1:0] intr_mem_raddr;
  logic [  DATA_WIDTH-1:0] intr_mem_rdata;
  logic [             1:0] intr_mem_rresp;


  logic                    intr_core_0_arst_n;
  logic                    intr_core_0_clk_en;
  logic                    intr_core_1_arst_n;
  logic                    intr_core_1_clk_en;
  logic                    intr_core_link_arst_n;
  logic                    intr_core_link_clk_en;
  logic                    intr_core_link_clk_mux_sel;
  logic                    intr_sys_link_arst_n;
  logic                    intr_sys_link_clk_en;
  logic                    intr_periph_link_arst_n;
  logic                    intr_periph_link_clk_en;

  logic [  REF_DIV_BW-1:0] core_0_pll_ref_div;
  logic [   FB_DIV_BW-1:0] core_0_pll_fb_div;
  logic                    core_0_pll_locked;
  logic [  REF_DIV_BW-1:0] core_1_pll_ref_div;
  logic [   FB_DIV_BW-1:0] core_1_pll_fb_div;
  logic                    core_1_pll_locked;
  logic [  REF_DIV_BW-1:0] sys_link_pll_ref_div;
  logic [   FB_DIV_BW-1:0] sys_link_pll_fb_div;
  logic                    sys_link_pll_locked;

  logic                    intr_core_0_pll_clk;
  logic                    intr_core_1_pll_clk;
  logic                    intr_core_link_clk;
  logic                    intr_sys_link_pll_clk;

  axil_to_simple_if #(
      .req_t   (dhs_axil_req_t),
      .resp_t  (dhs_axil_resp_t),
      .MEM_BASE(MEM_BASE),
      .MEM_SIZE(MEM_SIZE)
  ) u_cvtr (
      .arst_ni(arst_ni),
      .clk_i  (clk_i),
      .req_i  (axil_req_i),
      .resp_o (axil_resp_o),

      .mem_we_o   (intr_mem_we),
      .mem_waddr_o(intr_mem_waddr),
      .mem_wdata_o(intr_mem_wdata),
      .mem_wstrb_o(intr_mem_wstrb),
      .mem_wresp_i(intr_mem_wresp),

      .mem_re_o   (intr_mem_re),
      .mem_raddr_o(intr_mem_raddr),
      .mem_rdata_i(intr_mem_rdata),
      .mem_rresp_i(intr_mem_rresp)
  );

  soc_ctrl_reg_if #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_reg_if (
      .arst_ni                (arst_ni),
      .clk_i                  (clk_i),
      .mem_we_i               (intr_mem_we),
      .mem_waddr_i            (intr_mem_waddr),
      .mem_wdata_i            (intr_mem_wdata),
      .mem_wstrb_i            (intr_mem_wstrb),
      .mem_wresp_o            (intr_mem_wresp),
      .mem_re_i               (intr_mem_re),
      .mem_raddr_i            (intr_mem_raddr),
      .mem_rdata_o            (intr_mem_rdata),
      .mem_rresp_o            (intr_mem_rresp),
      .core_0_boot_addr_o     (core_0_boot_addr_o),
      .core_1_boot_addr_o     (core_1_boot_addr_o),
      .core_0_hart_id_o       (core_0_hart_id_o),
      .core_1_hart_id_o       (core_1_hart_id_o),
      .core_0_mtvec_o         (core_0_mtvec_o),
      .core_1_mtvec_o         (core_1_mtvec_o),
      .core_0_arst_n_o        (intr_core_0_arst_n),
      .core_0_clk_en_o        (intr_core_0_clk_en),
      .core_1_arst_n_o        (intr_core_1_arst_n),
      .core_1_clk_en_o        (intr_core_1_clk_en),
      .core_link_arst_n_o     (intr_core_link_arst_n),
      .core_link_clk_en_o     (intr_core_link_clk_en),
      .core_link_clk_mux_sel_o(intr_core_link_clk_mux_sel),
      .sys_link_arst_n_o      (intr_sys_link_arst_n),
      .sys_link_clk_en_o      (intr_sys_link_clk_en),
      .periph_link_arst_n_o   (intr_periph_link_arst_n),
      .periph_link_clk_en_o   (intr_periph_link_clk_en),
      .core_0_pll_ref_div_o   (core_0_pll_ref_div),
      .core_0_pll_fb_div_o    (core_0_pll_fb_div),
      .core_0_pll_locked_i    (core_0_pll_locked),
      .core_1_pll_ref_div_o   (core_1_pll_ref_div),
      .core_1_pll_fb_div_o    (core_1_pll_fb_div),
      .core_1_pll_locked_i    (core_1_pll_locked),
      .sys_link_pll_ref_div_o (sys_link_pll_ref_div),
      .sys_link_pll_fb_div_o  (sys_link_pll_fb_div),
      .sys_link_pll_locked_i  (sys_link_pll_locked),
      .gpr0_o                 (gpr0_o),
      .gpr1_o                 (gpr1_o),
      .boot_mode_i            (boot_mode_i)
  );


  always_comb begin
    if (intr_core_link_clk_mux_sel) begin
      intr_core_link_clk = intr_core_1_pll_clk;
    end else begin
      intr_core_link_clk = intr_core_0_pll_clk;
    end
  end


  pll #(
      .REF_DEV_WIDTH(REF_DIV_BW),
      .FB_DIV_WIDTH (FB_DIV_BW)
  ) core_0_pll (
      .arst_ni  (arst_ni),
      .clk_ref_i(clk_i),
      .refdiv_i (core_0_pll_ref_div),
      .fbdiv_i  (core_0_pll_fb_div),
      .clk_o    (intr_core_0_pll_clk),
      .locked_o (core_0_pll_locked)
  );

  pll #(
      .REF_DEV_WIDTH(REF_DIV_BW),
      .FB_DIV_WIDTH (FB_DIV_BW)
  ) core_1_pll (
      .arst_ni  (arst_ni),
      .clk_ref_i(clk_i),
      .refdiv_i (core_1_pll_ref_div),
      .fbdiv_i  (core_1_pll_fb_div),
      .clk_o    (intr_core_1_pll_clk),
      .locked_o (core_1_pll_locked)
  );

  pll #(
      .REF_DEV_WIDTH(REF_DIV_BW),
      .FB_DIV_WIDTH (FB_DIV_BW)
  ) sys_link_pll (
      .arst_ni  (arst_ni),
      .clk_ref_i(clk_i),
      .refdiv_i (sys_link_pll_ref_div),
      .fbdiv_i  (sys_link_pll_fb_div),
      .clk_o    (intr_sys_link_pll_clk),
      .locked_o (sys_link_pll_locked)
  );

  dhs_soc_ctrl_clk_rst_gen #() core_0_clk_rst_gen (
      .arst_ni (intr_core_0_arst_n),
      .clk_en_i(intr_core_0_clk_en),
      .clk_i   (intr_core_0_pll_clk),
      .arst_n_o(core_0_arst_n_o),
      .clk_en_o(core_0_clk_en_o),
      .clk_o   (core_0_clk_o)
  );

  dhs_soc_ctrl_clk_rst_gen #() core_1_clk_rst_gen (
      .arst_ni (intr_core_1_arst_n),
      .clk_en_i(intr_core_1_clk_en),
      .clk_i   (intr_core_1_pll_clk),
      .arst_n_o(core_1_arst_n_o),
      .clk_en_o(core_1_clk_en_o),
      .clk_o   (core_1_clk_o)
  );

  dhs_soc_ctrl_clk_rst_gen #() core_link_clk_rst_gen (
      .arst_ni (intr_core_link_arst_n),
      .clk_en_i(intr_core_link_clk_en),
      .clk_i   (intr_core_link_clk),
      .arst_n_o(core_link_arst_n_o),
      .clk_en_o(core_link_clk_en_o),
      .clk_o   (core_link_clk_o)
  );

  dhs_soc_ctrl_clk_rst_gen #() sys_link_clk_rst_gen (
      .arst_ni (intr_sys_link_arst_n),
      .clk_en_i(intr_sys_link_clk_en),
      .clk_i   (intr_sys_link_pll_clk),
      .arst_n_o(sys_link_arst_n_o),
      .clk_en_o(sys_link_clk_en_o),
      .clk_o   (sys_link_clk_o)
  );

  dhs_soc_ctrl_clk_rst_gen #() periph_link_clk_rst_gen (
      .arst_ni (intr_periph_link_arst_n),
      .clk_en_i(intr_periph_link_clk_en),
      .clk_i   (clk_i),
      .arst_n_o(periph_link_arst_n_o),
      .clk_en_o(periph_link_clk_en_o),
      .clk_o   ()
  );

endmodule
