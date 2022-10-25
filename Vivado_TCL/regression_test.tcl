# run a regression test of the following simulations
set sim_list "sim_1 sim_2 sim_3 sim_4"

# setup
set script_path [ file dirname [ file normalize [ info script ] ] ]
set output_file [ file join $script_path regression_results.txt ]
set timestamp [clock format [clock seconds]]
set results_dict [dict create]
set all_tests_ok true

# simulation runs
foreach sim $sim_list {
	# operate the Vivado simulator and capture the results
	put "USER: $sim"
	launch_simulation -simset $sim
	set test_time [current_time]
	set test_ok [get_value test_ok]
	close_sim -quiet	
	set all_tests_ok [expr {$all_tests_ok && $test_ok}]
	# record the results in a dictionary structure
	set test_result [dict create runtime $test_time test_ok $test_ok]	
	dict append results_dict $sim $test_result	
	# output results to the console
	puts "USER: $test_result"	
}

set conclusion "*** REGRESSION TESTS [expr {$all_tests_ok ? "PASSED" : "FAILED"}] ***"

# outputs results to a logfile
set output_channel [open $output_file w]
puts $output_channel $timestamp
puts $output_channel $conclusion
dict for {key value} $results_dict {
		puts $output_channel $key
		puts $output_channel $value
	}
close $output_channel

puts "USER: $conclusion"