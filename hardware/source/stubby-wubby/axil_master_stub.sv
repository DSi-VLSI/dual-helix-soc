module axil_master_stub #(
    parameter type req_t  = logic,
    parameter type resp_t = logic
) (
    input  logic clk_i,
    input  logic arst_ni,
    output logic req_o,
    input  logic resp_i
);

  always @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      req_o <= '0;
    end else begin
      // resp_o <= '0;
    end
  end

endmodule
