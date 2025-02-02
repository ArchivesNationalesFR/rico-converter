[_Home_](index.md) > Error Codes
# Error Codes

## XSLT_PARSING_ERROR
  - code : 1
  - definition : Indicates the parsing of the XSLT file failed. Check the syntax of the eac2rico XSLT file.

## INPUT_IS_NOT_A_DIRECTORY
  - code : 2
  - definition : Indicates the input parameter is not a directory (but a single file).

## CONVERSION_XSLT_ERROR
  - code : 3
  - definition : Indicates an error happened during the XSLT conversion; the error will usually contain an XSLT error code documented in the [XSLT Error Codes page](ErrorCodesXslt.md).

## CONFIGURATION_EXCEPTION
  - code : 4
  - definition : Indicates a problem in the configuration in some part of the code.

## DIRECTORY_OR_FILE_HANDLING_EXCEPTION
  - code : 5
  - definition : Indicates a problem when creating, deleting or moving directories or files during the process.

## SPLITTING_XSLT_ERROR
  - code : 6
  - definition : Indicates an error happened during the XSLT transformation used for splitting.

## PREPROCESSING_XSLT_ERROR
  - code : 6
  - definition : Indicates an error happened during the XSLT transformation used for preprocessing EAD files.

## SHOULD_NEVER_HAPPEN_EXCEPTION
  - code : -1
  - definition : This error code should never be thrown ! if you see this error code, there is an unexpected situation in the code that must be fixed (e.g. a file cannot be found while it was supposed to exists because of a previous check)

