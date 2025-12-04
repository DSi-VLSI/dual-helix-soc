`ifndef __O2A_DPD__
`define __O2A_DPD__

`define ERROR_MSG(_msg) $display("\033[1;31m%s\033[0m", _msg);
`define HIGHLIGHT_MSG(_msg) $display("\033[1;33m%s\033[0m", _msg);
`define PASS_MSG(_msg) $display("\033[1;32m%s\033[0m", _msg);

`define START_CLK(_clk_name, _clk_speed_mhz)            \
    initial begin                                       \
        automatic realtime tp = 1us / _clk_speed_mhz;   \
        fork                                            \
            forever begin                               \
                _clk_name <= '0;                        \
                #(tp / 2);                              \
                _clk_name <= '1;                        \
                #(tp / 2);                              \
            end                                         \
        join_none                                       \
    end

`endif
