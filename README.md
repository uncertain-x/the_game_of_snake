# the_game_of_snake
## Use this structure when adding your own module
```
the_game_of_snake/
├── README.md
├── docs/
│   └── interfaces.md
├── srcs/
│   ├── display/
│   │   ├── seven_seg_controller.vhd
│   │   └── vga_control.vhd
│   └── food/
│       └── food_control.vhd
├── testbenches/
│   ├── food_control_tb.vhd
│   └── seven_seg_controller_tb.vhd
├── constrain/
│   └── 02_pins.xdc
└── scripts/
    └── create_project.tcl
```
The current interface contract is documented in `docs/interfaces.md`.

## Create the Vivado project

Open Vivado and run these commands in the Tcl Console:

```
cd ${your_repo_path}
source ./scripts/create_project.tcl
```

Simulation testbenches use VHDL-2008 features, so compile them with VHDL-2008 enabled.
