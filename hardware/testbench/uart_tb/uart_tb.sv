module uart_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOG
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial $display("\033[7;38m---------------------- TEST STARTED ----------------------\033[0m");
  final $display("\033[7;38m----------------------- TEST ENDED -----------------------\033[0m");

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  import uart_pkg::REG_CTRL_ADDR;
  import uart_pkg::REG_CFG_ADDR;
  import uart_pkg::REG_CLK_DIV_ADDR;
  import uart_pkg::REG_TX_FIFO_STAT_ADDR;
  import uart_pkg::REG_RX_FIFO_STAT_ADDR;
  import uart_pkg::REG_TX_FIFO_DATA_ADDR;
  import uart_pkg::REG_RX_FIFO_DATA_ADDR;
  import uart_pkg::REG_RX_FIFO_PEEK_ADDR;
  import uart_pkg::REG_ACCESS_ID_REQ_ADDR;
  import uart_pkg::REG_ACCESS_ID_GNT_ADDR;
  import uart_pkg::REG_ACCESS_ID_GNT_PEEK_ADDR;

  import uart_pkg::ctrl_reg_t;
  import uart_pkg::cfg_reg_t;
  import uart_pkg::clk_div_reg_t;
  import uart_pkg::tx_fifo_stat_reg_t;
  import uart_pkg::rx_fifo_stat_reg_t;
  import uart_pkg::tx_fifo_data_reg_t;
  import uart_pkg::rx_fifo_data_reg_t;
  import uart_pkg::rx_fifo_peek_reg_t;
  import uart_pkg::access_id_req_reg_t;
  import uart_pkg::access_id_gnt_reg_t;
  import uart_pkg::access_id_gnt_peek_reg_t;

  import uart_pkg::TX_FIFO_SIZE;
  import uart_pkg::RX_FIFO_SIZE;
  import uart_pkg::AID_FIFO_SIZE;

  import dual_helix_pkg::dhs_addr_t;
  import dual_helix_pkg::dhs_user_t;
  import dual_helix_pkg::dhs_data_t;
  import dual_helix_pkg::dhs_strb_t;

  import dual_helix_pkg::dhs_axil_req_t;
  import dual_helix_pkg::dhs_axil_resp_t;

  import dual_helix_pkg::UART_BASE;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PHYSICAL ADDRESS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  /* verilog_format: off */
  dhs_addr_t CTRL_ADDR               = UART_BASE + REG_CTRL_ADDR;
  dhs_addr_t CFG_ADDR                = UART_BASE + REG_CFG_ADDR;
  dhs_addr_t CLK_DIV_ADDR            = UART_BASE + REG_CLK_DIV_ADDR;
  dhs_addr_t TX_FIFO_STAT_ADDR       = UART_BASE + REG_TX_FIFO_STAT_ADDR;
  dhs_addr_t RX_FIFO_STAT_ADDR       = UART_BASE + REG_RX_FIFO_STAT_ADDR;
  dhs_addr_t TX_FIFO_DATA_ADDR       = UART_BASE + REG_TX_FIFO_DATA_ADDR;
  dhs_addr_t RX_FIFO_DATA_ADDR       = UART_BASE + REG_RX_FIFO_DATA_ADDR;
  dhs_addr_t RX_FIFO_PEEK_ADDR       = UART_BASE + REG_RX_FIFO_PEEK_ADDR;
  dhs_addr_t ACCESS_ID_REQ_ADDR      = UART_BASE + REG_ACCESS_ID_REQ_ADDR;
  dhs_addr_t ACCESS_ID_GNT_ADDR      = UART_BASE + REG_ACCESS_ID_GNT_ADDR;
  dhs_addr_t ACCESS_ID_GNT_PEEK_ADDR = UART_BASE + REG_ACCESS_ID_GNT_PEEK_ADDR;
  /* verilog_format: on */

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  /* verilog_format: off */
  ctrl_reg_t               ctrl_reg;
  cfg_reg_t                cfg_reg;
  clk_div_reg_t            clk_div_reg;
  tx_fifo_stat_reg_t       tx_fifo_stat_reg;
  rx_fifo_stat_reg_t       rx_fifo_stat_reg;
  tx_fifo_data_reg_t       tx_fifo_data_reg;
  rx_fifo_data_reg_t       rx_fifo_data_reg;
  rx_fifo_peek_reg_t       rx_fifo_peek_reg;
  access_id_req_reg_t      access_id_req_reg;
  access_id_gnt_reg_t      access_id_gnt_reg;
  access_id_gnt_peek_reg_t access_id_gnt_peek_reg;
  /* verilog_format: on */
  typedef enum logic [3:0] {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
  } uart_state_t;
  uart_state_t          send_rx_state;
  int                   baud_rate;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // WIRES AND SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic                 arst_n;
  logic                 clk;
  dhs_axil_req_t        req;
  dhs_axil_resp_t       resp;
  logic                 tx;
  logic                 rx;
  logic           [7:0] irq;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DUT INSTANCE
  //////////////////////////////////////////////////////////////////////////////////////////////////

  uart_top #(
      .req_t(dhs_axil_req_t),
      .resp_t(dhs_axil_resp_t),
      .MEM_BASE(UART_BASE),
      .MEM_SIZE(12),
      .DATA_WIDTH(32)
  ) u_dut (
      .arst_ni(arst_n),  // Active-low asynchronous reset
      .clk_i(clk),  // System clock
      .req_i(req),  // Bus request (AXI or APB)
      .resp_o(resp),  // Bus response (AXI or APB)
      .tx_o(tx),  // UART transmit output
      .rx_i(rx),  // UART receive input
      .irq_o(irq)  // Interrupt output (RX data ready)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic start_clock();
    `START_CLK(clk, 100)
  endtask

  // verilog_format: off
  task automatic apply_reset();
  `APPLY_RST(
    arst_n,
    10ns,
    rx <= '1;
    req <= '0;
  )
  endtask
  // verilog_format: on

  task automatic send_write(dhs_addr_t addr, dhs_data_t data);
    fork

      //------------------------------------------------------------------------------------------------
      // WRITE REQUEST
      //------------------------------------------------------------------------------------------------

      begin
        req.aw_valid <= '1;
        req.aw.addr  <= addr;

        do @(posedge clk); while (!resp.aw_ready);
        req.aw_valid <= '0;
      end

      begin
        req.w_valid <= '1;
        req.w.data  <= data;
        req.w.strb  <= '1;

        do @(posedge clk); while (!resp.w_ready);
        req.w_valid <= '0;
      end

      begin
        req.b_ready <= '1;

        do @(posedge clk); while (!resp.b_valid);
        `HIGHLIGHT_MSG($sformatf("W::ADDR: 0x%h, DATA: 0x%h, RESP: 0x%h", addr, data, resp.b.resp))
        req.b_ready <= '0;
      end

    join
  endtask

  task automatic send_read(dhs_addr_t addr);
    fork

      //------------------------------------------------------------------------------------------------
      // READ REQUEST
      //------------------------------------------------------------------------------------------------

      begin
        req.ar_valid <= '1;
        req.ar.addr  <= addr;

        do @(posedge clk); while (!resp.ar_ready);
        req.ar_valid <= '0;
      end

      begin
        req.r_ready <= '1;

        do @(posedge clk); while (!resp.r_valid);
        `HIGHLIGHT_MSG($sformatf(
                       "R::ADDR: 0x%h, DATA: 0x%h, RESP: 0x%h", addr, resp.r.data, resp.r.resp))
        req.r_ready <= '0;
      end

    join
  endtask

  task automatic send_read_peek(dhs_addr_t addr, output dhs_data_t data);
    fork

      //------------------------------------------------------------------------------------------------
      // READ REQUEST
      //------------------------------------------------------------------------------------------------

      begin
        req.ar_valid <= '1;
        req.ar.addr  <= addr;

        do @(posedge clk); while (!resp.ar_ready);
        req.ar_valid <= '0;
      end

      begin
        req.r_ready <= '1;

        do @(posedge clk); while (!resp.r_valid);
        // `HIGHLIGHT_MSG($sformatf(
        //                "R::ADDR: 0x%h, DATA: 0x%h, RESP: 0x%h", addr, resp.r.data, resp.r.resp))
        if (resp.r.resp == 0) data = resp.r.data;
        req.r_ready <= '0;
      end

    join
  endtask

  task automatic send_request(dhs_addr_t addr, dhs_data_t data);

    fork

      //------------------------------------------------------------------------------------------------
      // WRITE REQUEST
      //------------------------------------------------------------------------------------------------

      begin
        req.aw_valid <= '1;
        req.aw.addr  <= addr;

        do @(posedge clk); while (!resp.aw_ready);
        req.aw_valid <= '0;
      end

      begin
        req.w_valid <= '1;
        req.w.data  <= data;
        req.w.strb  <= '1;

        do @(posedge clk); while (!resp.w_ready);
        req.w_valid <= '0;
      end

      begin
        req.b_ready <= '1;

        do @(posedge clk); while (!resp.b_valid);
        `HIGHLIGHT_MSG($sformatf("W::ADDR: 0x%h, DATA: 0x%h, RESP: 0x%h\n", addr, data, resp.b.resp
                       ))
        req.b_ready <= '0;
      end

      //------------------------------------------------------------------------------------------------
      // READ REQUEST
      //------------------------------------------------------------------------------------------------

      begin
        req.ar_valid <= '1;
        req.ar.addr  <= addr;

        do @(posedge clk); while (!resp.ar_ready);
        req.ar_valid <= '0;
      end

      begin
        req.r_ready <= '1;

        do @(posedge clk); while (!resp.r_valid);
        `HIGHLIGHT_MSG($sformatf(
                       "R::ADDR: 0x%h, DATA: 0x%h, RESP: 0x%h\n", addr, resp.r.data, resp.r.resp))
        req.r_ready <= '0;
      end

    join

  endtask

  task automatic send_to_rx(logic [7:0] data, int numDataBits, int baud_rate, logic parityEnable,
                            logic parityType, int numStopBits);
    realtime time_period = (1s / baud_rate);
    send_rx_state = IDLE;

    while (1) begin
      if (send_rx_state == IDLE) begin
        rx <= '1;
        send_rx_state <= START;
        #(time_period);
      end else if (send_rx_state == START) begin
        rx <= '0;
        send_rx_state <= DATA;
        #(time_period);
      end else if (send_rx_state == DATA) begin
        for (int i = 0; i < numDataBits; i++) begin
          rx <= data[i];
          if (i == numDataBits - 1) begin
            if (parityEnable) send_rx_state <= PARITY;
            else send_rx_state <= STOP;
          end
          #(time_period);
        end
      end else if (send_rx_state == PARITY) begin
        if (parityType) begin
          rx <= ~(^data);
        end else begin
          rx <= (^data);
        end
        send_rx_state <= STOP;
        #(time_period);
      end else if (send_rx_state == STOP) begin
        for (int i = 0; i < numStopBits; i++) begin
          rx <= '1;
          if (i == numStopBits - 1) send_rx_state <= IDLE;
          #(time_period);
        end
        break;
      end
    end
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    $timeformat(-6, 3, "us");

    ctrl_reg                 = '0;
    ctrl_reg.CLK_EN          = '1;

    cfg_reg                  = '0;
    cfg_reg.TX_FULL_EN       = 1;
    cfg_reg.TX_NEAR_FULL_EN  = 1;
    cfg_reg.RX_FULL_EN       = 1;
    cfg_reg.RX_NEAR_FULL_EN  = 1;
    cfg_reg.RX_VALID_EN      = 1;
    cfg_reg.RX_PARITY_ERR_EN = 1;
    cfg_reg.STOP_BITS        = 0;
    cfg_reg.PARITY_TYPE      = 0;
    cfg_reg.PARITY_EN        = 1;

    apply_reset();
    start_clock();
    send_write(CTRL_ADDR, ctrl_reg);
    send_read(CTRL_ADDR);

    send_write(CFG_ADDR, cfg_reg);
    send_read(CFG_ADDR);

    // Configure Baud Rate
    begin
      baud_rate = 9600;
      clk_div_reg.CLK_DIV = int'(100e6 / baud_rate);
      send_read(CLK_DIV_ADDR);
      send_write(CLK_DIV_ADDR, clk_div_reg);
      send_read(CLK_DIV_ADDR);
    end

    // Test RX FIFO VALID Interrupt
    begin
      rx_fifo_data_reg.RX_DATA = $urandom;
      send_to_rx(rx_fifo_data_reg.RX_DATA, 8, baud_rate, cfg_reg.PARITY_EN, cfg_reg.PARITY_TYPE,
                 cfg_reg.STOP_BITS + 1);
      wait (irq[4]);
      `HIGHLIGHT_MSG("RX DATA FIFO VALID")
      send_read(RX_FIFO_DATA_ADDR);
      if (~irq[4]) `HIGHLIGHT_MSG("RX DATA FIFO POPPED")
    end

    // Check RX FIFO NEAR FULL and FULL Interrupt
    begin
      while (~irq[2]) begin
        rx_fifo_data_reg.RX_DATA = $urandom;
        send_to_rx(rx_fifo_data_reg.RX_DATA, 8, baud_rate, cfg_reg.PARITY_EN, cfg_reg.PARITY_TYPE,
                   cfg_reg.STOP_BITS + 1);
        if (irq[3]) begin
          `HIGHLIGHT_MSG("RX DATA FIFO HALF FULL")
        end
      end
      `HIGHLIGHT_MSG("RX DATA FIFO FULL")
    end

    // Empty RX DATA FIFO
    while (irq[4]) begin
      send_read(RX_FIFO_DATA_ADDR);
    end

    // ACCESS ID testing
    // verilog_format: off
    // verilog_lint: waive-start
    begin

      // Send Access Request

      access_id_req_reg = '0;

      access_id_req_reg.ACCESS_ID = 'h1;
      send_write(ACCESS_ID_REQ_ADDR, access_id_req_reg);

      access_id_req_reg.ACCESS_ID = 'h2;
      send_write(ACCESS_ID_REQ_ADDR, access_id_req_reg);

      fork  // Check the peek status;

        begin  // core 1

          int core_id;

          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 1 Requesting Access", `__FILE__, `__LINE__, $realtime))
          while (1) begin
            `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 1 Peeking Access", `__FILE__, `__LINE__, $realtime))
            send_read_peek(ACCESS_ID_GNT_PEEK_ADDR, core_id);
            if (core_id == 1) begin
              break;
            end else begin
              `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 1 Idling", `__FILE__, `__LINE__, $realtime))
              repeat (100) @(posedge clk);
            end
          end

          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 1 has access", `__FILE__, `__LINE__, $realtime))
          do @(posedge clk); while (irq[0]);
          send_write(TX_FIFO_DATA_ADDR, 'hAB);
          send_read(ACCESS_ID_GNT_ADDR);
          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 1 Access Release", `__FILE__, `__LINE__, $realtime))
        end

        begin  // core 2

          int core_id;

          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 2 Requesting Access", `__FILE__, `__LINE__, $realtime))
          while (1) begin
            `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 2 Peeking Access", `__FILE__, `__LINE__, $realtime))
            send_read_peek(ACCESS_ID_GNT_PEEK_ADDR, core_id);
            if (core_id == 2) begin
              break;
            end else begin
              `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 2 Idling", `__FILE__, `__LINE__, $realtime))
              repeat (100) @(posedge clk);
            end
          end

          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 2 has access", `__FILE__, `__LINE__, $realtime))
          do @(posedge clk); while (irq[0]);
          send_write(TX_FIFO_DATA_ADDR, 'hAB);
          send_read(ACCESS_ID_GNT_ADDR);
          `HIGHLIGHT_MSG($sformatf("[%s][%0d][%0t] Core 2 Access Release", `__FILE__, `__LINE__, $realtime))
        end

      join

    end
    // verilog_lint: waive-stop
    // verilog_format: on

    $display("tx_fifo_full: 0b%b", irq[0]);

    // Check TX FIFO NEAR FULL and FULL Interrupt
    begin
      tx_fifo_data_reg = '0;
      while (1) begin
        tx_fifo_data_reg.TX_DATA = $urandom;
        send_write(TX_FIFO_DATA_ADDR, tx_fifo_data_reg);
        if (irq[1]) begin
          `HIGHLIGHT_MSG("TX DATA FIFO HALF FULL")
        end
        if (irq[0]) break;
      end
      `HIGHLIGHT_MSG("TX DATA FIFO FULL")
    end

    repeat (10000) @(posedge clk);
    `HIGHLIGHT_MSG("TEST COMPLETE")
    $finish;
  end

  initial begin
    #100ms;
    `HIGHLIGHT_MSG("NON-FATAL TIMEOUT")
    $finish;
  end
endmodule
