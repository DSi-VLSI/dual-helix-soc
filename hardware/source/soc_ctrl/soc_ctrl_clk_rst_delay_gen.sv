module soc_ctrl_clk_rst_delay_gen #(
    parameter int DELAY_CYCLES = 50
) (
    input logic ref_clk_i,
    input logic glb_arst_ni,

    input  logic clk_i,
    input  logic arst_ni,
    input  logic clk_en_i,
    output logic clk_o,
    output logic arst_no,
    output logic clk_en_o
);

  logic                            intr_arst_n;
  logic                            arst_n_posedge_found;
  logic                            initiate_delay;
  logic [$clog2(DELAY_CYCLES)-1:0] delay_status;
  logic                            clk_en_good_to_go;
  logic                            clk_en_pass_mux_sel;
  logic clk_en_synced, clk_en_pass;

  always_comb begin
    intr_arst_n = glb_arst_ni && arst_ni;
    arst_no = intr_arst_n;
  end

  edge_detector #(
      .POSEDGE('1),
      .NEGEDGE('0),
      .ASYNC  ('1)
  ) reset_posedge (
      .arst_ni  (intr_arst_n),
      .clk_i    (ref_clk_i),
      .d_i      (intr_arst_n),
      .posedge_o(arst_n_posedge_found),
      .negedge_o()
  );

  soc_ctrl_counter #(
      .MAX_COUNT  (DELAY_CYCLES),
      .RESET_VALUE(0),
      .UP_COUNT   (1),
      .DOWN_COUNT (0)
  ) delay_counter (
      .clk_i  (ref_clk_i),
      .arst_ni(intr_arst_n),
      .up_i   (initiate_delay),
      .down_i ('0),
      .count_o(delay_status)
  );

  always_comb begin
    clk_en_good_to_go = '0;
    if (delay_status == 50) begin
      clk_en_good_to_go = '1;
    end
  end

  always_ff @(posedge ref_clk_i or negedge intr_arst_n) begin
    if (!intr_arst_n) begin
      initiate_delay <= '0;
      clk_en_pass_mux_sel <= '0;
    end else begin
      if (arst_n_posedge_found) begin
        initiate_delay <= '1;
      end
      if (clk_en_good_to_go) begin
        initiate_delay <= '0;
        clk_en_pass_mux_sel <= '1;
      end
    end
  end

  dual_flop_sync #(
      .FETCH_AT_POSEDGE('1),
      .LAUNCH_AT_POSEDGE('1),
      .BYPASS_EN('1)
  ) u_df_sync_clk_en_i (
      .clk_i  (clk_i),
      .arst_ni(intr_arst_n),
      .d_i    (clk_en_i),
      .q_o    (clk_en_synced)
  );

  always_comb begin
    if (clk_en_pass_mux_sel) begin
      clk_en_pass = clk_en_synced;
    end else begin
      clk_en_pass = '0;
    end
  end

  clk_gate #(
      .FETCH_AT_POSEDGE('0),
      .LAUNCH_AT_POSEDGE('0),
      .BYPASS_EN('0)
  ) u_clk_gate (
      .arst_ni (intr_arst_n),
      .clk_en_i(clk_en_pass),
      .clk_i   (clk_i),
      .clk_en_o(clk_en_o),
      .clk_o   (clk_o)
  );

endmodule
