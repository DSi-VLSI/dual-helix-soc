module dual_flop_sync #(
    parameter logic FETCH_AT_POSEDGE = 1,
    parameter logic LAUNCH_AT_POSEDGE = 1,
    parameter logic BYPASS_EN = 0,
    parameter logic MIDDLE_STAGE_EN = 0
) (
    input  logic clk_i,
    input  logic arst_ni,
    input  logic d_i,
    output logic q_o
);

  logic d_d, d_intr, d_dd;
  logic d_mstage_1, d_mstage_2;

  generate
    if (FETCH_AT_POSEDGE && LAUNCH_AT_POSEDGE) begin : g_fpos_lpos
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d <= '0;
        end else begin
          d_d <= d_i;
        end
      end
      if (MIDDLE_STAGE_EN) begin : g_middle_stage
        assign d_mstage_1 = d_d;
        assign d_intr = d_mstage_2;
        always_ff @(posedge clk_i or negedge arst_ni) begin
          if (~arst_ni) begin
            d_mstage_2 <= '0;
          end else begin
            d_mstage_2 <= d_mstage_1;
          end
        end
      end else begin : g_no_middle_stage
        assign d_intr = d_d;
      end
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_intr;
        end
      end
    end else if (~FETCH_AT_POSEDGE && ~LAUNCH_AT_POSEDGE) begin : g_fneg_lneg
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d <= '0;
        end else begin
          d_d <= d_i;
        end
      end
      if (MIDDLE_STAGE_EN) begin : g_middle_stage
        assign d_mstage_1 = d_d;
        assign d_intr = d_mstage_2;
        always_ff @(posedge clk_i or negedge arst_ni) begin
          if (~arst_ni) begin
            d_mstage_2 <= '0;
          end else begin
            d_mstage_2 <= d_mstage_1;
          end
        end
      end else begin : g_no_middle_stage
        assign d_intr = d_d;
      end
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_intr;
        end
      end
    end else if (FETCH_AT_POSEDGE && ~LAUNCH_AT_POSEDGE) begin : g_fpos_lneg
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d <= '0;
        end else begin
          d_d <= d_i;
        end
      end
      if (MIDDLE_STAGE_EN) begin : g_middle_stage
        assign d_mstage_1 = d_d;
        assign d_intr = d_mstage_2;
        always_ff @(posedge clk_i or negedge arst_ni) begin
          if (~arst_ni) begin
            d_mstage_2 <= '0;
          end else begin
            d_mstage_2 <= d_mstage_1;
          end
        end
      end else begin : g_no_middle_stage
        assign d_intr = d_d;
      end
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_intr;
        end
      end
    end else if (~FETCH_AT_POSEDGE && LAUNCH_AT_POSEDGE) begin : g_fneg_lpos
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d <= '0;
        end else begin
          d_d <= d_i;
        end
      end
      if (MIDDLE_STAGE_EN) begin : g_middle_stage
        assign d_mstage_1 = d_d;
        assign d_intr = d_mstage_2;
        always_ff @(posedge clk_i or negedge arst_ni) begin
          if (~arst_ni) begin
            d_mstage_2 <= '0;
          end else begin
            d_mstage_2 <= d_mstage_1;
          end
        end
      end else begin : g_no_middle_stage
        assign d_intr = d_d;
      end
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_intr;
        end
      end
    end
  endgenerate

  assign q_o = (BYPASS_EN) ? d_i : d_dd;

endmodule
