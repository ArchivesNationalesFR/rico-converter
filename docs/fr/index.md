_Accueil_

# RiC-O Converter

Bienvenue dans la **documentation de RiC-O converter** ! RiC-O converter est un outil en ligne de commande permettant de convertir des fichiers EAD et EAC en fichiers RDF exprimés à l'aide de [l'ontologie Records in Contexts](https://www.ica.org/standards/RiC/ontology).

Cet outil est téléchargeable depuis la [section *release*](https://github.com/ArchivesNationalesFR/rico-converter/releases) du [dépôt Github du convertisseur](https://github.com/ArchivesNationalesFR/rico-converter/).

## Table des matières

La documentation se compose des rubriques suivantes :

### Au sujet de RiC-CM et RiC-O

- [RiC-CM et RiC-O](RecordsInContexts) : consultez cette page pour en savoir plus sur le modèle conceptuel et l'ontologie Records in Contexts ;
- [À propos du projet RiC-O converter](About) : comprendre le projet RiC-O Converter ;
- [Mappings](Mappings) : découvrez comment les fichiers EAD et EAC sont mappés sur l'ontologie RiC par le convertisseur.

### La documentation technique de RiC-O converter

- [Pour commencer](GettingStarted.html) : commencez par consulter cette page pour tester le convertisseur, comprendre la structure du répertoire, apprendre à afficher un message d'aide et ajuster les paramètres de l'outil ;
- [La conversion](Conversion.html) : cette page documente le processus de conversion des fichiers EAD et EAC ;
- [Lancer des tests unitaires](UnitTests.html) : explique comment lancer les tests unitaires du convertisseur ;
- [Personnaliser la conversion](Customize.html) : explique comment personnaliser la conversion pour vos propres fichiers ;
- [Problèmes courants](CommonProblems.html) : permet de résoudre des problèmes courants que vous pourrez rencontrer ;
- [Compile RiC-O Converter](Compile.html) : explique comment adapter et recompiler le code Java.

### Listes de référence des codes d'erreur

- [Les codes d'erreurs](ErrorCodes.html) : liste de référence des codes d'erreur de l'application ;
- [Les codes d'erreur EAC XSLT] (ErrorCodesXsltEac.html) : liste de référence des codes d'erreur possibles lors de la conversion EAC par XSLT ;
- [Les codes d'erreurs EAD XSLT](ErrorCodesXsltEad.html) : liste de référence des codes d'erreur possibles lors de la conversion EAD par XSLT.

## Licence

Ce projet est distribué sous les termes de la licence CeCILL-B (équivalente à une licence MIT et proche d'une licence du domaine public) (voir le [fichier de licence en anglais](../en/license.txt) ou [en français](licence.txt)).

## Contact

Si vous avez des questions sur RiC-O converter, vous pouvez contacter :

- [Florence Clavaud](mailto:florence.clavaud@culture.gouv.fr), responsable du Lab aux [Archives nationales de France](http://www.archives-nationales.culture.gouv.fr/), qui pilote également le développement de l'ontologie RiC-O ;
- [Thomas Francart](mailto:thomas.francart@sparna.fr) chez [Sparna](http://sparna.fr), développeur du convertisseur RiC-O ([blog](http://blog.sparna.fr)).