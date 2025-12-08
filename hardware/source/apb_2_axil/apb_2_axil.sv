module apb_2_axil #(
    parameter int  ADDR_WIDTH = 32,
    parameter int  DATA_WIDTH = 32,
    parameter type apb_req_t  = logic,
    parameter type apb_resp_t = logic,
    parameter type axi_req_t  = logic,
    parameter type axi_resp_t = logic
) (

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // APB Slave Interface
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input  logic      apb_clk_i,
    input  logic      apb_arst_ni,
    input  apb_req_t  apb_req_i,
    output apb_resp_t apb_resp_o,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXI4-Lite Master Interface Outputs
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input  logic      axi_clk_i,
    input  logic      axi_arst_ni,
    output axi_req_t  axi_req_o,
    input  axi_resp_t axi_resp_i
);

  apb_cdc #(
      .LogDepth(2),
      .req_t   (apb_req_t),
      .resp_t  (apb_resp_t),
      .addr_t  (logic [31:0]),
      .data_t  (logic [31:0]),
      .strb_t  (logic [3:0])
  ) u_apb_cdc (
      .src_pclk_i   (apb_clk_i),
      .src_preset_ni(apb_arst_ni),
      .src_req_i    (apb_req_i),
      .src_resp_o   (apb_resp_o),
      .dst_pclk_i   (axi_clk_i),
      .dst_preset_ni(axi_arst_ni),
      .dst_req_o    (axi_req_o),
      .dst_resp_i   (axi_resp_i)
  );

  typedef enum int {
    IDLE,
    SETUP,
    SEND_AW,
    SEND_W,
    RECV_B,
    SEND_AR,
    RECV_R,
    ACCESS
  } state_t;

  state_t current_state;
  state_t next_state;

  logic   response_clear;
  logic   response_latch_en;

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      apb_resp_o.prdata  <= '0;
      apb_resp_o.pslverr <= '0;
    end else if (response_latch_en) begin
      apb_resp_o.prdata  <= apb_req_i.pwrite ? axi_req_o.w.data : axi_resp_i.r.data;
      apb_resp_o.pslverr <= apb_req_i.pwrite ? axi_resp_i.b.resp[1] : axi_resp_i.r.resp[1];
    end else if (response_clear) begin
      apb_resp_o.prdata  <= '0;
      apb_resp_o.pslverr <= '0;
    end
  end

  always_comb axi_req_o.aw.addr = apb_req_i.paddr;
  always_comb axi_req_o.aw.prot = '0;

  always_comb axi_req_o.w.data = apb_req_i.pwdata;
  always_comb axi_req_o.w.strb = apb_req_i.pstrb;

  always_comb axi_req_o.ar.addr = apb_req_i.paddr;
  always_comb axi_req_o.ar.prot = '0;

  always_comb begin

    next_state        = current_state;
    axi_req_o.aw_valid = '0;
    axi_req_o.w_valid  = '0;
    axi_req_o.b_ready  = '0;
    axi_req_o.ar_valid = '0;
    axi_req_o.r_ready  = '0;
    response_clear    = '0;
    response_latch_en = '0;
    apb_resp_o.pready = '0;

    case (current_state)

      IDLE: begin
        if (apb_req_i.psel && !apb_req_i.penable) begin
          next_state = SETUP;
        end
      end

      SETUP: begin
        response_clear = 1'b1;
        if (apb_req_i.psel && apb_req_i.penable) begin
          if (apb_req_i.pwrite) begin
            next_state = SEND_AW;
          end else begin
            next_state = SEND_AR;
          end
        end
      end

      SEND_AW: begin
        axi_req_o.aw_valid = 1'b1;
        if (axi_resp_i.aw_ready) begin
          next_state = SEND_W;
        end
      end

      SEND_W: begin
        axi_req_o.w_valid = 1'b1;
        if (axi_resp_i.w_ready) begin
          next_state = RECV_B;
        end
      end

      RECV_B: begin
        axi_req_o.b_ready  = 1'b1;
        response_latch_en = 1'b1;
        if (axi_resp_i.b_valid) begin
          next_state = ACCESS;
        end
      end

      SEND_AR: begin
        axi_req_o.ar_valid = 1'b1;
        if (axi_resp_i.ar_ready) begin
          next_state = RECV_R;
        end
      end

      RECV_R: begin
        axi_req_o.r_ready  = 1'b1;
        response_latch_en = 1'b1;
        if (axi_resp_i.r_valid) begin
          next_state = ACCESS;
        end
      end

      ACCESS: begin
        apb_resp_o.pready = 1'b1;
        if (!apb_req_i.psel) begin
          next_state = IDLE;
        end else if (!apb_req_i.penable) begin
          next_state = SETUP;
        end
      end

      default: begin
      end

    endcase

  end

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

endmodule
