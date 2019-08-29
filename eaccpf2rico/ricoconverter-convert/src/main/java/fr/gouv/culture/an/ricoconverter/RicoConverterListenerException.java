package fr.gouv.culture.an.ricoconverter;

public class RicoConverterListenerException extends Exception {

	public RicoConverterListenerException(String message, Throwable exception) {
		super(message, exception);
	}

	public RicoConverterListenerException(String message) {
		super(message);
	}

	public RicoConverterListenerException(Throwable exception) {
		super(exception);
	}

	
}
