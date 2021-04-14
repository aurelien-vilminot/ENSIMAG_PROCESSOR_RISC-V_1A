# TAG = bltu
	.text

    lui x31, 0
    lui x29, 0xe2344
    lui x30, 0xe2345
    bltu x29, x30, test_bltu
    addi x31, x31, 0x002

test_bltu:
    addi x31, x31, 0x001
    lui x29, 0xe2345
    bltu x29, x30, test_bltu2
    addi x31, x31, 0x001
    lui x29, 0xe2346
    bltu x30, x29, test_bltu3
    addi x31, x31, 0x044

test_bltu2:
    addi x31, x31, 0x044

test_bltu3:
    addi x31, x31, 0x001

	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000002
    # 00000003
	# pout_end