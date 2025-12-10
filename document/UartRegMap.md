# UART Register Map

This document describes the memory-mapped register interface for the UART peripheral.

---

## Register Summary

| Address | Register Name               | Access | Reset Value | Description                                 |
| ------- | --------------------------- | ------ | ----------- | ------------------------------------------- |
| 0x00    | DHS_UART_CTRL               | RW     | 0x00000000  | Clock and FIFO control                      |
| 0x04    | DHS_UART_CFG                | RW     | 0x00000000  | UART configuration                          |
| 0x08    | DHS_UART_CLK_DIV            | RW     | 0x000028B1  | Baud rate generation divisor                |
| 0x0C    | DHS_UART_TX_FIFO_STAT       | R      | 0x00000000  | Transmit FIFO occupancy status              |
| 0x10    | DHS_UART_RX_FIFO_STAT       | R      | 0x00000000  | Receive FIFO occupancy status               |
| 0x14    | DHS_UART_TX_FIFO_DATA       | W      | N/A         | Write data to transmit FIFO                 |
| 0x18    | DHS_UART_RX_FIFO_DATA       | R      | N/A         | Read and pop data from receive FIFO         |
| 0x1C    | DHS_UART_RX_FIFO_PEEK       | R      | N/A         | Read data from receive FIFO without popping |
| 0x20    | DHS_UART_ACCESS_ID_REQ      | RW     | 0x00000000  | ID queue of pending requests                |
| 0x24    | DHS_UART_ACCESS_ID_GNT      | RW     | 0x00000000  | pop ID of current request                   |
| 0x28    | DHS_UART_ACCESS_ID_GNT_PEEK | RW     | 0x00000000  | current granted request ID                  |

---

## Detailed Register Descriptions

---

### Control Register (DHS_UART_CTRL)

**Address:** 0x00  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name    | Type | Reset | Description                                   |
| ---- | ------------- | ---- | ----- | --------------------------------------------- |
| 0    | CLK_EN        | RW   | 0     | Clock Enable (1: Enable, 0: Disable)          |
| 1    | TX_FIFO_FLUSH | RW   | 0     | Flush TX FIFO (1: Flush, 0: Normal Operation) |
| 2    | RX_FIFO_FLUSH | RW   | 0     | Flush RX FIFO (1: Flush, 0: Normal Operation) |
| 31:3 | Reserved      | -    | 0     | Reserved for future use                       |

**Description:** Controls the clock enable and FIFO flush operations. The flush bits are self-clearing and will automatically return to 0 after the flush operation completes.

---

### Configuration Register (DHS_UART_CFG)

**Address:** 0x04  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name    | Type | Reset | Description                                  |
| ---- | ------------- | ---- | ----- | -------------------------------------------- |
| 0    | PARITY_EN     | RW   | 0     | Enable Parity Checking                       |
| 1    | PARITY_TYPE   | RW   | 0     | Parity Type (0: Even, 1: Odd)                |
| 2    | STOP_BITS     | RW   | 0     | Stop Bit Configuration (0: 1 bit, 1: 2 bits) |
| 3    | RX_PARITY_ERR | RW   | 0     | RX parity mismatch, duh!                     | // TODO |
| 4    | RX_VALID      | RW   | 0     | RX has arrived                               | // TODO |
| 5    | RX_NEAR_FULL  | RW   | 0     | RX FIFO about to explode                     | // TODO |
| 6    | RX_FULL       | RW   | 0     | TX FIFO about to combust                     | // TODO |
| 7    | TX_NEAR_FULL  | RW   | 0     | TX FIFO about to combust                     | // TODO |
| 8    | TX_FULL       | RW   | 0     | TX FIFO about to combust                     | // TODO |
| 31:9 | Reserved      | -    | 0     | Reserved for future use                      |

**Description:** Configures UART communication parameters including parity, stop bits, and interrupt enable.

---

### Clock Divisor Register (DHS_UART_CLK_DIV)

**Address:** 0x08  
**Reset Value:** 0x000028B1  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description                                  |
| ---- | ---------- | ---- | ---------- | -------------------------------------------- |
| 31:0 | CLK_DIV    | RW   | 0x000028B1 | Clock divisor value for baud rate generation |

**Description:** This register configures the baud rate by dividing the system clock. The baud rate is calculated as: `Baud Rate = System Clock / (CLK_DIV + 1)`

---


### Transmit FIFO Status Register (DHS_UART_TX_FIFO_STAT)

**Address:** 0x0C  
**Reset Value:** 0x00000000  
**Access:** Read-Only

| Bits | Field Name    | Type | Reset | Description                              |
| ---- | ------------- | ---- | ----- | ---------------------------------------- |
| 31:0 | TX_FIFO_COUNT | R    | 0     | Number of bytes currently in the TX FIFO |

---


### Receive FIFO Status Register (DHS_UART_RX_FIFO_STAT)

**Address:** 0x10  
**Reset Value:** 0x00000000  
**Access:** Read-Only

| Bits | Field Name    | Type | Reset | Description                              |
| ---- | ------------- | ---- | ----- | ---------------------------------------- |
| 31:0 | RX_FIFO_COUNT | R    | 0     | Number of bytes currently in the RX FIFO |

---

### Transmit FIFO Data Register (DHS_UART_TX_FIFO_DATA)

**Address:** 0x14  
**Access:** Write-Only

| Bits | Field Name | Type | Description                 |
| ---- | ---------- | ---- | --------------------------- |
| 7:0  | TX_DATA    | W    | Data byte to be transmitted |
| 31:8 | Reserved   | -    | Reserved for future use     |

**Description:** Writing to this register pushes the data byte into the transmit FIFO for transmission.

---


### Receive FIFO Data Register (DHS_UART_RX_FIFO_DATA)

**Address:** 0x18  
**Access:** Read-Only

| Bits | Field Name | Type | Description             |
| ---- | ---------- | ---- | ----------------------- |
| 7:0  | RX_DATA    | R    | Received data byte      |
| 31:8 | Reserved   | -    | Reserved for future use |

**Description:** Reading from this register pops and returns the next byte from the receive FIFO.

---


### Receive FIFO Peek Register (DHS_UART_RX_FIFO_PEEK)

**Address:** 0x1C  
**Access:** Read-Only

| Bits | Field Name   | Type | Description                               |
| ---- | ------------ | ---- | ----------------------------------------- |
| 7:0  | RX_PEEK_DATA | R    | Received data byte (non-destructive read) |
| 31:8 | Reserved     | -    | Reserved for future use                   |

**Description:** Reading from this register returns the next byte from the receive FIFO without removing it from the queue.


---


### Access ID Request Register (DHS_UART_ACCESS_ID_REQ)

**Address:** 0x20  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                                |
| ---- | ---------- | ---- | ----- | ------------------------------------------ |
| 7:0  | ACCESS_ID  | RW   | 0x00  | 0: No ongoing access, 1: Core 1, 2: Core 2 |
| 31:8 | Reserved   | -    | 0     | Reserved for future use                    |

**Description:** // TODO


---

### Access ID Grant Pop Register (DHS_UART_ACCESS_ID_GNT)

**Address:** 0x24  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                                |
| ---- | ---------- | ---- | ----- | ------------------------------------------ |
| 7:0  | ACCESS_ID  | RW   | 0x00  | 0: No ongoing access, 1: Core 1, 2: Core 2 |
| 31:8 | Reserved   | -    | 0     | Reserved for future use                    |

**Description:** // TODO

---

### Access ID Grant Peek Register (DHS_UART_ACCESS_ID_GNT_PEEK)

**Address:** 0x28  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                                |
| ---- | ---------- | ---- | ----- | ------------------------------------------ |
| 7:0  | ACCESS_ID  | RW   | 0x00  | 0: No ongoing access, 1: Core 1, 2: Core 2 |
| 31:8 | Reserved   | -    | 0     | Reserved for future use                    |

**Description:** // TODO
