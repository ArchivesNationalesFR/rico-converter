package fr.gouv.culture.an.eaccpf2rico.convert;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
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

import org.apache.commons.io.FileUtils;
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
	protected File convertOutputDirectory;
	
	/**
	 * The XSLT transformer to be used
	 */
	protected Transformer eac2ricoTransformer;
	
	/**
	 * The listeners that listen to the process
	 */
	protected List<Eac2RicoConverterListener> listeners;
	
	/**
	 * Path to output directory for agents files
	 */
	protected File arrangeOutputAgentsDirectory;
	
	/**
	 * Path to output directory for relation files
	 */
	protected File arrangeOutputRelationsDirectory;
	
	/**
	 * Path to output directory for places files
	 */
	protected File arrangeOutputPlacesDirectory;
	
	/**
	 * The XSLT transformer to group relations
	 */
	protected Transformer arrangeTransformer;
	
	/**
	 * The XSLT transformer to deduplicate relations
	 */
	protected Transformer deduplicateTransformer;

	public Eac2RicoConverter(
			Transformer eac2ricoTransformer,
			File convertOutputDirectory
	) {
		super();
		this.eac2ricoTransformer = eac2ricoTransformer;
		this.convertOutputDirectory = convertOutputDirectory;
	}
	
	public Eac2RicoConverter(Transformer eac2ricoTransformer) {
		this(eac2ricoTransformer, null);
	}

	public void convertDirectory(File inputDirectory) throws Eac2RicoConverterException {
		log.info("Converter ran on inputDirectory "+inputDirectory.getAbsolutePath());
		
		if(this.convertOutputDirectory == null) {
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
	
	public void convertDirectoryAndArrange(File inputDirectory) throws Eac2RicoConverterException {
		log.info("Converter ran on inputDirectory "+inputDirectory.getAbsolutePath()+" with arrange option");
		
		if(this.convertOutputDirectory == null) {
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
		
		// then arrange	
		log.info("Running arrange transformer from "+this.convertOutputDirectory.getAbsolutePath()+" to "+this.arrangeOutputAgentsDirectory.getAbsolutePath()+" and "+this.arrangeOutputRelationsDirectory.getAbsolutePath());
		this.arrangeTransformer.setParameter("INPUT_FOLDER", this.convertOutputDirectory.toURI());
		this.arrangeTransformer.setParameter("OUTPUT_AGENTS_FOLDER", this.arrangeOutputAgentsDirectory.toURI());
		this.arrangeTransformer.setParameter("OUTPUT_RELATIONS_FOLDER", this.arrangeOutputRelationsDirectory.toURI());
		this.arrangeTransformer.setParameter("OUTPUT_PLACES_FOLDER", this.arrangeOutputPlacesDirectory.toURI());

		try {
			this.notifyStartArrange();
			this.arrangeTransformer.transform(new StreamSource(new ByteArrayInputStream("<dummy />".getBytes())), new StreamResult(new ByteArrayOutputStream()));
		} catch (TransformerException e) {
			throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
		} catch (Eac2RicoConverterListenerException e) {
			log.error("Error in listener notifyStartArrange", e);
		}
		
		
		File relationsBeforeDeduplicateFolder = new File(this.arrangeOutputRelationsDirectory.getParent(), this.arrangeOutputRelationsDirectory.getName()+"-before-deduplicate");
		File placesBeforeDeduplicateFolder = new File(this.arrangeOutputPlacesDirectory.getParent(), this.arrangeOutputPlacesDirectory.getName()+"-before-deduplicate");
		try {
			log.info("Backing up relations and places folder...");
			// back up relations folder
			FileUtils.copyDirectory(this.arrangeOutputRelationsDirectory, relationsBeforeDeduplicateFolder);
			FileUtils.copyDirectory(this.arrangeOutputPlacesDirectory, placesBeforeDeduplicateFolder);
		} catch (IOException e1) {
			throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
		}
		
		// deduplicate
		try {
			this.notifyStartDeduplicate();
			for (File aRelationFile : relationsBeforeDeduplicateFolder.listFiles()) {
				log.info("Deduplicate "+aRelationFile.getName()+"...");
				File outputFile = new File(this.arrangeOutputRelationsDirectory, aRelationFile.getName());
				try(FileOutputStream fos = new FileOutputStream(outputFile)) {
					this.deduplicateTransformer.transform(new StreamSource(new FileInputStream(aRelationFile)), new StreamResult(fos));
				} catch (TransformerException e) {
					throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
				} catch (FileNotFoundException e1) {
					throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
				} catch (IOException e1) {
					throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
				}
			}
			for (File aPlaceFile : placesBeforeDeduplicateFolder.listFiles()) {
				log.info("Deduplicate "+aPlaceFile.getName()+"...");
				File outputFile = new File(this.arrangeOutputPlacesDirectory, aPlaceFile.getName());
				try(FileOutputStream fos = new FileOutputStream(outputFile)) {
					this.deduplicateTransformer.transform(new StreamSource(new FileInputStream(aPlaceFile)), new StreamResult(fos));
				} catch (TransformerException e) {
					throw new Eac2RicoConverterException(ErrorCode.XSLT_TRANSFORM_ERROR, e);
				} catch (FileNotFoundException e1) {
					throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
				} catch (IOException e1) {
					throw new Eac2RicoConverterException(ErrorCode.DIRECTORY_OR_FILE_HANDLING_EXCEPTION, e1);
				}
			}
		} catch (Eac2RicoConverterListenerException e) {
			log.error("Error in listener notifyStartDeduplicate", e);
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
		// do NOT recurse on subdirectories
		if(!inputFile.isDirectory()) {

			if(!inputFile.getName().endsWith(".xml")) {
				log.info("File " + inputFile.getName() + " does not have 'xml' extension, skipping it.");
				return;
			}
			
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
							log.info("Overriding input folder XSLT param with "+f.getAbsolutePath());
							this.eac2ricoTransformer.setParameter("INPUT_FOLDER", f.getAbsolutePath());
							
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
		return new File(convertOutputDirectory, inputFile.getName().substring(0, inputFile.getName().lastIndexOf('.'))+".rdf");
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
	
	private void notifyStartArrange() throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleStartArrange();
		}
	}
	
	private void notifyStartDeduplicate() throws Eac2RicoConverterListenerException {
		for (Eac2RicoConverterListener aListener : listeners) {
			aListener.handleStartDeduplicating();
		}
	}

	public File getArrangeOutputAgentsDirectory() {
		return arrangeOutputAgentsDirectory;
	}

	public void setArrangeOutputAgentsDirectory(File arrangeOutputAgentsDirectory) {
		this.arrangeOutputAgentsDirectory = arrangeOutputAgentsDirectory;
	}

	public File getArrangeOutputRelationsDirectory() {
		return arrangeOutputRelationsDirectory;
	}

	public void setArrangeOutputRelationsDirectory(File arrangeOutputRelationsDirectory) {
		this.arrangeOutputRelationsDirectory = arrangeOutputRelationsDirectory;
	}

	public Transformer getArrangeTransformer() {
		return arrangeTransformer;
	}

	public void setArrangeTransformer(Transformer arrangeTransformer) {
		this.arrangeTransformer = arrangeTransformer;
	}

	public Transformer getDeduplicateTransformer() {
		return deduplicateTransformer;
	}

	public void setDeduplicateTransformer(Transformer deduplicateTransformer) {
		this.deduplicateTransformer = deduplicateTransformer;
	}

	public File getArrangeOutputPlacesDirectory() {
		return arrangeOutputPlacesDirectory;
	}

	public void setArrangeOutputPlacesDirectory(File arrangeOutputPlacesDirectory) {
		this.arrangeOutputPlacesDirectory = arrangeOutputPlacesDirectory;
	}
	
}
