module dhs_soc_ctrl_clk_rst_gen #(
) (
    input  logic arst_ni,
    input  logic clk_en_i,
    input  logic clk_i,
    output logic arst_n_o,
    output logic clk_en_o,
    output logic clk_o
);

  always_comb begin
    clk_en_o = clk_en_i;
    arst_n_o = arst_ni;
    clk_o    = clk_i;
  end

endmodule
