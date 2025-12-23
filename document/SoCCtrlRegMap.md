
# SoC Controller Register Map

This document describes the memory-mapped register interface for the SoC Controller peripheral.

---

## Register Summary

| Address | Register Name    | Access | Reset Value | Description                    |
| ------- | ---------------- | ------ | ----------- | ------------------------------ |
| 0x00    | BOOT_ADDR_CORE_0 | RW     | 0x00000000  | Boot address for Core 0        |
| 0x04    | BOOT_ADDR_CORE_1 | RW     | 0x00000000  | Boot address for Core 1        |
| 0x08    | HARD_ID_CORE_0   | RW     | 0x00000000  | Hardware ID for Core 0         |
| 0x0C    | HARD_ID_CORE_1   | RW     | 0x00000000  | Hardware ID for Core 1         |
| 0x10    | MTVEC_CORE_0     | RW     | 0x00000000  | mtvec register for Core 0      |
| 0x14    | MTVEC_CORE_1     | RW     | 0x00000000  | mtvec register for Core 1      |
| 0x18    | CLK_RST_CORE_0   | RW     | 0x00000000  | Clock/reset control for Core 0 |
| 0x1C    | CLK_RST_CORE_1   | RW     | 0x00000000  | Clock/reset control for Core 1 |
| 0x20    | CLK_RST_CL       | RW     | 0x00000000  | Clock/reset control for CL     |
| 0x24    | CLK_RST_SL       | RW     | 0x00000000  | Clock/reset control for SL     |
| 0x28    | CLK_RST_PL       | RW     | 0x00000000  | Clock/reset control for PL     |
| 0x2C    | PLL_CFG_CORE_0   | RW/RO  | 0x00000000  | PLL config/status for Core 0   |
| 0x30    | PLL_CFG_CORE_1   | RW/RO  | 0x00000000  | PLL config/status for Core 1   |
| 0x34    | PLL_CFG_SL       | RW/RO  | 0x00000000  | PLL config/status for SL       |
| 0x38    | GPR_0            | RW     | 0x00000000  | General-purpose register 0     |
| 0x3C    | GPR_1            | RW     | 0x00000000  | General-purpose register 1     |
| 0x40    | BOOT_MODE        | RO     | 0x00000000  | Boot mode indicator            |

---

## Detailed Register Descriptions

---

### Boot Address Register Core 0 (BOOT_ADDR_CORE_0)

**Address:** 0x00  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description             |
| ---- | ---------- | ---- | ---------- | ----------------------- |
| 31:0 | BOOT_ADDR  | RW   | 0x00000000 | Boot address for Core 0 |

**Description:** Sets the boot address for Core 0.

---

### Boot Address Register Core 1 (BOOT_ADDR_CORE_1)

**Address:** 0x04  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description             |
| ---- | ---------- | ---- | ---------- | ----------------------- |
| 31:0 | BOOT_ADDR  | RW   | 0x00000000 | Boot address for Core 1 |

**Description:** Sets the boot address for Core 1.

---

### Hardware ID Register Core 0 (HARD_ID_CORE_0)

**Address:** 0x08  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description            |
| ---- | ---------- | ---- | ---------- | ---------------------- |
| 31:0 | HART_ID    | RW   | 0x00000000 | Hardware ID for Core 0 |

**Description:** Hardware identifier for Core 0.

---

### Hardware ID Register Core 1 (HARD_ID_CORE_1)

**Address:** 0x0C  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description            |
| ---- | ---------- | ---- | ---------- | ---------------------- |
| 31:0 | HART_ID    | RW   | 0x00000000 | Hardware ID for Core 1 |

**Description:** Hardware identifier for Core 1.

---

### MTVEC Register Core 0 (MTVEC_CORE_0)

**Address:** 0x10  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description            |
| ---- | ---------- | ---- | ---------- | ---------------------- |
| 31:0 | MTVEC_ADDR | RW   | 0x00000000 | mtvec value for Core 0 |

**Description:** Sets the mtvec register for Core 0.

---

### MTVEC Register Core 1 (MTVEC_CORE_1)

**Address:** 0x14  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description            |
| ---- | ---------- | ---- | ---------- | ---------------------- |
| 31:0 | MTVEC_ADDR | RW   | 0x00000000 | mtvec value for Core 1 |

**Description:** Sets the mtvec register for Core 1.

---

### Clock/Reset Register Core 0 (CLK_RST_CORE_0)

**Address:** 0x18  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                     |
| ---- | ---------- | ---- | ----- | ------------------------------- |
| 0    | ARST_N     | RW   | 0     | Asynchronous reset (active low) |
| 1    | CLK_EN     | RW   | 0     | Clock enable                    |
| 31:2 | Reserved   | -    | 0     | Reserved                        |

**Description:** Controls asynchronous reset and clock enable for Core 0.

---

### Clock/Reset Register Core 1 (CLK_RST_CORE_1)

**Address:** 0x1C  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                     |
| ---- | ---------- | ---- | ----- | ------------------------------- |
| 0    | ARST_N     | RW   | 0     | Asynchronous reset (active low) |
| 1    | CLK_EN     | RW   | 0     | Clock enable                    |
| 31:2 | Reserved   | -    | 0     | Reserved                        |

**Description:** Controls asynchronous reset and clock enable for Core 1.

---

### Clock/Reset Register CL (CLK_RST_CL)

**Address:** 0x20  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name  | Type | Reset | Description                                     |
| ---- | ----------- | ---- | ----- | ----------------------------------------------- |
| 0    | ARST_N      | RW   | 0     | Asynchronous reset (active low)                 |
| 1    | CLK_EN      | RW   | 0     | Clock enable                                    |
| 2    | CLK_MUX_SEL | RW   | 0     | Clock mux select (0: core 0 clk, 1: core 1 clk) |
| 31:3 | Reserved    | -    | 0     | Reserved                                        |

**Description:** Controls asynchronous reset, clock enable, and clock mux select for CL.

---

### Clock/Reset Register SL (CLK_RST_SL)

**Address:** 0x24  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                     |
| ---- | ---------- | ---- | ----- | ------------------------------- |
| 0    | ARST_N     | RW   | 0     | Asynchronous reset (active low) |
| 1    | CLK_EN     | RW   | 0     | Clock enable                    |
| 31:2 | Reserved   | -    | 0     | Reserved                        |

**Description:** Controls asynchronous reset and clock enable for SL.

---

### Clock/Reset Register PL (CLK_RST_PL)

**Address:** 0x28  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset | Description                     |
| ---- | ---------- | ---- | ----- | ------------------------------- |
| 0    | ARST_N     | RW   | 0     | Asynchronous reset (active low) |
| 31:1 | Reserved   | -    | 0     | Reserved                        |

**Description:** Controls asynchronous reset for PL.

---

### PLL Config Register Core 0 (PLL_CFG_CORE_0)

**Address:** 0x2C  
**Reset Value:** 0x00000000  
**Access:** Read/Write, Read-Only (locked)

| Bits  | Field Name | Type | Reset | Description       |
| ----- | ---------- | ---- | ----- | ----------------- |
| 3:0   | REF_DIV    | RW   | 0     | Reference divider |
| 15:4  | FB_DIV     | RW   | 0     | Feedback divider  |
| 16    | LOCKED     | RO   | 0     | PLL lock status   |
| 31:17 | Reserved   | -    | 0     | Reserved          |

**Description:** Configures and monitors PLL for Core 0.

---

### PLL Config Register Core 1 (PLL_CFG_CORE_1)

**Address:** 0x30  
**Reset Value:** 0x00000000  
**Access:** Read/Write, Read-Only (locked)

| Bits  | Field Name | Type | Reset | Description       |
| ----- | ---------- | ---- | ----- | ----------------- |
| 3:0   | REF_DIV    | RW   | 0     | Reference divider |
| 15:4  | FB_DIV     | RW   | 0     | Feedback divider  |
| 16    | LOCKED     | RO   | 0     | PLL lock status   |
| 31:17 | Reserved   | -    | 0     | Reserved          |

**Description:** Configures and monitors PLL for Core 1.

---

### PLL Config Register SL (PLL_CFG_SL)

**Address:** 0x34  
**Reset Value:** 0x00000000  
**Access:** Read/Write, Read-Only (locked)

| Bits  | Field Name | Type | Reset | Description       |
| ----- | ---------- | ---- | ----- | ----------------- |
| 3:0   | REF_DIV    | RW   | 0     | Reference divider |
| 15:4  | FB_DIV     | RW   | 0     | Feedback divider  |
| 16    | LOCKED     | RO   | 0     | PLL lock status   |
| 31:17 | Reserved   | -    | 0     | Reserved          |

**Description:** Configures and monitors PLL for SL.

---

### General Purpose Register 0 (GPR_0)

**Address:** 0x38  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description                |
| ---- | ---------- | ---- | ---------- | -------------------------- |
| 31:0 | GPR_0      | RW   | 0x00000000 | General-purpose register 0 |

**Description:** General-purpose register 0 for software use.

---

### General Purpose Register 1 (GPR_1)

**Address:** 0x3C  
**Reset Value:** 0x00000000  
**Access:** Read/Write

| Bits | Field Name | Type | Reset      | Description                |
| ---- | ---------- | ---- | ---------- | -------------------------- |
| 31:0 | GPR_1      | RW   | 0x00000000 | General-purpose register 1 |

**Description:** General-purpose register 1 for software use.

---

### Boot Mode Register (BOOT_MODE)

**Address:** 0x40  
**Reset Value:** 0x00000000  
**Access:** Read-Only

| Bits | Field Name | Type | Reset | Description         |
| ---- | ---------- | ---- | ----- | ------------------- |
| 0    | BOOT_MODE  | RO   | 0     | Boot mode indicator |
| 31:1 | Reserved   | -    | 0     | Reserved            |

**Description:** Indicates the boot mode selected at startup.