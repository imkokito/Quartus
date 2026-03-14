# UART Communication using the MAX10

This project implements a UART (Universal Asynchronous Receiver-Transmitter) communication system between two MAX10 FPGAs using Verilog. It includes:

- `UART_Tx`: transmits an 8-bit value serially.
- `UART_Rx`: receives a serial signal and reconstructs the 8-bit value.
- `top_tx`: wrapper for the transmitter FPGA.
- `top_rx`: wrapper for the receiver FPGA.
- `BCD`: converts a single 4-bit digit (0–9) into a 7-segment output pattern.
- `BCD_4display`: splits a binary number into 4 decimal digits and drives 4 displays.
- `uart_tb`: testbench that connects TX and RX together and verifies end-to-end transmission.

## How it works

The project is split across two FPGAs connected by a wire:

**Transmitter (top_tx):**
1. You set a value (0–255) using `SW[7:0]`.
2. You press `KEY[0]` to trigger the transmission.
3. `UART_Tx` sends the value as a serial UART frame through `ARDUINO_IO[1]`.
4. The current value is shown on `HEX3–HEX0`.

**Receiver (top_rx):**
1. `UART_Rx` listens on `ARDUINO_IO[0]` for an incoming frame.
2. Once a full frame is received, `data_ready` pulses high.
3. The received value is shown on `HEX3–HEX0`.

UART frame format:
- 1 start bit (low)
- 8 data bits (LSB first)
- 1 stop bit (high)

## Project structure

- `UART_Tx.v`
- `UART_Rx.v`
- `top_tx.v`
- `top_rx.v`
- `BCD.v`
- `BCD_4display.v`
- `uart_tb.v`
- `top_tx.qsf`
- `top_rx.qsf`

## Modules

### `UART_Tx`

Serializes an 8-bit value and transmits it as a UART frame.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz clock |
| `rst` | input | reset |
| `data_in[7:0]` | input | Byte to transmit |
| `start` | input | Trigger transmission |
| `tx_out` | output | Serial TX line |
| `busy` | output | 1 while transmitting |

States: `IDLE → START_BIT → DATA_BITS → STOP_BIT → IDLE`

Uses a `baud_counter` that counts to `CLOCK_FREQ/BAUD_RATE` cycles per bit, shifting out one bit at a time LSB first.

### `UART_Rx`

Receives a serial UART frame and reconstructs the 8-bit value.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz clock |
| `rst` | input | reset |
| `rx_in` | input | Serial RX line |
| `data_out[7:0]` | output | Received byte |
| `data_ready` | output | Pulses high when a byte is ready |

Includes a 2-stage synchronizer on `rx_in` to avoid metastability issues when receiving signals from another FPGA.

Samples each bit at the center of its period by waiting `(BAUD_TICK-1)/2` cycles after the start bit is detected, which gives the most reliable reading.

States: `IDLE → START_BIT → DATA_BITS → STOP_BIT → IDLE`

### `top_tx`

Wrapper for the transmitter FPGA.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[0] = send, KEY[1] = reset |
| `SW[9:0]` | input | SW[7:0] = byte to send |
| `ARDUINO_IO[15:0]` | output | TX signal on pin 1 |
| `HEX0–HEX3` | output | Current value on display |

### `top_rx`

Wrapper for the receiver FPGA.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[1] = reset |
| `ARDUINO_IO[15:0]` | input | RX signal on pin 0 |
| `HEX0–HEX3` | output | Received value on display |

### `BCD`

Single digit (0–9) to 7-segment decoder. See [BCD](../Practica2/README.md) for full description.

### `BCD_4display`

Splits a binary number into 4 decimal digits and drives 4 displays. See [BIN_TO_4_DISPLAY](../Practica2/README.md) for full description.

### `uart_tb`

Testbench — connects TX and RX directly and sends 4 values.

- `ARDUINO_IO_tx[1]` is wired directly to `RX_UUT.ARDUINO_IO[0]`, simulating the physical wire between the two FPGAs
- Sends: 255, 0, 165, 127
- Each case waits 2 ms for the full UART frame to complete
- `$monitor` prints TX line, `data_ready` and `data_out` on every change
- `$dumpfile` generates `uart_tb.vcd` for GTKWave

## Simulation
```bash
iverilog -o sim UART_Tx.v UART_Rx.v top_tx.v top_rx.v BCD.v BCD_4display.v uart_tb.v
vvp sim
gtkwave uart_tb.vcd
```
