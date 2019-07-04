package fr.gouv.culture.an.eac2rico.validator.report;

public class ValidationResult {

	protected String focusNode;
	protected String resultMessage;
	protected String resultPath;
	protected String resultSeverity;
	protected String sourceConstraintComponent;
	protected String value;
	protected String sourceShape;
	
	
	
	public String getSourceShape() {
		return sourceShape;
	}
	public void setSourceShape(String sourceShape) {
		this.sourceShape = sourceShape;
	}
	public String getFocusNode() {
		return focusNode;
	}
	public void setFocusNode(String focusNode) {
		this.focusNode = focusNode;
	}
	public String getResultMessage() {
		return resultMessage;
	}
	public void setResultMessage(String resultMessage) {
		this.resultMessage = resultMessage;
	}
	public String getResultPath() {
		return resultPath;
	}
	public void setResultPath(String resultPath) {
		this.resultPath = resultPath;
	}
	public String getResultSeverity() {
		return resultSeverity;
	}
	public void setResultSeverity(String resultSeverity) {
		this.resultSeverity = resultSeverity;
	}
	public String getSourceConstraintComponent() {
		return sourceConstraintComponent;
	}
	public void setSourceConstraintComponent(String sourceConstraintComponent) {
		this.sourceConstraintComponent = sourceConstraintComponent;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	
	
	
}
