`include "axi/typedef.svh"
`include "o2a_dpd.svh"

module obi_2_axi_core_tb;

  // PARAMETERS
  parameter int OBI_ADDRW = 32;  // Address width
  parameter int OBI_DATAW = 32;  // Data Width
  parameter int OBI_STRBW = (OBI_DATAW / 8);  // Strobe width

  parameter int OBI_CLK_SPEED = 5000;  // Clock speed range in MHz

  // TYPEDEFS
  typedef struct packed {
    logic [OBI_ADDRW-1:0] addr;
    logic we;
    logic [OBI_DATAW-1:0] wdata;
    logic [OBI_STRBW-1:0] be;
  } obi_req_info_t;

  // WIRES AND SIGNALS
  `AXI_TYPEDEF_ALL(o2a_tb, logic [OBI_ADDRW-1:0], logic [3:0], logic [OBI_DATAW-1:0],
                   logic [OBI_STRBW-1:0], logic [7:0])

  logic                         clk_i;  // OBI Clock
  logic                         arst_ni;  // Async Global Reset
  logic         [OBI_ADDRW-1:0] addr_i;  // OBI request address
  logic                         we_i;  // OBI write enable
  logic         [OBI_DATAW-1:0] wdata_i;  // OBI write data
  logic         [OBI_STRBW-1:0] be_i;  // OBI byte enable
  logic                         req_i;  // OBI Request
  logic                         gnt_o;  // OBI Grant
  logic                         rvalid_o;  // OBI rvalid
  logic         [OBI_DATAW-1:0] rdata_o;  // OBI read data
  o2a_tb_req_t                  axi_req_o;  // AXI Request
  o2a_tb_resp_t                 axi_resp_i;  // AXI Response

  // REGISTERS
  logic         [OBI_DATAW-1:0] local_data_reg;

  // DUT INSTANTIATION
  obi_2_axi_core #(
      .OBI_ADDRW (OBI_ADDRW),
      .OBI_DATAW (OBI_DATAW),
      .OBI_STRBW (OBI_STRBW),
      .axi_req_t (o2a_tb_req_t),
      .axi_resp_t(o2a_tb_resp_t)
  ) u_dut (
      .clk_i(clk_i),
      .arst_ni(arst_ni),
      .addr_i(addr_i),
      .we_i(we_i),
      .wdata_i(wdata_i),
      .be_i(be_i),
      .req_i(req_i),
      .gnt_o(gnt_o),
      .rvalid_o(rvalid_o),
      .rdata_o(rdata_o),
      .axi_req_o(axi_req_o),
      .axi_resp_i(axi_resp_i)
  );

  // MACROS AND AUTOMATA
  `START_CLK(clk_i, OBI_CLK_SPEED)

  // TASKS AND FUNCTIONS
  task automatic apply_global_reset();
    arst_ni <= '1;
    #200ns;
    arst_ni <= '0;
    req_i <= '0;
    axi_resp_i <= '0;
    #700ns;
    arst_ni <= '1;
  endtask

  task automatic assert_arready();
    axi_resp_i.ar_ready <= '1;
  endtask
  task automatic deassert_arready();
    axi_resp_i.ar_ready <= '0;
  endtask

  task automatic send_rchannel(input logic [OBI_DATAW-1:0] rdata);
    axi_resp_i.r_valid <= '1;
    axi_resp_i.r.data  <= rdata;
    axi_resp_i.r.last  <= '1;
  endtask
  task automatic deassert_rvalid();
    axi_resp_i.r_valid <= '0;
  endtask

  task automatic assert_awready();
    axi_resp_i.aw_ready <= '1;
  endtask
  task automatic deassert_awready();
    axi_resp_i.aw_ready <= '0;
  endtask

  task automatic assert_wready();
    axi_resp_i.w_ready <= '1;
  endtask
  task automatic recv_wchannel(output logic [OBI_DATAW-1:0] wdata);
    axi_resp_i.w_ready <= '0;
    wdata = axi_req_o.w.data;
  endtask

  task automatic assert_bvalid();
    axi_resp_i.b_valid <= '1;
  endtask
  task automatic deassert_bvalid();
    axi_resp_i.b_valid <= '0;
  endtask

  task automatic send_request(logic [OBI_ADDRW-1:0] addr, logic we, logic [OBI_DATAW-1:0] wdata,
                              logic [OBI_STRBW-1:0] be);
    req_i <= '1;
    addr_i <= addr;
    we_i <= we;
    wdata_i <= wdata;
    be_i <= be;
    do @(posedge clk_i); while (~gnt_o);
    req_i <= '0;
  endtask

  task automatic service_request();
    obi_req_info_t current_req;
    logic [OBI_DATAW-1:0] current_local_reg_value = local_data_reg;

    @(posedge req_i);

    `HIGHLIGHT_MSG($sformatf("[%0t] KICK STARTING SERVICE REQWEST", $realtime))
    // store the incoming request as current request
    current_req.addr = addr_i;
    current_req.we = we_i;
    current_req.wdata = wdata_i;
    current_req.be = be_i;

    fork

      begin
        assert_arready();
        do @(posedge clk_i); while (~axi_req_o.ar_valid);
        deassert_arready();
      end
      begin
        send_rchannel(current_local_reg_value);
        do @(posedge clk_i); while (~axi_req_o.r_ready);
        deassert_rvalid();
      end

      if (current_req.we) begin
        assert_awready();
        do @(posedge clk_i); while (~axi_req_o.aw_valid);
        deassert_awready();
      end

      if (current_req.we) begin
        assert_wready();
        do @(posedge clk_i); while (~axi_req_o.w_valid);
        recv_wchannel(local_data_reg);
      end

      if (current_req.we) begin
        assert_bvalid();
        do @(posedge clk_i); while (~axi_req_o.b_ready);
        deassert_bvalid();
      end

    join

  endtask

  // TEST DRIVE
  initial begin
    local_data_reg = 32'h45;

    apply_global_reset();
    `HIGHLIGHT_MSG("Reset applied. test started")
    #10ns;
    send_request(32'hab, '0, '0, '0);
    #10ns;
    send_request(32'hab, '1, 32'h69, '1);
    #10ns;
    send_request(32'hab, '0, '0, '0);
    #10ns;
    send_request(32'hab, '1, 32'h78, '1);
    #10ns;
    send_request(32'hab, '1, 32'hFC, '1);
  end

  // TEST REACT
  initial begin
    forever begin
      service_request();
    end
  end

  // FINISH
  initial begin
    #10000ns;
    `HIGHLIGHT_MSG("Test timed out. NON-FATAL")
    $finish;
  end

endmodule
