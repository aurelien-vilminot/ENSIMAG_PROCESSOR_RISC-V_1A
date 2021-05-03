# TAG = srai
	.text

    # Parameters
    lui x29, 0xfffff

    # Basic tests
    srai x31, x29, 1     
    srai x31, x31, 10

    # More
    lui x31, 0x0ffff
    srai x31, x31, 10

	# max_cycle 100
	# pout_start
    # fffff800
    # fffffffe
    # 0ffff000
    # 0003fffc
	# pout_end
