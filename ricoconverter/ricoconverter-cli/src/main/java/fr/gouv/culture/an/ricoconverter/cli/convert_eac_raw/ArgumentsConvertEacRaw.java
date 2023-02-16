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
	
	@Parameter(
			names = { "xslt.BASE_URI" },
			description = "The BASE_URI parameter for the XSLT conversion. Indicates the root of the URI that will be generated. If not set, defaults to 'http://data.archives-nationales.culture.gouv.fr/'.",
			required = false
	)
	protected String xsltBaseUri = "http://data.archives-nationales.culture.gouv.fr/";

	@Parameter(
			names = { "xslt.AUTHOR_URI" },
			description = "The AUTHOR_URI parameter for the XSLT conversion. Indicates the URI to be used as value for authors. If not set, defaults to 'http://data.archives-nationales.culture.gouv.fr/agent/005061'.",
			required = false
	)
	protected String xsltAuthorUri = "http://data.archives-nationales.culture.gouv.fr/agent/005061";

	@Parameter(
			names = { "xslt.LITERAL_LANG" },
			description = "The LITERAL_LANG parameter for the XSLT conversion. Indicates the language code that will be inserted for literal values. If not set, defaults to 'fr'.",
			required = false
	)
	protected String xsltLiteralLang = "fr";
	
	@Parameter(
			names = { "xslt.VOCABULARY_LEGAL_STATUSES" },
			description = "The VOCABULARY_LEGAL_STATUSES parameter for the XSLT conversion. Indicates the path to the vocabulary file of legal statuses, relative to the XSLT. If not set, defaults to '../vocabularies/FRAN_RI_104_Ginco_legalStatuses.rdf'.",
			required = false
	)
	protected String xsltVocabularyLegalStatuses = null;

	@Parameter(
			names = { "xslt.VOCABULARY_RULES" },
			description = "The VOCABULARY_RULES parameter for the XSLT conversion. Indicates the path to the vocabulary file of rules, relative to the XSLT. If not set, defaults to '../vocabularies/referentiel_rules.rdf'.",
			required = false
	)
	protected String xsltVocabularyRules = null;
	
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

	public String getXsltBaseUri() {
		return xsltBaseUri;
	}

	public void setXsltBaseUri(String xsltBaseUri) {
		this.xsltBaseUri = xsltBaseUri;
	}

	public File getError() {
		return error;
	}

	public void setError(File error) {
		this.error = error;
	}

	public String getXsltAuthorUri() {
		return xsltAuthorUri;
	}

	public String getXsltLiteralLang() {
		return xsltLiteralLang;
	}

	public String getXsltVocabularyLegalStatuses() {
		return xsltVocabularyLegalStatuses;
	}

	public String getXsltVocabularyRules() {
		return xsltVocabularyRules;
	}
	
}
