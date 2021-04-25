# TAG = sh
	.text
    lui x31, 0
    lui x29, 1

    lw x30, storage

    sh x30, 50(x29)
    lw x31, 50(x29)

storage:
    .word -1891285

	# max_cycle 100
	# pout_start
    # 00000000
    # FFFF242B
	# pout_end
