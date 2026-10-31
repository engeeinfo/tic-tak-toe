# Tic-Tac-Toe FPGA Game

Synthesizable Verilog for a nine-cell tic-tac-toe game with player and
computer moves, illegal-move detection, and winner detection.

## Requirements

- Icarus Verilog 11 or newer for simulation
- `make`

The design is simulator-friendly and does not require external HDL libraries.
The target board and pin constraints are not part of this repository yet.

## Run the simulation

```sh
make test
```

The testbench checks the player/computer move sequence, winner reporting, and
the 3-5-7 diagonal regression case.

## Structure

- `tic_tac_toe.v` contains the top-level `tik_tac_toe_game` module and its
  decoders, state machine, position storage, and detectors.
- `tic_tac_toe_game_tb.v` is the self-checking simulation testbench.
- `docs/ARCHITECTURE.md` describes module responsibilities and dependency
  direction.
- `docs/MODERNIZATION.md` records the baseline, audit, and changes.

## Interface

The top-level module accepts a clock, asynchronous reset, player/computer
control signals, and 0-9 positions. It exposes nine two-bit cell states and
the winning player. Cell values are `2'b00` for empty, `2'b01` for player,
and `2'b10` for computer.

## Contributing

Keep synthesizable logic in `tic_tac_toe.v`, add a failing regression before
fixing a behavior defect, and run `make test` before submitting a change.
