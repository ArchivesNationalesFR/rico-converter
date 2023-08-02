[_Accueil_](index.md) > Les codes d'erreurs EAC XSLT

# Les codes d'erreurs de conversion EAC en RiC-O

## Codes et messages d'avertissement

### HREF_FILE_NOT_FOUND
  - code : HREF_FILE_NOT_FOUND
  - message : Cannot find file in input folder referenced by a @xlink:href
  - [traduction du message] : Le fichier référencé par *@xlink:href* n'a pas été trouvé dans le dossier *input*

### MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS
  - code : MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS
  - message : Missing @vocabularySource on legalStatus
  - [traduction du message] : L'attribut *@vocabularySource* de l'élément *legalStatus* est absent

### UNKNOWN_LANGUAGE
  - code : UNKNOWN_LANGUAGE
  - message : Unknown language
  - [traduction du message] : Langue inconnue

### RELATION_IN_ONE_DIRECTION_ONLY
  - code : RELATION_IN_ONE_DIRECTION_ONLY
  - message : A relation was found only once, indicating it was in one direction only
  - [traduction du message] : Une relation n'a été trouvée qu'une seule fois, ce qui signifie qu'elle ne va que dans une seule direction

### MORE_THAN_TWO_RELATIONS
  - code : MORE_THAN_TWO_RELATIONS
  - message : A relation was found more than twice
  - [traduction du message] : Une relation a été trouvée plus de deux fois

### RELATION_SUCCESSFULLY_DEDUPLICATED
  - code : RELATION_SUCCESSFULLY_DEDUPLICATED
  - message : Relation was sucessfully deduplicated
  - [traduction du message] : La relation a été dédoublonnée avec succès

### PLACE_WITH_MORE_THAN_ONE_VOIE
  - code : PLACE_WITH_MORE_THAN_ONE_VOIE
  - message : Found place with more than one voie
  - [traduction du message] : Un élément *place* avec plus d'une *voie* a été trouvé

### PLACE_WITHOUT_NOMLIEU_WITH_SINGLE_REFERENCE_TO_AUTHORITY_LIST
  - code : PLACE_WITHOUT_NOMLIEU_WITH_SINGLE_REFERENCE_TO_AUTHORITY_LIST
  - message : Found place without nomLieu but with reference to authority list (still processed)
  - [traduction du message] : Un élément *place* lié à une notice d'autorité mais sans *nomLieu* a été trouvé

### PLACE_WITHOUT_REFERENCE_TO_AUTHORITY_LIST
  - code : PLACE_WITHOUT_REFERENCE_TO_AUTHORITY_LIST
  - message : Found place without reference to authority list
  - [traduction du message] : Un élément *place* sans référence à une liste d'autorité à été trouvé

### MORE_THAN_ONE_PLACEENTRY
  - code : MORE_THAN_ONE_PLACEENTRY
  - message : More than one placeEntry found in a single place
  - [traduction du message] : Plusieurs *placeEntry* ont été trouvés dans un seul lieu

### INVALID_URL_IN_HREF
  - code : INVALID_URL_IN_HREF
  - message : Found an unexpected URL in an @xlink:href
  - [traduction du message] : Un URL inopiné a été trouvé comme valeur de l'attribut *@xlink:href*

### MULTIPLE_P_IN_MANDATE
  - code : MULTIPLE_P_IN_MANDATE
  - message : Found a mandate with a descriptiveNote containing multiple 'p' elements
  - [traduction du message] : Un élément *mandate* avec une *descriptiveNote* contenant plusieurs éléments *p* a été trouvé

## Codes et messages d'erreur

### MISSING_RECORD_ID
  - code : MISSING_RECORD_ID
  - message : recordId not found
  - [traduction du message] : aucun *recordId* n'a pas été trouvé