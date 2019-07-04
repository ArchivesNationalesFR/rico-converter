package fr.gouv.culture.an.eac2rico.validator.report;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.io.IOUtils;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.sparql.resultset.TSVOutput;


public class ValidationReportTsvWriter implements ValidationReportWriter {

	@Override
	public void write(Model validationReport, OutputStream out) {
		QueryExecution qe = null;
		try {
			String sparqlRequest = IOUtils.toString(this.getClass().getResource("shacl-report.rq"), "UTF-8");
			qe = QueryExecutionFactory.create(sparqlRequest, validationReport);
			ResultSet rs = qe.execSelect();
			TSVOutput output = new TSVOutput();
			output.format(out, rs);
		} catch (IOException ignore) {
			ignore.printStackTrace();
		} finally {
			if(qe != null) {
				qe.close();
			}
		}
	}

	@Override
	public ValidationReportFormat getFormat() {
		return ValidationReportFormat.TSV;
	}

	
	
}
