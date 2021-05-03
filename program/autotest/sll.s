# TAG = sll
	.text
    # Parameters
    lui x29, 0xfffff
	lui x30, 0       
    addi x30, x30, 0x001

    # Basic tests
    sll x31, x29, x30
    addi x30, x30, 0x007
    sll x31, x29, x30  

    # More complicated
    lui x31, 0x80000
    sll x31, x31, x30


	# max_cycle 100
	# pout_start
    # ffffe000
    # fff00000
    # 80000000
    # 00000000
	# pout_end
