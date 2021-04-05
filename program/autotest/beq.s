# TAG = beq
	.text

    lui x31, 0
    lui x29, 0x12345
    lui x30, 0x12345
    beq x29, x30, test_beq
    addi x31, x31, 0x002

test_beq2:
    addi x31, x31, 0x045

test_beq3:
    addi x31, x31, 0x044

test_beq:
    addi x31, x31, 0x001
    lui x29, 0x12346
    beq x29, x30, test_beq2
    addi x31, x31, 0x002
    lui x29, 0x12344
    beq x29, x30, test_beq3
    addi x31, x31, 0x002


	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000003
    # 00000005
	# pout_end