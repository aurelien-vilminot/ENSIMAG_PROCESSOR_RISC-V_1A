# TAG = sb
	.text
    lui x31, 0
    lui x30, 1
    addi x30, x30, 0x008
    
    add x29, x0, 0x1E8

    sb x29, (x30)
    lw x31, (x30)

	# max_cycle 100
	# pout_start
    # 00000000
    # 000000E8
	# pout_end