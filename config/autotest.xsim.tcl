
if {[info exists ::env(TESTS)]} {
	set string_test $env(TESTS)
} else {
	set string_test 
}


set tests [regexp -all -inline -- {\S+} $string_test]
puts $string_test
puts $tests

foreach test $tests {
	put "Preparing test: ${test}"
	file delete test_default.out test_default.irq test_default.setup test_default.mem
	file link -symbolic test_default.out   ${test}/test_default.out
	file link -symbolic test_default.irq   ${test}/test_default.irq
	file link -symbolic test_default.setup ${test}/test_default.setup
	file link -symbolic test_default.mem   ../mem/${test}.mem

	put "Running test: ${test}"
	restart
	run -all
	file copy -force test_default.res  ${test}
	file copy -force test_default.test ${test}
}

exit

