# TAG = sb
	.text
    lui x31, 0
    lui x29, 1

    lw x30, storage

    sb x30, 40(x29)
    lw x31, 40(x29)

storage:
    .word -1525522

	# max_cycle 100
	# pout_start
    # 00000000
    # FFFFFFEE
	# pout_end
