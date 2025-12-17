module dual_flop_sync #(
    parameter logic FETCH_AT_POSEDGE = 1,
    parameter logic LAUNCH_AT_POSEDGE = 1,
    parameter logic BYPASS_EN = 0
) (
    input  logic clk_i,
    input  logic arst_ni,
    input  logic d_i,
    output logic q_o
);

  logic d_d, d_dd;

  generate
    if (FETCH_AT_POSEDGE && LAUNCH_AT_POSEDGE) begin : g_fpos_lpos
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d  <= '0;
          d_dd <= '0;
        end else begin
          d_d  <= d_i;
          d_dd <= d_d;
        end
      end
    end else if (~FETCH_AT_POSEDGE && ~LAUNCH_AT_POSEDGE) begin : g_fneg_lneg
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_d  <= '0;
          d_dd <= '0;
        end else begin
          d_d  <= d_i;
          d_dd <= d_d;
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
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_d;
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
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          d_dd <= '0;
        end else begin
          d_dd <= d_d;
        end
      end
    end
  endgenerate

  assign q_o = (BYPASS_EN) ? d_i : d_dd;

endmodule
