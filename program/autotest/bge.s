# TAG = bge
	.text

    # On verifie que le chemin d'exécution corresponde aux sorties

    # On cherche à éviter la 5eme ins.
    lui x31, 0
    lui x29, 0x12346
    lui x30, 0x12345
    bge x29, x30, test_bge
    addi x31, x31, 0x002

    # On cherche à éviter la dernière ins. en sautant à test_bge3
test_bge:
    addi x31, x31, 0x001
    lui x29, 0x12344
    bge x29, x30, test_bge2
    addi x31, x31, 0x002
    lui x29, 0x12345
    bge x29, x30, test_bge3
    addi x31, x31, 0x045

test_bge2:
    addi x31, x31, 0x045

test_bge3:
    addi x31, x31, 0x001

	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000003
    # 00000004
	# pout_end