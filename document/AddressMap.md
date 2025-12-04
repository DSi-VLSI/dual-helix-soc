## Address Map

| Module Name       | Start Address | End Address   | Size     | Notes |
|-------------------|---------------:|---------------:|---------:|-------|
| BOOT_ROM_START    | 0xFFFFEFFF    | 0xFFFFFFFF    | 4 KB     | Boot ROM (top of address space). Matches original raw entry.
| RAM_START         | 0x00080000    | 0x0008FFFF    | 64 KB    | On-chip RAM. Matches original raw entry.
| DMA_START         | 0x10000000    | 0x10000FFF    | 4 KB     | DMA MMIO region. Matches original raw entry.
| UART_START        | 0x10001000    | 0x10001FFF    | 4 KB     | UART MMIO region. Matches original raw entry.
| SPI_MASTER_START  | 0x10002000    | 0x10002FFF    | 4 KB     | SPI master controller MMIO (assigned here).
| SOC_CTRL_START    | 0x10003000    | 0x10003FFF    | 4 KB     | SoC control / configuration registers.
| PLIC_START        | 0x30000000    | 0x3000FFFF    | 64 KB    | Platform-Level Interrupt Controller (PLIC).
| CLINT_START       | 0x32000000    | 0x3200FFFF    | 64 KB    | Core Local Interruptor (CLINT) for timers/interrupts.
| APB_SLAVE_START   | 0x34000000    | 0x3400FFFF    | 64 KB    | APB-connected peripheral address window / bridge.

