# PWM Signal Generator using the MAX10

This project implements a PWM (Pulse Width Modulation) signal generator on a MAX10 FPGA using Verilog. It includes:

- `counter`: counts clock cycles to set the PWM period.
- `comparador`: compares the counter value against a threshold to generate the PWM pulse width.
- `pwm_maybe`: top-level module that connects the clock divider, PWM generator and displays.
- `clk_divider_parameter`: divides the 50 MHz board clock to 5 MHz.
- `BCD`: converts a single 4-bit digit (0–9) into a 7-segment output pattern.
- `BIN_TO_4DISPLAY`: splits a binary number into 4 decimal digits and drives 4 displays.
- `pwm_maybe_tb`: testbench that runs the PWM at 0°, 90° and 180° positions.

## How it works

1. You set an angle (0–180) using `SW[7:0]`.
2. The input is limited to 180.
3. `comparador` maps the angle to a pulse width between the minimum (3%) and maximum (12%) duty cycle, matching the servo motor timing.
4. The PWM signal is output through `ARDUINO_IO`.
5. The current angle value is shown across `HEX3–HEX0`.

Duty cycle range:
- SW = 0 → ~3% duty cycle (servo at 0°)
- SW = 90 → ~7.5% duty cycle (servo at 90°)
- SW = 180 → ~12% duty cycle (servo at 180°)

## Project structure

- `counter.v`
- `comparador.v`
- `pwm_maybe.v`
- `clk_divider_parameter.v`
- `BCD.v`
- `BIN_TO_4DISPLAY.v`
- `pwm_maybe_tb.v`
- `pwm_maybe.qsf`

## Modules

### `counter #(parameter pwm=50, parameter CLK_FREQ=5_000_000)`

Free-running counter that sets the PWM period.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | Clock |
| `rst` | input | reset |
| `counter[16:0]` | output | Current count value |

Counts from 0 to `CLK_FREQ/pwm` and resets, producing a period of 20 ms at 50 Hz.

### `comparador #(parameter pwm=50, parameter CLK_FREQ=5_000_000)`

Generates the PWM output by comparing the counter against a computed threshold.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | Clock |
| `rst` | input | reset |
| `in[7:0]` | input | Angle (0–180) |
| `out` | output | PWM signal |

The threshold is calculated as:
```verilog
localparam min = ((CLK_FREQ/pwm)*3)/100;   // 3% of period
localparam max = ((CLK_FREQ/pwm)*12)/100;  // 12% of period
localparam m   = (max-min)/180;            // slope per degree
comp = min + (in * m);
```

Output is `1` while `counter < comp`, and `0` otherwise.

### `pwm_maybe`

Top-level wrapper for the FPGA board.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[0] = reset |
| `SW[7:0]` | input | Angle (0–180) |
| `ARDUINO_IO` | output | PWM signal output |
| `HEX0–HEX3` | output | Current angle on display |
| `HEX4–HEX5` | output | Always off |

### `clk_divider_parameter`

Used here at 5 MHz instead of the usual 5 Hz to generate the PWM base clock. See [Up/Down Counter](../Practica3/README.md) for full description.

### `BCD`

Single digit (0–9) to 7-segment decoder. See [BCD to 7-Segment Display](../Practica2/README.md) for full description.

### `BIN_TO_4DISPLAY`

Splits a binary number into 4 decimal digits and drives 4 displays. See [BCD to 7-Segment Display](../Practica2/README.md) for full description.

### `pwm_maybe_tb`

Testbench — tests 3 angle positions.

- SW = 0 → minimum duty cycle (~3%)
- SW = 90 → mid duty cycle (~7.5%)
- SW = 180 → maximum duty cycle (~12%)
- Each case runs for 20 ms of simulation time to capture full PWM periods
- `$dumpfile` generates `pwm_maybe_tb.vcd` for GTKWave

## Simulation
```bash
iverilog -o sim counter.v comparador.v pwm_maybe.v clk_divider_parameter.v BCD.v BIN_TO_4DISPLAY.v pwm_maybe_tb.v
vvp sim
gtkwave pwm_maybe_tb.vcd
```
