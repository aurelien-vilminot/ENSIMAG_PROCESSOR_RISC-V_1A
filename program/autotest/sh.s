# TAG = sh
	.text
    lui x31, 0 # 0x1000
    lui x30, 1 # 0x1004
    addi x30, x30, 0x024 # 0x1008
    
    lui x29, 14 # 0x100c
    addi x29, x29, 0x7DB # 0x1010
    addi x29, x29, 0x7DB # 0x1014
    addi x29, x29, 0x001 # 0x1018

    sh x29, (x30) # 0x101C
    lui x31,2 # 0x1020
    lui x31,5 # 0x1024
    lui x31,3 # 0x1028

	# max_cycle 100
	# pout_start
    # 00000000
    # 00002000
    # 0000E000
    # 00003000
	# pout_end