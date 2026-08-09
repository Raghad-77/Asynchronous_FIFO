# Asynchronous FIFO

Verilog RTL | CDC | Gray Code | FIFO | Digital Design

## Overview

This project implements a parameterized asynchronous FIFO with independent write and read clock domains.

The FIFO is designed to safely transfer data between two clock domains operating at different frequencies. Write operations occur on the write clock domain, while read operations occur on the read clock domain.

The design uses Gray-coded read and write pointers together with clock-domain synchronization to safely communicate FIFO status information between the two asynchronous clock domains.

## Specifications

| Parameter / Signal | Description |
| DATA_WIDTH | Parameterized FIFO data width |
| DEPTH | Parameterized FIFO depth |
| data_in | Input data |
| data_out | Output data |
| w_en | Write enable |
| r_en | Read enable |
| w_clk | Write clock |
| r_clk | Read clock |
| w_rst | Write-domain reset |
| r_rst | Read-domain reset |
| full | FIFO full status |
| empty | FIFO empty status |
| Write Clock | 60 MHz |
| Read Clock | 10 MHz |
| Burst Size | 120 transactions |

## Architecture

The FIFO operates using two independent clock domains:

### Write Clock Domain

The write side:

1. Accepts input data when `w_en` is asserted and the FIFO is not full.
2. Updates the binary write pointer.
3. Converts the write pointer from binary to Gray code.
4. Synchronizes the read pointer Gray code into the write clock domain.
5. Uses the synchronized read pointer to determine the `full` condition.

### Read Clock Domain

The read side:

1. Produces output data when `r_en` is asserted and the FIFO is not empty.
2. Updates the binary read pointer.
3. Converts the read pointer from binary to Gray code.
4. Synchronizes the write pointer Gray code into the read clock domain.
5. Uses the synchronized write pointer to determine the `empty` condition.

## Clock-Domain Crossing

Because the write and read clocks are asynchronous, directly transferring multi-bit binary pointers between the clock domains can result in unsafe sampling.

To address this, the design uses Gray-coded pointers.

Gray code changes only one bit between consecutive pointer values, reducing the possibility of inconsistent pointer values being observed during clock-domain crossing.

The synchronized Gray-coded pointers are then used for safe full and empty status generation.

## Pointer Generation

Binary pointers are maintained independently in the write and read clock domains.

The pointers are converted to Gray code before crossing clock domains.

The design therefore includes:

- Binary-to-Gray conversion
- Gray-to-binary conversion where required
- Pointer synchronization between clock domains
- Full detection
- Empty detection

## FIFO Status

### Empty

The FIFO is considered empty when the read pointer reaches the synchronized write pointer.

### Full

The FIFO is considered full when the write pointer reaches the appropriate synchronized read-pointer position indicating that the FIFO has no available storage locations.

## Clock Configuration

The design is intended to operate with:

- Write clock frequency: 60 MHz
- Read clock frequency: 10 MHz

This creates independent asynchronous clock domains and demonstrates data transfer between clocks operating at different rates.

## Burst Requirement

The FIFO supports a burst size of 120 transactions.

The faster 60 MHz write domain and slower 10 MHz read domain allow the FIFO to buffer data while the two sides operate at different rates.

## Parameterization

The FIFO is designed to be reusable through parameterized:

- Data width
- FIFO depth

This allows the same RTL architecture to be adapted to different data-storage requirements without changing the core design structure.

## Verification

The design is verified using scenarios covering:

- Write operations
- Read operations
- Simultaneous read/write activity
- FIFO empty condition
- FIFO full condition
- Write attempts while full
- Read attempts while empty
- Reset behavior in both clock domains
- Different write/read clock frequencies
- Burst transfers
- Correct data ordering
- Correct full/empty status

Waveform analysis used to verify pointer synchronization, data integrity, and FIFO status transitions.

## Tools

- Verilog / SystemVerilog
- QuestaSim
- VS Code
