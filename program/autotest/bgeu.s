# TAG = bgeu
	.text

    # On verifie que le chemin d'exécution corresponde aux sorties

    # On cherche à sauter à test_bgeu2
    lui x31, 0
    lui x29, 0xe2344
    lui x30, 0xe2345
    bgeu x29, x30, test_bgeu1
    addi x31, x31, 0x002
    lui x29, 0xe2345
    bgeu x29, x30, test_bgeu2
    addi x31, x31, 0x002

test_bgeu1:
    addi x31, x31, 0x001

    # On cherche à sauter à test_bgeu3
test_bgeu2:
    addi x31, x31, 0x003
    lui x30, 0xe2346
    bgeu x30, x29, test_bgeu3
    addi x31, x31, 0x001

test_bgeu3:
    addi x31, x31, 0x004



	# max_cycle 100
	# pout_start
    # 00000000
	# 00000002
    # 00000005
    # 00000009
	# pout_end