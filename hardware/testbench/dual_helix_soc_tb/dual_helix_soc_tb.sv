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

  int symbols[int][string];

  int ram_bdl = 1;

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

  function automatic void load_sym(string filename, int index);
    int file, r;
    string line;
    string key;
    int value;
    file = $fopen(filename, "r");
    if (file != 0) begin
      while (!$feof(
          file
      )) begin
        r = $fgets(line, file);
        if (r != 0) begin
          r = $sscanf(line, "%h %*s %s", value, key);
          symbols[index][key] = value;
        end
      end
    end
    $fclose(file);
  endfunction

  task automatic load_hex(string filename);
    int cnt = 0;  // TODO REMOVE
    logic [7:0] memb[int];
    logic [3:0][7:0] memw[int];
    $readmemh(filename, memb);
    foreach (memb[i]) begin
      // $display("BYTE MEM[0x%x]:0x%x", i, memb[i]);
      memw[i&'hFFFF_FFFC][i&'h0000_0003] = memb[i];
      // $display("WORD MEM[0x%x]:0x%x", i, memw[i&'hFFFF_FFFC][i&'h0000_0003]);
    end

    foreach (memw[i]) begin
      if (ram_bdl) ext_ram.write_mem_w(i, memw[i]);
      else u_apb_if.write(i, memw[i]);
      cnt++;
      if ((cnt % 16) == 0)
        $display("[%0t] LOADED %0d OF %0d FROM %s", $realtime, cnt, memw.size(), filename);
    end

    $display("[%0t] LOADED %0d WORDS OF %s", $realtime, memw.size(), filename);
    // foreach (memw[i]) u_apb_if.write(i, memw[i]);
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

    if ($value$plusargs("RAM_BDL=%d", ram_bdl)) begin
      $display("[%0t] RAM BACK-DOOR LOAD: %0d", $realtime, ram_bdl);
    end

    load_sym("prog_0.sym", 0);
    load_sym("prog_1.sym", 1);

    core_1_boot_addr_i <= symbols[0]["_start"];
    core_2_boot_addr_i <= symbols[1]["_start"];

    apply_reset(100ns);
    start_clock();

    load_hex("prog_0.hex");
    load_hex("prog_1.hex");

    #100ns;

    start_core_clocks();
    #100us;

    $display("[%0t] TEST DONE", $realtime);
    $finish;

  end
endmodule
