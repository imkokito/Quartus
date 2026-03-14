# Accelerometer-Based Robotic Arm Controller using the MAX10

This project implements a robotic arm controller on a DE10-Lite (Intel MAX10) FPGA using Verilog. It reads motion data from the onboard accelerometer, converts it into angle values, and generates PWM signals to control the joints and gripper of a robotic arm. The system supports two control modes: live accelerometer input and automatic playback of saved positions.

## How it works

1. The onboard accelerometer sends raw X, Y, Z motion data through an SPI interface.
2. The data is sampled at 100 Hz and converted into angle values (0–180°) for each axis.
3. `SW[0]` selects the control mode:
   - **Live mode** (`SW[0]=0`): the arm follows the accelerometer in real time.
   - **Playback mode** (`SW[0]=1`): the arm replays positions previously saved in memory.
4. `SW[1]` controls the gripper: open or closed.
5. Pressing `KEY[1]` saves the current position to memory (up to 8 positions).
6. Four PWM signals are output through `ARDUINO_IO[0–3]` to drive the servo motors.
7. The current angles are shown on the VGA display and the memory address is shown on `HEX0–HEX2`.

## Project structure

- `accel.v` — top-level module
- `comparador.v` — angle conversion and PWM generation
- `counter.v` — PWM period counter
- `counter_mem.v` — memory address counter
- `fsm_brazo.v` — control mode FSM
- `mem.v` — position memory (8 slots × 32 bits)
- `one_shot.v` — button edge detector
- `tick_1hz.v` — 1 Hz tick generator for playback
- `hvsync_generator.v` — VGA sync signal generator
- `VGACounterDemo.v` — VGA angle display
- `clk_divider_parameter.v` — parameterized clock divider
- `seg7.v` — 7-segment display decoder
- `PLL.v` — Quartus IP clock generator
- `spi_control.v` — accelerometer SPI interface (Quartus IP)
- `font_rom.v` — character ROM for VGA text rendering
- `accel.qsf`

## Modules

### `accel`

Top-level module. Connects all subsystems and maps them to the FPGA board pins.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `KEY[1:0]` | input | KEY[0] = reset, KEY[1] = save position |
| `SW[9:0]` | input | SW[0] = mode, SW[1] = gripper |
| `ARDUINO_IO[3:0]` | output | PWM outputs for Z, Y, X, gripper |
| `HEX0–HEX5` | output | 7-segment displays |
| `LEDR[9:0]` | output | Shows raw Z axis data |
| `VGA_R/G/B` | output | VGA color output |
| `VGA_HS/VS` | output | VGA sync signals |
| `GSENSOR_*` | inout | Accelerometer SPI interface |

### `comparador`

Converts raw accelerometer data into angles and generates the four PWM outputs.

| Port | Direction | Description |
|------|-----------|-------------|
| `data_x/y/z_reg[19:0]` | input | Raw accelerometer data |
| `garra` | input | Gripper control (SW[1]) |
| `selector` | input | Mode selector (SW[0]) |
| `angle_x/y/z/g_mem[7:0]` | input | Angles from memory (playback mode) |
| `angle_x/y/z/g[7:0]` | output | Computed or selected angles |
| `out_x/y/z/g` | output | PWM signals |

Angle conversion from raw accelerometer data:
```verilog
angle_x_calc = 90 + (data_x_reg >>> 2);
```

Mode selection between live and playback:
```verilog
assign angle_x = selector ? angle_x_mem : angle_x_calc;
```

PWM generation uses the same comparator method as [comparador](../Practica5/README.md).

### `counter`

PWM period counter. See [counter](../Practica5/README.md) for full description.

### `counter_mem`

Increments the memory address used to store or replay arm positions.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | Clock |
| `rst` | input | Async reset |
| `avanzar` | input | Advance address signal |
| `count[2:0]` | output | Current address (0–7) |

In live mode, advances on each button press. In playback mode, advances on each 1 Hz tick automatically.

### `fsm_brazo`

Controls the operating mode of the system.

| Port | Direction | Description |
|------|-----------|-------------|
| `selector` | input | SW[0]: 0 = manual, 1 = playback |
| `guardar` | input | Save pulse from one_shot |
| `guardar_dato` | output | Enable write to memory |
| `habilitar_contador` | output | Enable address counter |
| `state[1:0]` | output | Current state |

States: `MANUAL → GUARDADO → MANUAL` or `MANUAL → AUTOMATICO`

- **MANUAL**: arm follows accelerometer, waiting for save or mode switch.
- **GUARDADO**: writes current position to memory for one cycle, then returns to MANUAL.
- **AUTOMATICO**: replays stored positions automatically until `SW[0]` is cleared.

### `mem`

Stores up to 8 robotic arm positions. Each position is a 32-bit word packed as:
```verilog
data_in = {angle_x, angle_y, angle_z, angle_g};  // 8 bits each
```

| Port | Direction | Description |
|------|-----------|-------------|
| `guardar_dato` | input | Write enable |
| `addr[2:0]` | input | Address (0–7) |
| `data_in[31:0]` | input | Position to store |
| `data_out[31:0]` | output | Position at current address |

### `one_shot`

Detects the rising edge of a button press and outputs a single-cycle pulse, preventing a held button from triggering multiple saves.

| Port | Direction | Description |
|------|-----------|-------------|
| `btn` | input | Raw button signal |
| `pulse` | output | Single-cycle pulse on rising edge |

### `tick_1hz`

Generates a 1 Hz tick used to automatically advance the memory address during playback mode.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz clock |
| `rst` | input | Async reset |
| `tick` | output | Single-cycle pulse at 1 Hz |

### `hvsync_generator`

Generates VGA sync signals and pixel counters. See [VGA Signal Generator](../Practica6/README.md) for full description.

### `VGACounterDemo`

Displays the current X, Y, Z and gripper angles as text on the VGA monitor.

| Port | Direction | Description |
|------|-----------|-------------|
| `angle_x/y/z/g[7:0]` | input | Current angles to display |
| `pixel[2:0]` | output | RGB pixel color |
| `hsync_out/vsync_out` | output | VGA sync signals |

Renders 4 lines of text in a 48×64 pixel area at position (200, 250) on screen using a character ROM (`font_rom`). Each line shows the label (x/y/z/g) followed by its 3-digit decimal value.

### `clk_divider_parameter`

Divides the 25 MHz PLL clock to a slower frequency. See [clk_divider_parameter](../Practica3/README.md) for full description.

### `seg7`

7-segment display decoder. See [BCD](../Practica2/README.md) for full description.

### `PLL`

Quartus IP block that generates the internal clocks from the 50 MHz board clock:

| Output | Frequency | Use |
|--------|-----------|-----|
| `c0` | 25 MHz | Main system clock |
| `c1` | 2 MHz | SPI clock |
| `c2` | 2 MHz (270° phase) | SPI clock output |

## How to compile

Open the project in Quartus Prime and compile `accel.qsf`. Make sure all `.v` files and the `font_rom` IP are included in the project before compiling.

## Dependencies

The following modules are required and must be present in the project:

- `PLL.v` — generated by Quartus IP Catalog
- `spi_control.v` — accelerometer SPI controller
- `font_rom.v` — character bitmap ROM for VGA text
