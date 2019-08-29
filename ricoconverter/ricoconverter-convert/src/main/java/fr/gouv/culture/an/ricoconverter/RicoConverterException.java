package fr.gouv.culture.an.ricoconverter;

public class RicoConverterException extends Exception {

	private ErrorCode code;

	public RicoConverterException(ErrorCode code, String message, Throwable exception) {
		super(message, exception);
		this.code = code;
	}

	public RicoConverterException(ErrorCode code, String message) {
		super(message);
		this.code = code;
	}

	public RicoConverterException(ErrorCode code, Throwable exception) {
		super(exception);
		this.code = code;
	}
	@Override
	public String getMessage() {
		return super.getMessage()+" (error code "+this.code+")";
	}

	public ErrorCode getCode() {
		return code;
	}
	
	
	
}
