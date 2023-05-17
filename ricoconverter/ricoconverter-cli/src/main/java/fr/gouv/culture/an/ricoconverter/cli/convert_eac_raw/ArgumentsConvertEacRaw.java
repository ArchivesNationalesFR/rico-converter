package fr.gouv.culture.an.ricoconverter.cli.convert_eac_raw;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.ricoconverter.cli.ExistingFileValidator;

@Parameters(
		commandDescription = "Converts EAC-CPF to RiC-O RDF",
		separators = "="
)
public class ArgumentsConvertEacRaw {
	
	@Parameter(
			names = { "input" },
			description = "Input folder containg the EAC-CPF files. If not set, defaults to 'input-eac'",			
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	protected File input = new File("input-eac");
	
	@Parameter(
			names = { "output" },
			description = "Output folder where the RiC-O files will be generated. If not set, defaults to 'output-eac-YYYYMMDD'",
			converter = FileConverter.class,
			required = false
	)
	protected File output = new File("output-eac"+"-"+new SimpleDateFormat("yyyyMMdd").format(new Date()));

	@Parameter(
			names = { "error" },
			description = "Error folder where the input files that triggered an error during processing will be copied. "
					+ "The folder is created only if error files are found. If not set, defaults to 'error-YYYYMMDD'",
			converter = FileConverter.class,
			required = false
	)
	protected File error = new File("error"+"-"+new SimpleDateFormat("yyyyMMdd").format(new Date()));
	
	@Parameter(
			names = { "xslt" },
			description = "Relative path to the XSLT file to be used to convert EAC to RiC-O. If not set, defaults to 'xslt_eac/main.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	protected File xslt = new File("xslt_eac/main.xslt");
	
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

	public File getXslt() {
		return xslt;
	}

	public void setXslt(File xslt) {
		this.xslt = xslt;
	}

	public File getError() {
		return error;
	}

	public void setError(File error) {
		this.error = error;
	}
	
}
