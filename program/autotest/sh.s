# TAG = sh
	.text
    lui x31, 0
    lui x30, 1
    addi x30, x30, 0x008
    
    lui x29, 0x1E8

    sh x29, (x30)
    lw x31, (x30)

	# max_cycle 100
	# pout_start
    # 00000000
    # 00008000
	# pout_end
