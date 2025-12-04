## OBI → AXI Bridge

![OBI-2-AXI Block Diagram](svg/OBI-2-AXI-UPDATED-BLOCK.svg)
![OBI-2-AXI FSM Diagram](svg/OBI-2-AXI-FSM.svg)

This section documents the two diagrams above:

- `svg/OBI-2-AXI-UPDATED-BLOCK.svg` — Block-level view of the OBI-to-AXI bridge.
- `svg/OBI-2-AXI-FSM.svg` — Finite State Machine (FSM) used by the bridge to translate transactions.

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
- Diagrams (SVGs): `svg/OBI-2-AXI-UPDATED-BLOCK.svg` and `svg/OBI-2-AXI-FSM.svg`.
