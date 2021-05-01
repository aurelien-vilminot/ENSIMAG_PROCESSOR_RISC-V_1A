# TAG = blt
	.text

    # On verifie que le chemin d'exécution corresponde aux sorties

    # On cherche à éviter la 5eme ins.
    lui x31, 0
    lui x29, 0x12344
    lui x30, 0x12345
    blt x29, x30, test_blt
    addi x31, x31, 0x002

    # On cherche à sauter à test_blt3
test_blt:
    addi x31, x31, 0x001
    lui x29, 0x012345
    blt x29, x30, test_blt2
    addi x31, x31, 0x001
    lui x29, 0x12346
    blt x30, x29, test_blt3
    addi x31, x31, 0x045

test_blt2:
    addi x31, x31, 0x045

test_blt3:
    addi x31, x31, 0x002
	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000002
    # 00000004
	# pout_end