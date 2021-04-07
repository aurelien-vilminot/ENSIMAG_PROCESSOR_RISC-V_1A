# TAG = sw
    .data
    p:.word 50

	.text
    lui x31, 0
    lui x30, 0
    addi x30, x30, 0x003

    sw x30, p, x1
    lw x31, p
	# max_cycle 100
	# pout_start
    # 00000000
	# 00000003
	# pout_end