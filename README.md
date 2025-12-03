![Dual Helix SoC Architecture](document/svg/DHS-ARCH-DIAGRAM.svg)

# Dual Helix SoC

Dual Helix SoC (DHS) is a small, experimental System-on-Chip project intended as a playground for RTL design, verification, and software bring-up. This repo will host the RTL, simulation testbenches, and basic bare‑metal software tests (assembly and C).

## Goals

- Define a minimal but realistic SoC architecture (core, bus, memory, peripherals).
- Implement synthesizable RTL for the core and top-level SoC.
- Develop a reusable testbench environment for block-level and SoC-level verification.
- Run assembly and C programs on the SoC via simulation (and later, optionally, FPGA).

## Design Overview

The high-level architecture is shown above in `document/svg/DHS-ARCH-DIAGRAM.svg`. At a minimum, the SoC is expected to include:

- **CPU core**: In-order, single/multi-cycle core with a simple ISA (e.g., RISC-V-like or custom).
- **Memory system**: On-chip SRAM, boot ROM, and a well-defined memory map.
- **Peripherals**: Basic timer, UART (for printf-style debug), and GPIO.
- **Interconnect**: Simple bus or crossbar connecting core, memory, and peripherals.

The exact ISA and microarchitecture details can be refined as the project progresses.

## RTL Design Plan

1. Define the ISA subset and programmer’s model (registers, CSRs if any).
2. Specify the memory map and SoC address space.
3. Implement the core microarchitecture:
	 - ALU, register file, immediate/gen, control unit
	 - Instruction fetch/decode/execute pipeline (or multi-cycle FSM)
4. Implement SoC top level:
	 - Bus/interconnect
	 - On-chip memory blocks and peripheral integration
5. Add synthesis-friendly reset and clocking strategy.

## Verification & Testbench Plan

The verification flow will be simulation-driven, using a simple but extensible testbench framework.

- **Unit-level testbenches (`tb/unit/`)**
	- Verify ALU operations, register file behavior, immediate generation, etc.
	- Self-checking tests with assertions and small directed vectors.

- **Core-level testbenches**
	- Load small instruction sequences into an instruction memory model.
	- Check register/memory state after program execution.

- **SoC-level testbench (`tb/soc/`)**
	- Integrate CPU core, memories, and peripherals.
	- Provide models for external interfaces (e.g., UART sink).
	- Drive clock/reset, load program images, and monitor pass/fail conditions.

## Assembly and C Test Flow

The goal is to be able to compile and run bare-metal programs against the RTL:

1. **Toolchain**
	 - Use or configure a cross-compiler toolchain targeting the chosen ISA (e.g., `riscv64-unknown-elf-gcc`), or a custom assembler if using a custom ISA.

2. **Build Steps (conceptual)**
	 - Write tests in `sw/asm/` or `sw/c/`.
	 - Compile/assemble and link against a linker script in `sw/linker/` that matches the SoC memory map.
	 - Produce a flat binary, hex, or memory initialization file (e.g., `.hex`, `.mem`) for the simulated memory.

3. **Simulation Flow**
	 - Use scripts in `sim/` to:
		 - Build the RTL (with your chosen simulator).
		 - Load the program image into the instruction/data memory model.
		 - Run the simulation until a pass/fail signature is detected (e.g., write to a specific memory-mapped address or UART string).

4. **Pass/Fail Convention**
	 - Define a small ABI for tests, for example:
		 - Writing a specific value to a `TEST_STATUS` MMIO register.
		 - Or writing "PASS"/"FAIL" over UART.

## Status

- Architecture definition: in progress.
- RTL implementation: TODO.
- Testbench environment: TODO.
- Assembly/C test flow: TODO.

This README will be refined as the RTL, testbench, and software infrastructure are implemented.

## OBI → AXI Bridge

![OBI-2-AXI Block Diagram](document/svg/OBI-2-AXI-UPDATED-BLOCK.svg)
![OBI-2-AXI FSM Diagram](document/svg/OBI-2-AXI-FSM.svg)

This section documents the two diagrams above:

- `document/svg/OBI-2-AXI-UPDATED-BLOCK.svg` — Block-level view of the OBI-to-AXI bridge.
- `document/svg/OBI-2-AXI-FSM.svg` — Finite State Machine (FSM) used by the bridge to translate transactions.

Use this as a quick reference when reading or modifying the bridge RTL in `source/obi_2_axi/`.

**Block Diagram (High-Level Overview)**

The block diagram shows the bridge that converts a simple OBI-style master interface into an AXI4-style slave interface. The bridge consists of several logical pieces:

- OBI Frontend: Accepts requests from the OBI master. Typical signals include address, read/write strobes, data (write), and handshake/ack.
- Command Decoder / Translator: Maps OBI transfer types (read/write, burst semantics if any) into the appropriate AXI channel transactions (AW/ W / B for write; AR / R for read).
- AXI Interface Engine: Manages the AXI channel logic (AW, W, B, AR, R) including IDs, lengths, and response handling.
- Response Arbiter / Completion Logic: Converts AXI responses and data back to the OBI master's expected format and signals completion.

Important mapping notes (concrete signal names may vary in RTL):

- `OBI.addr` -> `AXI.ARADDR` / `AXI.AWADDR`
- `OBI.write_data` -> `AXI.WDATA`
- `OBI.read_data` <- `AXI.RDATA`
- OBI byte enable -> `AXI.WSTRB` (and AWVALID/AWREADY, WVALID/WREADY handshakes)
- OBI read request -> `AXI.ARVALID`/`ARREADY`
- `AXI.RRESP` / `AXI.BRESP` -> reported back via OBI status/ack signals

**FSM Diagram (State Machine Behavior)**

The FSM diagram illustrates how the bridge sequences operations. Typical states and transitions are:

- IDLE: Waiting for an OBI request (read or write). On request: load address and control info and move to the appropriate state.
- ADDR_SETUP / ADDR_ISSUE: Assert AWVALID or ARVALID and wait for AWREADY/ARREADY from the AXI slave.
- WRITE_DATA: For writes, present WDATA and WSTRB and wait for WREADY; when last beat is written, assert WLAST (if supporting burst) and wait for completion.
- WRITE_RESP: Wait for BVALID from AXI and capture BRESP; report completion back to the OBI master and return to IDLE.
- READ_WAIT / READ_DATA: After AR handshake, wait for RVALID/RLAST beats; capture RDATA and RRESP and forward to the OBI master. After last beat, complete and return to IDLE.
- ERROR / RECOVER: Optional error handling state if AXI returns an error response. Bridge may translate BRESP/RRESP error into OBI failure indications.

Transition triggers to look for in the diagram/RTL:

- OBI request asserted: triggers IDLE -> ADDR_SETUP
- AXI *READY* asserted (e.g., AWREADY, ARREADY): move to send data or wait for response
- AXI *VALID* asserted for responses (RVALID, BVALID): capture and process response
- WLAST/RLAST: indicate termination of a burst transfer (if supported)

**Where to look in the repo**

- RTL source for this bridge: `source/obi_2_axi/obi_2_axi.sv` (or similarly named file in the `source/obi_2_axi/` directory).
- Diagrams (SVGs): `document/svg/OBI-2-AXI-UPDATED-BLOCK.svg` and `document/svg/OBI-2-AXI-FSM.svg`.
