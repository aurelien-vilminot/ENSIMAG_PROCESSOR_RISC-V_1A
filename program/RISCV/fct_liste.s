/*
void liste_au_carre(struct cellule_t **l, int32_t tab[])
{
   struct cellule_t *first = *l;
   bool found;
    while (*l != NULL) {
        found = find_in_tab(tab, (*l)->val)
        if (found) {
            eleve_au_carre((*l))
        }
        *l = (*l)->suiv;
    }
    *l = first;
}
*/

    .text
    .globl liste_au_carre

/*
    Contexte :
        l : $a0/sp+8(struct cellule_t **)
        tab : $a1/sp+12 (uint32_t) taille des éléments 4 octets donc ieme élément : tab[i*4]
        first : sp+4 (cellule_t *)
        found : sp+0 (bool)
        NULL = zero
        adresse de retour : ra/sp+16

        La pile doit réserver 20 octets

        PILE:
        sp+0 : place pour la variable locale found
        sp+4 : place pour la variable locale first
        sp+8 : place pour permettre à la fonction de sauvegarder son registre a0, paramètre l
        sp+12 : place pour permettre à la fonction de sauvegarder son registre a1, paramètre tab
        sp+16 : place de l'adresse de retour (ra) dans la pile
*/

liste_au_carre:
    /* prologue */
    addi sp, sp, -20
    sw ra, 16(sp)   /* sauvegarde de ra */

    /* struct cellule_t *first = *l; */
    lw t0, (a0)
    sw t0, 4(sp)    /* sauvegarde de first */

while:
    /* while (*l != NULL) */
    lw t1, (a0) /* *l = $t1 */
    beq t1, zero, end_while

    sw a1, 12(sp)   /* sauvegarde de tab */
    sw a0, 8(sp)    /* sauvegarde de l */

    /* found = find_in_tab(tab, (*l)->val) */
    add a0, zero, a1
    lw a1, (t1) /* a1 = (*l)->val */
    jal find_in_tab
    sw a0, 0(sp)    /* sauvegarde de found */

    /* if (found) { */
    beq a0, zero, end_if

    /* eleve_au_carre((*l)) */
    lw a0, 8(sp)    /* restaure l */
    lw a0, (a0)
    jal eleve_au_carre

end_if:
    lw a1, 12(sp)   /* restaure de tab */
    lw a0, 8(sp)    /* restaure de l */

    /* *l = (*l)->suiv; */
    lw t2, (a0)
    lw t2, 4(t2)    /* (*l)->suiv */
    sw t2, (a0)

    /* } */
    j while

end_while:
    /* *l = first; */
    lw t0, 4(sp)    /* restaure de first */
    sw t0, (a0)

    /* epilogue */
    lw ra, 16(sp)   /* restaure ra */
    addi sp, sp, 20
    ret


/*
bool find_in_tab(uint32_t tab[], int32_t val) {
    uint32_t i;
    for (i = 0; i < taille - 1; i++) {
        if (val == tab[i]) {
            return True
        }
    }
    return False
}
*/
    .text
    .globl find_in_tab

/*
    Contexte :
        tab : $a0 (uint32_t) taille des éléments 4 octets donc ieme élément : tab[i*4]
        val : $a1 (int32_t)
        i : $t0 (uint32_t)
*/

find_in_tab:
    /* for (i = 0; i < taille - 1; i++)  */
    li t0, 0
    addi t1, a1, -1 /* $t1 = taille - 1 */

for_loop:
    bge t0, t1, return_false

    /* if (val == tab[i]) */

    slli t2, t0, 2  
    add t3, a0, t2
    lw t3, (t3) /* $t3 = tab[i] */
    beq a1, t3, return_true

    addi t0, t0, 1 /* i++ */
    j for_loop

return_false:
    /* return False */
    add a0, zero, zero
    j return

return_true:
    /* return True */
    addi a0, zero, 1

return:
    /* } */
    ret


/*
void eleve_au_carre(struct cellule_t *l) {
    l->val = l->val*2
}
*/
    .text
    .globl eleve_au_carre

/*
    Contexte :
        l : $a0 (struct cellule_t *)
*/

eleve_au_carre:
    /* l->val = l->val**2 */
    lw t0, (a0) /* t0 = l->val */
    slli t0, t0, 1 /* $t0 = l->val*2 */
    sw t0, (a0)
