# TAG = lw
	.text
    lui x31, 0
    lui x29, 0
    addi x30, x29, 0x003

    lui x28, 0x00001
    lw x31, 0(x28)
	# max_cycle 100
	# pout_start
    # 00000000
	# 00000fb7
	# pout_end