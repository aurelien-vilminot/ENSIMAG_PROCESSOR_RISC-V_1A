# TAG = sub
	.text
	lui x30, 0
	addi x30, x30, 0x007
	lui x29, 0
	addi x29, x29, 0x002
    lui x31, 0
	sub x31, x30, x29

	# max_cycle 50
	# pout_start
    # 00000000
	# 00000005
	# pout_end