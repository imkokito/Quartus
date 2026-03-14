# Prime Number Detector (MAX10) — Combinational Logic + Testbench (Verilog)

This project implements a combinational prime number detector on an Intel MAX10 FPGA using Verilog. It includes:

- `primos`: detects whether a 4-bit input (0–15) is a prime number and drives an LED output.
- `primos_tb`: a testbench that exhaustively tests all 16 possible input values and prints results to the console.

## How it works

1. You set a 4-bit value using `SW[3:0]` (0–15).
2. The circuit evaluates the input combinationally (no clock needed).
3. If the value is a prime number → `LED = 1`.
4. If the value is not prime → `LED = 0`.

Primes detected: **2, 3, 5, 7, 11, 13**

> Note: 4-bit input covers 0–15, so primes 11 and 13 are included but 0, 1, 4, 6, 8, 9, 10, 12, 14, 15 output 0.

## Project structure

- `primos.v`
- `primos_tb.v`
- `primos.qsf`
- `primos.qpf`

## Modules

### `primos`

Combinational prime detector.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `SW` | input | 4 bits | Number to evaluate (0–15) |
| `LED` | output | 1 bit | 1 if prime, 0 otherwise |

Implementation uses a single `assign` with OR conditions for each prime value:
```verilog
assign LED = (SW==4'd2) || (SW==4'd3) || (SW==4'd5) ||
             (SW==4'd7) || (SW==4'd11) || (SW==4'd13);
```

### `primos_tb`

Exhaustive testbench — iterates all 16 input combinations.

- Uses a `for` loop from 0 to 15
- `$monitor` prints every input/output change
- `$display` marks start and end of simulation
- `$stop` pauses simulation for waveform inspection

Expected output:

| SW (decimal) | Prime? | LED |
|:---:|:---:|:---:|
| 0 | No | 0 |
| 1 | No | 0 |
| 2 | Yes | 1 |
| 3 | Yes | 1 |
| 4 | No | 0 |
| 5 | Yes | 1 |
| 6 | No | 0 |
| 7 | Yes | 1 |
| 8–10 | No | 0 |
| 11 | Yes | 1 |
| 12 | No | 0 |
| 13 | Yes | 1 |
| 14–15 | No | 0 |

## Simulation
```bash
iverilog -o primos_sim primos.v primos_tb.v
vvp primos_sim
gtkwave primos_tb.vcd
```

In GTKWave add: `SW[3:0]` and `LED`. Set `SW` to **Decimal** format to read values easily.

## RTL View

The synthesized RTL consists of a multi-input OR gate fed by equality comparators — one per prime value. No flip-flops or clock are involved since the design is purely combinational.
