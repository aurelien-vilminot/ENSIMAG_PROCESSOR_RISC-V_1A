# TAG = auipc
	.text

    lui x31, 0
    auipc x31, 0x00001
    auipc x31, 0x00008
    auipc x31, 0x33333
    
    lui x30, 1

    auipc x31, 0xFFFFE  # Test avec rajout d'instruction précédant auipc

	# max_cycle 100
	# pout_start
    # 00000000
    # 00002004
	# 00009008
    # 3333400c
    # FFFFF014
	# pout_end