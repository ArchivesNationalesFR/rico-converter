package fr.gouv.culture.an.ricoconverter.ead.convert;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

import fr.gouv.culture.an.ricoconverter.ErrorCode;
import fr.gouv.culture.an.ricoconverter.RicoConverterException;
import fr.gouv.culture.an.ricoconverter.RicoConverterListenerException;

public class Ead2RicoConverter {
	
	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	/**
	 * Path to output directory
	 */
	protected File convertOutputDirectory;
	
	/**
	 * The XSLT transformer to be used
	 */
	protected Transformer ead2ricoTransformer;
	
	/**
	 * The listeners that listen to the process
	 */
	protected List<Ead2RicoConverterListener> listeners;
	
	/**
	 * The entity resolver to use when parsing input XML files
	 */
	protected EntityResolver entityResolver;

	public Ead2RicoConverter(
			Transformer eac2ricoTransformer,
			File convertOutputDirectory
	) {
		super();
		this.ead2ricoTransformer = eac2ricoTransformer;
		this.convertOutputDirectory = convertOutputDirectory;
	}
	
	public Ead2RicoConverter(Transformer eac2ricoTransformer) {
		this(eac2ricoTransformer, null);
	}

	public void convertDirectory(File inputDirectory) throws RicoConverterException {
		log.info("Converter ran on inputDirectory "+inputDirectory.getAbsolutePath());
		
		if(this.convertOutputDirectory == null) {
			throw new RicoConverterException(ErrorCode.CONFIGURATION_EXCEPTION, "Output directory is null - cannot process input directory");
		}
		
		try {
			notifyStart(inputDirectory);
		} catch (RicoConverterListenerException e) {
			log.error("Error in listener notifyStart for "+inputDirectory.getName(), e);
		}
		
		// for each file in the input directory...
		for(File f : inputDirectory.listFiles()) {
			processFileOrDirectory(f, this.convertOutputDirectory);
		}
		
		try {
			notifyStop();
		} catch (RicoConverterListenerException e) {
			log.error("Error in listener notifyStop for "+inputDirectory.getName(), e);
		}
		
		log.info("Done converting.");
	}
	
	private void processFileOrDirectory(File inputFile, File currentOutputDir) throws RicoConverterException {
		log.info("Processing "+inputFile.getName());
		
		// DO recurse on subdirectories
		if(!inputFile.isDirectory()) {

			if(!inputFile.getName().endsWith(".xml")) {
				log.info("File " + inputFile.getName() + " does not have 'xml' extension, skipping it.");
				return;
			}
			
			try {
				notifyBeginProcessing(inputFile);
			} catch (RicoConverterListenerException e) {
				log.error("Error in listener notifyBeginProcessing for "+inputFile.getName(), e);
			}
			
			File outputFile = createOutputFile(inputFile, currentOutputDir);
			
			boolean success = false;
			try(FileOutputStream out = new FileOutputStream(outputFile)) {
				// StreamSource source = new StreamSource(new FileInputStream(inputFile));
				
				try {
					XMLReader reader = XMLReaderFactory.createXMLReader();
					reader.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);					
					if(this.entityResolver != null) {
						reader.setEntityResolver(this.entityResolver);
					}
					SAXSource source = new SAXSource(reader, new InputSource(new FileInputStream(inputFile)));
					
					// set a SystemId to resolve references to DTD
					// source.setSystemId(inputFile);
					
					this.convert(source, new StreamResult(out));
				} catch (SAXException e1) {
					log.error("Error when creating XMLReader for "+inputFile.getName(), e1);
				}
				
				try {
					notifyEndProcessing(inputFile);
				} catch (RicoConverterListenerException e) {
					log.error("Error in listener notifyEndProcessing for "+inputFile.getName(), e);
				}
				success = true;
			} catch (FileNotFoundException e) {
				throw new RicoConverterException(ErrorCode.SHOULD_NEVER_HAPPEN_EXCEPTION, e);
			} catch (RicoConverterException e2) {
				log.error("Error when processing file "+inputFile.getName(), e2);
				
				try {
					notifyError(inputFile, e2);
				} catch (RicoConverterListenerException e) {
					log.error("Error in listener notifyError for "+inputFile.getName(), e);
				}
			} catch (IOException e1) {
				throw new RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
			}
			
			if(!success) {
				// if an error happens, delete output file
				log.info("Deleting outputFile "+outputFile.getAbsolutePath());
				outputFile.delete();
			}
		} else {
			// create subdirectory in output dir
			File outputSubdir = new File(currentOutputDir, inputFile.getName());
			outputSubdir.mkdir();
			
			// recurse
			for(File f : inputFile.listFiles()) {
				processFileOrDirectory(f, outputSubdir);
			}
		}
	}
	
	public void convert(Source source, Result result) throws RicoConverterException {
		try {
			log.debug("Running XSLT engine...");
			this.ead2ricoTransformer.transform(source, result);
		} catch (TransformerException e) {
			throw new RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
		}
	}
	
	public void unitTests(File unitTestsDirectory) {
		log.info("Converter ran on unit tests directory "+unitTestsDirectory.getAbsolutePath());
		
		// for each file in the unit tests directory...
		List<File> sortedTestDirs = Arrays.asList(unitTestsDirectory.listFiles());
        Collections.sort(sortedTestDirs);
		for(File f : sortedTestDirs) {
			if(f.isDirectory()) {
				File inputFile = new File(f, "input.xml");
				File expectedFile = new File(f, "expected.xml");
				if(inputFile.exists() && expectedFile.exists()) {
					File outputFile = new File(f, "result.xml");
					try {
						try(FileOutputStream out = new FileOutputStream(outputFile)) {
							log.info("Processing test : "+f.getName()+"...");
							log.info("Overriding input folder XSLT param with "+f.getAbsolutePath());
							this.ead2ricoTransformer.setParameter("INPUT_FOLDER", f.getAbsolutePath());
							
							this.convert(new StreamSource(new FileInputStream(inputFile)), new StreamResult(out));

							DiffBuilder builder = 
									DiffBuilder
											.compare(Input.fromFile(expectedFile).build())
											.ignoreWhitespace()
											.ignoreComments()
											.checkForSimilar()
											.withTest(Input.fromFile(outputFile).build());
							
							// ignore some elements in general cases
							if(!f.getName().contains("origination") && !f.getName().contains("repository") && !f.getName().contains("FindingAid")) {
								builder.withNodeFilter(node -> {						
									boolean comparison = (
											node.getNodeType() != Node.ELEMENT_NODE
											||
											!(
													node.getLocalName().equals("hasProvenance")
													||
													node.getLocalName().equals("heldBy")
													||
													node.getLocalName().equals("FindingAid")
													||
													node.getLocalName().equals("seeAlso")
											)
									);
									return comparison;
								});
							}
							
							Diff diff = builder.build();
							
//							Diff diff = DiffBuilder
//									.compare(Input.fromFile(expectedFile).build())
//									.ignoreWhitespace()
//									.ignoreComments()
//									.checkForSimilar()
//									.withTest(Input.fromFile(outputFile).build())
//									.build();
							
							if(diff.hasDifferences()) {
								System.out.println(f.getName()+" : "+"FAILURE");
								System.out.println(diff.toString());
							} else {
								System.out.println(f.getName()+" : "+"success");
							}

						} catch (FileNotFoundException e) {
							throw new RicoConverterException(ErrorCode.SHOULD_NEVER_HAPPEN_EXCEPTION, e);
						} catch (IOException e1) {
							throw new RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
						} catch (RicoConverterException e) {
							throw new RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
						}
					} catch (RicoConverterException e) {
						System.out.println(f.getName()+" : "+"FAILURE");
					}
				}
			}
		}
		
		log.info("Done unit-tests.");
	}
	
	public List<Ead2RicoConverterListener> getListeners() {
		return listeners;
	}

	public void setListeners(List<Ead2RicoConverterListener> listeners) {
		this.listeners = listeners;
	}

	public EntityResolver getEntityResolver() {
		return entityResolver;
	}

	public void setEntityResolver(EntityResolver entityResolver) {
		this.entityResolver = entityResolver;
	}

	private File createOutputFile(File inputFile, File outputDir) {
		return new File(outputDir, inputFile.getName().substring(0, inputFile.getName().lastIndexOf('.'))+".rdf");
	}
	
	private void notifyStart(File inputFile) throws RicoConverterListenerException {
		for (Ead2RicoConverterListener aListener : listeners) {
			aListener.handleStart(inputFile);
		}
	}
	
	private void notifyStop() throws RicoConverterListenerException {
		for (Ead2RicoConverterListener aListener : listeners) {
			aListener.handleStop();
		}
	}
	
	private void notifyBeginProcessing(File inputFile) throws RicoConverterListenerException {
		for (Ead2RicoConverterListener aListener : listeners) {
			aListener.handleBeginProcessing(inputFile);
		}
	}
	
	private void notifyEndProcessing(File inputFile) throws RicoConverterListenerException {
		for (Ead2RicoConverterListener aListener : listeners) {
			aListener.handleEndProcessing(inputFile);
		}
	}
	
	private void notifyError(File inputFile, RicoConverterException e2) throws RicoConverterListenerException {
		for (Ead2RicoConverterListener aListener : listeners) {
			aListener.handleError(inputFile);
		}
	}
	
}