module apb_2_axil #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Global signals
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input logic arst_ni,  // Asynchronous reset, active low
    input logic clk_i,    // Clock input

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // APB Slave Interface
    ////////////////////////////////////////////////////////////////////////////////////////////////

    input logic                        psel_i,     // Peripheral select
    input logic                        penable_i,  // Peripheral enable
    input logic [      ADDR_WIDTH-1:0] paddr_i,    // Peripheral address
    input logic                        pwrite_i,   // Peripheral write enable
    input logic [      DATA_WIDTH-1:0] pwdata_i,   // Peripheral write data
    input logic [(DATA_WIDTH / 8)-1:0] pstrb_i,    // Peripheral byte strobe

    output logic                  pready_o,  // Peripheral ready
    output logic [DATA_WIDTH-1:0] prdata_o,  // Peripheral read data
    output logic                  pslverr_o, // Peripheral slave error

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // AXI4-Lite Master Interface Outputs
    ////////////////////////////////////////////////////////////////////////////////////////////////

    output logic [ADDR_WIDTH-1:0] awaddr_o,   // AXI write address
    output logic [           2:0] awprot_o,   // AXI write protection type
    output logic                  awvalid_o,  // AXI write address valid
    input  logic                  awready_i,  // AXI write address ready

    output logic [    DATA_WIDTH-1:0] wdata_o,   // AXI write data
    output logic [(DATA_WIDTH/8)-1:0] wstrb_o,   // AXI write strobes
    output logic                      wvalid_o,  // AXI write data
    input  logic                      wready_i,  // AXI write ready

    input  logic [1:0] bresp_i,   // AXI write response
    input  logic       bvalid_i,  // AXI write response valid
    output logic       bready_o,  // AXI write response ready

    output logic [ADDR_WIDTH-1:0] araddr_o,   // AXI read address
    output logic [           2:0] arprot_o,   // AXI read protection type
    output logic                  arvalid_o,  // AXI read address valid
    input  logic                  arready_i,  // AXI read address ready

    input  logic [DATA_WIDTH-1:0] rdata_i,   // AXI read data
    input  logic [           1:0] rresp_i,   // AXI read response
    input  logic                  rvalid_i,  // AXI read valid
    output logic                  rready_o   // AXI read ready
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
      prdata_o  <= '0;
      pslverr_o <= '0;
    end else if (response_latch_en) begin
      prdata_o  <= pwrite_i ? wdata_o : rdata_i;
      pslverr_o <= pwrite_i ? bresp_i[1] : rresp_i[1];
    end else if (response_clear) begin
      prdata_o  <= '0;
      pslverr_o <= '0;
    end
  end


  always_comb awaddr_o = paddr_i;
  always_comb awprot_o = '0;

  always_comb wdata_o = pwdata_i;
  always_comb wstrb_o = pstrb_i;

  always_comb araddr_o = paddr_i;
  always_comb arprot_o = '0;

  always_comb begin

    next_state        = current_state;
    awvalid_o         = '0;
    wvalid_o          = '0;
    bready_o          = '0;
    arvalid_o         = '0;
    rready_o          = '0;
    response_clear    = '0;
    response_latch_en = '0;
    pready_o          = '0;

    case (current_state)

      IDLE: begin
        if (psel_i && !penable_i) begin
          next_state = SETUP;
        end
      end

      SETUP: begin
        response_clear = 1'b1;
        if (psel_i && penable_i) begin
          if (pwrite_i) begin
            next_state = SEND_AW;
          end else begin
            next_state = SEND_AR;
          end
        end
      end

      SEND_AW: begin
        awvalid_o = 1'b1;
        if (awready_i) begin
          next_state = SEND_W;
        end
      end

      SEND_W: begin
        wvalid_o = 1'b1;
        if (wready_i) begin
          next_state = RECV_B;
        end
      end

      RECV_B: begin
        bready_o = 1'b1;
        response_latch_en = 1'b1;
        if (bvalid_i) begin
          next_state = ACCESS;
        end
      end

      SEND_AR: begin
        arvalid_o = 1'b1;
        if (arready_i) begin
          next_state = RECV_R;
        end
      end

      RECV_R: begin
        rready_o = 1'b1;
        response_latch_en = 1'b1;
        if (rvalid_i) begin
          next_state = ACCESS;
        end
      end

      ACCESS: begin
        pready_o = 1'b1;
        if (!psel_i) begin
          next_state = IDLE;
        end else if (!penable_i) begin
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
