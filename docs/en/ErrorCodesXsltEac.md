[_Home_](index.md) > EAC XSLT Error Codes
# EAC 2 RiC-O XSLT Error Codes

## Warning codes and messages

### HREF_FILE_NOT_FOUND
  - code : HREF_FILE_NOT_FOUND
  - message : Cannot find file in input folder referenced by a @xlink:href

### MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS
  - code : MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS
  - message : Missing @vocabularySource on legalStatus

### UNKNOWN_LANGUAGE
  - code : UNKNOWN_LANGUAGE
  - message : Unknown language

### RELATION_IN_ONE_DIRECTION_ONLY
  - code : RELATION_IN_ONE_DIRECTION_ONLY
  - message : A relation was found only once, indicating it was in one direction only

### MORE_THAN_TWO_RELATIONS
  - code : MORE_THAN_TWO_RELATIONS
  - message : A relation was found more than twice

### RELATION_SUCCESSFULLY_DEDUPLICATED
  - code : RELATION_SUCCESSFULLY_DEDUPLICATED
  - message : Relation was sucessfully deduplicated

### PLACE_WITH_MORE_THAN_ONE_VOIE
  - code : PLACE_WITH_MORE_THAN_ONE_VOIE
  - message : Found place with more than one voie

### PLACE_WITHOUT_NOMLIEU_WITH_SINGLE_REFERENCE_TO_AUTHORITY_LIST
  - code : PLACE_WITHOUT_NOMLIEU_WITH_SINGLE_REFERENCE_TO_AUTHORITY_LIST
  - message : Found place without nomLieu but with reference to authority list (still processed)

### PLACE_WITHOUT_REFERENCE_TO_AUTHORITY_LIST
  - code : PLACE_WITHOUT_REFERENCE_TO_AUTHORITY_LIST
  - message : Found place without reference to authority list

### MORE_THAN_ONE_PLACEENTRY
  - code : MORE_THAN_ONE_PLACEENTRY
  - message : More than one placeEntry found in a single place

### INVALID_URL_IN_HREF
  - code : INVALID_URL_IN_HREF
  - message : Found an unexpected URL in an @xlink:href

### MULTIPLE_P_IN_MANDATE
  - code : MULTIPLE_P_IN_MANDATE
  - message : Found a mandate with a descriptiveNote containing multiple 'p' elements

## Error codes and messages

### MISSING_RECORD_ID
  - code : MISSING_RECORD_ID
  - message : recordId not found