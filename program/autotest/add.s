# TAG = add
	.text
	lui x30, 0
	addi x30, x30, 0x007
	lui x27, 0x84739 
    add x31, x27, x30
    add x31, x31, x30
    add x31, x31, x30

	# max_cycle 50
	# pout_start
	# 84739007
	# 8473900E
    # 84739015
	# pout_end
