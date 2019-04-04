package fr.gouv.culture.an.eaccpf2rico.cli.test;

import java.io.File;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.eaccpf2rico.cli.ExistingFileValidator;

@Parameters(
		commandDescription = "Runs the unit tests of conversion",
		separators = "="
)
public class ArgumentsTest {
	
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
			description = "Relative path to the XSLT file to be used to convert EAC to RiC-O. If not set, defaults to 'xslt/eac2rico.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File xslt = new File("xslt/eac2rico.xslt");

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
