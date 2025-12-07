module obi_2_axi #(
    parameter int OBI_FIFO_DEPTH = 4,
    parameter int AXI_FIFO_DEPTH = 4,

    parameter int OBI_ADDRW = 32,  // Address width
    parameter int OBI_DATAW = 32,  // Data Width
    parameter int OBI_STRBW = (OBI_DATAW / 8),  // Strobe width

    parameter type aw_chan_t = logic,
    parameter type w_chan_t  = logic,
    parameter type b_chan_t  = logic,
    parameter type ar_chan_t = logic,
    parameter type r_chan_t  = logic,

    parameter type axi_req_t  = logic,  // AXI Request structure
    parameter type axi_resp_t = logic   // AXI Response structure
) (

    input logic clk_obi_i,  // OBI Clock
    input logic clk_axi_i,  // AXI clock
    input logic arst_ni,    // Async Global Reset

    input  logic [OBI_ADDRW-1:0] addr_i,   // OBI request address
    input  logic                 we_i,     // OBI write enable
    input  logic [OBI_DATAW-1:0] wdata_i,  // OBI write data
    input  logic [OBI_STRBW-1:0] be_i,     // OBI byte enable
    input  logic                 req_i,    // OBI Request
    output logic                 gnt_o,    // OBI Grant

    output logic                 rvalid_o,  // OBI rvalid
    output logic [OBI_DATAW-1:0] rdata_o,   // OBI read data

    output axi_req_t  axi_req_o,  // AXI request signals
    input  axi_resp_t axi_resp_i  // AXI response signals

);

  logic      [OBI_ADDRW-1:0] intr_addr_i;
  logic                      intr_we_i;
  logic      [OBI_DATAW-1:0] intr_wdata_i;
  logic      [OBI_STRBW-1:0] intr_be_i;
  logic                      intr_req_i;
  logic                      intr_gnt_o;

  logic                      intr_rvalid_o;
  logic      [OBI_DATAW-1:0] intr_rdata_o;

  axi_req_t                  intr_axi_req_o;
  axi_resp_t                 intr_axi_resp_i;

  cdc_fifo #(
      .ELEM_WIDTH($bits(intr_addr_i) + $bits(intr_we_i) + $bits(intr_wdata_i) + $bits(intr_be_i)),
      .FIFO_SIZE ($clog2(OBI_FIFO_DEPTH))
  ) u_req_fifo (
      .arst_ni(arst_ni),
      .elem_in_i({addr_i, we_i, wdata_i, be_i}),
      .elem_in_clk_i(clk_obi_i),
      .elem_in_valid_i(req_i),
      .elem_in_ready_o(gnt_o),
      .elem_out_o({intr_addr_i, intr_we_i, intr_wdata_i, intr_be_i}),
      .elem_out_clk_i(clk_axi_i),
      .elem_out_valid_o(intr_req_i),
      .elem_out_ready_i(intr_gnt_o)
  );

  cdc_fifo #(
      .ELEM_WIDTH($bits(intr_rdata_o)),
      .FIFO_SIZE ($clog2(OBI_FIFO_DEPTH))
  ) u_resp_fifo (
      .arst_ni(arst_ni),
      .elem_in_i(intr_rdata_o),
      .elem_in_clk_i(clk_axi_i),
      .elem_in_valid_i(intr_rvalid_o),
      .elem_in_ready_o(),
      .elem_out_o(rdata_o),
      .elem_out_clk_i(clk_obi_i),
      .elem_out_valid_o(rvalid_o),
      .elem_out_ready_i('1)
  );


  axi_fifo #(
      .Depth      (AXI_FIFO_DEPTH),
      .FallThrough('0),
      .aw_chan_t  (aw_chan_t),
      .w_chan_t   (w_chan_t),
      .b_chan_t   (b_chan_t),
      .ar_chan_t  (ar_chan_t),
      .r_chan_t   (r_chan_t),
      .axi_req_t  (axi_req_t),
      .axi_resp_t (axi_resp_t)
  ) u_axi_fifo (
      .clk_i(clk_axi_i),
      .rst_ni(arst_ni),
      .test_i('0),
      .slv_req_i(intr_axi_req_o),
      .slv_resp_o(intr_axi_resp_i),
      .mst_req_o(axi_req_o),
      .mst_resp_i(axi_resp_i)
  );

  obi_2_axi_core #(
      .OBI_ADDRW (OBI_ADDRW),
      .OBI_DATAW (OBI_DATAW),
      .OBI_STRBW (OBI_STRBW),
      .axi_req_t (axi_req_t),
      .axi_resp_t(axi_resp_t)
  ) u_core (
      .clk_i(clk_axi_i),
      .arst_ni(arst_ni),
      .req_i(intr_req_i),
      .gnt_o(intr_gnt_o),
      .rvalid_o(intr_rvalid_o),
      .we_i(intr_we_i),
      .be_i(intr_be_i),
      .addr_i(intr_addr_i),
      .wdata_i(intr_wdata_i),
      .rdata_o(intr_rdata_o),
      .axi_req_o(intr_axi_req_o),
      .axi_resp_i(intr_axi_resp_i)
  );

endmodule
