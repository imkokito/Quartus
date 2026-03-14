# VGA Signal Generator using the MAX10

This project implements a VGA signal generator on a MAX10 FPGA using Verilog. It displays a checkerboard pattern on a monitor using the standard 640×480 @ 60Hz VGA timing.

- `vga`: generates the horizontal and vertical sync signals and tracks the current pixel position.
- `vga_demo`: top-level module that drives the pixel color based on the current position, producing a checkerboard pattern.

## How it works

1. The 50 MHz clock is divided by 2 with a `pixel_tick` toggle, producing a 25 MHz pixel clock — the standard pixel rate for 640×480 @ 60Hz VGA.
2. `vga` counts pixels horizontally (0–799) and lines vertically (0–524), covering both the visible area and the blanking intervals.
3. Sync pulses are generated at the correct positions within the blanking intervals.
4. Inside the visible area (640×480), the pixel color is determined by XORing bit 5 of `CounterX` and `CounterY`, which creates a checkerboard of 32×32 pixel squares.
5. Outside the visible area the pixel is forced to black.

VGA timing (640×480 @ 60Hz):

| Region | Horizontal | Vertical |
|--------|-----------|----------|
| Visible area | 640 px | 480 lines |
| Front porch | 16 px | 10 lines |
| Sync pulse | 96 px | 2 lines |
| Back porch | 48 px | 33 lines |
| **Total** | **800 px** | **525 lines** |

## Project structure

- `vga.v`
- `vga_demo.v`
- `vga_demo.qsf`

## Modules

### `vga`

Generates VGA sync signals and pixel counters.

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | input | 50 MHz clock |
| `pixel_tick` | input | 25 MHz enable pulse (1 every 2 cycles) |
| `vga_h_sync` | output | Horizontal sync (active-low) |
| `vga_v_sync` | output | Vertical sync (active-low) |
| `inDisplayArea` | output | 1 when current pixel is in the visible area |
| `CounterX[9:0]` | output | Current horizontal pixel position (0–799) |
| `CounterY[9:0]` | output | Current vertical line position (0–524) |

`CounterX` increments every `pixel_tick`. When it reaches 799 it resets to 0 and `CounterY` advances by one. When `CounterY` reaches 524 it resets to 0, completing one full frame at 60Hz.

Sync pulses are generated in the blanking region:
```verilog
vga_HS <= (CounterX >= 656) && (CounterX < 752);  // 96 px pulse
vga_VS <= (CounterY >= 490) && (CounterY < 492);  // 2 line pulse
```

### `vga_demo`

Top-level wrapper that generates the checkerboard pattern.

| Port | Direction | Description |
|------|-----------|-------------|
| `MAX10_CLK1_50` | input | 50 MHz board clock |
| `pixel[2:0]` | output | RGB pixel color |
| `hsync_out` | output | Horizontal sync to VGA connector |
| `vsync_out` | output | Vertical sync to VGA connector |

The checkerboard pattern is generated with a single XOR:
```verilog
if (CounterX[5] ^ CounterY[5])
    pixel <= 3'b111;  // white
else
    pixel <= 3'b000;  // black
```

Bit 5 of each counter changes every 32 pixels, so each square in the pattern is 32×32 pixels.
