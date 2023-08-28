[Accueil](index.md) > Codes d’erreur
# Codes d’erreur

## XSLT_PARSING_ERROR
  - code : 1
  - définition : Indique que l’analyse du fichier XSLT a échoué. Vérifiez la syntaxe du fichier eac2rico XSLT.

## INPUT_IS_NOT_A_DIRECTORY
  - code : 2
  - définition : Indique que le paramètre d’entrée n’est pas un répertoire (mais un seul fichier).

## CONVERSION_XSLT_ERROR
  - code : 3
  - définition : Indique qu’une erreur s’est produite pendant la conversion XSLT ; l’erreur contiendra généralement un code d’erreur XSLT documenté dans la [page des codes d’erreur XSLT](ErrorCodesXslt.md).

## CONFIGURATION_EXCEPTION
  - code : 4
  - définition : Indique un problème de configuration dans certaines parties du code.

## DIRECTORY_OR_FILE_HANDLING_EXCEPTION
  - code : 5
  - définition : Indique un problème lors de la création, de la suppression ou du déplacement de répertoires ou de fichiers pendant le processus.

## SPLITTING_XSLT_ERROR
  - code : 6
  - définition : Indique qu’une erreur s’est produite lors de la transformation XSLT utilisée pour le regroupement.

## PREPROCESSING_XSLT_ERROR
  - code : 6
  - définition : Indique qu’une erreur s’est produite lors de la transformation XSLT utilisée pour le prétraitement des fichiers EAD.

## SHOULD_NEVER_HAPPEN_EXCEPTION
  - code : -1
  - définition : Ce code d’erreur ne devrait jamais être déclenché ! Si vous voyez ce code d’erreur, il y a une situation inattendue dans le code qui doit être corrigée (par exemple, un fichier ne peut pas être trouvé alors qu’il était censé exister en raison d’une vérification précédente).
