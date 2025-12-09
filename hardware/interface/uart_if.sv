interface uart_if;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Signals
  //////////////////////////////////////////////////////////////////////////////////////////////////

  tri1 tx;
  tri1 rx;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Parameters
  //////////////////////////////////////////////////////////////////////////////////////////////////

  int   BAUD_RATE = 115200;
  bit   PARITY_ENABLE = 0;
  bit   PARITY_TYPE = 1;
  bit   SECOND_STOP_BIT = 0;
  int   DATA_BITS = 8;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Methods
  //////////////////////////////////////////////////////////////////////////////////////////////////

  function void reset();
    BAUD_RATE       = 115200;
    PARITY_ENABLE   = 0;
    PARITY_TYPE     = 1;
    SECOND_STOP_BIT = 0;
    DATA_BITS       = 8;
  endfunction

  `define SEND_RECV(__PORT__)                                                                      \
    bit drive_``__PORT__``;                                                                        \
    bit reg_``__PORT__``;                                                                          \
                                                                                                   \
    assign ``__PORT__`` = drive_``__PORT__`` ? reg_``__PORT__`` : 1'bz;                            \
                                                                                                   \
    task automatic send_``__PORT__``(                                                              \
        input logic [7:0] data, input int baud_rate = BAUD_RATE,                                   \
        input bit parity_enable = PARITY_ENABLE, input bit parity_type = PARITY_TYPE,              \
        input bit second_stop_bit = SECOND_STOP_BIT, input int data_bits = DATA_BITS);             \
                                                                                                   \
      realtime bit_time;                                                                           \
      bit parity_bit;                                                                              \
                                                                                                   \
      BAUD_RATE = baud_rate;                                                                       \
      PARITY_ENABLE = parity_enable;                                                               \
      PARITY_TYPE = parity_type;                                                                   \
      SECOND_STOP_BIT = second_stop_bit;                                                           \
      DATA_BITS = data_bits;                                                                       \
                                                                                                   \
      bit_time   = 1s / baud_rate;                                                                 \
      parity_bit = 0;                                                                              \
                                                                                                   \
      for (int i = 0; i < data_bits; i++) begin                                                    \
        parity_bit ^= data[i];                                                                     \
      end                                                                                          \
                                                                                                   \
      if (parity_type) begin                                                                       \
        parity_bit = ~parity_bit;                                                                  \
      end                                                                                          \
                                                                                                   \
      // Start bit                                                                                 \
      reg_``__PORT__`` <= '0;                                                                      \
      #(bit_time);                                                                                 \
                                                                                                   \
      // Data bits                                                                                 \
      for (int i = 0; i < data_bits; i++) begin                                                    \
        reg_``__PORT__`` <= data[i];                                                               \
        #(bit_time);                                                                               \
      end                                                                                          \
                                                                                                   \
      // Parity bit                                                                                \
      if (parity_enable) begin                                                                     \
        reg_``__PORT__`` <= parity_bit;                                                            \
        #(bit_time);                                                                               \
      end                                                                                          \
                                                                                                   \
      // Stop bits                                                                                 \
      reg_``__PORT__`` <= '1;                                                                      \
      #(bit_time);                                                                                 \
      if (second_stop_bit) begin                                                                   \
        #(bit_time);                                                                               \
      end                                                                                          \
                                                                                                   \
    endtask                                                                                        \
                                                                                                   \
    task automatic recv_``__PORT__``(                                                              \
        output logic [7:0] data, input int baud_rate = BAUD_RATE,                                  \
        input bit parity_enable = PARITY_ENABLE, input bit parity_type = PARITY_TYPE,              \
        input bit second_stop_bit = SECOND_STOP_BIT, input int data_bits = DATA_BITS);             \
                                                                                                   \
      realtime bit_time;                                                                           \
      bit expected_parity;                                                                         \
      bit received_parity;                                                                         \
                                                                                                   \
      BAUD_RATE = baud_rate;                                                                       \
      PARITY_ENABLE = parity_enable;                                                               \
      PARITY_TYPE = parity_type;                                                                   \
      SECOND_STOP_BIT = second_stop_bit;                                                           \
      DATA_BITS = data_bits;                                                                       \
                                                                                                   \
      data = '0;                                                                                   \
                                                                                                   \
      bit_time = 1s / baud_rate;                                                                   \
                                                                                                   \
      // Start bit                                                                                 \
      do begin                                                                                     \
        @(negedge ``__PORT__``);                                                                   \
        #(bit_time / 2);                                                                           \
      end while (``__PORT__`` != '0);                                                              \
                                                                                                   \
      // Data bits                                                                                 \
      for (int i = 0; i < data_bits; i++) begin                                                    \
        #(bit_time);                                                                               \
        data[i] = ``__PORT__``;                                                                    \
      end                                                                                          \
                                                                                                   \
      // Parity bit                                                                                \
      if (parity_enable) begin                                                                     \
        #(bit_time);                                                                               \
        received_parity = ``__PORT__``;                                                            \
      end                                                                                          \
                                                                                                   \
      expected_parity = 0;                                                                         \
      for (int i = 0; i < data_bits; i++) begin                                                    \
        expected_parity ^= data[i];                                                                \
      end                                                                                          \
      if (parity_type) begin                                                                       \
        expected_parity = ~expected_parity;                                                        \
      end                                                                                          \
      if (parity_enable) begin                                                                     \
        if (received_parity !== expected_parity) begin                                             \
          $display(`"UART Parity Error for ``__PORT__`` data 0x%0x\nExpected %0b, Received %0b`",  \
            data, expected_parity, received_parity);                                               \
        end                                                                                        \
      end                                                                                          \
                                                                                                   \
    endtask                                                                                        \


  `SEND_RECV(tx)
  // task automatic send_tx(DATA, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);
  // task automatic recv_tx(DATA, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);

  `SEND_RECV(rx)
  // task automatic send_rx(DATA, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);
  // task automatic recv_rx(DATA, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);

  `undef SEND_RECV

endinterface
