module clk_gate (
    input  logic arst_ni,
    input  logic en_i,
    input  logic clk_i,
    output logic clk_o
);

  logic sampled_en_i;

  assign clk_o = clk_i & sampled_en_i;

  dual_flop_synchronizer #(
      .FIRST_FF_EDGE_POSEDGED(1),
      .LAST_FF_EDGE_POSEDGED (1)
  ) u_dual_flop_synchronizer (
      .clk_i  (clk_i),
      .arst_ni(arst_ni),
      .en_i   ('1),
      .d_i    (en_i),
      .q_o    (sampled_en_i)
  );

endmodule
