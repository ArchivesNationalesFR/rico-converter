package fr.gouv.culture.an.ricoconverter.cli.convert_ead;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.ricoconverter.cli.ExistingFileValidator;

@Parameters(
		commandDescription = "Converts EAD to RiC-O RDF",
		separators = "="
)
public class ArgumentsConvertEad {
	
	@Parameter(
			names = { "input" },
			description = "Input folder containg the EAD files. If not set, defaults to 'input-ead'",			
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	protected File input = new File("input-ead");
	
	@Parameter(
			names = { "output" },
			description = "Output folder where the RiC-O files will be generated. If not set, defaults to 'output-ead-YYYYMMDD'",
			converter = FileConverter.class,
			required = false
	)
	protected File output = new File("output-ead"+"-"+new SimpleDateFormat("yyyyMMdd").format(new Date()));

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
			description = "Relative path to the XSLT file to be used to convert EAD to RiC-O. If not set, defaults to 'xslt_ead/main.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	protected File xslt = new File("xslt_ead/main.xslt");

	@Parameter(
			names = { "split" },
			description = "Boolean (true/false) indicating whether the output RDF/XML files should be split. Defaults to 'false'.\n"
					+ "If this option is activated, each input file will generate an output directory instead of a single output file.\n"
					+ "Each output directory will contain the result of the split. The Finding Aid and the top Record Resource are output in a file, \n"
					+ "and each top-level Record Resource, as well as the whole 'branch' below it are output in separate files.\n"
					+ "The splitting is done using the XSLT file in 'xslt_ead/ead2rico-split.xslt', so you can adjust the XSLT to match your splitting need.\n"
					+ "Note that this parameter affects performance significantly (~ +30% of processing time, and more disk space)",
			required = false
	)
	protected String split = "false";
	
	@Parameter(
			names = { "filterAudienceInternal" },
			description = "Boolean (true/false) indicating whether to filter out the EAD elements that have an @audience=\"internal\".\n"
					+ "Defaults to 'true'. This means that such elements will be filtered prior to conversion, and will not be converted in output RDF/XML files.\n",
			required = false
	)
	protected String filterAudienceInternal = "true";

	@Parameter(
			names = { "filterAudienceExternal" },
			description = "Boolean (true/false) indicating whether to filter out the EAD elements that have an @audience=\"external\".\n"
					+ "Defaults to 'false'. Setting this parameter to 'true' means that elements that have an @audience=\"external\" \n"
					+ "will be filtered prior to conversion, and will not be converted in output RDF/XML files.\n"
					+ "This value is specific to France Archives Nationales where it is used to indicate information that is displayed in #'salle de lecture' only, but not disseminated. \n"
					+ "In all other contexts this should be left to the default value 'false'.",
			required = false
	)
	protected String filterAudienceExternal = "false";
	
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

	public String getSplit() {
		return split;
	}

	public void setSplit(String split) {
		this.split = split;
	}

	public String getFilterAudienceInternal() {
		return filterAudienceInternal;
	}

	public void setFilterAudienceInternal(String filterAudienceInternal) {
		this.filterAudienceInternal = filterAudienceInternal;
	}

	public String getFilterAudienceExternal() {
		return filterAudienceExternal;
	}

	public void setFilterAudienceExternal(String filterAudienceExternal) {
		this.filterAudienceExternal = filterAudienceExternal;
	}

	
}
