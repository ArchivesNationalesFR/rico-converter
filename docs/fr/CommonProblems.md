[Accueil](index.html) > Problèmes courants

# Problèmes courants

### Error occurred during initialization of VM, could not reserve enough space for xxxxxx object heap

Cette erreur indique que votre machine n'a pas assez de mémoire pour exécuter le script de conversion. Pour remédier à 
cela, vous pouvez essayer de réduire la quantité de mémoire utilisée par le script. Voici comment faire :

- Ouvrir le script `ricoconverter.bat` dans un éditeur de texte.
- Vers la fin du script, repérer la ligne où l'exécutable Java est lancé ; elle ressemble à ceci : 
`SET fullCommandLine=java -Xmx2048M -Xms1024M -jar eaccpf2rico-cli..........`. Le paramètre `-Xmx` 
définit la quantité _maximum_ de mémoire allouée à la machine virtuelle Java, et `-Xms` définit la quantité de 
mémoire _initiale_ allouée à la machine virtuelle Java.
- Essayer de diminuer les deux chiffres, par exemple en les définissant à `-Xmx1024M -Xms500M`. Le script fonctionnera 
avec moins de mémoire, mais cela devrait suffire ; essayer cependant de rester au-dessus de 1024M de mémoire maximale, 
sinon cela pourrait potentiellement provoquer des erreurs de type "OutOfMemoryErrors" lors de l'exécution du script.
- Enregistrer le fichier et essayez de le relancer ;