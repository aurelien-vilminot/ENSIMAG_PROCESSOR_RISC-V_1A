# TAG = auipc
	.text

    lui x31, 0
    auipc x31, 0x00001
    auipc x31, 0x00008

	# max_cycle 100
	# pout_start
    # 00000000
    # 00002008
	# 0000900c
	# pout_end