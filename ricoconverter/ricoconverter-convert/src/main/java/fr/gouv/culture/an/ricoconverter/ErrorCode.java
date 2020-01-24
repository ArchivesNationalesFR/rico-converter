package fr.gouv.culture.an.ricoconverter;

public enum ErrorCode {

	@Description(
			notation = 1,
			definition = "Indicates the parsing of the XSLT file failed. Check the syntax of the eac2rico XSLT file."
	)
	XSLT_PARSING_ERROR(1),
	
	@Description(
			notation = 2,
			definition = "Indicates the input parameter is not a directory (but a single file)."
	)
	INPUT_IS_NOT_A_DIRECTORY(2),
	
	@Description(
			notation = 3,
			definition = "Indicates an error happened during the XSLT conversion; the error will usually contain an XSLT error code documented in the [XSLT Error Codes page](ErrorCodesXslt.html)."
	)
	CONVERSION_XSLT_ERROR(3),
	
	@Description(
			notation = 4,
			definition = "Indicates a problem in the configuration in some part of the code."
	)
	CONFIGURATION_EXCEPTION(4),
	
	@Description(
			notation = 5,
			definition = "Indicates a problem when creating, deleting or moving directories or files during the process."
	)
	DIRECTORY_OR_FILE_HANDLING_EXCEPTION(5),
	
	@Description(
			notation = 6,
			definition = "Indicates an error happened during the XSLT transformation used for splitting."
	)
	SPLITTING_XSLT_ERROR(3),
	
	@Description(
			notation = 6,
			definition = "Indicates an error happened during the XSLT transformation used for preprocessing EAD files."
	)
	PREPROCESSING_XSLT_ERROR(3),
	
	@Description(
			notation = -1,
			definition = "This error code should never be thrown ! if you see this error code, there is an unexpected situation in the code that must be fixed (e.g. a file cannot be found while it was supposed to exists because of a previous check)"
	)
	SHOULD_NEVER_HAPPEN_EXCEPTION(-1);
	
	protected int code;

	private ErrorCode(int code) {
		this.code = code;
	}

	public int getCode() {
		return code;
	}
	
}
