# Password FSM Lock using the MAX10

This project implements a 4-digit password lock on a MAX10 FPGA using Verilog. It includes:

- `PASSWORD`: a finite state machine that validates a 4-digit password entered via switches and confirmed with a button.
- `password_w`: top-level wrapper that connects the FSM, clock divider and displays.
- `clk_divider_parameter`: divides the 50 MHz board clock to a slow clock.
- `BCD`: converts a single 4-bit digit (0–9) into a 7-segment output pattern.
- `psw_tb`: testbench that runs correct and incorrect password sequences.

## How it works

1. You set a digit using `SW[3:0]`.
2. You press `KEY[0]` to confirm that digit.
3. The FSM compares each digit to the stored password one by one:
   - Default password: **1-4-0-4**
4. If any digit is wrong → the FSM enters `BAD` and stays there until you hit reset.
5. If all four digits match → the FSM enters `GOOD` and stays there until you hit reset.
6. Displays:
   - Normal entry: shows each digit as it is entered on `HEX3–HEX0`
   - `good` → shows `"GooD"` on `HEX3–HEX0`
   - `bad` → shows `"bAd"` with one display blank
7. `KEY[1]` resets the FSM back to `IDLE` and clears the displays.

## Project structure

- `PASSWORD.v`
- `password_w.v`
- `clk_divider_parameter.v`
- `BCD.v`
- `psw_tb.v`
- `password_w.qsf`

## Modules

### `PASSWORD`

Main FSM lock controller.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | Clock |
| `rst` | input | reset |
| `enter` | input | Confirm button |
| `SW[3:0]` | input | Current digit to enter |
| `d0–d3` | output | Captured digits for display |
| `good` | output | 1 if password correct |
| `bad` | output | 1 if any digit was wrong |

States: `IDLE → DIG1 → DIG2 → DIG3 → GOOD`. Any mismatch goes directly to `BAD`.

Uses edge detection on `enter` so each button press is captured exactly once regardless of how long the button is held.

Default password:
```verilog
parameter PASS1 = 4'd1;
parameter PASS2 = 4'd4;
parameter PASS3 = 4'd0;
parameter PASS4 = 4'd4;
```

### `password_w`

Top-level wrapper for the FPGA board.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[0] = enter, KEY[1] = reset |
| `SW[3:0]` | input | Digit to enter |
| `HEX0–HEX3` | output | 7-segment displays |

Handles the display multiplexing: shows digits during entry, `"GooD"` on success and `"bAd"` on failure using segment patterns.

### `clk_divider_parameter`

Divides the 50 MHz board clock down to a slower frequency. See [clk_divider_parameter](../Practica3/README.md) for full description.

### `BCD`

Single digit (0–9) to 7-segment decoder. See [BCD](../Practica2/README.md) for full description.

### `psw_tb`

Testbench — runs 3 password entry sequences.

- Correct password: 1-4-0-4 → expects `good=1 bad=0`
- Wrong first digit: 5-4-0-4 → expects `good=0 bad=1`
- Wrong middle digit: 1-4-9-4 → expects `good=0 bad=1`
- `$monitor` prints SW, KEY, good and bad on every change
- `$dumpfile` generates `psw_tb.vcd` for GTKWave
- Reset is applied between each test case

## Simulation
```bash
iverilog -o sim PASSWORD.v password_w.v clk_divider_parameter.v BCD.v psw_tb.v
vvp sim
gtkwave psw_tb.vcd
```
