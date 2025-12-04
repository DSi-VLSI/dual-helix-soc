# UART Register Map

This document describes the memory-mapped register interface for the UART peripheral.

---

## Register Summary

| Address | Register Name | Access | Reset Value | Description                                 |
| ------- | ------------- | ------ | ----------- | ------------------------------------------- |
| 0x00    | CTRL          | RW     | 0x00000000  | Clock and FIFO control                      |
| 0x04    | CFG           | RW     | 0x00000000  | UART configuration                          |
| 0x08    | CLK_DIV       | RW     | 0x000028B1  | Baud rate generation divisor                |
| 0x0C    | TX_FIFO_STAT  | R      | 0x00000000  | Transmit FIFO occupancy status              |
| 0x10    | RX_FIFO_STAT  | R      | 0x00000000  | Receive FIFO occupancy status               |
| 0x14    | TX_FIFO_DATA  | W      | N/A         | Write data to transmit FIFO                 |
| 0x18    | RX_FIFO_DATA  | R      | N/A         | Read and pop data from receive FIFO         |
| 0x1C    | RX_FIFO_PEEK  | R      | N/A         | Read data from receive FIFO without popping |
| 0x20    | ACCESS_ID     | RW     | 0x00000000  | ID of the currently accessing core          |
---

## Detailed Register Descriptions

### Control Register (CTRL)

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

### Configuration Register (CFG)

**Address:** 0x04  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name  | Type | Reset | Description                                  |
| ---- | ----------- | ---- | ----- | -------------------------------------------- |
| 0    | PARITY_EN   | RW   | 0     | Enable Parity Checking                       |
| 1    | PARITY_TYPE | RW   | 0     | Parity Type (0: Even, 1: Odd)                |
| 2    | STOP_BITS   | RW   | 0     | Stop Bit Configuration (0: 1 bit, 1: 2 bits) |
| 3    | RX_INT_EN   | RW   | 0     | RX Interrupt Enable                          |
| 31:4 | Reserved    | -    | 0     | Reserved for future use                      |

**Description:** Configures UART communication parameters including parity, stop bits, and interrupt enable.

---

### Clock Divisor Register (CLK_DIV)

**Address:** 0x08  
**Reset Value:** 0x000028B1  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description                                  |
| ---- | ---------- | ---- | ---------- | -------------------------------------------- |
| 31:0 | CLK_DIV    | RW   | 0x000028B1 | Clock divisor value for baud rate generation |

**Description:** This register configures the baud rate by dividing the system clock. The baud rate is calculated as: `Baud Rate = System Clock / (CLK_DIV + 1)`

---

### TX FIFO Status Register (TX_FIFO_STAT)

**Address:** 0x0C  
**Reset Value:** 0x00000000  
**Access:** Read-Only

| Bits | Field Name    | Type | Reset | Description                              |
| ---- | ------------- | ---- | ----- | ---------------------------------------- |
| 31:0 | TX_FIFO_COUNT | R    | 0     | Number of bytes currently in the TX FIFO |

---

### RX FIFO Status Register (RX_FIFO_STAT)

**Address:** 0x10  
**Reset Value:** 0x00000000  
**Access:** Read-Only

| Bits | Field Name    | Type | Reset | Description                              |
| ---- | ------------- | ---- | ----- | ---------------------------------------- |
| 31:0 | RX_FIFO_COUNT | R    | 0     | Number of bytes currently in the RX FIFO |

---

### TX FIFO Data Register (TX_FIFO_DATA)

**Address:** 0x14  
**Access:** Write-Only

| Bits | Field Name | Type | Description                 |
| ---- | ---------- | ---- | --------------------------- |
| 7:0  | TX_DATA    | W    | Data byte to be transmitted |
| 31:8 | Reserved   | -    | Reserved for future use     |

**Description:** Writing to this register pushes the data byte into the transmit FIFO for transmission.

---

### RX FIFO Data Register (RX_FIFO_DATA)

**Address:** 0x18
**Access:** Read-Only

| Bits | Field Name | Type | Description             |
| ---- | ---------- | ---- | ----------------------- |
| 7:0  | RX_DATA    | R    | Received data byte      |
| 31:8 | Reserved   | -    | Reserved for future use |

**Description:** Reading from this register pops and returns the next byte from the receive FIFO.

---

### RX FIFO Peek Register (RX_FIFO_PEEK)

**Address:** 0x1C  
**Access:** Read-Only

| Bits | Field Name   | Type | Description                               |
| ---- | ------------ | ---- | ----------------------------------------- |
| 7:0  | RX_PEEK_DATA | R    | Received data byte (non-destructive read) |
| 31:8 | Reserved     | -    | Reserved for future use                   |

**Description:** Reading from this register returns the next byte from the receive FIFO without removing it from the queue.

---

### Access ID Register (ACCESS_ID)

**Address:** 0x20  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                                |
| ---- | ---------- | ---- | ----- | ------------------------------------------ |
| 7:0  | ACCESS_ID  | RW   | 0x00  | 0: No ongoing access, 1: Core 1, 2: Core 2 |
| 31:8 | Reserved   | -    | 0     | Reserved for future use                    |

**Description:** Contains the ID of the core currently performing accesses to the UART registers. Reading returns the current access identifier.


