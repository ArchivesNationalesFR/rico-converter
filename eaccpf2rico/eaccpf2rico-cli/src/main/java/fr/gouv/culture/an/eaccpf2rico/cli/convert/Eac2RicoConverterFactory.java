package fr.gouv.culture.an.eaccpf2rico.cli.convert;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;
import fr.gouv.culture.an.eaccpf2rico.cli.test.ArgumentsTest;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverter;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterErrorListener;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterListener;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterReportListener;
import fr.sparna.commons.xml.TransformerBuilder;

public class Eac2RicoConverterFactory {

	private Logger log = LoggerFactory.getLogger(Eac2RicoConverterFactory.class.getName());
	
	private static final String XSLT_PARAMETER_BASE_URI = "BASE_URI";
	private static final String XSLT_PARAMETER_AUTHOR_URI = "AUTHOR_URI";
	private static final String XSLT_PARAMETER_LITERAL_LANG = "LITERAL_LANG";
	
	private String baseRdfUri;
	private String authorUri;
	private String literalLang;
	
	public Eac2RicoConverterFactory(ArgumentsConvert args) {
		this(args.getXsltBaseUri(), args.getXsltAuthorUri(), args.getXsltLiteralLang());
	}
	
	public Eac2RicoConverterFactory(
			String baseRdfUri,
			String authorUri,
			String literalLang
	) {
		super();
		this.baseRdfUri = baseRdfUri;
		this.authorUri = authorUri;
		this.literalLang = literalLang;
	}

	public Eac2RicoConverter createConverter(File xslt, File outputDirectory, File errorDirectory, File inputDirectory) throws Eac2RicoConverterException {
		// create output directory if it does not exists
		if(!outputDirectory.exists()) {
			log.info("Creating output directory {}", outputDirectory.getAbsolutePath());
			outputDirectory.mkdirs();
		}
		
		Transformer transformer;
		try {
			transformer = TransformerBuilder.createSaxonProcessor().setUriResolver(new URIResolver() {

				@Override
				public Source resolve(String href, String base) throws TransformerException {
					return new StreamSource(new File(xslt.getParentFile(), href));
				}
				
			}).createTransformer(new StreamSource(xslt));
			// disable error listener to prevent messing with the progress bar
			transformer.setErrorListener(new SaxonErrorListener());
		} catch (TransformerConfigurationException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
		}
		// sets XSLT parameters
		if(this.baseRdfUri != null) {
			transformer.setParameter(XSLT_PARAMETER_BASE_URI, this.baseRdfUri);
		}
		if(this.authorUri != null) {
			transformer.setParameter(XSLT_PARAMETER_AUTHOR_URI, this.authorUri);
		}
		if(this.literalLang != null) {
			transformer.setParameter(XSLT_PARAMETER_LITERAL_LANG, this.literalLang);
		}
		
		Eac2RicoConverter c = new Eac2RicoConverter(transformer, outputDirectory);
		// sets the error listener
		if(errorDirectory.exists()) {
			try {
				FileUtils.deleteDirectory(errorDirectory);
			} catch (IOException e) {
				throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e);
			}
		}
		
		List<Eac2RicoConverterListener> listeners = new ArrayList<>();
		
		// error listener
		Eac2RicoConverterErrorListener errorListener = new Eac2RicoConverterErrorListener(errorDirectory);
		listeners.add(errorListener);
		
		// progress bar listener		
		Eac2RicoConverterProgressListener pbListener = new Eac2RicoConverterProgressListener();
		listeners.add(pbListener);
		
		// report listener
		Eac2RicoConverterReportListener reportListener = new Eac2RicoConverterReportListener();
		listeners.add(reportListener);
		
		c.setListeners(listeners);
		return c;
	}
	
}
