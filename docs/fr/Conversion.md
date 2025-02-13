[Accueil](index.md) > Conversion

# Conversion

## Conversion de EAC vers RiC-O

La conversion de EAC vers RiC-O est effectuée à l’aide d’un ensemble 
de fichiers XSLT situés dans le dossier `xslt_eac`. Les étapes de 
conversion sont les suivantes :

1. **Conversion principale** : Le point d’entrée de la conversion 
est le fichier `main.xslt`, qui ne contient que quelques paramètres et 
importe la feuille de conversion principale : `eac2rico.xslt`.
Cette feuille appelle à son tour les fichiers suivants :
   - `eac2rico-uris.xslt` : définit comment les URI sont générés ;
   - `eac2rico-relations.xslt` : tout ce qui concerne la conversion des
relations ; et repose à son tour sur `eac2rico-keywords.xml`, 
qui définit des mots-clés à rechercher dans les fichiers d’entrée 
pour déterminer le type de relation dans certains cas ;
   - `eac2rico-codes.xml` : définit les codes d’erreur utilisés pour 
la conversion de EAC ;
   - `eac2rico-builtins.xslt` : une réécriture et une extension des 
modèles XSLT prédéfinis pour la conversion de EAC ;


2. **Organiser les fichiers de sortie** : La conversion principale de
la première étape génère un fichier de sortie pour chaque fichier 
d’entrée. Cette étape regroupe ensuite les entités de relations 
dans un fichier de sortie par type de relation et réorganise la 
hiérarchie du dossier de sortie. Le dossier de sortie final ressemble 
à ceci :
   - `agents` : contient les descriptions d’agents, sans leurs relations ;
   - `places` : contient les lieux ;
   - `relations` : contient les relations, dans les fichiers suivants :
     - `agentHierarchicalRelations`
     - `organicProvenanceRelations`
     - `agentTemporalRelations`
     - `agentToAgentRelations`
     - `familyRelations`
     - `membershipRelations`
     - `workRelations`

   _Notez que même lorsque aucune relation d’un type donné n’est 
générée, le fichier correspondant est quand même généré, avec un 
contenu RDF vide._


3. **Supprimer les relations en double** : 
une fois que les relations du même type sont regroupées dans le même 
fichier, la feuille XSLT `eac2rico-deduplicate.xslt` se 
charge de supprimer les relations en double dans ce fichier (en se 
basant sur leur URI), de sorte que la même relation n’apparaisse 
qu’une seule fois.

### Conversion de EAC vers RiC-O sans regroupement et déduplication

Il est possible d’exécuter uniquement la conversion principale de EAC 
vers RiC-O (première étape) tout en évitant le regroupement des 
relations et leur déduplication. Pour ce faire, utilisez la commande
`convert_eac_raw`.

Cela peut être utile pour déboguer une sortie correspondant à un fichier 
d’entrée EAC donné.

## Conversion de EAD vers RiC-O

La conversion de EAD vers RiC-O est effectuée à l’aide d’un ensemble 
de fichiers XSLT situés dans le dossier `xslt_ead`. Les étapes de 
conversion sont les suivantes :

1. **Prétraitement EAD (filtrage par audience)** : si un filtrage sur 
la propriété @audience est requis (c’est le cas par défaut), la feuille
de style XSLT `ead2rico-preprocessing.xslt` est appliquée sur le 
fichier d’entrée ; sinon, le fichier original est directement traité ;


2. **Conversion principale** : Le point d’entrée de la conversion est 
le fichier `main.xslt`, qui ne contient que quelques paramètres et 
importe la feuille de conversion principale `ead2rico.xslt`. 
Cette feuille appelle à son tour les fichiers suivants :
   - `ead2rico-uris.xslt` : définit comment les URI sont générés ;
   - `ead2rico-codes.xml` : définit les codes d’erreur utilisés pour 
la conversion de EAD ;
   - `ead2rico-builtins.xslt` : une réécriture et une extension des 
instructions XSLT prédéfinies pour la conversion de EAD ;


3. **Fractionnement des fichiers de sortie** : si nécessaire 
(par défaut, ce n’est pas le cas), le résultat de la conversion 
est fractionné à l’aide de `ead2rico-split.xslt`. Le principal Record 
et le RecordResource supérieur de chaque fichier sont regroupés 
dans un fichier, et chaque "branche" de l’instrument de recherche est 
placée dans un fichier séparé.
