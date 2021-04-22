#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <inttypes.h>

struct cellule_t {
   int32_t val;
   struct cellule_t *suiv;
};

void traitement_liste(struct cellule_t **l, int32_t tab[], uint32_t taille_tab);
bool find_in_tab(uint32_t tab[], int32_t val, uint32_t taille_tab);
void mult_par_deux(struct cellule_t *l);

struct cellule_t *decoupe(struct cellule_t *l, struct cellule_t **l1, struct cellule_t **l2);

static struct cellule_t *cree_liste(int32_t tab[])
{
   struct cellule_t *liste = NULL;
   for (uint32_t i = 0; tab[i] != -1; i++) {
      struct cellule_t *cell = malloc(sizeof(struct cellule_t));
      if (cell == NULL) {
         printf("Erreur : malloc retourne NULL\n");
         exit(1);
      }
      cell->val = tab[i];
      cell->suiv = liste;
      liste = cell;
   }
   return liste;
}

static void affiche_liste(struct cellule_t *liste)
{
   while (liste != NULL) {
      printf("%" PRId32 " -> ", liste->val);
      liste = liste->suiv;
   }
   printf("FIN\n");
}

static void detruit_liste(struct cellule_t *liste)
{
   while (liste != NULL) {
      struct cellule_t *suiv = liste->suiv;
      free(liste);
      liste = suiv;
   }
}

static void test(int32_t tableau[])
{
   const uint32_t taille_tab = 10;
   int32_t tableau_val_a_chercher[taille_tab];
   srandom(0xdeadbeef);
   for (uint32_t i = 0; i < taille_tab - 1; i++) {
      tableau_val_a_chercher[i] = random() % 10;
   }
   tableau_val_a_chercher[taille_tab - 1] = -1;

   struct cellule_t *liste;
   printf("Tableau de valeurs à multiplier par deux : ");
   for (uint32_t i = 0; tableau_val_a_chercher[i] != -1; i++) {
      printf("%" PRId32 " ", tableau_val_a_chercher[i]);
   }
   printf("\n");
   liste = cree_liste(tableau);
   printf("Liste initiale : ");
   affiche_liste(liste);
   
   traitement_liste(&liste, tableau_val_a_chercher, taille_tab);
   
   printf("Liste modifiée : ");
   affiche_liste(liste);

   detruit_liste(liste);
}

int main(void)
{
   const uint32_t taille_tab = 11;
   int32_t tableau[taille_tab];
   srandom(0xdeadbeef);
   printf("** Test d'un tableau quelconque **\n");
   for (uint32_t i = 0; i < taille_tab - 1; i++) {
      tableau[i] = random() % 10;
   }
   tableau[taille_tab - 1] = -1;
   test(tableau);

   return 0;
}
