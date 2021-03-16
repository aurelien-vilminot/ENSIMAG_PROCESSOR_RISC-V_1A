
if {[info exists ::env(TIME)]} {
	set sim_time $env(TIME)
} else {
	set sim_time 5ns
}

if {[info exists ::env(VCD_FILE)]} {
	set sim_vcd  $env(VCD_FILE)
} else {
	set sim_vcd out.vcd
}

put "simulation time  $sim_time"
put "vcd wave file    $sim_vcd"
open_vcd $sim_vcd

log_vcd [get_scopes -r]
log_wave [get_scopes -r]

run $sim_time

close_vcd

exit
