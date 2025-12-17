module clk_mux #(
    parameter int NUM_SELECT = 2,
    parameter int STABILIZATION_CYCLES = 2
) (
    input logic ref_clk_i,
    input logic arst_ni,
    input logic [$clog2(NUM_SELECT)-1:0] sel_i,
    input logic [NUM_SELECT-1:0] clk_i,
    output logic clk_o
);
  logic [$clog2(NUM_SELECT)-1:0] sel_toggle_seeker_array;
  logic sel_toggle_found;

  logic initiate_stabilization;
  logic [$clog2(STABILIZATION_CYCLES)-1:0] stabilization_status;
  logic stabilization_complete;
  logic clk_o_ready_mux_sel;

  logic clk_o_ready;
  logic [NUM_SELECT-1:0] intr_clk_i_en_array;

  logic [NUM_SELECT-1:0] intr_clk_array;
  logic intr_selected_clk;

  // Detect when the select pin toggles
  for (genvar i = 0; i < $clog2(NUM_SELECT); i++) begin : g_sel_toggle
    toggle_detector #(
        .POSEDGE_ONLY('0),
        .NEGEDGE_ONLY('0)
    ) u_sel_toggle_detect (
        .clk_i         (ref_clk_i),
        .arst_ni       (arst_ni),
        .target_i      (sel_i[i]),
        .toggle_found_o(sel_toggle_seeker_array[i])
    );
  end
  assign sel_toggle_found = |sel_toggle_seeker_array;  // select value has been altered

  soc_ctrl_counter #(
      .MAX_COUNT  (STABILIZATION_CYCLES),
      .RESET_VALUE(0),
      .UP_COUNT   (1),
      .DOWN_COUNT (0)
  ) delay_counter (
      .clk_i  (ref_clk_i),
      .arst_ni(arst_ni),
      .up_i   (initiate_stabilization),
      .down_i ('0),
      .count_o(stabilization_status)
  );

  always_comb begin
    stabilization_complete = '0;
    if (stabilization_status == STABILIZATION_CYCLES) begin
      stabilization_complete = '1;
    end
  end

  always_ff @(posedge ref_clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      clk_o_ready_mux_sel <= '0;  // Stop clk_o gate after reset
      // Since a select value is always present, start counter on reset as well
      initiate_stabilization <= '1;
    end else begin
      if (sel_toggle_found) begin // when select pin changes
        clk_o_ready_mux_sel <= '0; // clk_o gate needs to stop
        initiate_stabilization <= '1; // need to start stabilization
      end
      if (stabilization_complete) begin
        clk_o_ready_mux_sel <= '1;
        initiate_stabilization <= '0;
      end
    end
  end

  always_comb begin
    if (clk_o_ready_mux_sel) begin
      clk_o_ready = '1;
    end else begin
      clk_o_ready = '0;
    end
  end

  always_comb begin
    intr_clk_i_en_array = '0;
    intr_clk_i_en_array = (1 << sel_i);
  end

  for (genvar i = 0; i < NUM_SELECT; i++) begin : g_filter_clk
    clk_gate #(
        .FETCH_AT_POSEDGE('0),
        .LAUNCH_AT_POSEDGE('0),
        .BYPASS_EN('0)
    ) u_clk_gate (
        .arst_ni (arst_ni),
        .clk_en_i(intr_clk_i_en_array[i]),
        .clk_i   (clk_i[i]),
        .clk_en_o(),
        .clk_o   (intr_clk_array[i])
    );
  end

  assign intr_selected_clk = |intr_clk_array;

  clk_gate #(
      .FETCH_AT_POSEDGE('0),
      .LAUNCH_AT_POSEDGE('0),
      .BYPASS_EN('0)
  ) u_clk_gate (
      .arst_ni (arst_ni),
      .clk_en_i(clk_o_ready),
      .clk_i   (intr_selected_clk),
      .clk_en_o(),
      .clk_o   (clk_o)
  );

endmodule
