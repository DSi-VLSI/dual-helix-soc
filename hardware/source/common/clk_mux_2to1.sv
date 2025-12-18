module clk_mux_2to1 (
    input  logic arst_ni,
    input  logic sel_i,
    input  logic clk_0_i,
    input  logic clk_1_i,
    output logic clk_o
);

  logic clk_0_evlp;
  logic clk_1_evlp;

  logic intr_clk_0_en;
  logic intr_clk_1_en;

  logic intr_clk_0_copy;
  logic intr_clk_1_copy;

  always_comb begin
    clk_0_evlp = ~intr_clk_1_en & ~sel_i;
    clk_1_evlp = ~intr_clk_0_en & sel_i;
  end

  clk_gate #(
      .FETCH_AT_POSEDGE('0),
      .LAUNCH_AT_POSEDGE('0),
      .BYPASS_EN('0)
  ) u_clk_0_gate (
      .arst_ni (arst_ni),
      .clk_en_i(clk_0_evlp),
      .clk_i   (clk_0_i),
      .clk_en_o(intr_clk_0_en),
      .clk_o   (intr_clk_0_copy)
  );

  clk_gate #(
      .FETCH_AT_POSEDGE('0),
      .LAUNCH_AT_POSEDGE('0),
      .BYPASS_EN('0)
  ) u_clk_1_gate (
      .arst_ni (arst_ni),
      .clk_en_i(clk_1_evlp),
      .clk_i   (clk_1_i),
      .clk_en_o(intr_clk_1_en),
      .clk_o   (intr_clk_1_copy)
  );

  assign clk_o = intr_clk_0_copy | intr_clk_1_copy;

endmodule
