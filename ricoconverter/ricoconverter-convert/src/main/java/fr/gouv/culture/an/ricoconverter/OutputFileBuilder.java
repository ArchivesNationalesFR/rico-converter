package fr.gouv.culture.an.ricoconverter;

import java.io.File;
import java.util.function.BinaryOperator;

public interface OutputFileBuilder extends BinaryOperator<File> {
	
	@Override
	public File apply(File outputDir, File inputFile);
	
}
