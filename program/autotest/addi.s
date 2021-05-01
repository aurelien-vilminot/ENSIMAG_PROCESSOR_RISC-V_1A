# TAG = addi
	.text

	lui x31, 0       		#Test chargement d'une valeur nulle
    addi x31, x31, 0x008
	addi x31, x31, 0
    addi x31, x31, -1

    lui x27, 0x13427
    addi x31, x27, 0x007

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000008
	# 00000008
	# 00000007
    # 13427007
	# pout_end
