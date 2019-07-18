package fr.gouv.culture.an.eac2rico.validator.report;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.io.IOUtils;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.Model;


public class ValidationReportTextSummaryWriter implements ValidationReportWriter {

	@Override
	public void write(Model validationReport, OutputStream out) {
		QueryExecution qe = null;
		try {
			String sparqlRequest = IOUtils.toString(this.getClass().getResource("shacl-count-validation-results.rq"), "UTF-8");
			qe = QueryExecutionFactory.create(sparqlRequest, validationReport);
			ResultSet rs = qe.execSelect();
			StringBuffer result = new StringBuffer();
			while(rs.hasNext()) {
				QuerySolution solution = rs.next();
				String severity = solution.getLiteral("severity").getLexicalForm();
				String count = solution.getLiteral("count").getLexicalForm();
				result.append(count+" "+severity+", ");
			}
			if(result.length() > 0) {
				result.deleteCharAt(result.length()-1);
				result.deleteCharAt(result.length()-1);
				result.append('\n');
			}
			out.write(result.toString().getBytes());
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
		return ValidationReportFormat.TXT;
	}
	
}
