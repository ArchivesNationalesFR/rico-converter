package fr.gouv.culture.an.ricoconverter.cli;

import java.io.File;

import com.beust.jcommander.IParameterValidator;
import com.beust.jcommander.ParameterException;

public class ExistingFileValidator implements IParameterValidator {

	@Override
	public void validate(String name, String value)
	throws ParameterException {
		File f = new File(value);
		if(!f.exists()) {
			throw new ParameterException("Parameter " + name + " should point to an existing directory (" + value +" does not exist)");
		}		
	}

	
}
