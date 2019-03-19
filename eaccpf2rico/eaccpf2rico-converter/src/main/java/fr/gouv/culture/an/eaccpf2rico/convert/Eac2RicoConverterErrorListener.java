package fr.gouv.culture.an.eaccpf2rico.convert;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterListenerException;

public class Eac2RicoConverterErrorListener extends Eac2RicoConverterListenerBase implements Eac2RicoConverterListener {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	protected File errorFolder;
	
	public Eac2RicoConverterErrorListener(File errorFolder) {
		this.errorFolder = errorFolder;
	}	

	@Override
	public void handleError(File inputFile) throws Eac2RicoConverterListenerException {
		// create error directory if it does not exists
		if(!errorFolder.exists()) {
			log.info("Creating error directory {}", errorFolder.getAbsolutePath());
			errorFolder.mkdirs();
		}
		
		// copy the original file into error folder
		File errorFile = new File(errorFolder, inputFile.getName());
		try {
			Files.copy(inputFile.toPath(), errorFile.toPath());
		} catch (IOException e) {
			throw new Eac2RicoConverterListenerException(e);
		}
	}

}
