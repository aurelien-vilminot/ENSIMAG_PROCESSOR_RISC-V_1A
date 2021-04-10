# TAG = sltiu
	.text

    lui x30, 0
    sltiu x31, x30, 0x001

    addi x30, x30, 0x001
    slti x31, x30, 0x001

    addi x30, x30, 0x003
    slti x31, x30, 0x001
    slti x31, x30, 0x045

	# max_cycle 100
	# pout_start
    # 00000001
	# 00000000
    # 00000000
    # 00000001
	# pout_end