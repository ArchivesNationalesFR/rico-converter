package fr.gouv.culture.an.eaccpf2rico.cli.convertAndArrange;

import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;
import fr.gouv.culture.an.eaccpf2rico.arrange.Eac2RicoArranger;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.SaxonErrorListener;
import fr.sparna.commons.xml.TransformerBuilder;
import net.sf.saxon.serialize.MessageWarner;

public class Eac2RicoArrangerFactory {

	private Logger log = LoggerFactory.getLogger(Eac2RicoArrangerFactory.class.getName());

	public Eac2RicoArranger createArranger(File xslt, File outputDirectory, File errorDirectory) throws Eac2RicoConverterException {
		// create output directory if it does not exists
		if(!outputDirectory.exists()) {
			log.info("Creating output directory {}", outputDirectory.getAbsolutePath());
			outputDirectory.mkdirs();
		}
		
		Transformer transformer;
		try {
			transformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(xslt));
			// disable error listener to prevent messing with the progress bar
			transformer.setErrorListener(new SaxonErrorListener());
			// direct Saxon message output to the JAXP ErrorListener as warnings
			((net.sf.saxon.jaxp.TransformerImpl)transformer).getUnderlyingController().setMessageEmitter(new MessageWarner());			
			
		} catch (TransformerConfigurationException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
		}
		
		Eac2RicoArranger a = new Eac2RicoArranger(transformer, outputDirectory);
		
		return a;
	}
	
}
