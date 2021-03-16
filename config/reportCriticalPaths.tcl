proc report_critical_paths { filename } {

	# Open the specified output file in write mode
	set FH [open $filename w]
	# Write the current date and CSV format to a file header
	puts $FH "#\n# File created on [clock format [clock seconds]]\n#\n"
	puts $FH "Startpoint,Endpoint,Slack,#Levels,#LUTs"
	# Collect details from the 50 worst timing paths for the current analysis 
	# The $path variable contains a Timing Path object.
	foreach path [get_timing_paths -max_paths 500 -nworst 1] {
		# Get the LUT cells of the timing paths
		set luts [get_cells -filter {REF_NAME =~ LUT*} -of_object $path]
		# Get the startpoint of the Timing Path object
		set startpoint [get_property STARTPOINT_PIN $path]
		# Get the endpoint of the Timing Path object
		set endpoint [get_property ENDPOINT_PIN $path]
		# Get the slack on the Timing Path object
		set slack [get_property SLACK $path]
		# Get the number of logic levels between startpoint and endpoint
		set levels [get_property LOGIC_LEVELS $path]
		# Save the collected path details to the CSV file
		puts $FH "$startpoint,$endpoint,$slack,$levels,[llength $luts]"
	}
	# Close the output file
	close $FH
	puts "CSV file $filename has been created.\n"
	return 0
}; # End PROC
