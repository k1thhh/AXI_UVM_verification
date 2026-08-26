# 🔌 AXI4 UVM Verification IP

A **parameterized UVM 1.2 verification environment** for a subset of the **AMBA AXI4 protocol**, supporting write and read channels with burst transfers.

The project implements a complete master-slave verification architecture with **active master and reactive slave agents**, constrained-random and directed sequences, protocol assertions, and a **self-checking scoreboard** that compares transactions between the master and slave sides.

The verification environment supports all three AXI burst types — **FIXED, INCR, and WRAP** — and is designed to provide reusable, DUT-agnostic AXI4 verification functionality. :contentReference[oaicite:1]{index=1}

<p align="center">

<img src="https://img.shields.io/badge/Domain-UVM%20Verification-blue" alt="UVM Verification">
<img src="https://img.shields.io/badge/Protocol-AXI4-orange" alt="AXI4">
<img src="https://img.shields.io/badge/Language-SystemVerilog-green" alt="SystemVerilog">
<img src="https://img.shields.io/badge/Framework-UVM%201.2-purple" alt="UVM 1.2">
<img src="https://img.shields.io/badge/Simulation-Vivado-red" alt="Vivado">
<img src="https://img.shields.io/badge/Verification-Constrained%20Random-yellow" alt="Constrained Random">

</p>

---

## Why

AXI4 is widely used as a high-performance on-chip communication protocol, but verifying its multiple independent channels, handshakes, burst modes, and transaction dependencies requires extensive and systematic testing.

This project builds a reusable **UVM Verification IP (VIP)** that can generate, monitor, compare, and validate AXI4 transactions.

The environment focuses on:

- **Independent AXI master and slave agents**
- Transaction-level self-checking
- Constrained-random stimulus generation
- Directed burst testing
- AXI protocol assertions
- Concurrent read and write verification
- Parameterized address and data widths

## Features

- 🔌 AXI4 write and read channel verification
- 🔄 Support for `FIXED`, `INCR`, and `WRAP` bursts
- 🧪 Constrained-random AXI transactions
- 🎯 Directed AXI burst tests
- 🧑‍💻 Active AXI master agent
- 💾 Reactive memory-backed AXI slave agent
- 📊 Self-checking scoreboard
- 🔍 Transaction comparison using AXI IDs
- ⚡ Concurrent read and write sequences
- 🛡️ AXI protocol assertions
- ⏱️ Synchronous, race-free clocking blocks
- 📐 Parameterized address and data widths
- 📈 Vivado XSim simulation flow
- 🌊 Waveform generation and analysis

## System Architecture

```text
                         ┌────────────────────────────────────┐
                         │             axi_env                │
                         │                                    │
 axi_write_seq ────────► │   ┌────────────┐    ┌────────────┐ │
                         │   │ AXI Master │    │ AXI Slave  │ │
 axi_read_seq ─────────► │   │   Agent    │◄──►│   Agent    │ │
                         │   │            │    │            │ │
                         │   │ Driver     │    │ Driver     │ │
                         │   │ Monitor    │    │ Monitor    │ │
                         │   └─────┬──────┘    └─────┬──────┘ │
                         │         │                 │        │
                         │         └────────┬────────┘        │
                         │                  ▼                 │
                         │           AXI Scoreboard           │
                         │                  │                 │
                         │                  ▼                 │
                         │          PASS / FAIL Check        │
                         └────────────────────────────────────┘
````

**Flow:** sequence generation → master driver → AXI interface → slave agent → transaction monitoring → scoreboard comparison → self-checking result.

## AXI Interface

The `axi_intf` interface provides a DUT-agnostic connection between the master and slave agents.

It carries all five AXI4 channels:

```text
AW → Write Address
W  → Write Data
B  → Write Response
AR → Read Address
R  → Read Data
```

The interface also contains:

* Three clocking blocks
* `m_drv_cb`
* `s_drv_cb`
* `mon_cb`
* Four modports
* `MDRV`
* `MMON`
* `SDRV`
* `SMON`

These provide the driver and monitor classes with a synchronized and race-free view of the AXI bus. 

## AXI Master Agent

The AXI master is implemented as an **active UVM agent**.

```text
             AXI Master Agent
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
       Driver              Monitor
          │                   │
          ▼                   ▼
      AXI Bus           Analysis Port
          │
          ▼
       DUT / Slave
```

The master agent contains:

* Driver
* Monitor
* Write sequencer
* Read sequencer

The independent write and read sequencers allow read and write sequences to execute concurrently. 

## AXI Slave Agent

The slave agent operates as a **reactive UVM agent**.

Instead of receiving transactions from a sequencer, its driver behaves like a memory-backed AXI slave.

```text
             AXI Slave Agent
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
       Driver              Monitor
          │                   │
          ▼                   ▼
   Memory-backed        Analysis Port
       Slave
```

Write transactions are stored in an associative memory structure and corresponding data is returned when the master performs reads. 

## Scoreboard

The `axi_scoreboard` provides the main self-checking mechanism.

It receives completed transactions from both master and slave analysis ports and compares the corresponding transactions using their AXI IDs.

```text
       Master Monitor
             │
             ▼
     ┌─────────────────┐
     │                 │
     │ AXI Scoreboard  │
     │                 │
     └────────┬────────┘
              ▲
              │
       Slave Monitor
```

The scoreboard:

* Receives master transactions
* Receives slave transactions
* Matches transactions by ID
* Separates read and write comparisons
* Calls `axi_transaction::compare()`
* Reports `PASSED` or `FAILED`



## Transaction Model

The `axi_transaction` class acts as the common sequence item shared throughout the environment.

It contains:

* AXI transaction ID
* Address
* Data
* Burst size
* Burst length
* Burst type

The transaction is **randomizable**, allowing constrained-random stimulus to be generated for different AXI configurations. 

## Burst Types

The VIP supports all three AXI burst types:

### FIXED

The address remains constant throughout the burst.

```text
ADDR → ADDR → ADDR → ADDR
```

### INCR

The address increments after each transfer.

```text
ADDR → ADDR+N → ADDR+2N → ADDR+3N
```

### WRAP

The address increments within a defined boundary and then wraps back to the beginning of the region.

```text
ADDR → ADDR+N → ADDR+2N → WRAP
```

Directed tests are provided for each burst type.

## Constrained-Random Testing

The verification environment generates randomized AXI transactions using UVM sequence items.

```text
Randomization
     │
     ▼
AXI Transaction
     │
     ├── ID
     ├── Address
     ├── Data
     ├── Burst Size
     ├── Burst Length
     └── Burst Type
     │
     ▼
Master Sequencer
     │
     ▼
Master Driver
     │
     ▼
AXI Interface
```

The default sequences generate **20 write transactions and 20 read transactions**, configurable through `test_config`. 

## Protocol Assertions

The AXI interface contains SystemVerilog `assert property` checks to verify that the AXI channels obey the required handshake behavior.

The assertions verify that the:

* AW channel
* W channel
* B channel
* AR channel
* R channel

remain stable while `VALID` is asserted and the corresponding `READY` signal remains low.

This directly checks the AXI4 handshake requirements. 

## Technologies Used

* **SystemVerilog**
* **UVM 1.2**
* **AMBA AXI4**
* **Xilinx Vivado**
* **Vivado XSim**
* **Constrained-random verification**
* **SystemVerilog Assertions**
* **UVM Scoreboarding**
* **Transaction-level modeling**

## Parameters

The VIP is parameterized through:

| Parameter | Default | Description       |
| --------- | ------: | ----------------- |
| `A_WIDTH` |     `8` | Address bus width |
| `D_WIDTH` |   `128` | Data bus width    |

These parameters are defined in `src/tb/axi_tb_top.sv` and propagated throughout the verification environment. 

To retarget the VIP, modify the parameter values in `axi_tb_top.sv` before compilation.

## Repository Structure

```text
axi-uvm-vip/
├── src/
│   ├── axi_interface.sv
│   ├── axi_transaction.sv
│   ├── axi_config_objs.svh
│   ├── axi_package.svh
│   │
│   ├── env/
│   │   ├── axi_env.sv
│   │   └── axi_scoreboard.sv
│   │
│   ├── agents/
│   │   ├── master/
│   │   │   ├── driver
│   │   │   └── monitor
│   │   │
│   │   └── slave/
│   │       ├── driver
│   │       └── monitor
│   │
│   ├── sequences/
│   │   ├── axi_write_seq.sv
│   │   └── axi_read_seq.sv
│   │
│   └── tb/
│       ├── axi_tb_top.sv
│       └── axi_test.sv
│
├── sim/
│   ├── axi.f
│   ├── Makefile
│   ├── logs/
│   │   └── simulate.log
│   └── waves/
│       └── top_behav.wdb
│
└── docs/
    ├── waveform_write_channel.png
    └── waveform_read_channel.png
```



## Getting Started

### Requirements

* Xilinx Vivado with `xvlog`, `xelab`, and `xsim`
* SystemVerilog support
* UVM 1.2
* Make

The environment itself uses standard SystemVerilog and UVM 1.2 and is not inherently tied to Vivado. It can also be compiled with simulators such as **Questa, VCS, or Xcelium** by using the provided filelist and include paths. 

### 1. Clone the Repository

```bash
git clone <repository-url>
cd axi-uvm-vip
```

### 2. Enter the Simulation Directory

```bash
cd sim
```

### 3. Run the Base Test

```bash
make
```

This compiles, elaborates, and runs `axi_base_test`. 

### 4. Run a Directed Test

For example:

```bash
make TEST=axi_wrap_test
```

### 5. Open the Waveform Viewer

```bash
make gui
```

### 6. Clean Simulation Artifacts

```bash
make clean
```

## Available Tests

| Test             | Purpose                                       |
| ---------------- | --------------------------------------------- |
| `axi_base_test`  | Concurrent randomized read/write verification |
| `axi_write_test` | Directed write testing                        |
| `axi_read_test`  | Directed read testing                         |
| `axi_fixed_test` | FIXED burst verification                      |
| `axi_incr_test`  | INCR burst verification                       |
| `axi_wrap_test`  | WRAP burst verification                       |

These tests are defined in `axi_test.sv`. 

## Simulation Flow

```text
              UVM Test
                  │
                  ▼
            axi_base_test
                  │
                  ▼
              axi_env
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
   AXI Master           AXI Slave
     Agent                Agent
        │                   │
        └─────────┬─────────┘
                  ▼
             AXI Interface
                  │
                  ▼
             Transactions
                  │
                  ▼
             Scoreboard
                  │
          ┌───────┴───────┐
          ▼               ▼
        PASS             FAIL
```

## Sample Results

The captured `axi_base_test` simulation uses the default **20 write + 20 read transactions**.

The scoreboard reports the result of each completed transfer after both master-side and slave-side transaction copies have arrived.

The captured simulation log contains:

* **21/21 transactions PASSED**
* **0 FAILED**
* **0 UVM_ERROR**



## Waveform Analysis

Waveforms are provided for both the AXI write and read channels:

* [`docs/waveform_write_channel.png`](docs/waveform_write_channel.png)
* [`docs/waveform_read_channel.png`](docs/waveform_read_channel.png)

These waveforms provide visual verification of the AXI handshake and channel behavior. 

## Impact & Results

This project demonstrates a reusable **UVM-based AXI4 verification environment** capable of automatically generating and checking a wide range of transactions.

The combination of:

* Constrained-random sequences
* Directed tests
* Protocol assertions
* Master/slave monitoring
* Transaction-level scoreboarding

provides multiple layers of verification coverage for the AXI4 interface.

## Limitations

* The project implements a **subset of AXI4**, rather than the complete protocol.
* Verification is focused on write/read channels and burst transfers.
* The provided simulation flow targets Vivado XSim.
* The default configuration uses an 8-bit address bus and 128-bit data bus.
* No complete AXI interconnect or multi-master system is included.

## Future Scope

* Extend coverage to additional AXI4 features
* Add AXI4-Lite verification
* Add AXI4-Stream verification
* Add functional coverage models
* Add coverage-driven constrained-random testing
* Add more protocol assertion checks
* Add error-response testing
* Add multiple master/slave agents
* Add AXI interconnect verification
* Add protocol stress testing
* Add regression automation across multiple simulators
* Integrate the VIP with a real AXI-based DUT

## Project Highlights

* 🔹 Parameterized **UVM 1.2 AXI4 VIP**
* 🔹 Active master agent
* 🔹 Reactive memory-backed slave agent
* 🔹 AXI write and read verification
* 🔹 `FIXED`, `INCR`, and `WRAP` bursts
* 🔹 Constrained-random transactions
* 🔹 Directed verification sequences
* 🔹 Protocol assertions
* 🔹 Transaction-level scoreboard
* 🔹 ID-based transaction matching
* 🔹 Concurrent read/write sequences
* 🔹 Self-checking simulation
* 🔹 Vivado XSim regression flow
* 🔹 Waveform-based debugging
* 🔹 **21/21 captured transactions passed**
* 🔹 0 `UVM_ERROR` in captured simulation

## Key Concepts Demonstrated

* UVM
* SystemVerilog
* AXI4
* AMBA Protocols
* Verification IP
* Constrained-Random Verification
* Directed Testing
* UVM Agents
* UVM Drivers
* UVM Monitors
* UVM Sequencers
* UVM Scoreboards
* Transaction-Level Modeling
* SystemVerilog Assertions
* Protocol Verification
* Burst Transfers
* Functional Verification
* Simulation-Based Verification
* Verification Environment Architecture

## Comprehensive Project Documentation

For detailed information about the AXI interface, UVM architecture, simulation flow, waveforms, and verification results, refer to the documentation included in the repository:

* [`docs/waveform_write_channel.png`](docs/waveform_write_channel.png)
* [`docs/waveform_read_channel.png`](docs/waveform_read_channel.png)
* [`sim/logs/simulate.log`](sim/logs/simulate.log)

## Acknowledgements

* **Accellera** — UVM methodology and UVM 1.2
* **ARM** — AMBA AXI4 protocol specification
* **Xilinx AMD** — Vivado simulation environment

```
```
