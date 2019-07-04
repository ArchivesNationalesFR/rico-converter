package fr.gouv.culture.an.eac2rico.validator.report;

import java.util.Arrays;
import java.util.List;

public enum ValidationReportFormat {

	RDF(Arrays.asList(new String[] { "ttl", "rdf", "jsonld" })),
	TSV(Arrays.asList(new String[] { "tsv" }));
	
	protected List<String> fileExtensions;
	
	private ValidationReportFormat(List<String> fileExtensions) {
		this.fileExtensions = fileExtensions;
	}

	public List<String> getFileExtensions() {
		return fileExtensions;
	}
	
	public static ValidationReportFormat forFileName(String filename) {
		String extension = filename.substring(filename.lastIndexOf('.')+1);
		for (ValidationReportFormat f : ValidationReportFormat.values()) {
			if(f.getFileExtensions().contains(extension)) {
				return f;
			}
		}
		
		return null;
	}
	
}
