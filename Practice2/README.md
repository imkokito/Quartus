# BCD to 7-Segment Display usign the MAX10

This project implements a binary to 7-segment display decoder on a MAX10 FPGA using Verilog. It includes:

- `BCD`: converts a single 4-bit digit (0–9) into a 7-segment output pattern.
- `BIN_TO_4DISPLAY`: takes a 10-bit binary number (0–1023) and splits it into thousands, hundreds, tens and units, driving 4 displays simultaneously.
- `BCD_4displays_w`: top-level wrapper that connects the 10 switches of the board to the 4 HEX displays.
- `BIN_TO_4DISPLAY_tb`: testbench that runs 50 random inputs and prints results to the console.

## How it works

1. You set a value (0–999) using `SW[9:0]`.
2. `BIN_TO_4DISPLAY` splits the number into its decimal digits using division and modulo.
3. Each digit is passed to a `BCD` instance which converts it to the 7-segment pattern.
4. The result is shown across `HEX3`, `HEX2`, `HEX1`, `HEX0` in the display.

## Project structure

- `BCD.v`
- `BIN_TO_4DISPLAY.v`
- `BCD_4displays_w.v`
- `BIN_TO_4DISPLAY_tb.v`
- `BCD_4displays_w.qsf`

## Modules

### `BCD`

Single digit (0–9) to 7-segment decoder.

| Port | Direction | Description |
|------|-----------|-------------|
| `bcd` | input | 4-bit digit (0–9) |
| `out` | output | 7-segment pattern (active-low) |

Uses a `case` statement for each digit. Any value outside 0–9 outputs `1111111` will turn all segments off.

### `BIN_TO_4DISPLAY`

Splits a binary number into 4 decimal digits and drives 4 displays.

| Port | Direction | Description |
|------|-----------|-------------|
| `bcd` | input | 10-bit number (0–1023) |
| `out_uni` | output | Units display |
| `out_dec` | output | Tens display |
| `out_cent` | output | Hundreds display |
| `out_mil` | output | Thousands display |

Digit extraction:
```verilog
assign uni   = bcd % 10;
assign dec   = (bcd / 10) % 10;
assign centi = (bcd / 100) % 10;
assign mil   = (bcd / 1000) % 10;
```

### `BCD_4displays_w`

Top-level wrapper for the FPGA board.

| Port | Direction | Description |
|------|-----------|-------------|
| `SW[9:0]` | input | Number to display (0–999) |
| `HEX0–HEX3` | output | 7-segment displays |

### `BIN_TO_4DISPLAY_tb`

Testbench — runs 50 random inputs.

- Uses `$random % 1023` to generate values in range
- `$monitor` prints every input/output change
- `$dumpfile` generates `BIN_TO_4DISPLAY_tb.vcd` for GTKWave
- `$stop` pauses simulation for waveform inspection

## Simulation
```bash
iverilog -o sim BCD.v BIN_TO_4DISPLAY.v BIN_TO_4DISPLAY_tb.v
vvp sim
gtkwave BIN_TO_4DISPLAY_tb.vcd
```
