package fr.gouv.culture.an.eaccpf2rico.cli.validate;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

import org.apache.jena.ontology.OntModel;
import org.apache.jena.ontology.OntModelSpec;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.RDFLanguages;
import org.apache.jena.vocabulary.RDF;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import fr.gouv.culture.an.eac2rico.validator.ShaclValidator;
import fr.gouv.culture.an.eac2rico.validator.Slf4jProgressMonitor;
import fr.gouv.culture.an.eac2rico.validator.report.ValidationReportFormat;
import fr.gouv.culture.an.eac2rico.validator.report.ValidationReportRdfWriter;
import fr.gouv.culture.an.eac2rico.validator.report.ValidationReportTextSummaryWriter;
import fr.gouv.culture.an.eac2rico.validator.report.ValidationReportTsvWriter;
import fr.gouv.culture.an.eac2rico.validator.report.ValidationReportWriterRegistry;
import fr.gouv.culture.an.eaccpf2rico.cli.CommandIfc;

public class Validate implements CommandIfc {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	@Override
	public void execute(Object args) {
		ArgumentsValidate a = (ArgumentsValidate)args;
		
		// read input file or URL
		System.out.println("Reading data files in "+a.getInput().getName()+"...");
		Model dataModel = readRecursiveRdf(a.getInput());
		for(int i=0; i < 50; i++) { System.out.print("\b"); }
		
		try {
			// read shapes file
			OntModel shapesModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
			log.debug("Reading shapes from "+a.getShapes().getAbsolutePath());
			shapesModel.read(
					new FileInputStream(a.getShapes()),
					a.getShapes().toPath().toAbsolutePath().getParent().toUri().toString(),
					RDFLanguages.filenameToLang(a.getShapes().getName(), Lang.RDFXML).getName()
			);
			
			// run the validator
			System.out.println("Applying validation ...");
			ShaclValidator validator = new ShaclValidator(shapesModel);
			validator.setProgressMonitor(new Slf4jProgressMonitor("SHACL validator", log));
			Model validationResults = validator.validate(dataModel);
			
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportTsvWriter());
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportTextSummaryWriter());
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportRdfWriter(Lang.TTL));
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportRdfWriter(Lang.RDFXML));
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportRdfWriter(Lang.JSONLD));
			ValidationReportWriterRegistry.getInstance().register(new ValidationReportRdfWriter(Lang.NT));
			
		
		
			if(!a.getOutput().exists()) {
				a.getOutput().createNewFile();
			}
			
			ValidationReportWriterRegistry.getInstance().getWriter(ValidationReportFormat.forFileName(a.getOutput().getName()))
			.orElse(new ValidationReportRdfWriter(Lang.TTL))
			.write(validationResults, new FileOutputStream(a.getOutput()));
			ValidationReportWriterRegistry.getInstance().getWriter(ValidationReportFormat.TXT).get().write(validationResults, System.out);
			System.out.println("Report written to "+a.getOutput().getName());
			
		} catch (Exception e) {
			throw new RuntimeException(e);
		}	
	}

	
	protected Model readRecursiveRdf(File input) {
		Model inputModel = ModelFactory.createDefaultModel();

		for(int i=0; i < 50; i++) { System.out.print("\b"); }
		
		String message = "Reading "+input.getName()+"...";
		for(int i=message.length(); i < 50; i++) {
			message += " ";
		}
		System.out.print(message);
		
		if(input.isDirectory()) {
			for (File aFile : input.listFiles()) {
				inputModel.add(readRecursiveRdf(aFile));
			}			
		} else {
			if(RDFLanguages.filenameToLang(input.getName()) != null) {
				try {
					RDFDataMgr.read(
							inputModel,
							new FileInputStream(input),
							// set base URI to null
							null,
							RDFLanguages.filenameToLang(input.getName())
				    );
				} catch (FileNotFoundException ignore) {
					ignore.printStackTrace();
				}
			} else {
				log.error("Unknown RDF format for file "+input.getAbsolutePath());
			}			
		}
		
		return inputModel;
	}

}
