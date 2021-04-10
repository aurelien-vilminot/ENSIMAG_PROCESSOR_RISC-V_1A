# TAG = sltu
	.text

    lui x30, 0
    lui x29, 0
    addi x29, x29, 0x001
    sltu x31, x30, x29

    addi x30, x30, 0x001
    sltu x31, x30, x29

    addi x30, x30, 0x003
    sltu x31, x30, x29
    addi x29, x29, 0x045
    sltu x31, x30, x29

	# max_cycle 100
	# pout_start
    # 00000001
	# 00000000
    # 00000000
    # 00000001
	# pout_end