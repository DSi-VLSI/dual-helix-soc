`include "tb_dpd.svh"

module soc_ctrl_clk_rst_delay_gen_tb;

  parameter int DELAY_CYCLES = 50;
  logic ref_clk_i;
  logic glb_arst_ni;
  logic clk_i;
  logic arst_ni;
  logic clk_en_i;
  logic clk_o;
  logic arst_no;
  logic clk_en_o;


  soc_ctrl_clk_rst_delay_gen #(
      .DELAY_CYCLES(DELAY_CYCLES)
  ) u_dut (
      .ref_clk_i,
      .glb_arst_ni,
      .clk_i,
      .arst_ni,
      .clk_en_i,
      .clk_o,
      .arst_no,
      .clk_en_o
  );

  initial begin
    arst_ni = 1'b1;
    fork
      `APPLY_RST(glb_arst_ni, 100ns,);
      `START_CLK(ref_clk_i, 100);
    join
    `START_CLK(clk_i, 3200);

    `APPLY_RST(arst_ni, 100ns, clk_en_i <= 1'b1;);
    #2002ns;
    clk_en_i <= '0;
    #2us;
    $finish;
  end

  // specify
  //   $width(__SIGNAL__, __TRIGGER__, __MIN_WIDTH__, __TOLARENCE__, __NOTIFIER__);
  // endspecify

endmodule
