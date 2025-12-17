module toggle_detector #(
    parameter logic POSEDGE_ONLY = '0,
    parameter logic NEGEDGE_ONLY = '0
) (
    input  logic clk_i,
    input  logic arst_ni,
    input  logic target_i,
    output logic toggle_found_o
);

  logic target_previous;

  generate
    if ((~(POSEDGE_ONLY || NEGEDGE_ONLY)) || (POSEDGE_ONLY && NEGEDGE_ONLY)) begin : g_tgl_detect
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          target_previous <= '0;
        end else begin
          target_previous <= target_i;
        end
      end

      assign toggle_found_o = target_previous ^ target_i;
    end else if (POSEDGE_ONLY && ~NEGEDGE_ONLY) begin : g_posedge_detect
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          target_previous <= '0;
        end else begin
          target_previous <= target_i;
        end
      end

      assign toggle_found_o = ~target_previous & target_i;
    end else if (~POSEDGE_ONLY && NEGEDGE_ONLY) begin : g_negedge_detect
      always_ff @(posedge clk_i or negedge arst_ni) begin
        if (~arst_ni) begin
          target_previous <= '0;
        end else begin
          target_previous <= target_i;
        end
      end

      assign toggle_found_o = target_previous & ~target_i;
    end
  endgenerate

endmodule
