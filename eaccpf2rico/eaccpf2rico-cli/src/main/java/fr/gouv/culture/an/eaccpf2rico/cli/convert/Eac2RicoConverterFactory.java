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
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverter;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterErrorListener;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterListener;
import fr.gouv.culture.an.eaccpf2rico.convert.Eac2RicoConverterReportListener;
import fr.sparna.commons.xml.TransformerBuilder;
import net.sf.saxon.serialize.MessageWarner;

public class Eac2RicoConverterFactory {

	private Logger log = LoggerFactory.getLogger(Eac2RicoConverterFactory.class.getName());
	
	private static final String XSLT_PARAMETER_BASE_URI = "BASE_URI";
	private static final String XSLT_PARAMETER_AUTHOR_URI = "AUTHOR_URI";
	private static final String XSLT_PARAMETER_LITERAL_LANG = "LITERAL_LANG";
	private static final String XSLT_PARAMETER_INPUT_FOLDER = "INPUT_FOLDER";
	private static final String XSLT_PARAMETER_VOCABULARY_LEGAL_STATUSES = "VOCABULARY_LEGAL_STATUSES";
	private static final String XSLT_PARAMETER_VOCABULARY_RULES = "VOCABULARY_RULES";
	
	private String baseRdfUri;
	private String authorUri;
	private String literalLang;
	private String vocabularyLegalStatuses;
	private String vocabularyRules;
	
	public Eac2RicoConverterFactory(ArgumentsConvert args) {
		this(args.getXsltBaseUri(), args.getXsltAuthorUri(), args.getXsltLiteralLang(), args.getXsltVocabularyLegalStatuses(), args.getXsltVocabularyRules());
	}
	
	public Eac2RicoConverterFactory(
			String baseRdfUri,
			String authorUri,
			String literalLang,
			String vocabularyLegalStatuses,
			String vocabularyRules
	) {
		super();
		this.baseRdfUri = baseRdfUri;
		this.authorUri = authorUri;
		this.literalLang = literalLang;
		this.vocabularyLegalStatuses = vocabularyLegalStatuses;
		this.vocabularyRules = vocabularyRules;
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
					// if href looks like an absolute file path, then read it as such
					File test = new File(href);
					if(test.exists()) {
						// this is the case when running unit tests command
						return new StreamSource(test);
					} else {
						return new StreamSource(new File(xslt.getParentFile(), href));
					}
					
				}
				
			}).createTransformer(new StreamSource(xslt));
			// disable error listener to prevent messing with the progress bar
			transformer.setErrorListener(new SaxonErrorListener());
			// direct Saxon message output to the JAXP ErrorListener as warnings
			((net.sf.saxon.jaxp.TransformerImpl)transformer).getUnderlyingController().setMessageEmitter(new MessageWarner());			
			
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
		if(this.vocabularyLegalStatuses != null) {
			transformer.setParameter(XSLT_PARAMETER_VOCABULARY_LEGAL_STATUSES, this.vocabularyLegalStatuses);
		}
		if(this.vocabularyRules != null) {
			transformer.setParameter(XSLT_PARAMETER_VOCABULARY_RULES, this.vocabularyRules);
		}
		String relativeInputFolder = xslt.getParentFile().toPath().relativize(inputDirectory.toPath()).toString();
		log.info("Found relative path of input folder from XSLT : {}", relativeInputFolder);
		transformer.setParameter(XSLT_PARAMETER_INPUT_FOLDER, relativeInputFolder);
		
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
	
	public void adaptConverterForArrange(
			Eac2RicoConverter converter,
			File arrangeXslt,
			File deduplicateXslt,
			File outputAgentsDirectory,
			File outputRelationsDirectory,
			File outputPlacesDirectory,
			File errorDirectory
	) throws Eac2RicoConverterException {
		// create output directory if it does not exists
		if(!outputAgentsDirectory.exists()) {
			log.info("Creating output agents directory {}", outputAgentsDirectory.getAbsolutePath());
			outputAgentsDirectory.mkdirs();
		}
		if(!outputRelationsDirectory.exists()) {
			log.info("Creating output relations directory {}", outputRelationsDirectory.getAbsolutePath());
			outputRelationsDirectory.mkdirs();
		}
		
		Transformer transformer;
		try {
			transformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(arrangeXslt));
			// disable error listener to prevent messing with the progress bar
			transformer.setErrorListener(new SaxonErrorListener());
			// direct Saxon message output to the JAXP ErrorListener as warnings
			((net.sf.saxon.jaxp.TransformerImpl)transformer).getUnderlyingController().setMessageEmitter(new MessageWarner());			
			
		} catch (TransformerConfigurationException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
		}
		
		converter.setArrangeTransformer(transformer);
		converter.setArrangeOutputAgentsDirectory(outputAgentsDirectory);
		converter.setArrangeOutputRelationsDirectory(outputRelationsDirectory);
		converter.setArrangeOutputPlacesDirectory(outputPlacesDirectory);
		
		Transformer deduplicateTransformer;
		try {
			deduplicateTransformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(deduplicateXslt));
			// disable error listener to prevent messing with the progress bar
			deduplicateTransformer.setErrorListener(new SaxonErrorListener());
			// direct Saxon message output to the JAXP ErrorListener as warnings
			((net.sf.saxon.jaxp.TransformerImpl)deduplicateTransformer).getUnderlyingController().setMessageEmitter(new MessageWarner());			
			
		} catch (TransformerConfigurationException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
		}
		
		converter.setDeduplicateTransformer(deduplicateTransformer);
	}
	
}
