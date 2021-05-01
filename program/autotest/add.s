# TAG = add
	.text
	# Parameters
	lui x5, 0
	addi x5, x5, 7
	lui x6, 0x84739
	lui x7, 0xfffff

	# Tests 
    add x31, x5, x6
    add x31, x31, x5
    add x31, x31, x5

	# Test negativ sum
	lui x5, 0
	addi x5, x5, -1
	add x31, x31, x5

	# Test overflow
	lui x5, 0x00001
	add x31, x7, x5

	# max_cycle 50
	# pout_start
	# 84739007
	# 8473900E
    # 84739015
	# 84739014
	# 00000000
	# pout_end
