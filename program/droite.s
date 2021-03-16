.text
	jal efface_ecran
	ori a0, zero, 0
	ori a1, zero, 0
	li  a2, 0xFFFFFF
	ori a3, zero, 720
	jal trace_simple
	ori a0, zero, 560
	ori a1, zero, 0
	li a2, 0xFFFF
	ori a3, zero, 1280
	jal trace_simple
	ori a0, zero, 360
	ori a1, zero, 0
	li a2, 1280
	jal trace_hori
	ori a0, zero, 0
	ori a1, zero, 360
	li a2, 1280
	jal trace_hori
	ori a0, zero, 0
	#ori a1, zero, 719 # Visible avec adaptateur HDMI -> VGA à 719 ou 718, et tronqué avec HDMI direct (visible à partir de 717) 
    li a1,719	
	li a2, 1280
	jal trace_hori
	li a0,0
	li a1,0
	li a2,720
	jal trace_verti
	li a0,1200 # Si on le met sur 1278 ou 1279 la ligne n'est plus visible!(avec l'adaptateur HDMI -> VGA)
			   # En HDMI direct décalage / 0 avec 1278, mis à gauche avec 1279
	li a1,0
	li a2,720
	jal trace_verti
	li a0,640
	li a1,0
	li a2,720
	jal trace_verti
	
boucle:
	j   boucle

efface_ecran:
    li t0, 0x867A4000
	li t1, 0x80000000
for1:
	beq t0,t1,fin_efface_ecran
	sw zero,0(t1)
	addi t1,t1,4
	j for1
fin_efface_ecran:
	jr ra

trace_verti:
	mv a3,a2
	li a2,0xFFFFFF
	mv t3,ra
for3:
	beq a3,a1,fin_for3
	jal affiche_pixel
	addi a1,a1,1
	j for3
fin_for3:
	mv ra,t3
	jr ra

trace_hori:
# fonction tracant une droite horizontale du point (x,y) jusqu'au point (x,y2) avec une couleur incrémentale
# contexte :
# a0 : x
# a1 : y
# a2 : couleur (variable locale beurk)
# a3 : x2 (recu de a2)
	
	mv a3, a2
	li a2, 0xFFFFFF # couleur initiale
	li t3, 0 # pas de la couleur
	
	ori  t2, ra, 0 # Sauvegarde l'adresse de retour (ra) dans un registre qui ne sera pas utilise par la suite (t0)
for2:                   # for(;$a0!=$a3;$a0++){ affiche_pixel($a0,$a1,$a2); $a1++;}
	beq  a3, a0, fin_for2
	jal  affiche_pixel
	addi a0, a0, 1
	add  a2, a2, t3
	j    for2
fin_for2:
	ori  ra, t2, 0 # Restaure ra
	jr   ra


trace_simple:
# fonction tracant un segment du point [x=$a0,y=$a1] au point [x=$a3-1, y=$a1+($a3-$a0)-1] avec la couleur $a2
# contexte :
# $a0 =x
# $a1=y
# $a2=couleur
# $t2 = sauvegarde de $ra

	ori  t2, ra, 0 # Sauvegarde l'adresse de retour (ra) dans un registre qui ne sera pas utilise par la suite (t0)
for:                   # for(;$a0!=$a3;$a0++){ affiche_pixel($a0,$a1,$a2); $a1++;}
	beq  a3, a0, fin_for
	jal  affiche_pixel
	addi a0, a0, 1
	addi a1, a1, 1
	j    for
fin_for:
	ori  ra, t2, 0 # Restaure ra
	jr   ra

affiche_pixel:
# contexte :
# $a0 =x
# $a1=y
# $a2=couleur

# On calcule l'adresse du pixel à la coordonnée (x,y) : 0x80000000 + (1280*y +x)*4 = 0x8000 + (y<<12)+ (y<<10)+(x<<2)
	li t0, 0x80000000
	sll t1, a0, 2
	add t0, t0, t1
	sll t1, a1, 12
	add t0, t0, t1
	sll t1, a1, 10
	add t0, t0, t1
	sw  a2, 0(t0)
	jr  ra
