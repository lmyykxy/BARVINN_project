set_host_options -max_cores 16

set dontuse_ref " \
	*/DEL* \
	*/FIL* \
	*/ANT* \
	*/TIEO* \
	*/TIE1* \
	*/CK* \
	"

set dontuse_cell [get_lib_cells $dontuse_ref]
set_attribute $dontuse_cell dont_use true

set_svf ../result/mvutop_wrapper.svf
saif_map -start
set_app_var hdlin_vrlg_std 2001
set_app_var compile_seqmap_propagate_constants false
set_app_var power_cg_auto_identify true
set_app_var hdlin_check_no_latch true
define_design_lib work -path elab

analyze -format sverilog -vcs "-f /storage1/2024contest/server2_06/s2_06_fe/Desktop/11_12/BARVINN_project/syn/script/filelist.f"
elaborate mvutop_wrapper
set_register_merging [get_designs mvutop_wrapper] false
link

# set_clock_gating_style \
# 	-sequential cell latch \
# 	-positive_edge_logic {integrated:CKLNQD20BWP40P140} \
# 	-control_point before \
# 	-control_signal scan_enable \
# 	-num_stages 3 \
# 	-max_fanout 8 \
# 	-minimum_bitwidth 4

source /storage1/2024contest/server2_06/s2_06_fe/Desktop/11_12/BARVINN_project/syn/script/sys.sdc
check_design -no_warnings
