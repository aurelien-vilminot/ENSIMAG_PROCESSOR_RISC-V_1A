# TAG = jalr
	.text

    lui x31, 0
    jalr x30, 0x00001
    addi x30, x30, 0x008
    jalr x31, 0x004(x30)


	# max_cycle 100
	# pout_start
    # 00000000
    # 00001014
	# pout_end