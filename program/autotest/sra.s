# TAG = sra
	.text
    
    # Parameters
	lui x30, 0      
    addi x30, x30, 0x001
    lui x29, 0xfffff

    # Basic tests
    sra x31, x29, x30       
    addi x30, x30, 0x009
    sra x31, x31, x30

    # More
    lui x31, 0x0ffff
    sra x31, x31, x30

	# max_cycle 100
	# pout_start
    # fffff800
    # fffffffe
    # 0ffff000
    # 0003fffc
	# pout_end
