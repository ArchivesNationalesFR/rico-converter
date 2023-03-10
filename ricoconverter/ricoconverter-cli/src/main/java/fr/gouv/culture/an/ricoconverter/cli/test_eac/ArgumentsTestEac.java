package fr.gouv.culture.an.ricoconverter.cli.test_eac;

import java.io.File;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.ricoconverter.cli.ExistingFileValidator;

@Parameters(
		commandDescription = "Runs the unit tests of EAC conversion",
		separators = "="
)
public class ArgumentsTestEac {
	
	@Parameter(
			names = { "unit-tests" },
			description = "Input folder containg the unit tests files. If not set, defaults to 'unit-tests/eac2rico'",			
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File unitTests = new File("unit-tests/eac2rico");
	
	@Parameter(
			names = { "xslt" },
			description = "Relative path to the XSLT file to be used to convert EAC to RiC-O. If not set, defaults to 'xslt_eac/main.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File xslt = new File("xslt_eac/main.xslt");

	public File getUnitTests() {
		return unitTests;
	}

	public void setUnitTests(File unitTests) {
		this.unitTests = unitTests;
	}

	public File getXslt() {
		return xslt;
	}

	public void setXslt(File xslt) {
		this.xslt = xslt;
	}
	
}
