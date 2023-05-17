package fr.gouv.culture.an.ricoconverter.cli.convert_ead;

import java.io.File;
import java.io.FileInputStream;
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
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import fr.gouv.culture.an.ricoconverter.ErrorCode;
import fr.gouv.culture.an.ricoconverter.RicoConverterException;
import fr.gouv.culture.an.ricoconverter.cli.commons.RicoConverterProgressListener;
import fr.gouv.culture.an.ricoconverter.cli.commons.SaxonErrorListener;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverter;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverterErrorListener;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverterListener;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverterReportListener;
import fr.sparna.commons.xml.TransformerBuilder;
import net.sf.saxon.serialize.MessageWarner;

public class Ead2RicoConverterFactory {

	private static final String XSLT_PARAMETER_INPUT_FOLDER = "INPUT_FOLDER";

	private Logger log = LoggerFactory.getLogger(Ead2RicoConverterFactory.class.getName());
	
	private File splitXslt = new File("xslt_ead/ead2rico-split.xslt");
	private File preprocessingXslt = new File("xslt_ead/ead2rico-preprocessing.xslt");
	
	public Ead2RicoConverterFactory() {
	}

	public Ead2RicoConverter createConverter(File xslt, File outputDirectory, File errorDirectory, File inputDirectory, boolean split, boolean filterAudienceInternal, boolean filterAudienceExternal) throws RicoConverterException {
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
			throw new RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
		}
		// sets XSLT parameters
		String relativeInputFolder = xslt.getParentFile().toPath().relativize(inputDirectory.toPath()).toString();
		log.info("Found relative path of input folder from XSLT : {}", relativeInputFolder);
		transformer.setParameter(XSLT_PARAMETER_INPUT_FOLDER, relativeInputFolder);
		
		Ead2RicoConverter c = new Ead2RicoConverter(transformer, outputDirectory);
		// sets the error listener
		if(errorDirectory.exists()) {
			try {
				FileUtils.deleteDirectory(errorDirectory);
			} catch (IOException e) {
				throw new RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e);
			}
		}
		
		// set entity resolver to resolve DTDs
		c.setEntityResolver(new EntityResolver() {
			@Override
			public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
				File test = new File(xslt.getParentFile(), systemId);
				if(test.exists()) {
					// this is the case when running unit tests command
					return new InputSource(new FileInputStream(test));
				} else {
					test = new File(inputDirectory, systemId);
					if(test.exists()) {
						return new InputSource(new FileInputStream(test));
					}
				}
				
				return null;
			}
		});
		
		// set splitting transformer
		if(split) {
			try {
				Transformer splitTransformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(this.splitXslt));
				// disable error listener to prevent messing with the progress bar
				splitTransformer.setErrorListener(new SaxonErrorListener());
				// direct Saxon message output to the JAXP ErrorListener as warnings
				((net.sf.saxon.jaxp.TransformerImpl)splitTransformer).getUnderlyingController().setMessageEmitter(new MessageWarner());
				
				c.setSplittingTransformer(splitTransformer);
			} catch (TransformerConfigurationException e) {
				throw new RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
			}
		}
		
		// set preprocessing transformers
		if(filterAudienceInternal || filterAudienceExternal) {
			try {
				Transformer preprocessingTransformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(this.preprocessingXslt));
				// disable error listener to prevent messing with the progress bar
				preprocessingTransformer.setErrorListener(new SaxonErrorListener());
				// direct Saxon message output to the JAXP ErrorListener as warnings
				((net.sf.saxon.jaxp.TransformerImpl)preprocessingTransformer).getUnderlyingController().setMessageEmitter(new MessageWarner());
				
				// sets adequate options based on parameters
				preprocessingTransformer.setParameter("FILTER_INTERNAL", filterAudienceInternal);
				preprocessingTransformer.setParameter("FILTER_EXTERNAL", filterAudienceExternal);
				
				c.setPreProcessorTransformer(preprocessingTransformer);
			} catch (TransformerConfigurationException e) {
				throw new RicoConverterException(ErrorCode.XSLT_PARSING_ERROR, e);
			}
		}
		
		List<Ead2RicoConverterListener> listeners = new ArrayList<>();
		
		// error listener
		Ead2RicoConverterErrorListener errorListener = new Ead2RicoConverterErrorListener(errorDirectory);
		listeners.add(errorListener);
		
		// progress bar listener		
		RicoConverterProgressListener pbListener = new RicoConverterProgressListener();
		listeners.add(pbListener);
		
		// report listener
		Ead2RicoConverterReportListener reportListener = new Ead2RicoConverterReportListener();
		listeners.add(reportListener);
		
		c.setListeners(listeners);
		return c;
	}

	public File getSplitXslt() {
		return splitXslt;
	}

	public void setSplitXslt(File splitXslt) {
		this.splitXslt = splitXslt;
	}
	
	
	
}
