# the_game_of_snake
## Please follow the structure to construct own function
```
snake_game/                                     ← Vivado project root directory
├── 
├── srcs/                                       ← Source files directory
│   ├── sources_1/                              ← Design source files
│   │   ├── top/                                ← Top-level files
│   │   │   └── top_snake.vhd                   (Top-level file, instantiates all submodules)
│   │   ├── control/                            ← Control logic
│   │   │   ├── debouncer.vhd                   (Key debouncer)
│   │   │   ├── direction_control.vhd           (Direction control)
│   │   │   └── game_state.vhd                  (Game state machine)
│   │   ├── snake/                              ← Snake logic
│   │   │   ├── snake_control.vhd               (Snake movement, length, coordinate update)
│   │   │   └── snake_body.vhd                  (Snake body storage)
│   │   ├── food/                               ← Food logic
│   │   │   ├── food_control.vhd                (Food generation, position management)
│   │   │   └── food_eat.vhd                    (Food eaten detection)
│   │   ├── display/                            ← Display output
│   │   │   ├── vga_controller.vhd              (VGA timing driver)
│   │   │   ├── display_control.vhd             (Pixel mapping: snake/food/background)
│   │   │   └── seven_seg_controller.vhd        (7-segment display score)
│   │   └── utils/                              ← Utility modules
│   │       ├── game_tick.vhd                   (Game tick frequency divider)
│   │       
│   └── constrs_1/                              ← Constraints files directory
│       ├── 01_clock.xdc                        ★ Clock constraints (loaded first)
│       ├── 02_pins.xdc                         ★ Physical pin assignments
│       ├── 03_vga.xdc                          ★ VGA interface timing constraints
│       ├── 04_keyboard.xdc                     ★ Keyboard/switch constraints
│       ├── 05_display.xdc                      ★ 7-segment display constraints
│       └── 06_timing.xdc                       ★ Timing exceptions (false paths, etc.)
└── ... (other Vivado auto-generated directories, ignored by .gitignore)
```
## Generate project automatically
open the vivado to input this command in Tcl Console

```
cd ${your_repo_path}/snake_game
source snake_game.tcl
```

Note: the script resolves all paths relative to the directory you `cd` into, and it
expects to be sourced from `snake_game/` (where `snake_game.srcs/` lives). Sourcing it
from the repo root will fail with "file does not exist" errors.
If a previous run left a broken project behind, delete `snake_game/snake_game/` first —
re-sourcing the script on top of an existing project errors out on `add_files`.
