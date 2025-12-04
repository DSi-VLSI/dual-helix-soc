
module obi_2_axi_core #(
    parameter int OBI_ADDRW = 32,  // Address width
    parameter int OBI_DATAW = 32,  // Data Width
    parameter int OBI_STRBW = (OBI_DATAW / 8),  // Strobe width

    parameter type axi_req_t  = logic,  // AXI Request structure
    parameter type axi_resp_t = logic   // AXI Response structure
) (

    input logic clk_i,   // Core speed
    input logic arst_ni, // Async Global Reset

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

  typedef enum {
    IDLE,
    SEND_AR,
    RECV_R,
    SEND_AW,
    SEND_W,
    RECV_B,
    GRANT
  } axi_fsm_state_e;

  axi_fsm_state_e axi_fsm_state, axi_fsm_next_state;

  always_comb begin
    axi_fsm_next_state = axi_fsm_state;

    axi_req_o = '0;
    axi_req_o.aw.addr = addr_i;
    axi_req_o.aw.size = 2;
    axi_req_o.aw.burst = 1;

    axi_req_o.ar.addr = addr_i;
    axi_req_o.ar.size = 2;
    axi_req_o.ar.burst = 1;

    axi_req_o.w.data = wdata_i;
    axi_req_o.w.strb = be_i;
    axi_req_o.w.last = '1;

    rdata_o = axi_resp_i.r.data;

    gnt_o = 0;
    rvalid_o = '0;

    axi_req_o.ar_valid = 0;
    axi_req_o.r_ready = 0;

    axi_req_o.aw_valid = 1'b0;
    axi_req_o.w_valid = 1'b0;
    axi_req_o.ar_valid = 1'b0;

    case (axi_fsm_state)
      IDLE: begin
        if (req_i) axi_fsm_next_state = SEND_AR;
      end
      SEND_AR: begin
        axi_req_o.ar_valid = '1;
        if (axi_resp_i.ar_ready) axi_fsm_next_state = RECV_R;
      end
      RECV_R: begin
        if (axi_resp_i.r_valid && axi_resp_i.r.last) begin
          if (we_i) begin
            axi_fsm_next_state = SEND_AW;
          end else begin
            axi_fsm_next_state = GRANT;
          end
        end
      end
      SEND_AW: begin
        axi_req_o.aw_valid = '1;
        if (axi_resp_i.aw_ready) axi_fsm_next_state = SEND_W;
      end
      SEND_W: begin
        axi_req_o.w_valid = '1;
        axi_req_o.w.last  = '1;
        if (axi_resp_i.w_ready) axi_fsm_next_state = RECV_B;
      end
      RECV_B: begin
        axi_req_o.b_ready = '1;
        if (axi_resp_i.b_valid) begin
          axi_fsm_next_state = GRANT;
        end
      end
      GRANT: begin
        axi_req_o.r_ready = '1;
        gnt_o = '1;
        rvalid_o = '1;
        axi_fsm_next_state = IDLE;
      end
      default: begin
      end
    endcase
  end

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      axi_fsm_state <= IDLE;
    end else begin
      axi_fsm_state <= axi_fsm_next_state;
    end
  end

endmodule
