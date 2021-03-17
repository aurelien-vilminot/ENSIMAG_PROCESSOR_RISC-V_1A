# TAG = add
	.text

	lui x31, 0
	lui x27, 0x84739 
    addi x13, x0, 0x007
    add x31, x27, x13
    addi x14, x0, 0x008
    add x31, x31, x14

	# max_cycle 50
	# pout_start
	# 00000000
	# 84739007
    # 8473900f
	# pout_end
