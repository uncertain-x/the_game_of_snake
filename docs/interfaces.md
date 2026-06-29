# Snake module interfaces

This file defines the initial integration contract for Schaefer's two modules.

## Grid contract

- The game uses a 20 x 15 grid.
- `x` coordinates use the range 0..19.
- `y` coordinates use the range 0..14.
- The outer border is treated as wall space by the game logic.
- The food generator keeps new food inside the playable area: x = 1..18 and y = 1..13.

## `seven_seg_controller`

Purpose: show the current score on the four-digit Basys 3 seven-segment display.

| Port | Direction | Width | Meaning |
|---|---:|---:|---|
| `clk` | in | 1 | 100 MHz board clock |
| `reset` | in | 1 | synchronous active-high reset |
| `score` | in | `std_logic_vector(9 downto 0)` | binary score, displayed as decimal 0..999 |
| `seg` | out | `std_logic_vector(6 downto 0)` | active-low cathodes, `seg(6 downto 0) = g f e d c b a` |
| `an` | out | `std_logic_vector(3 downto 0)` | active-low digit enables, `an(0)` is the rightmost digit |
| `dp` | out | 1 | decimal point, held inactive high |

The controller scans one digit at a time. The active digit changes after `SCAN_DIV` clock cycles.

## `food_control`

Purpose: keep the current food coordinate and generate a new pseudo-random coordinate after the snake eats it.

| Port | Direction | Width | Meaning |
|---|---:|---:|---|
| `clk` | in | 1 | 100 MHz board clock |
| `reset` | in | 1 | synchronous active-high reset |
| `eat` | in | 1 | one-cycle pulse from `snake_control` |
| `food_x` | out | `std_logic_vector(4 downto 0)` | current food x coordinate |
| `food_y` | out | `std_logic_vector(3 downto 0)` | current food y coordinate |

`food_control` does not decide whether the snake has eaten the food. That comparison belongs in `snake_control`.
This first version does not take a snake-body occupancy map.
If `food_control` generates a coordinate on the snake body, `snake_control` should request another coordinate during integration.
The team can also extend this interface after the snake-body storage interface is defined.

## Integration signals expected from teammates

| Signal | Source | Consumer |
|---|---|---|
| `score` | `snake_control` or top-level score counter | `seven_seg_controller` |
| `eat` | `snake_control` | `food_control` |
| `food_x`, `food_y` | `food_control` | `snake_control` and VGA/display logic |
