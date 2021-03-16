# Gathering TCL args
set DEVICE [lindex $argv 0]
set TOP    [lindex $argv 1]

source ../config/open_ps_link_bd.tcl

source ../config/read_prj.vivado.tcl
source ../config/reportCriticalPaths.tcl

set_param general.maxThreads 4

# Create Project
read_prj ../config/${TOP}.prj

# Detect XPM memory
auto_detect_xpm

synth_design -top ${TOP} -part ${DEVICE} -fanout_limit 100 
#-flatten_hierarchy none 
#-directive RuntimeOptimized
#write_checkpoint -force synth_design.dcp

# Reading constraint file (.xdc file)
read_xdc ../config/${TOP}_${DEVICE}.xdc

# Run logic optimization
opt_design
#write_checkpoint opt_design.dcp

# Placing
place_design
# -directive Quick
#write_checkpoint synth_place.dcp

# Routing
route_design -ultrathreads
# -directive Quick
#write_checkpoint synth_route.dcp

# Reports
report_timing            -file ${TOP}_timing.rpt
report_timing_summary -max_paths 500 -nworst 1 -input_pins -file ${TOP}_timing_summary.rpt
report_utilization       -file ${TOP}_utilization_opt.rpt
report_critical_paths	 	   ${TOP}_critpath_report.csv
report_route_status		 -file ${TOP}_route_status.rpt
report_design_analysis   -file ${TOP}_design_analysis.rpt
report_io                -file ${TOP}_io_opt.rpt
report_drc -file ${TOP}_drc_route.rpt
report_clock_interaction -file ${TOP}_clock_interaction_opt.rpt

# Generate MMI map
write_mem_info -force -verbose map.mmi

# Create bitstream
write_bitstream -force ../bit/${TOP}.bit

