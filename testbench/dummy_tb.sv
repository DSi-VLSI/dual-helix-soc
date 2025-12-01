module dummy_tb;

  dummy_rtl dut();

  initial begin
    #10;
    $display("Dummy testbench completed.");
    $finish;
  end

endmodule
