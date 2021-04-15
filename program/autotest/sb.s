# TAG = sb
	.text
    lui x31, 0 # 0x1000
    lui x30, 1 # 0x1004
    addi x30, x30, 0x020 # 0x1008
    
    addi x29, x29, 0x0B7 # 0x100c

    lui x1, 15 # 0x1010
    add x31, x0, x1 # 0x1014

    sb x29, (x30) # 0x1018
    lui x31,2 # 0x101C
    lui x31,5 # 0x1020
    add x31, x0, x1 # 0x1024
    lui x31,3 # 0x1028

	# max_cycle 100
	# pout_start
    # 00000000
    # 0000F000
    # 00002000
    # 00000000
    # 00003000
	# pout_end