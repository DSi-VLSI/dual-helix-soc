module clk_gate #(
    parameter logic FETCH_AT_POSEDGE = 1,
    parameter logic LAUNCH_AT_POSEDGE = 1,
    parameter logic BYPASS_EN = 0
) (
    input  logic arst_ni,
    input  logic clk_en_i,
    input  logic clk_i,
    output logic clk_en_o,
    output logic clk_o
);

  logic clk_en_d, clk_en_dd;

  assign clk_en_o = (BYPASS_EN) ? clk_en_i : clk_en_dd;
  assign clk_o = (BYPASS_EN) ? clk_i : (clk_i && clk_en_dd);

  generate

    if (FETCH_AT_POSEDGE && LAUNCH_AT_POSEDGE) begin : g_fpos_lpos
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_d  <= '0;
          clk_en_dd <= '0;
        end else begin
          clk_en_d  <= clk_en_i;
          clk_en_dd <= clk_en_d;
        end
      end
    end else if (~FETCH_AT_POSEDGE && ~LAUNCH_AT_POSEDGE) begin : g_fneg_lneg
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_d  <= '0;
          clk_en_dd <= '0;
        end else begin
          clk_en_d  <= clk_en_i;
          clk_en_dd <= clk_en_d;
        end
      end
    end else if (FETCH_AT_POSEDGE && ~LAUNCH_AT_POSEDGE) begin : g_fpos_lneg
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_d <= '0;
        end else begin
          clk_en_d <= clk_en_i;
        end
      end
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_dd <= '0;
        end else begin
          clk_en_dd <= clk_en_d;
        end
      end
    end else if (~FETCH_AT_POSEDGE && LAUNCH_AT_POSEDGE) begin : g_fneg_lpos
      always_ff @(negedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_d <= '0;
        end else begin
          clk_en_d <= clk_en_i;
        end
      end
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          clk_en_dd <= '0;
        end else begin
          clk_en_dd <= clk_en_d;
        end
      end
    end

  endgenerate


endmodule
