
# Assemble the Design Source files
read_vhdl [glob ../vhd/*.vhd]
read_xdc ../config/HDMI_simple_xc7z010clg400-1.xdc
set_property PART xc7z010clg400-1  [current_project]

set_property source_mgmt_mode All [current_project]

# Set project properties
set obj [current_project]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7z010clg400-1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

#set ip repository path
set_property IP_REPO_PATHS ./ip_rep [current_fileset ]
update_ip_catalog

source ps_link.tcl
generate_target all [get_files bd/PS_Link/PS_Link.bd]
read_vhdl -library work [glob bd/PS_Link/hdl/PS_Link_wrapper.vhd]

set_property source_mgmt_mode All [current_project]

set outputDir ./output
file mkdir $outputDir

update_compile_order

synth_design -top HDMI_ENV -part xc7z010clg400-1
opt_design
place_design
route_design

write_bitstream -force -file $outputDir/output.bit
