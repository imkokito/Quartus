# Up/Down Counter to 100 using the MAX10

This project implements a configurable up/down counter (0–100) on a MAX10 FPGA using Verilog. It includes:

- `count`: core counter logic that counts up or down, with a load option to start at the numer you want and limit at 100.
- `contador`: top-level module that connects the clock divider, counter and display.
- `clk_divider_parameter`: divides the 50 MHz board clock to a slow clock (default 5 Hz).
- `BCD`: converts a single 4-bit digit (0–9) into a 7-segment output pattern.
- `BIN_TO_4DISPLAY`: splits a binary number into 4 decimal digits and drives 4 displays.
- `PINES`: wrapper that maps switches and buttons to the counter.
- `counter_a_100_tb`: testbench that runs count up, count down, load and resume sequences.

## How it works

1. The counter increments or decrements on each tick of the divided clock.
2. `SW[9]` selects direction: `0` = up, `1` = down.
3. `SW[6:0]` sets the value to load.
4. Pressing `KEY[1]` loads that value into the counter (clamped to 100 if over).
5. Pressing `KEY[0]` resets the counter to 0.
6. The current count is shown across `HEX3–HEX0`.

Limits:
- Counting down: wraps from 100 → 0
- Counting up: wraps from 0 → 100

## Project structure

- `count.v`
- `contador.v`
- `PINES.v`
- `clk_divider_parameter.v`
- `BCD.v`
- `BIN_TO_4DISPLAY.v`
- `counter_a_100_tb.v`
- `PINES.qsf`

## Modules

### `count`

Core counter logic.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | Clock |
| `rst` | input | reset |
| `up_down` | input | Direction: 0 = up, 1 = down |
| `load` | input | Load trigger |
| `data_in[6:0]` | input | Value to load (limited to 100) |
| `counter[7:0]` | output | Current count value |

### `contador`

Integrates clock divider, counter and display decoder.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz clock |
| `rst` | input | reset |
| `up_down` | input | Count direction |
| `load` | input | Load trigger |
| `data_in[6:0]` | input | Value to load |
| `out_uni–>out_mil` | output | 7-segment display outputs |

### `PINES`

Board-level wrapper.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[0] = reset, KEY[1] = load |
| `SW[9:0]` | input | SW[9] = direction, SW[6:0] = load value |
| `HEX0–HEX3` | output | 7-segment displays |

### `clk_divider_parameter`

Divides the 50 MHz board clock down to a slower clock frequency so the counter is visible to the human eye.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz board clock |
| `rst` | input | reset |
| `clk_div` | output | Divided clock output |

| Parameter | Default | Description |
|-----------|---------|-------------|
| `FREQ` | 5 | Output frequency in Hz |

The MAX10 runs at 50 MHz, meaning it produces 50,000,000 clock pulses per second — far too fast
to see any counter changes on the display. The clock divider solves this by counting those pulses
and only toggling its output every `CLK_FREQ / (2 * FREQ)` cycles.

For the default 5 Hz:
```
ConstantNumber = 50_000_000 / (2 * 5) = 5_000_000
```
This means `clk_div` toggles every 5,000,000 cycles of the base clock, producing a full
period every 10,000,000 cycles — exactly 5 times per second. The counter then advances
once per `clk_div` tick, making it easy to follow on the display.

### `BCD`

Single digit (0–9) to 7-segment decoder. See [BCD](../Practica2/README.md) for full description.

### `BIN_TO_4DISPLAY`

Splits a binary number into 4 decimal digits and drives 4 displays. See [BIN_TO_4DISPLAY](../Practica2/README.md) for full description.

### `counter_a_100_tb`

Testbench — runs 4 scenarios sequentially.

- Count up from 0 for 150 ms (sim time)
- Switch to count down for 150 ms
- Load value 37 
- Count up again from 37 for 150 ms
- `$monitor` prints counter value, load and direction on every change
- `$dumpfile` generates `counter_a_100_tb.vcd` for GTKWave

## Simulation
```bash
iverilog -o sim count.v contador.v clk_divider_parameter.v BCD.v BIN_TO_4DISPLAY.v counter_a_100_tb.v
vvp sim
gtkwave counter_a_100_tb.vcd
```
