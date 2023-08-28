[Accueil](index.md) > Personnaliser la conversion

# Personnaliser la conversion

Les conversions de EAC et de EAD peuvent être personnalisées en passant 
certains paramètres et en remplaçant la feuille de style "driver" 
`main.xslt`.

## Personnaliser la conversion de EAC/CPF

### Ajuster les paramètres généraux

Vous pouvez ajuster les paramètres d’exécution dans
`parameters/convert_eac.properties` pour modifier par exemple les 
dossiers d’entrée ou de sortie.

### Ajuster les paramètres XSLT

La conversion de EAC vers RiC-O est pilotée par les fichiers XSLT 
situés dans le dossier `xslt_eac`. Une première étape pour adapter la 
conversion consiste à modifier les paramètres XSLT déclarés dans 
`main.xslt`, tels que le code de langue pour les littéraux générés ou 
l’URI de l’auteur du record.

### Ajuster la logique de conversion

La logique de conversion complète se trouve dans `eac2rico.xslt`. 
Pour personnaliser davantage la logique de conversion de EAC/CPF, vous 
pouvez remplacer les modèles de cette feuille de style en les 
redéclarant dans `main.xslt` avec un comportement différent. 
Les modèles que vous écrivez dans `main.xslt` auront la priorité sur les 
modèles de `eac2rico.xslt` avec le même attribut `match`, ce qui vous 
permet d’adapter certains comportements plus facilement. De plus, 
si vous devez ajuster quelque chose dans le traitement des relations, 
vous devrez peut-être ajuster `eac2rico-relations.xslt` et 
`eac2rico-keywords.xml`.

Lorsque vous ajustez des éléments dans la logique de conversion XSLT, 
il est nécessaire d’ajouter de nouveaux tests unitaires sous 
`unit-tests/eac2rico`, ou d’ajuster les tests unitaires existants, et 
[exécutez la commande de tests unitaires](UnitTests.md) pour valider 
votre modification et vérifier que tout est correct.

`ead2rico-arrange.xslt` et `ead2rico-deduplicate.xslt` sont utilisés 
pour regrouper les entités du même type dans le même fichier et sont 
appliqués après la conversion. Vous ne devriez pas avoir 
besoin de modifier ces fichiers, sauf si vous avez besoin d’un 
regroupement différent des entités. Vous pouvez toujours sauter le 
regroupement et la déduplication en utilisant la commande 
`convert_eac_raw`.

## Personnaliser la conversion de EAD

### Ajuster les paramètres généraux

Vous pouvez ajuster les paramètres d’exécution dans 
`parameters/convert_ead.properties` pour modifier par exemple les 
dossiers d’entrée ou de sortie.

### Ajuster les paramètres XSLT

La conversion de EAD vers RiC-O est pilotée par les fichiers XSLT 
situés dans le dossier `xslt_ead`. Une première étape pour adapter la 
conversion consiste à modifier les paramètres XSLT déclarés dans 
`main.xslt`, tels que le code de langue pour les littéraux générés ou 
les motifs pour détecter les RecordSet ou RecordParts dans les 
attributs @otherlevel.

### Ajuster la logique de conversion

La logique de conversion complète se trouve dans `ead2rico.xslt`. 
Pour personnaliser davantage la logique de conversion de EAD, vous 
pouvez remplacer les modèles de cette feuille de style en les 
redéclarant dans `main.xslt` avec un comportement différent. 
Les modèles que vous écrivez dans `main.xslt` auront la priorité sur les 
modèles de `ead2rico.xslt` avec le même attribut `match`, ce qui vous 
permet d’adapter certains comportements plus facilement.

Lorsque vous ajustez des éléments dans la logique de conversion XSLT, 
il est nécessaire d’ajouter de nouveaux tests unitaires sous 
`unit-tests/ead2rico`, ou d’ajuster les tests unitaires existants, et 
[exécutez la commande de tests unitaires](UnitTests.md) pour valider 
votre modification et vérifier que tout est correct.