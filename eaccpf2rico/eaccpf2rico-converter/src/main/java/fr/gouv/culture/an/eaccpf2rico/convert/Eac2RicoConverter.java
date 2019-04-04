package fr.gouv.culture.an.eaccpf2rico.convert;

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
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterListenerException;
import fr.gouv.culture.an.eaccpf2rico.ErrorCode;

public class Eac2RicoConverter {
	
	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	/**
	 * Path to output directory
	 */
	protected File outputDirectory;
	
	/**
	 * The XSLT transformer to be used
	 */
	protected Transformer eac2ricoTransformer;
	
	/**
	 * The listeners that listen to the process
	 */
	protected List<Eac2RicoConverterListener> listeners;

	public Eac2RicoConverter(
			Transformer eac2ricoTransformer,
			File outputDirectory
	) {
		super();
		this.eac2ricoTransformer = eac2ricoTransformer;
		this.outputDirectory = outputDirectory;
	}
	
	public Eac2RicoConverter(Transformer eac2ricoTransformer) {
		this(eac2ricoTransformer, null);
	}

	public void processDirectory(File inputDirectory) throws Eac2RicoConverterException {
		log.info("Converter ran on inputDirectory "+inputDirectory.getAbsolutePath());
		
		if(this.outputDirectory == null) {
			throw new Eac2RicoConverterException(ErrorCode.CONFIGURATION_EXCEPTION, "Output directory is null - cannot process input directory");
		}
		
		try {
			notifyStart(inputDirectory);
		} catch (Eac2RicoConverterListenerException e) {
			log.error("Error in listener notifyStart for "+inputDirectory.getName(), e);
		}
		
		// for each file in the input directory...
		for(File f : inputDirectory.listFiles()) {
			processFileOrDirectory(f);
		}
		
		try {
			notifyStop();
		} catch (Eac2RicoConverterListenerException e) {
			log.error("Error in listener notifyStop for "+inputDirectory.getName(), e);
		}
		
		log.info("Done converting.");
	}
	
	private void processFileOrDirectory(File inputFile) throws Eac2RicoConverterException {
		log.info("Processing "+inputFile.getName());
		// recurse on subdirectories if necessary
		if(inputFile.isDirectory()) {
			for(File f : inputFile.listFiles()) {
				processFileOrDirectory(f);
			}
		} else {
			
			try {
				notifyBeginProcessing(inputFile);
			} catch (Eac2RicoConverterListenerException e) {
				log.error("Error in listener notifyBeginProcessing for "+inputFile.getName(), e);
			}
			
			File outputFile = createOutputFile(inputFile);
			
			boolean success = false;
			try(FileOutputStream out = new FileOutputStream(outputFile)) {
				this.convert(new StreamSource(new FileInputStream(inputFile)), new StreamResult(out));
				
				try {
					notifyEndProcessing(inputFile);
				} catch (Eac2RicoConverterListenerException e) {
					log.error("Error in listener notifyEndProcessing for "+inputFile.getName(), e);
				}
				success = true;
			} catch (FileNotFoundException e) {
				throw new Eac2RicoConverterException(ErrorCode.SHOULD_NEVER_HAPPEN_EXCEPTION, e);
			} catch (Eac2RicoConverterException e2) {
				log.error("Error when processing file "+inputFile.getName(), e2);
				
				try {
					notifyError(inputFile, e2);
				} catch (Eac2RicoConverterListenerException e) {
					log.error("Error in listener notifyError for "+inputFile.getName(), e);
				}
			} catch (IOException e1) {
				throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
			}
			
			if(!success) {
				// if an error happens, delete output file
				log.info("Deleting outputFile "+outputFile.getAbsolutePath());
				outputFile.delete();
			}
		}
	}
	
	public void convert(Source source, Result result) throws Eac2RicoConverterException {
		try {
			log.debug("Running XSLT engine...");
			this.eac2ricoTransformer.transform(source, result);
		} catch (TransformerException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
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
							this.convert(new StreamSource(new FileInputStream(inputFile)), new StreamResult(out));

							Diff diff = DiffBuilder
									.compare(Input.fromFile(expectedFile).build())
									.ignoreWhitespace()
									.ignoreComments()
									.checkForSimilar()
									.withTest(Input.fromFile(outputFile).build())
									.build();
							if(diff.hasDifferences()) {
								System.out.println(f.getName()+" : "+"FAILURE");
								System.out.println(diff.toString());
							} else {
								System.out.println(f.getName()+" : "+"success");
							}

						} catch (FileNotFoundException e) {
							throw new Eac2RicoConverterException(ErrorCode.SHOULD_NEVER_HAPPEN_EXCEPTION, e);
						} catch (IOException e1) {
							throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
						} catch (Eac2RicoConverterException e) {
							throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
						}
					} catch (Eac2RicoConverterException e) {
						System.out.println(f.getName()+" : "+"FAILURE");
					}
				}
			}
		}
		
		log.info("Done unit-tests.");
	}
	
	public List<Eac2RicoConverterListener> getListeners() {
		return listeners;
	}

	public void setListeners(List<Eac2RicoConverterListener> listeners) {
		this.listeners = listeners;
	}

	private File createOutputFile(File inputFile) {
		return new File(outputDirectory, inputFile.getName().substring(0, inputFile.getName().lastIndexOf('.'))+".rdf");
	}
	
	private void notifyStart(File inputFile) throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleStart(inputFile);
		}
	}
	
	private void notifyStop() throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleStop();
		}
	}
	
	private void notifyBeginProcessing(File inputFile) throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleBeginProcessing(inputFile);
		}
	}
	
	private void notifyEndProcessing(File inputFile) throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleEndProcessing(inputFile);
		}
	}
	
	private void notifyError(File inputFile, Eac2RicoConverterException e2) throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleError(inputFile);
		}
	}
}
