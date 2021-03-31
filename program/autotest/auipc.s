# TAG = auipc
	.text

    lui x31, 0
    auipc x31, 0x00001
    auipc x31, 0x00008
    auipc x31, 0x33333

	# max_cycle 100
	# pout_start
    # 00000000
    # 00002004
	# 00009008
    # 3333400c
	# pout_end