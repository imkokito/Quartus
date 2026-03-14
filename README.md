# Logica Programable — Intel MAX10 FPGA (Verilog)

This repository contains the projects and practices developed for a Programmable Logic course using the Intel MAX10 FPGA (DE10-Lite board). All designs are written in Verilog and implemented in Quartus Prime.

## Practices

| # | Project | Description |
|---|---------|-------------|
| 1 | [Prime Number Detector](./Practica1/README.md) | Combinational circuit that detects prime numbers (0–15) using switches and an LED |
| 2 | [BCD to 7-Segment Display](./Practica2/README.md) | Binary to decimal decoder driving 4 seven-segment displays |
| 3 | [Up/Down Counter](./Practica3/README.md) | Configurable counter (0–100) with clock divider, load and direction control |
| 4 | [Password FSM Lock](./Practica4/README.md) | 4-digit password lock implemented as a finite state machine |
| 5 | [PWM Signal Generator](./Practica5/README.md) | PWM generator for servo control with adjustable duty cycle |
| 6 | [VGA Signal Generator](./Practica6/README.md) | VGA 640×480 @ 60Hz signal generator with checkerboard pattern |
| 7 | [UART Communication](./Practica7/README.md) | Serial UART communication between two MAX10 FPGAs |

## Final Project

| Project | Description |
|---------|-------------|
| [Robotic Arm Controller](./ProyectoFinal/README.md) | Accelerometer-based robotic arm controller with PWM outputs, position memory, playback mode and VGA display |

## Tools

**Quartus Prime Lite** — used for synthesis, place & route, and programming the MAX10 FPGA.

**OSS CAD Suite** — open source toolchain used to run Verilog testbenches from the terminal without needing Quartus. Includes `iverilog` for compilation, `vvp` for simulation, and `gtkwave` for waveform viewing.

**Visual Studio Code** — used as the main code editor for writing and reviewing Verilog files, running testbenches through the integrated terminal with OSS CAD Suite.
