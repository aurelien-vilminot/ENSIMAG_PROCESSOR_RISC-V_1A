
# Assemble the Design Source files
read_vhdl [glob ../vhd/hdmi/*.vhd]
read_vhdl [glob ../vhd/axi/*.vhd]

read_xdc ../config/PROC_xc7z010clg400-1.xdc
set_property PART xc7z010clg400-1  [current_project]

set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

# Set project properties
set obj [current_project]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7z010clg400-1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

#set ip repository path
set_property IP_REPO_PATHS ../ip_rep [current_fileset ]
update_ip_catalog

source ../config/ps_link.tcl
generate_target all [get_files bd/PS_Link/PS_Link.bd]
read_vhdl -library work [glob bd/PS_Link/hdl/PS_Link_wrapper.vhd]

