#####CLK PERIOD CAN BE ADJUSTED UP TO 14.0 IF SYNTHESIS GOES WRONG#####
create_clock -name clk -period 13.0 [get_ports clk]
create_clock -name clk2 -period 100.0 [get_ports clk2]
set_clock_groups -asynchronous -group {clk} -group {clk2}
set_dont_touch_network      [all_clocks]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      1.0  [all_clocks]
set_ideal_network           [get_ports {clk clk2}]

#####REMEMBER TO SET THIS MAX DELAY TO 1/2 CLK PERIOD#####
set_input_delay  -max 6.5  -clock clk [remove_from_collection [all_inputs] [get_ports {clk clk2}]]
set_input_delay  -min  0.0  -clock clk [remove_from_collection [all_inputs] [get_ports {clk clk2}]]
set_output_delay -max 6.5  -clock clk [all_outputs]
set_output_delay -min  0.0  -clock clk [all_outputs]

set_driving_cell -library fsa0m_a_t33_generic_io_ss1p62v125c -lib_cell XMD -pin {O} [all_inputs]
#set_drive 0.1  [all_inputs]
set_load  0.05 [all_outputs]

set_operating_conditions -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM -min_library fsa0m_a_generic_core_ff1p98vm40c -min BCCOM
set auto_wire_load_selection

set_max_fanout 6 [all_inputs]
