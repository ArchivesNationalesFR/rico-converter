package fr.gouv.culture.an.eaccpf2rico.cli.convert;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SaxonErrorListener implements ErrorListener {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	@Override
	public void error(TransformerException exception) throws TransformerException {
		log.error(exception.getMessage(), exception.getException());
	}

	@Override
	public void fatalError(TransformerException exception) throws TransformerException {
		log.error(exception.getMessage(), exception.getException());
	}

	@Override
	public void warning(TransformerException exception) throws TransformerException {
		// these are reported separately in dedicated messages, easier to process than the stacktraces
		if(!exception.getMessage().startsWith("I/O error reported by XML parser") && !exception.getMessage().startsWith("Document has been marked not available")) {
			log.warn(exception.getMessage(), exception.getException());
		}
	}

}
