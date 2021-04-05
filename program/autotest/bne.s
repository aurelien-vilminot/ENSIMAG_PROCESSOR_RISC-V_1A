# TAG = bne
	.text

    lui x31, 0
    lui x29, 0x12346
    lui x30, 0x12345
    bne x29, x30, test_bne
    addi x31, x31, 0x002

test_bne:
    addi x31, x31, 0x001
    lui x29, 0x12345
    bne x29, x30, test_bne2
    addi x31, x31, 0x001
    lui x29, 0x12344
    bne x29, x30, test_bne3
    addi x31, x31, 0x045

test_bne2:
    addi x31, x31, 0x045

test_bne3:
    addi x31, x31, 0x002

	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000002
    # 00000004
	# pout_end