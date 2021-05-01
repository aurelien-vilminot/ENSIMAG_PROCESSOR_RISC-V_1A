# TAG = jal
	.text
    
    # On cherche à éviter test_jal_a_sauter et la 3eme ins.s
    lui x31, 0
    jal x31, test_jal
    addi x31, x31, 0x002

test_jal_a_sauter:
    addi x31, x31, 0x002

test_jal:
    addi x31, x31, 0x001

	# max_cycle 100
	# pout_start
    # 00000000
    # 00001008
    # 00001009
	# pout_end