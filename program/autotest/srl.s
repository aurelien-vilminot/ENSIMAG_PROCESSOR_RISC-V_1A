# TAG = srl
	.text

    # Parameters
	lui x30, 0       
    addi x30, x30, 0x001
    lui x29, 0xfffff

    # Basic tests
    srl x31, x29, x30      
    addi x30, x30, 0x009
    srl x31, x31, x30

    # More 
    srl x31, x31, x30

	# max_cycle 100
	# pout_start
    # 7ffff800
    # 001ffffe
    # 000007ff
	# pout_end
