package fr.gouv.culture.an.eaccpf2rico.arrange;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;

public class Eac2RicoArranger {
	
	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	/**
	 * Path to output directory
	 */
	protected File outputDirectory;
	
	/**
	 * The XSLT transformer to be used
	 */
	protected Transformer eac2ricoTransformer;

	public Eac2RicoArranger(
			Transformer eac2ricoTransformer,
			File outputDirectory
	) {
		super();
		this.eac2ricoTransformer = eac2ricoTransformer;
		this.outputDirectory = outputDirectory;
	}
	
	public Eac2RicoArranger(Transformer eac2ricoTransformer) {
		this(eac2ricoTransformer, null);
	}

	public void processDirectory(File inputDirectory) throws Eac2RicoConverterException {
		log.info("Arranger ran on inputDirectory "+inputDirectory.getAbsolutePath());
		
		this.eac2ricoTransformer.setParameter("INPUT_FOLDER", inputDirectory.toURI());
		this.eac2ricoTransformer.setParameter("OUTPUT_FOLDER", this.outputDirectory.toURI());
		try {
			this.eac2ricoTransformer.transform(new StreamSource(new ByteArrayInputStream("<dummy />".getBytes())), new StreamResult(new ByteArrayOutputStream()));
		} catch (TransformerException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
		}
		
		log.info("Done arranging.");
	}

}
