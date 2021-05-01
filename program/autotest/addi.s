# TAG = addi
	.text

	# Classic test
    addi x31, x0, 0x008
	addi x31, x31, 0
    addi x31, x31, -1

	# From an other register
    lui x5, 0x13427
    addi x31, x5, 0x007

	# max_cycle 50
	# pout_start
	# 00000008
	# 00000008
	# 00000007
    # 13427007
	# pout_end
