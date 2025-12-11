`include "axi/typedef.svh"

package uart_pkg;

  // Register Map:
  //   0x00 - Control Register (RW)       : Clock enable and FIFO flush control
  //   0x04 - Configuration Register (RW) : UART communication parameters
  //   0x08 - Clock Divisor Register (RW) : Baud rate divisor
  //   0x0C - TX FIFO Status (R)          : TX FIFO occupancy count
  //   0x10 - RX FIFO Status (R)          : RX FIFO occupancy count
  //   0x14 - TX FIFO Data (W)            : Write data to transmit
  //   0x20 - RX FIFO Data (R)            : Read and pop received data
  //   0x28 - RX FIFO Peek (R)            : Read received data (non-destructive)

  localparam int REG_CTRL_ADDR = 6'h00;
  localparam int REG_CFG_ADDR = 6'h04;
  localparam int REG_CLK_DIV_ADDR = 6'h08;
  localparam int REG_TX_FIFO_STAT_ADDR = 6'h0C;
  localparam int REG_RX_FIFO_STAT_ADDR = 6'h10;
  localparam int REG_TX_FIFO_DATA_ADDR = 6'h14;
  localparam int REG_RX_FIFO_DATA_ADDR = 6'h18;
  localparam int REG_RX_FIFO_PEEK_ADDR = 6'h1C;
  localparam int REG_ACCESS_ID_REQ = 6'h20;
  localparam int REG_ACCESS_ID_GNT = 6'h24;
  localparam int REG_ACCESS_ID_GNT_PEEK = 6'h28;

  // Control Register (CTRL) - 0x00
  typedef struct packed {
    logic [28:0] Reserved;       // [31:3] Reserved
    logic        RX_FIFO_FLUSH;  // [2] Flush RX FIFO
    logic        TX_FIFO_FLUSH;  // [1] Flush TX FIFO
    logic        CLK_EN;         // [0] Clock Enable
  } ctrl_reg_t;

  // Configuration Register (CONFIG) - 0x04
  typedef struct packed {
    logic [27:0] Reserved;       // [31:9] Reserved
    logic        TX_FULL;        // [8] TX FIFO full flag
    logic        TX_NEAR_FULL;   // [7] TX FIFO near full flag
    logic        RX_FULL;        // [6] RX FIFO full flag
    logic        RX_NEAR_FULL;   // [5] RX FIFO near full flag
    logic        RX_VALID;       // [4] RX data valid flag
    logic        RX_PARITY_ERR;  // [3] RX parity error flag
    logic        STOP_BITS;      // [2] Stop Bit Configuration
    logic        PARITY_TYPE;    // [1] Parity Type (0: Even, 1: Odd)
    logic        PARITY_EN;      // [0] Enable Parity Checking
  } cfg_reg_t;

  // Clock Divisor Register (CLK_DIV) - 0x08
  typedef struct packed {
    logic [31:0] CLK_DIV;  // [31:0] Clock divisor value
  } clk_div_reg_t;

  // TX FIFO Status Register (TX_FIFO_STAT) - 0x0C
  typedef struct packed {
    logic [31:0] TX_FIFO_COUNT;  // [31:0] Number of bytes in TX FIFO
  } tx_fifo_stat_reg_t;

  // RX FIFO Status Register (RX_FIFO_STAT) - 0x10
  typedef struct packed {
    logic [31:0] RX_FIFO_COUNT;  // [31:0] Number of bytes in RX FIFO
  } rx_fifo_stat_reg_t;

  // TX FIFO Data Register (TX_FIFO_DATA) - 0x14
  typedef struct packed {
    logic [23:0] Reserved;  // [31:8] Reserved
    logic [7:0]  TX_DATA;   // [7:0] Data byte to be transmitted
  } tx_fifo_data_reg_t;

  // RX FIFO Data Register (RX_FIFO_DATA) - 0x18
  typedef struct packed {
    logic [23:0] Reserved;  // [31:8] Reserved
    logic [7:0]  RX_DATA;   // [7:0] Received data byte
  } rx_fifo_data_reg_t;

  // RX FIFO Peek Register (RX_FIFO_PEEK) - 0x1C
  typedef struct packed {
    logic [23:0] Reserved;      // [31:8] Reserved
    logic [7:0]  RX_PEEK_DATA;  // [7:0] Received data byte (non-destructive read)
  } rx_fifo_peek_reg_t;

  // Access ID Request Register (ACCESS_ID_REQ) - 0x20
  typedef struct packed {
    logic [23:0] Reserved;   // [31:8] Reserved
    logic [7:0]  ACCESS_ID;  // [7:0] Access_id
  } access_id_req_reg_t;

  // Access ID Grant Register (ACCESS_ID_GNT) - 0x24
  typedef struct packed {
    logic [23:0] Reserved;   // [31:8] Reserved
    logic [7:0]  ACCESS_ID;  // [7:0] Access_id
  } access_id_gnt_reg_t;

  // Access ID Grant Peek Register (ACCESS_ID_GNT_PEEK) - 0x28
  typedef struct packed {
    logic [23:0] Reserved;   // [31:8] Reserved
    logic [7:0]  ACCESS_ID;  // [7:0] Access_id
  } access_id_gnt_peek_reg_t;

  localparam int ID_WIDTH = 2;
  localparam int ADDR_WIDTH = 32;
  localparam int USER_WIDTH = 8;
  localparam int DATA_WIDTH = 32;

  typedef logic [ID_WIDTH-1:0] id_t;
  typedef logic [ADDR_WIDTH-1:0] addr_t;
  typedef logic [DATA_WIDTH-1:0] data_t;
  typedef logic [DATA_WIDTH/8-1:0] strb_t;
  typedef logic [USER_WIDTH-1:0] user_t;

  // AXI Interface Type
  `AXI_TYPEDEF_ALL(axi, addr_t, id_t, data_t, strb_t, user_t)

  // APB Interface Type
  `AXI_LITE_TYPEDEF_ALL(axil, addr_t, data_t, strb_t)

  localparam int TX_FIFO_SIZE = 8;
  localparam int RX_FIFO_SIZE = 8;

endpackage
