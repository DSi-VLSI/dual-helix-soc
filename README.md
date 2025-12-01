![Dual Helix SoC Architecture](documents/svg/DHS-ARCH-DIAGRAM.svg)

# Dual Helix SoC

Dual Helix SoC (DHS) is a small, experimental System-on-Chip project intended as a playground for RTL design, verification, and software bring-up. This repo will host the RTL, simulation testbenches, and basic bare‑metal software tests (assembly and C).

## Goals

- Define a minimal but realistic SoC architecture (core, bus, memory, peripherals).
- Implement synthesizable RTL for the core and top-level SoC.
- Develop a reusable testbench environment for block-level and SoC-level verification.
- Run assembly and C programs on the SoC via simulation (and later, optionally, FPGA).

## Design Overview

The high-level architecture is shown above in `documents/svg/DHS-ARCH-DIAGRAM.svg`. At a minimum, the SoC is expected to include:

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
