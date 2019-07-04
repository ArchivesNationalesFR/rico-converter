package fr.gouv.culture.an.eac2rico.validator.report;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ValidationReportWriterRegistry {

	private static ValidationReportWriterRegistry instance;
	
	private List<ValidationReportWriter> writers = new ArrayList<>();
	
	public static ValidationReportWriterRegistry getInstance() {
		if(instance == null) {
			instance = new ValidationReportWriterRegistry();
		}
		return instance;
	}
	
	public Optional<ValidationReportWriter> getWriter(ValidationReportFormat format) {
		for (ValidationReportWriter writer : getWriters()) {
			if(writer.getFormat().equals(format)) {
				return Optional.of(writer);
			}
		}
		return Optional.empty();
	}
	
	public List<ValidationReportWriter> getWriters() {
		return writers;
	}
	
	public void register(ValidationReportWriter writer) {
		this.writers.add(writer);
	}
	
}
