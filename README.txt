####### Projet CEP #######
Année : 2020-2021
Étudiants : Aurélien VILMINOT, Pierre Arvy

# Conception des Processeurs

A l'issue de ce projet, nous avons réalisé l'ensemble des instructions typique demandés dans les objectifs par séance.
De plus, nous avons pris le soin d'implémenter toutes les déclinaisons de ces différentes instructions.
Ainsi, notre projet contient les familles suivantes :
- Arithmétiques
- Basiques
- Divers
- Logiques
- Décalages
- Sets
- Branchements
- Sauts
- Loads
- Stores
- Interruptions

Bien entendu, nous avons réalisé l'ensemble des tests pour chacunes des instructions implémentés. Ces tests ont tous été validés par le méchanisme mis en place sur GitLab.

# Exploitation des Processeurs

Pour cette partie du projet, nous avons effectué une traduction systématique d'une fonction écrite par nos en C vers de l'assembleur. L'ensemble du code est disponible dans le dossier program/RISCV/

Il s'agit d'une fonction possèdant en paramètre une liste chaînées et un tableau. Le programme effectue un parcours de la liste. Pour chaque valeur, un test de présence de cette dernière dans le tableau est effectué. Si ce test est bon, alors la valeur de la cellule concernée est élevée au carré.

Ce programme n'a, certes, pas beaucoup de sens mais il regroupe l'ensemble des éléments vus pendant les TD, à savoir : les listes, les structures, les pointeurs, les boucles (for, while), les conditions (if) ainsi que les appels de fonctions.
