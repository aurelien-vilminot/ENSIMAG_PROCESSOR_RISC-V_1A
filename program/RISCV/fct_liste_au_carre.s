/*
void liste_au_carre(struct cellule_t **l, uint32_t tab[])
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
        l : $a0 (struct cellule_t **)
        tab : $a1 (uint32_t) taille des éléments 4 octets donc ieme élément : tab[i*4]
        first : $t0 (cellule_t *)
        found : $t1 (bool)
        NULL = zero
*/

liste_au_carre:
    /* struct cellule_t *first = *l; */
    lw t0, (a0)

while:
    /* while (*l != NULL) */
    lw t2, (a0) /* *l = $t2 */
    beq t1, zero, end_while

    /* prologue */
    addi sp, sp, -4
    sw ra, 4(sp)


    /* } */
    j while

end_while


/*
void find_in_tab(uint32_t tab[], int32_t val) {
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
    l->val = l->val**2
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
    MULH t0, t0, t0 /* $t0 = l->val**2 */
    sw t0, (a0)
