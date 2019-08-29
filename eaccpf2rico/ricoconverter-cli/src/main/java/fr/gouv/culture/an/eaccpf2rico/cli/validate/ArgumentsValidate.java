package fr.gouv.culture.an.eaccpf2rico.cli.validate;

import java.io.File;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.eaccpf2rico.cli.ExistingFileValidator;

@Parameters(
		commandDescription = "Converts EAC-CPF to RiC-O RDF",
		separators = "="
)
public class ArgumentsValidate {
	
	@Parameter(
			names = { "input" },
			description = "Input folder containg all the RDF files to be validated. If not set, defaults to 'input-validation'",			
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	protected File input = new File("input-validation");
	
	@Parameter(
			names = { "output" },
			description = "Output folder where the validation report will be generated. If not set, defaults to validation-report.tsv",
			converter = FileConverter.class,
			required = false
	)
	protected File output = new File("validation-report.tsv");

	@Parameter(
			names = { "shapes" },
			description = "Relative path to the shapes file to use for validation. If not set, defaults to 'shapes/eac2rico-shapes.ttl'.",
			converter = FileConverter.class,
			required = false
	)
	protected File shapes = new File("shapes/eac2rico-shapes.ttl");
	

	public File getInput() {
		return input;
	}

	public void setInput(File input) {
		this.input = input;
	}

	public File getOutput() {
		return output;
	}

	public void setOutput(File output) {
		this.output = output;
	}

	public File getShapes() {
		return shapes;
	}

	public void setShapes(File shapes) {
		this.shapes = shapes;
	}
	
}
