# TAG = beq
	.text

    # On verifie que le chemin d'exécution corresponde aux sorties

    # On cherche à éviter la 5eme ins.
    lui x31, 0
    lui x5, 0x12345
    lui x6, 0x12345
    beq x5, x6, test_beq1
    addi x31, x31, 0x002

test_beq2:
    addi x31, x31, 0x045

test_beq3:
    addi x31, x31, 0x044

    # On cherche à ne pas aller à test_beq2 et 3
test_beq1:
    addi x31, x31, 0x001
    lui x6, 0x12346
    beq x6, x5, test_beq2
    addi x31, x31, 0x002
    lui x6, 0x12344
    beq x6, x5, test_beq3
    addi x31, x31, 0x002


	# max_cycle 100
	# pout_start
    # 00000000
	# 00000001
    # 00000003
    # 00000005
	# pout_end