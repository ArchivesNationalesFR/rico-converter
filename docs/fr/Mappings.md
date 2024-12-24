[Accueil](index.md) > Mappings

# Mappings d’EAD vers RiC-O et d’EAC vers RiC-O

## EAD vers RiC-O

Une documentation sur la manière dont RiC-O Converter fait correspondre le contenu des fichiers EAD 2002 avec les composants de RiC-O 1.0.2 se trouve dans le fichier Excel [EAD_to_RiC-O_1.0.2_documentation.xlsx](../EAD_to_RiC-O_1.0.2_documentation.xlsx). Ce tableau de correspondance est utile pour faire le lien entre EAD et RiC-O mais n’est pas une spécification formelle et ne documente pas tous les cas. La version précédente du mapping vers RiC-O 0.2 reste disponible dans la [table d'alignement précédente](../previous-mappings-RiC-O-0.2/EAD_to_RiC-O_0.2_documentation.xlsx)

Les spécifications précises et formelles de la conversion des fichiers EAD 2002 sont fournies sous la forme de tests unitaires dans le répertoire [Unit Tests](UnitTests.md), sous-répertoire `unit-tests/ead2rico`.

RiC-O Converter ne prend pas en compte les éléments EAD 2002 suivants, car cela a été considéré non pertinent dans l’univers RDF : 

- `frontmatter` ;
- `runner` ;
- `titlepage`.

Nous donnons ci-dessous une liste des éléments EAD 2002 que RiC-O Converter ne traite pas actuellement, parce que les Archives nationales de France (ANF) ne les utilisent pas, ou les utilisent très rarement, dans leurs instruments de recherche : 

- `abbr` et `expan` ;
- `abstract` ;
- `address` (dans `publicationstmt`) ;
- `bioghist` (les ANF utilisent le plus souvent des fichiers EAC-CPF pour encoder la biographie ou l’historique des agents qui ont produit ou accumlé les fonds d’archives que l’institution conserve) ;
- `blockquote` ;
- `chronlist` ;
- `dao` ;
- `fileplan` ;
- `listhead` ;
- `materialspec` ;
- `name` ;
- `phystech` ;
- `prefercite` ;
- `sponsor` (dans `titlestmt`) ;
- `table` (et ses sous-éléments) ;
- `title`.

## EAC vers RiC-O

Une documentation non technique, sur la manière dont RiC-O Converter fait correspondre le contenu des fichiers EAC-CPF avec les composants de RiC-O 1.0.2 se trouve dans le fichier Excel [EAC_to_Ric-O_1.0.2_documentation.xlsx](../EAC_to_RiC-O_1.0.2_documentation.xlsx). Ce tableau de correspondance est utile pour faire le lien entre EAC et RiC-O mais n’est pas une spécification formelle et ne documente pas tous les cas. La version précédente du mapping vers RiC-O 0.2 reste disponible dans la [table d'alignement précédente](../previous-mappings-RiC-O-0.2/EAC_to_RiC-O_0.2_documentation.xlsx)

Les spécifications précises et formelles de la conversion des fichiers EAC-CPF sont fournies sous forme de tests unitaires dans le répertoire [Unit Tests](UnitTests.md), sous-répertoire `unit-tests/eac2rico`.

Les ANF utilisent la très grande majorité des éléments EAC-CPF. Cependant quelques éléments ne sont actuellement pas traités par la version actuelle de RiC-O Converter. Voici une liste de ces éléments, que les ANF n’utilisent pas pour le moment :

- les sous-éléments de [nameEntry](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-nameEntry) (à l’exception de part et de useDates) ;
- [nameEntryParallel](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-nameEntryParallel) ;
- [languageUsed](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-languageUsed) ;
- [localDescription](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-localDescription) ;
- [abstract](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-abstract) et [chronList](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-chronList) (sous-éléments de biogHist) ;
- [address](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-address) (sous-élément de place) ;
- [objectBinWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectBinWrap),  [objectXMLWrap](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-objectXMLWrap) ;
- [functionRelation](https://eac.staatsbibliothek-berlin.de/schema/taglibrary/cpfTagLibrary2019_EN.html#elem-functionRelation).


## Exemples

Des exemples de fichiers XML à convertir sont fournis dans les répertoires `input-ead` ([ici](https://github.com/ArchivesNationalesFR/rico-converter/tree/master/ricoconverter/ricoconverter-release/src/main/resources/input-ead) dans les sources) et `input-eac` ([ici](https://github.com/ArchivesNationalesFR/rico-converter/tree/master/ricoconverter/ricoconverter-release/src/main/resources/input-eac) dans les sources).

