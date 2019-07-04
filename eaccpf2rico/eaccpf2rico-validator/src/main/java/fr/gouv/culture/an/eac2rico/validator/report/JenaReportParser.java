package fr.gouv.culture.an.eac2rico.validator.report;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.Model;

public class JenaReportParser {

	protected Model model;

	public JenaReportParser(Model model) {
		super();
		this.model = model;
	}


	public List<ValidationResult> getResults() {
		List<ValidationResult> results = new ArrayList<ValidationResult>();
		
		QueryExecution qe = null;
		try {
			String sparqlRequest = IOUtils.toString(this.getClass().getResource("shacl-report.rq"), "UTF-8");
			qe = QueryExecutionFactory.create(sparqlRequest, this.model);
			ResultSet rs = qe.execSelect();
			while(rs.hasNext()) {
				QuerySolution qs = rs.next();				
				ValidationResult result = new ValidationResult();
				
				result.setFocusNode(model.shortForm(qs.getResource("nodeUri").toString()));
				result.setResultSeverity(model.shortForm(qs.getResource("resultSeverity").toString()));
				result.setSourceConstraintComponent(model.shortForm(qs.getResource("sourceConstraintComponent").toString()));
				result.setSourceShape(model.shortForm(qs.get("sourceShape").toString()));
				
				if(qs.contains("message")) {
					result.setResultMessage(qs.getLiteral("message").getString());
				}
				if(qs.contains("resultPath")) {
					result.setResultPath(model.shortForm(qs.getResource("resultPath").toString()));
				}				
				if(qs.contains("value")) {
					result.setValue(qs.get("value").toString());
				}				
				
				results.add(result);
			}

		} catch (IOException ignore) {
			ignore.printStackTrace();
		} finally {
			if(qe != null) {
				qe.close();
			}
		}
		
		return results;
	}
}
