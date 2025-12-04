module apb_2_axil_tb;

  // Parameters
  localparam int ADDR_WIDTH = 32;
  localparam int DATA_WIDTH = 32;

  // Clock and reset
  logic                        clk_i;
  logic                        arst_ni;

  // APB Slave Interface signals
  logic                        psel_i;
  logic                        penable_i;
  logic [      ADDR_WIDTH-1:0] paddr_i;
  logic                        pwrite_i;
  logic [      DATA_WIDTH-1:0] pwdata_i;
  logic [(DATA_WIDTH / 8)-1:0] pstrb_i;

  logic                        pready_o;
  logic [      DATA_WIDTH-1:0] prdata_o;
  logic                        pslverr_o;

  // AXI4-Lite Master Interface signals
  logic [      ADDR_WIDTH-1:0] awaddr_o;
  logic [                 2:0] awprot_o;
  logic                        awvalid_o;
  logic                        awready_i;

  logic [      DATA_WIDTH-1:0] wdata_o;
  logic [  (DATA_WIDTH/8)-1:0] wstrb_o;
  logic                        wvalid_o;
  logic                        wready_i;

  logic [                 1:0] bresp_i;
  logic                        bvalid_i;
  logic                        bready_o;

  logic [      ADDR_WIDTH-1:0] araddr_o;
  logic [                 2:0] arprot_o;
  logic                        arvalid_o;
  logic                        arready_i;

  logic [      DATA_WIDTH-1:0] rdata_i;
  logic [                 1:0] rresp_i;
  logic                        rvalid_i;
  logic                        rready_o;

  // DUT instantiation
  apb_2_axil #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .arst_ni  (arst_ni),
      .clk_i    (clk_i),
      .psel_i   (psel_i),
      .penable_i(penable_i),
      .paddr_i  (paddr_i),
      .pwrite_i (pwrite_i),
      .pwdata_i (pwdata_i),
      .pstrb_i  (pstrb_i),
      .pready_o (pready_o),
      .prdata_o (prdata_o),
      .pslverr_o(pslverr_o),
      .awaddr_o (awaddr_o),
      .awprot_o (awprot_o),
      .awvalid_o(awvalid_o),
      .awready_i(awready_i),
      .wdata_o  (wdata_o),
      .wstrb_o  (wstrb_o),
      .wvalid_o (wvalid_o),
      .wready_i (wready_i),
      .bresp_i  (bresp_i),
      .bvalid_i (bvalid_i),
      .bready_o (bready_o),
      .araddr_o (araddr_o),
      .arprot_o (arprot_o),
      .arvalid_o(arvalid_o),
      .arready_i(arready_i),
      .rdata_i  (rdata_i),
      .rresp_i  (rresp_i),
      .rvalid_i (rvalid_i),
      .rready_o (rready_o)
  );

  initial begin

    $dumpfile("apb_2_axil_tb.vcd");
    $dumpvars(0, apb_2_axil_tb);

    arst_ni <= '0;
    clk_i <= '0;
    psel_i <= '0;
    penable_i <= '0;
    paddr_i <= '0;
    pwrite_i <= '0;
    pwdata_i <= '0;
    pstrb_i <= '0;
    awready_i <= '0;
    wready_i <= '0;
    bresp_i <= '0;
    bvalid_i <= '0;
    arready_i <= '0;
    rdata_i <= '0;
    rresp_i <= '0;
    rvalid_i <= '0;
    #20 arst_ni <= '1;

    // Clock generation
    fork
      forever begin
        #5 clk_i <= ~clk_i;
      end
    join_none

    fork
      begin
        @(posedge clk_i);
        psel_i   <= '1;
        paddr_i  <= 32'h00000004;
        pwrite_i <= '1;
        pwdata_i <= 32'hDEADBEEF;
        pstrb_i  <= 4'hF;
        @(posedge clk_i);
        penable_i <= '1;
      end
      begin
        wait (pready_o);
        @(posedge clk_i);
        psel_i <= '0;
        penable_i <= '0;
      end
      begin
        awready_i <= '1;
        do @(posedge clk_i); while (!awvalid_o);
        awready_i <= '0;
      end
      begin
        wready_i <= '1;
        do @(posedge clk_i); while (!wvalid_o);
        wready_i <= '0;
      end
      begin
        bvalid_i <= '1;
        do @(posedge clk_i); while (!bready_o);
        bvalid_i <= '0;
      end
    join

    repeat (10) @(posedge clk_i);

    fork
      begin
        @(posedge clk_i);
        psel_i   <= '1;
        paddr_i  <= 32'h00000004;
        pwrite_i <= '0;
        pwdata_i <= 32'hDEADBEEF;
        pstrb_i  <= 4'hF;
        @(posedge clk_i);
        penable_i <= '1;
      end
      begin
        wait (pready_o);
        @(posedge clk_i);
        psel_i <= '0;
        penable_i <= '0;
      end
      begin
        arready_i <= '1;
        do @(posedge clk_i); while (!arvalid_o);
        arready_i <= '0;
      end
      begin
        rvalid_i <= '1;
        rdata_i  <= 32'hf00dcafe;
        do @(posedge clk_i); while (!rready_o);
        rvalid_i <= '0;
      end
    join

    #100;
    $finish;
  end

endmodule
