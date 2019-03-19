package fr.gouv.culture.an.eaccpf2rico;

public class Eac2RicoConverterException extends Exception {

	private ErrorCode code;

	public Eac2RicoConverterException(ErrorCode code, String message, Throwable exception) {
		super(message, exception);
		this.code = code;
	}

	public Eac2RicoConverterException(ErrorCode code, String message) {
		super(message);
		this.code = code;
	}

	public Eac2RicoConverterException(ErrorCode code, Throwable exception) {
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
