module axil_slave_stub #(
    parameter type req_t  = logic,
    parameter type resp_t = logic
) (
    input  logic clk_i,
    input  logic arst_ni,
    input  logic req_i,
    output logic resp_o
);

  always @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      resp_o <= '0;
    end else begin
      // resp_o <= '0;
    end
  end

endmodule
