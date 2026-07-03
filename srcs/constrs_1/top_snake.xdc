#  clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin [get_ports clk]

# SW0  reset
set_property PACKAGE_PIN V17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]



#up
set_property PACKAGE_PIN T17 [get_ports btn_up]
set_property IOSTANDARD LVCMOS33 [get_ports btn_up]

#down
set_property PACKAGE_PIN W19 [get_ports btn_down]
set_property IOSTANDARD LVCMOS33 [get_ports btn_down]

#left
set_property PACKAGE_PIN U18 [get_ports btn_left]
set_property IOSTANDARD LVCMOS33 [get_ports btn_left]

#right
set_property PACKAGE_PIN T18 [get_ports btn_right]
set_property IOSTANDARD LVCMOS33 [get_ports btn_right]

# BTNC  start
set_property PACKAGE_PIN U17 [get_ports btn_start]
set_property IOSTANDARD LVCMOS33 [get_ports btn_start]