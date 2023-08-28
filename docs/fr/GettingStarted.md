[_Accueil_](index.md) > Pour commencer

# Pour commencer

## Prérequis

Pour exécuter le convertisseur, vous avez besoin d’un [environnement Java Runtime](https://www.java.com/fr/download/manual.jsp), version 8 ou supérieure.

## Téléchargez le convertisseur

Téléchargez le convertisseur depuis la [section *release* du dépôt Github](https://github.com/ArchivesNationalesFR/rico-converter/releases/latest), et décompressez-le.

## Testez l’application

Pour exécuter votre première conversion :

1. double-cliquez sur `ricoconverter.bat` (ou `ricoconverter.sh` sous Linux ou Mac - assurez-vous qu’il est bien exécutable),
2. appuyez sur la touche `Entrée` pour exécuter une conversion par défaut EAC vers RiC-O qui convertira le contenu de quelques fichiers de test EAC qui se trouvent dans le répertoire "input-eac".
3. appuyez à nouveau sur la touche `Entrée` pour laisser les valeurs par défaut des paramètres du script ;
4. attendez quelques secondes que la conversion se termine, vous trouverez le résultat de la conversion dans le dossier de sortie généré automatiquement `output-eac-<date_of_day>`.

Les quelques exemples de fichiers EAC fournis par défaut dans le dossier `input-eac` ont ainsi été convertis en RiC-O.

## Affichez le message d’aide

Pour afficher le message d’aide et obtenir les détails de toutes les commandes et options possibles, exécutez `ricoconverter.bat` et tapez "help" dans l’invite de  commande :


	> :: Welcome to Ric-O Converter ::
	>
	> Enter command to execute (convert_eac, convert_eac_raw, convert_ead, test_eac, test_ead, version, help)
	> [press Enter for ’convert_eac’] :help

## Contenu du dossier de *release* du convertisseur

Dans le dossier de *release* du convertisseur, vous trouverez les répertoires suivants :

   - `input-eac` : le dossier par défaut qui contient les fichiers EAC à convertir avec la commande `convert_eac` (ou `convert_eac_raw`) ;
   - `input_ead` : le dossier par défaut qui contient les fichiers EAD à convertir avec la commande `convert_ead` ;
   - `parameters` : contient les fichiers de paramètres pour chaque commande ; vous devez modifier ces fichiers si vous souhaitez ajuster les options d’une commande ;
   - `unit-tests` : contient les fichiers de tests unitaires utilisés par les commandes `test_eac` et `test_ead` ;
   - `vocabularies` : contient quelques vocabulaires contrôlés nécessaires au processus de conversion : langues, règles, états des enregistrements, types de jeux d’enregistrements, types de formulaires documentaires ;
   - `xslt_eac` : contient les fichiers XSLT utilisés par les commandes `convert_eac` et `convert_eac_raw` pour convertir EAC en RiC-O ; le principal fichier est `eac2rico.xslt` ;
   - `xslt_ead` : contient les fichiers XSLT utilisés par la commande `convert_ead` pour convertir EAC en RiC-O ; le principal fichier est `ead2rico.xslt`.

## Commandes et paramètres

Le convertisseur contient quelques commandes par défaut, les principales sont `convert_eac` et `convert_ead` pour convertir, comme leur nom l’indique, les fichiers EAC et EAD en RiC-O.

Chaque commande est associée à un ensemble de paramètres, et ces paramètres sont répertoriés dans le sous-dossier `parameters`, dans un fichier portant le même nom que la commande ; par exemple, les options de la commande `convert_eac` se trouvent dans `parameters/convert_eac.properties`.

Ces paramètres sont documentés dans le fichier de propriétés lui-même et dans le message d’aide. Ouvrez un fichier de paramètres dans un éditeur de texte pour lire la documentation de chaque paramètre.

Notez que vous pouvez faire une copie d’un fichier de paramètres sous un nom différent afin d’enregistrer des options spécifiques pour une commande donnée que vous seriez amené à exécuter plusieurs fois.

## Ajustez les dossiers d’entrée et de sortie (et d’autres dossiers)

Les paramètres que vous souhaiteriez ajuster le plus souvent sont probablement les dossiers d’entrée et de sortie des commandes de conversion ; par défaut, les commandes de conversion fonctionnent avec les dossiers suivants :

   - La conversion EAD (commande `convert_ead`) lit les fichiers à convertir à partir du dossier `input-ead` et affiche le résultat de la conversion dans un dossier nommé `output-ead-<date>`, par ex. `sortie-ead-20190718` ;
   - La conversion EAC (commande `convert_eac`) lit les fichiers à convertir à partir du dossier `input-eac` et affiche le résultat de la conversion dans un dossier nommé `output-eac-<date>`, par ex. `sortie-eac-20190718` ;
   - ces deux commandes génèrent des fichiers d’erreurs dans un dossier nommé `error-<date>`, par ex. `erreur-20190718` ;
   - les deux commandes génèrent des fichiers de log dans le dossier `log` ;
   - les deux commandes peuvent créer des fichiers dans le dossier `work` ;

Pour ajuster le dossier d’entrée de la conversion :

   1. Modifiez le fichier `parameters/convert_eac.properties` ou `parameters/convert_ead.properties`, selon la commande qui vous intéresse ;
   2. Trouvez la propriété `input` ;
   3. Décommentez la ligne en supprimant le caractère `#` au début de la ligne ;
   4. Réglez le paramètre d’entrée sur la valeur souhaitée, par ex. `input=monDossier`.