## Address Map

| Module Name      | Start Address | End Address |   Size | Notes                                                        |
| ---------------- | ------------: | ----------: | -----: | ------------------------------------------------------------ |
| SOC_CTRL_START   |    0x20000000 |  0x20000FFF |   4 KB | SoC control / configuration registers.                       |
| UART_START       |    0x20001000 |  0x20001FFF |   4 KB | UART MMIO region. Matches original raw entry.                |
| SPI_MASTER_START |    0x20002000 |  0x20002FFF |   4 KB | SPI master controller MMIO (assigned here).                  |
| DMA_START        |    0x20003000 |  0x20003FFF |   4 KB | DMA MMIO region. Matches original raw entry.                 |
| PLIC_START       |    0x20004000 |  0x20004FFF |   4 KB | Platform-Level Interrupt Controller (PLIC).                  |
| CLINT_START      |    0x20005000 |  0x20005FFF |   4 KB | Core Local Interruptor (CLINT) for timers/interrupts.        |
| SPI_MEM_START    |    0x30000000 |  0x3FFFFFFF | 256 MB | SPI flash memory-mapped region                               |
| RAM_START        |    0x40000000 |  0xFFFEFFFF |   3 GB | On-chip RAM. Matches original raw entry.                     |
| BOOT_ROM_START   |    0xFFFEFFFF |  0xFFFFFFFF |  64 KB | Boot ROM (top of address space). Matches original raw entry. |
