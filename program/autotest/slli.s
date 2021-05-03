# TAG = slli

	.text
    # Parameters
    lui x29, 0xfffff

    # Basic tests
    slli x31, x29, 1
    slli x31, x29, 8  

    # More complicated
    lui x31, 0x80000
    sll x31, x31, 1


	# max_cycle 100
	# pout_start
    # ffffe000
    # fff00000
    # 80000000
    # 00000000
	# pout_end
