package fr.gouv.culture.an.ricoconverter.cli.convert_eac;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.Parameters;
import com.beust.jcommander.converters.FileConverter;

import fr.gouv.culture.an.ricoconverter.cli.ExistingFileValidator;
import fr.gouv.culture.an.ricoconverter.cli.convert_eac_raw.ArgumentsConvertEacRaw;

@Parameters(
		commandDescription = "Converts EAC-CPF to RiC-O RDF, groups RiC-O relations in separate files, and deduplicate relations",
		separators = "="
)
public class ArgumentsConvertEac extends ArgumentsConvertEacRaw {
	
	
	/***
	 * Default constructor required
	 */
	public ArgumentsConvertEac() {
		super();
	}
	
	@Parameter(
			names = { "xsltArrange" },
			description = "Relative path to the XSLT file to be used to arrange RiC-O files. If not set, defaults to 'xslt/eac2rico-arrange.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File xsltArrange = new File("xslt_eac/eac2rico-arrange.xslt");
	
	@Parameter(
			names = { "xsltDeduplicate" },
			description = "Relative path to the XSLT file to be used to deduplicate relations. If not set, defaults to 'xslt/eac2rico-deduplicate.xslt'.",
			converter = FileConverter.class,
			required = false,
			validateWith = ExistingFileValidator.class
	)
	private File xsltDeduplicate = new File("xslt_eac/eac2rico-deduplicate.xslt");
	
	@Parameter(
			names = { "work" },
			description = "Work folder where temporary files will be written. "
					+ "The folder is deleted and recreated at each invocation. If not set, defaults to 'work'",
			converter = FileConverter.class,
			required = false
	)
	protected File work = new File("work");
	
	@Parameter(
			names = { "output_agents" },
			description = "The subfolder of the output directory where agents output files will be written. "
					+ "If not set, defaults to 'agents'",
			required = false
	)
	protected String agentsSubfolder = "agents";

	@Parameter(
			names = { "output_relations" },
			description = "The subfolder of the output directory where relation output files will be written. "
					+ "If not set, defaults to 'relations'",
			required = false
	)
	protected String relationsSubfolder = "relations";
	
	@Parameter(
			names = { "output_places" },
			description = "The subfolder of the output directory where places output files will be written. "
					+ "If not set, defaults to 'places'",
			required = false
	)
	protected String placesSubfolder = "places";
	
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

	public String getAgentsSubfolder() {
		return agentsSubfolder;
	}

	public void setAgentsSubfolder(String agentsSubfolder) {
		this.agentsSubfolder = agentsSubfolder;
	}

	public String getRelationsSubfolder() {
		return relationsSubfolder;
	}
	
	public String getPlacesSubfolder() {
		return placesSubfolder;
	}

	public void setRelationsSubfolder(String relationsSubfolder) {
		this.relationsSubfolder = relationsSubfolder;
	}

	public File getXsltDeduplicate() {
		return xsltDeduplicate;
	}

	public void setXsltDeduplicate(File xsltDeduplicate) {
		this.xsltDeduplicate = xsltDeduplicate;
	}
	
}
