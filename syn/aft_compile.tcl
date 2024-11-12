compile_ultra -gate_clock -no_autoungroup


set_fix_multiple_port_nets -all -buffer_constants

set_app_var uniquify_naming_style "digital_top_%s_%d"
uniquify -force

define_name_rules verilog -case_insensitive
change_names -rules verilog -hierarchy -verbose > ../reports/change_names

set_app_var verilogout_higher_designs_first true
set_app_var verilogout_no_tri true

write_file -format ddc -hierarchy -o "../result/syn_top.ddc"
write_file -format verilog -hierarchy -o "../result/netlist.v"

write_sdc -version 1.7 -nosplit ../result/fft.sdc
check_design -multiple_designs > ../reports/check_design

check_timing 						> ../reports/check_timing
report_qor 							> ../reports/gor
report_timing -delay max -max_paths 10 -nosplit -path full_clock_expanded -nets -transition_time -input_pins -derate \
									> ../reports/timing-max
report_area -hierarchy -physical -designware \
									> ../reports/area
report_power -nosplit				> ../reports/power
report_constraint -all_violators -nosplit \
									> ../reports/constraint_violators
report_design 						> ../reports/design
report_clocks -attributes -skew 	> ../reports/clocks
report_clock_gating -multi_stage -verbose -gated -ungated \
									> ../reports/clock_gating
report_clock_tree -summary -settings -structure \
									> ../reports/clock_tree
query_objects -truncate 0 [all_registers -level_sensitive ] \
									> ../reports/latches
report_isolate_ports -nosplit 		> ../reports/isolate_ports
report_net_fanout -threshold 32 	> ../reports/high_fanout_nets
report_port -verbose -nosplit 		> ../reports/port
report_hierarchy 					> ../reports/hierarchy
report_resources -hierarchy 		> ../reports/resources
report_compile_options 				> ../reports/compile_options
report_congestion 					> ../reports/congestion
gui_start
