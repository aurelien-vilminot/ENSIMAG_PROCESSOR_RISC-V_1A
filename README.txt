####### Projet CEP #######
Année : 2020-2021
Étudiants : Aurélien VILMINOT G8, Pierre ARVY G6

### Conception Processeur ###

L'ensemble des étapes des quatres premières séances sont validées. Ainsi, notre rendu contient l'ensemble des familles d'instructions demandées,
exceptées les interruptions. Nous n'avons pas réussi à implémenter la PO chargée de les gérer. Par conséquent, nous avons commenté le début 
d'implémentation du fichier CPU_CSR.vhd, et avons débuté l'implémentation de son traitement dans la PC.

Les tests des instructions sont les plus complets possibles, et testent les cas particuliers qu'il est possible de rencontrer (overflow pour une
addition, comparaison non-signée...). Aspirant à devenir ingénieurs, nous nous sommes imposés un coding-style strict, le code a été factorisé 
autant que possible, et les commentaires sont en anglais.

### Exploitation Processeur ###

Pour la partie "Expoitation Processeur", nous avons traduit de manière systématique une fonction écrite par nos soins en C, et vers de l'assembleur. 
L'ensemble du code est disponible dans le dossier program/RISCV/

Exécution du programme :
La fonction possède en paramètre une liste chaînée, un tableau et la taille de ce dernier. 
Le programme effectue un parcours de la liste. Pour chaque valeur, un test de présence de cette dernière dans le tableau est effectué. 
Si ce test est bon, alors la valeur de la cellule concernée est multipliée par deux.

Commentaires :
Le programme n'a pas beaucoup de sens, mais selon-nous il regroupe l'ensemble des éléments vus pendant les TD, à savoir : 
les listes, les structures, les pointeurs, les boucles (for, while), les conditions (if) ainsi que les appels de fonctions et 
la gestion de la pile.

### Le mot de la fin ###

Merci et bon courage au relecteur de ce projet.
