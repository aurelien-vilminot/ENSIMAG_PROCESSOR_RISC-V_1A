# TAG = jal
	.text

    lui x31, 0
    jal x30, test_jal
    addi x31, x31, 0x002

test_jal_a_sauter:
    addi x31, x31, 0x002

test_jal:
    addi x31, x31, 0x001
    addi x31, x30, 0

	# max_cycle 100
	# pout_start
    # 00000000
    # 00000001
    # 00001008
	# pout_end