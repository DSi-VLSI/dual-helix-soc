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

  apb_req_t  fast_apb_req;
  apb_resp_t fast_apb_resp;

  logic cst_arst_n;

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
      .dst_req_o    (fast_apb_req),
      .dst_resp_i   (fast_apb_resp)
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

  always_ff @(posedge axi_clk_i or negedge cst_arst_n) begin
    if (~cst_arst_n) begin
      fast_apb_resp.prdata  <= '0;
      fast_apb_resp.pslverr <= '0;
    end else if (response_latch_en) begin
      fast_apb_resp.prdata  <= fast_apb_req.pwrite ? axi_req_o.w.data : axi_resp_i.r.data;
      fast_apb_resp.pslverr <= fast_apb_req.pwrite ? axi_resp_i.b.resp[1] : axi_resp_i.r.resp[1];
    end else if (response_clear) begin
      fast_apb_resp.prdata  <= '0;
      fast_apb_resp.pslverr <= '0;
    end
  end

  always_comb axi_req_o.aw.addr = fast_apb_req.paddr;
  always_comb axi_req_o.aw.prot = '0;

  always_comb axi_req_o.w.data = fast_apb_req.pwdata;
  always_comb axi_req_o.w.strb = fast_apb_req.pstrb;

  always_comb axi_req_o.ar.addr = fast_apb_req.paddr;
  always_comb axi_req_o.ar.prot = '0;

  always_comb begin

    next_state           = current_state;
    axi_req_o.aw_valid   = '0;
    axi_req_o.w_valid    = '0;
    axi_req_o.b_ready    = '0;
    axi_req_o.ar_valid   = '0;
    axi_req_o.r_ready    = '0;
    response_clear       = '0;
    response_latch_en    = '0;
    fast_apb_resp.pready = '0;

    case (current_state)

      IDLE: begin
        if (fast_apb_req.psel && !fast_apb_req.penable) begin
          next_state = SETUP;
        end
      end

      SETUP: begin
        response_clear = 1'b1;
        if (fast_apb_req.psel && fast_apb_req.penable) begin
          if (fast_apb_req.pwrite) begin
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
        axi_req_o.b_ready = 1'b1;
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
        axi_req_o.r_ready = 1'b1;
        response_latch_en = 1'b1;
        if (axi_resp_i.r_valid) begin
          next_state = ACCESS;
        end
      end

      ACCESS: begin
        fast_apb_resp.pready = 1'b1;
        if (!fast_apb_req.psel) begin
          next_state = IDLE;
        end else if (!fast_apb_req.penable) begin
          next_state = SETUP;
        end
      end

      default: begin
      end

    endcase

  end

  always_comb cst_arst_n = apb_arst_ni & axi_arst_ni;

  always_ff @(posedge axi_clk_i or negedge cst_arst_n) begin
    if (~cst_arst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

endmodule
