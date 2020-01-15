package fr.gouv.culture.an.ricoconverter;

import java.io.File;

public class DefaultOutputFileBuilder implements OutputFileBuilder {

	@Override
	public File apply(File outputDir, File inputFile) { 
		String filename = inputFile.getName().substring(0, inputFile.getName().lastIndexOf('.'))+".rdf";
		
		// some hardcoded magic for Archives Nationales naming
		filename = filename.replaceAll("FRAN_IR", "FRAN_RecordResource");
		filename = filename.replaceAll("FRAN_NP", "FRAN_Agent");
		
		return new File(outputDir, filename);
	}

}
