package fr.gouv.culture.an.eaccpf2rico.cli.convertAndArrange;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.eaccpf2rico.cli.ExistingFileValidator;
import fr.gouv.culture.an.eaccpf2rico.cli.convert.ArgumentsConvert;

@Parameters(
		commandDescription = "Converts EAC-CPF to RiC-O RDF, and arrange RiC-O relations in separate files",
		separators = "="
)
public class ArgumentsConvertAndArrange extends ArgumentsConvert {
	
	
	/***
	 * Default constructor required
	 */
	public ArgumentsConvertAndArrange() {
		super();
	}

	/**
	 * Copy constructor
	 * @param other
	 */
	public ArgumentsConvertAndArrange(ArgumentsConvertAndArrange other) {
		this.xslt = new File(other.xslt.getPath());
		this.error = new File(other.error.getPath());
		this.input = new File(other.input.getPath());
		this.output = new File(other.output.getPath());
		this.xsltAuthorUri = other.xsltAuthorUri;
		this.xsltBaseUri = other.xsltBaseUri;
		this.xsltLiteralLang = other.xsltLiteralLang;
		this.xsltArrange = new File(other.xsltArrange.getPath());
	}
	
	@Parameter(
			names = { "xsltArrange" },
			description = "Relative path to the XSLT file to be used to arrange RiC-O files. If not set, defaults to 'xslt/eac2rico-arrange.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File xsltArrange = new File("xslt/eac2rico-arrange.xslt");
	
	@Parameter(
			names = { "work" },
			description = "Work folder where temporary files will be written. "
					+ "The folder is deleted and recreated at each invocation. If not set, defaults to 'work'",
			converter = FileConverter.class,
			required = false
	)
	protected File work = new File("work");

	public File getXsltArrange() {
		return xsltArrange;
	}

	public void setXsltArrange(File xsltArrange) {
		this.xsltArrange = xsltArrange;
	}

	public File getWork() {
		return work;
	}

	public void setWork(File work) {
		this.work = work;
	}
	
}
