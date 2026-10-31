# Architecture

## Module dependency direction

```text
tik_tac_toe_game
├── fsm_controller
├── position_decoder
├── illegal_move_detector
├── nospace_detector
├── position_registers
└── winner_detector
    └── winner_detect_3
```

The top-level module wires the game policy and state. Leaf modules are
combinational detectors/decoders except for `fsm_controller` and
`position_registers`, which are clocked state holders.

## Responsibilities

- `fsm_controller` sequences idle, player, computer, and game-over phases.
- `position_decoder` turns a 0-9 move into a one-hot enable.
- `illegal_move_detector` rejects a move targeting an occupied cell.
- `position_registers` stores the nine two-bit cell states.
- `winner_detector` evaluates rows, columns, and diagonals.
- `nospace_detector` identifies a full board.

The design has no external module dependencies. Board-specific I/O should be
added above `tik_tac_toe_game` rather than embedded in the game logic.
