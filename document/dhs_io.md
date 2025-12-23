# Dual Helix SoC I/O Documentation

This document provides an overview of the input/output (I/O) architecture of the Dual Helix System on Chip (SoC). It covers the various I/O interfaces, their configurations, and usage guidelines.

## I/O Interfaces

| Port Name         | Type   | Description                             | Description                                                                  |
| ----------------- | ------ | --------------------------------------- | ---------------------------------------------------------------------------- |
| `ref_clk_i`       | Input  | Reference Clock Input                   | This port receives the main reference clock signal for the SoC.              |
| `glob_arst_ni`    | Input  | Asynchronous Reset (Active Low)         | This port is used to reset the SoC asynchronously when driven low.           |
|                   |        |                                         |                                                                              |
| `boot_mode_i`     | Input  | Boot Mode Selection Input               | This port is used to select the boot mode of the SoC during startup.         |
|                   |        |                                         |                                                                              |
| `apb_slv_clk_i`   | Input  | APB Clock Input                         | This port receives the clock signal for the APB interface.                   |
| `apb_slv_arst_ni` | Input  | APB Asynchronous Reset (Active Low)     | This port is used to reset the APB interface asynchronously when driven low. |
| `apb_slv_req_i`   | Input  | APB Request Input                       | This port is used to send requests to the APB interface.                     |
| `apb_slv_resp_o`  | Output | APB Response Output                     | This port is used to send responses from the APB interface.                  |
|                   |        |                                         |                                                                              |
| `spi_cs_o`        | Output | SPI Chip Select Output                  | This port is used to select the SPI device for communication.                |
| `spi_sclk_o`      | Output | SPI Serial Clock Output                 | This port provides the clock signal for SPI communication.                   |
| `spi_io0_io`      | Inout  | SPI Data Line 0                         | This port is used for data transmission and reception on SPI data line 0.    |
| `spi_io1_io`      | Inout  | SPI Data Line 1                         | This port is used for data transmission and reception on SPI data line 1.    |
| `spi_io2_io`      | Inout  | SPI Data Line 2                         | This port is used for data transmission and reception on SPI data line 2.    |
| `spi_io3_io`      | Inout  | SPI Data Line 3                         | This port is used for data transmission and reception on SPI data line 3.    |
|                   |        |                                         |                                                                              |
| `uart_rx_i`       | Input  | UART Receive Input                      | This port receives data for the UART interface.                              |
| `uart_tx_o`       | Output | UART Transmit Output                    | This port transmits data from the UART interface.                            |
|                   |        |                                         |                                                                              |
| `gpr0_o`          | Output | General Purpose Register 0 Output       | This port outputs the value of General Purpose Register 0.                   |
| `gpr1_o`          | Output | General Purpose Register 1 Output       | This port outputs the value of General Purpose Register 1.                   |
|                   |        |                                         |                                                                              |
| `ddr3_reset_n`    | Output | DDR3 Reset (Active Low)                 | This port is used to reset the DDR3 memory when driven low.                  |
| `ddr3_ck_p`       | Output | DDR3 Clock Positive                     | This port provides the positive clock signal for DDR3 memory.                |
| `ddr3_ck_n`       | Output | DDR3 Clock Negative                     | This port provides the negative clock signal for DDR3 memory.                |
| `ddr3_cke`        | Output | DDR3 Clock Enable                       | This port enables the clock signal for DDR3 memory.                          |
| `ddr3_cs_n`       | Output | DDR3 Chip Select (Active Low)           | This port selects the DDR3 memory chip when driven low.                      |
| `ddr3_ras_n`      | Output | DDR3 Row Address Strobe (Active Low)    | This port is used to signal row address strobe for DDR3 memory.              |
| `ddr3_cas_n`      | Output | DDR3 Column Address Strobe (Active Low) | This port is used to signal column address strobe for DDR3 memory.           |
| `ddr3_we_n`       | Output | DDR3 Write Enable (Active Low)          | This port is used to enable write operations to DDR3 memory when driven low. |
| `ddr3_dm`         | Output | DDR3 Data Mask                          | This port is used to mask data during DDR3 memory operations.                |
| `ddr3_ba`         | Output | DDR3 Bank Address                       | This port provides the bank address for DDR3 memory operations.              |
| `ddr3_addr`       | Output | DDR3 Address                            | This port provides the address for DDR3 memory operations.                   |
| `ddr3_dq`         | Inout  | DDR3 Data Bus                           | This port is used for data transmission and reception on the DDR3 data bus.  |
| `ddr3_dqs_p`      | Inout  | DDR3 Data Strobe Positive               | This port is used for positive data strobe signals in DDR3 memory.           |
| `ddr3_dqs_n`      | Inout  | DDR3 Data Strobe Negative               | This port is used for negative data strobe signals in DDR3 memory.           |
| `ddr3_odt`        | Output | DDR3 On-Die Termination                 | This port is used to control on-die termination for DDR3 memory.             |
