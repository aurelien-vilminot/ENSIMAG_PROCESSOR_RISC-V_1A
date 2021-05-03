# TAG = srli
	.text

    # Parameters
    lui x29, 0xfffff

    # Basic tests
    srli x31, x29, 1    
    srli x31, x31, 10

    # More 
    srli x31, x31, 10

	# max_cycle 100
	# pout_start
    # 7ffff800
    # 001ffffe
    # 000007ff
	# pout_end
