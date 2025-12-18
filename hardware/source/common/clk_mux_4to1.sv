module clk_mux_4to1 (
    input logic arst_ni,
    input logic [1:0] sel_i,
    input logic clk_0_i,
    input logic clk_1_i,
    input logic clk_2_i,
    input logic clk_3_i,
    output logic clk_o
);

  logic lsb_mux_1_clk_o;
  logic lsb_mux_2_clk_o;

  clk_mux_2to1 sel_lsb_mux_1 (
      .arst_ni(arst_ni),
      .sel_i  (sel_i[0]),
      .clk_0_i(clk_0_i),
      .clk_1_i(clk_1_i),
      .clk_o  (lsb_mux_1_clk_o)
  );

  clk_mux_2to1 sel_lsb_mux_2 (
      .arst_ni(arst_ni),
      .sel_i  (sel_i[0]),
      .clk_0_i(clk_2_i),
      .clk_1_i(clk_3_i),
      .clk_o  (lsb_mux_2_clk_o)
  );

  clk_mux_2to1 sel_msb_mux (
      .arst_ni(arst_ni),
      .sel_i  (sel_i[1]),
      .clk_0_i(lsb_mux_1_clk_o),
      .clk_1_i(lsb_mux_2_clk_o),
      .clk_o  (clk_o)
  );

endmodule
