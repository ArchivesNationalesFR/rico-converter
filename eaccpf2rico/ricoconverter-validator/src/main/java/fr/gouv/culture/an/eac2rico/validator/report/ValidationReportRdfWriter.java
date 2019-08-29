package fr.gouv.culture.an.eac2rico.validator.report;

import java.io.OutputStream;

import org.apache.jena.rdf.model.Model;
import org.apache.jena.riot.Lang;

public class ValidationReportRdfWriter implements ValidationReportWriter {

	protected Lang lang;
	
	public ValidationReportRdfWriter(Lang lang) {
		super();
		this.lang = lang;
	}

	@Override
	public void write(Model validationReport, OutputStream out) {
		validationReport.write(out,this.lang.getName());
	}

	@Override
	public ValidationReportFormat getFormat() {
		return ValidationReportFormat.RDF;
	}

	
	
}
