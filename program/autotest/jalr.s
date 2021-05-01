# TAG = jalr
	.text

    # Parameters
    lui x31, 0
    lui x5, 0x0001

    # Basic test
    jalr x31, 0x010(x5) 
    lui x31, 0
    addi x31, x31, 0x002

    # Test of constant low-weight bit = 0
    addi x5, x5, 0x020
    jalr x31, 0x001(x5)
    lui x31, 0
    addi x31, x31, 0x002

	# max_cycle 100
	# pout_start
    # 00000000
    # 0000100c
    # 0000100e
    # 0000101c
    # 0000101e
	# pout_end