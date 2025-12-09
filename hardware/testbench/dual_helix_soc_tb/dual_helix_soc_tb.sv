`timescale 1ns / 1ps
`include "tb_dpd.svh"

module dual_helix_soc_tb;

  // Display messages at the start and end of the test
  initial $display("\033[7;38m---------------------- TEST STARTED ----------------------\033[0m");
  final $display("\033[7;38m----------------------- TEST ENDED -----------------------\033[0m");

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORT
  //////////////////////////////////////////////////////////////////////////////////////////////////

  import dual_helix_pkg::dhs_addr_t;
  import dual_helix_pkg::dhs_data_t;
  import dual_helix_pkg::dhs_apb_req_t;
  import dual_helix_pkg::dhs_apb_resp_t;
  import dual_helix_pkg::dhs_axil_req_t;
  import dual_helix_pkg::dhs_axil_resp_t;
  import dual_helix_pkg::dhs_sl_mp_axi_req_t;
  import dual_helix_pkg::dhs_sl_mp_axi_resp_t;
  import dual_helix_pkg::UART_BASE;
  import dual_helix_pkg::RAM_BASE;
  import dual_helix_pkg::DHS_ADDRW;
  import dual_helix_pkg::DHS_DATAW;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERNAL WIRE AND SIGNAL
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic core1_clk_i;  // TODO -  internal pll
  logic core2_clk_i;  // TODO -  internal pll
  logic corel_clk_i;  // TODO -  internal pll
  logic sysl_clk_i;  // TODO -  internal pll
  logic periphl_clk_i;  // TODO -  internal pll

  logic core1_arst_ni;  // TODO - glb_arst_ni
  logic core2_arst_ni;  // TODO - glb_arst_ni
  logic corel_arst_ni;  // TODO - glb_arst_ni
  logic sysl_arst_ni;  // TODO - glb_arst_ni
  logic periphl_arst_ni;  // TODO - glb_arst_ni

  dhs_addr_t core_1_boot_addr_i;  // TODO - SoC Controller
  dhs_data_t core_1_hart_id_i;  // TODO - SoC Controller
  dhs_addr_t core_2_boot_addr_i;  // TODO - SoC Controller
  dhs_data_t core_2_hart_id_i;  // TODO - SoC Controller

  // General I/O pins
  logic ref_clk_i;
  logic glb_arst_ni;
  logic boot_mode_i;

  // PLIC signals
  logic [3:0] ext_int_i;

  // APB slave interface for APB master
  logic apb_slv_clk_i;
  logic apb_slv_arst_ni;
  dhs_apb_req_t apb_slv_req_i;
  dhs_apb_resp_t apb_slv_resp_o;

  // External AXI RAM interface
  logic ext_ram_clk_o;
  logic ext_ram_arst_no;
  dhs_sl_mp_axi_req_t ext_ram_axi_req_o;
  dhs_sl_mp_axi_resp_t ext_ram_axi_resp_i;

  // UART interface
  logic uart_rx_i;
  logic uart_tx_o;

  // Quad SPI Interface
  wire cs_o;
  wire sclk_o;
  wire io0_io;
  wire io1_io;
  wire io2_io;
  wire io3_io;

  // GPR-N: General Purpose Register
  dhs_data_t gpr0_o;
  dhs_data_t gpr1_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INTERFACE
  //////////////////////////////////////////////////////////////////////////////////////////////////

  apb_if #(
      .ADDR_WIDTH(DHS_ADDRW),
      .DATA_WIDTH(DHS_DATAW)
  ) u_apb_if (
      .arst_ni(apb_slv_arst_ni),
      .clk_i  (apb_slv_clk_i)
  );

  uart_if u_uart_if ();

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLE
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int DEBUG = 0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DUAL HELIX SOC INSTANCE
  //////////////////////////////////////////////////////////////////////////////////////////////////

  dual_helix_soc u_dut (
      .core1_clk_i(core1_clk_i),
      .core2_clk_i(core2_clk_i),
      .corel_clk_i(corel_clk_i),
      .sysl_clk_i(sysl_clk_i),
      .periphl_clk_i(periphl_clk_i),
      .core1_arst_ni(core1_arst_ni),
      .core2_arst_ni(core2_arst_ni),
      .corel_arst_ni(corel_arst_ni),
      .sysl_arst_ni(sysl_arst_ni),
      .periphl_arst_ni(periphl_arst_ni),
      .core_1_boot_addr_i(core_1_boot_addr_i),
      .core_1_hart_id_i(core_1_hart_id_i),
      .core_2_boot_addr_i(core_2_boot_addr_i),
      .core_2_hart_id_i(core_2_hart_id_i),
      .ref_clk_i(ref_clk_i),
      .glb_arst_ni(glb_arst_ni),
      .boot_mode_i(boot_mode_i),
      .ext_int_i(ext_int_i),
      .apb_slv_clk_i(apb_slv_clk_i),
      .apb_slv_arst_ni(apb_slv_arst_ni),
      .apb_slv_req_i(apb_slv_req_i),
      .apb_slv_resp_o(apb_slv_resp_o),
      .ext_ram_clk_o(ext_ram_clk_o),
      .ext_ram_arst_no(ext_ram_arst_no),
      .ext_ram_axi_req_o(ext_ram_axi_req_o),
      .ext_ram_axi_resp_i(ext_ram_axi_resp_i),
      .uart_rx_i(uart_rx_i),
      .uart_tx_o(uart_tx_o),
      .cs_o(cs_o),
      .sclk_o(sclk_o),
      .io0_io(io0_io),
      .io1_io(io1_io),
      .io2_io(io2_io),
      .io3_io(io3_io),
      .gpr0_o(gpr0_o),
      .gpr1_o(gpr1_o)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // EXT RAM INSTANCE
  //////////////////////////////////////////////////////////////////////////////////////////////////

  axi_ram #(
      .MEM_BASE    (RAM_BASE),
      .MEM_SIZE    (31),
      .ALLOW_WRITES('1),
      .req_t       (dhs_sl_mp_axi_req_t),
      .resp_t      (dhs_sl_mp_axi_resp_t)
  ) ext_ram (
      .clk_i  (ext_ram_clk_o),
      .arst_ni(ext_ram_arst_no),
      .req_i  (ext_ram_axi_req_o),
      .resp_o (ext_ram_axi_resp_i)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // COMBINATIONAL
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    apb_slv_req_i = '0;
    apb_slv_req_i.psel = u_apb_if.psel;
    apb_slv_req_i.penable = u_apb_if.penable;
    apb_slv_req_i.paddr = u_apb_if.paddr;
    apb_slv_req_i.pwrite = u_apb_if.pwrite;
    apb_slv_req_i.pwdata = u_apb_if.pwdata;
    apb_slv_req_i.pstrb = u_apb_if.pstrb;
    u_apb_if.pready = apb_slv_resp_o.pready;
    u_apb_if.prdata = apb_slv_resp_o.prdata;
    u_apb_if.pslverr = apb_slv_resp_o.pslverr;
  end

  assign u_uart_if.rx = uart_tx_o;
  assign uart_rx_i = u_uart_if.tx;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIAL
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHOD
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task automatic start_clock();
    fork
      forever begin
        sysl_clk_i <= '1;
        #(1us / 3200);
        sysl_clk_i <= '0;
        #(1us / 3200);
      end
      forever begin
        periphl_clk_i <= '1;
        #(1us / 100);
        periphl_clk_i <= '0;
        #(1us / 100);
      end
      forever begin
        apb_slv_clk_i <= '1;
        #(1us / 80);
        apb_slv_clk_i <= '0;
        #(1us / 80);
      end
    join_none
  endtask

  task automatic start_core_clocks();
    fork
      forever begin
        core1_clk_i <= '1;
        #(1us / 2000);
        core1_clk_i <= '0;
        #(1us / 2000);
      end
      forever begin
        core2_clk_i <= '1;
        #(1us / 4000);
        core2_clk_i <= '0;
        #(1us / 4000);
      end
      forever begin
        corel_clk_i <= '1;
        #(1us / 5000);
        corel_clk_i <= '0;
        #(1us / 5000);
      end
    join_none
  endtask

  task automatic apply_reset(realtime hold_time);
    core1_clk_i <= '0;
    core2_clk_i <= '0;
    corel_clk_i <= '0;
    sysl_clk_i <= '0;
    periphl_clk_i <= '0;
    apb_slv_clk_i <= '0;
    core1_arst_ni <= '0;
    core2_arst_ni <= '0;
    corel_arst_ni <= '0;
    sysl_arst_ni <= '0;
    periphl_arst_ni <= '0;
    apb_slv_arst_ni <= '0;
    #(hold_time);
    core1_arst_ni <= '1;
    core2_arst_ni <= '1;
    corel_arst_ni <= '1;
    sysl_arst_ni <= '1;
    periphl_arst_ni <= '1;
    apb_slv_arst_ni <= '1;
    #(hold_time / 2);
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURAL
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin

    $timeformat(-6, 3, "us");

    // DEBUG Valueplusargs
    if ($value$plusargs("DEBUG=%d", DEBUG)) begin
      $display("[%0t] DEBUG LEVEL SET TO %0d", $realtime, DEBUG);
      $dumpfile("dual_helix_soc_tb.vcd");
      $dumpvars(0, dual_helix_soc_tb);
    end

    apply_reset(100ns);
    start_clock();

    fork
      begin
        // dhs_addr_t addr = UART_BASE;
        automatic dhs_addr_t addr = RAM_BASE;
        automatic dhs_data_t dummy_data, read_data;
        automatic dhs_addr_t uart_addr[3] = '{UART_BASE, UART_BASE + 'h4, UART_BASE + 'h18};
        automatic dhs_data_t uart_config_data[3] = '{32'h00000001, 32'h00000009, 32'h000000ab};
        dummy_data = $urandom;

        for (int i = 0; i < 32; i++) begin
          $display("[%0t] APB WRITE DATA TO  0x%h: 0x%h", $realtime, addr, dummy_data);
          u_apb_if.write(addr, dummy_data);
          u_apb_if.read(addr, read_data);
          $display("[%0t] APB READ DATA FROM 0x%h: 0x%h", $realtime, addr, read_data);
          if (read_data !== dummy_data) begin
            $error("\033[1;31mDATA MISMATCH AT ADDRESS 0x%h: WROTE 0x%h, READ 0x%h\033[0m", addr,
                   dummy_data, read_data);
          end else begin
            $display("\033[1;32mDATA MATCH AT ADDRESS 0x%h: 0x%h\033[0m", addr, read_data);
          end
          addr = addr + 'h4;
          dummy_data = dummy_data + 'h1;
          $display("\n");
        end

        for (int i = 0; i < 3; i++) begin
          $display("[%0t] APB WRITE DATA TO  0x%h: 0x%h", $realtime, uart_addr[i],
                   uart_config_data[i]);
          u_apb_if.write(uart_addr[i], uart_config_data[i]);
          if (uart_addr[i] !== (UART_BASE + 'h18)) begin
            u_apb_if.read(uart_addr[i], read_data);
            $display("[%0t] APB READ DATA FROM 0x%h: 0x%h", $realtime, uart_addr[i], read_data);
            if (read_data !== uart_config_data[i]) begin
              $error("\033[1;31mDATA MISMATCH AT ADDRESS 0x%h: WROTE 0x%h, READ 0x%h\033[0m",
                     uart_addr[i], uart_config_data[i], read_data);
            end else begin
              $display("\033[1;32mDATA MATCH AT ADDRESS 0x%h: 0x%h\033[0m", uart_addr[i],
                       read_data);
            end
          end
          $display("\n");
        end

        // // AXI
        // $display("WRITE DATA TO 0x%h: 0x%h", addr, dummy_data);
        //
        // fork
        //   begin
        //     axil_slv_req_i.aw <= '0;
        //     axil_slv_req_i.aw_valid <= '1;
        //     axil_slv_req_i.aw.addr <= addr;
        //
        //     do @(posedge periphl_clk_i); while (!axil_slv_resp_o.aw_ready);
        //     axil_slv_req_i.aw_valid <= '0;
        //   end
        //   begin
        //     axil_slv_req_i.w <= '0;
        //     axil_slv_req_i.w_valid <= '1;
        //     axil_slv_req_i.w.data <= dummy_data;
        //     axil_slv_req_i.w.strb <= 'hf;
        //
        //     do @(posedge periphl_clk_i); while (!axil_slv_resp_o.w_ready);
        //     axil_slv_req_i.w_valid <= '0;
        //   end
        //   begin
        //     axil_slv_req_i.b_ready <= '1;
        //
        //     do @(posedge periphl_clk_i); while (!axil_slv_resp_o.b_valid);
        //     axil_slv_req_i.b_ready <= '0;
        //   end
        // join
        // fork
        //   begin
        //     axil_slv_req_i.ar <= '0;
        //     axil_slv_req_i.ar_valid <= '1;
        //     axil_slv_req_i.ar.addr <= addr;
        //
        //     do @(posedge periphl_clk_i); while (!axil_slv_resp_o.ar_ready);
        //     axil_slv_req_i.ar_valid <= '0;
        //   end
        //   begin
        //     axil_slv_req_i.r_ready <= '1;
        //
        //     do @(posedge periphl_clk_i); while (!axil_slv_resp_o.r_valid);
        //     read_data = axil_slv_resp_o.r.data;
        //     axil_slv_req_i.r_ready <= '0;
        //   end
        // join
        // $display("READ DATA FROM 0x%h: 0x%h", addr, axil_slv_resp_o.r.data);
      end
      // begin
      //   #1ms;
      //   $display("[%0t] FORCE QUIT", $realtime);
      // end
      repeat (100) begin
        #100us;
        $display("[%0t] TEST IS RUNNING", $realtime);
      end
    join

    $display("[%0t] TEST DONE", $realtime);
    $finish;

  end
endmodule
