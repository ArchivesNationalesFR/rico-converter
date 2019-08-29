package fr.gouv.culture.an.eac2rico.validator;

import java.net.URI;
import java.util.UUID;
import java.util.stream.Collectors;

import org.apache.jena.graph.Graph;
import org.apache.jena.graph.compose.MultiUnion;
import org.apache.jena.query.Dataset;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.rdf.model.RDFList;
import org.apache.jena.rdf.model.RDFNode;
import org.apache.jena.rdf.model.Resource;
import org.apache.jena.vocabulary.RDF;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.topbraid.jenax.progress.ProgressMonitor;
import org.topbraid.jenax.util.ARQFactory;
import org.topbraid.jenax.util.RDFLabels;
import org.topbraid.shacl.arq.SHACLFunctions;
import org.topbraid.shacl.engine.ShapesGraph;
import org.topbraid.shacl.validation.ValidationEngine;
import org.topbraid.shacl.validation.ValidationEngineFactory;
import org.topbraid.shacl.validation.sparql.AbstractSPARQLExecutor;
import org.topbraid.shacl.vocabulary.TOSH;

public class ShaclValidator {

	private Logger log = LoggerFactory.getLogger(this.getClass().getName());
	
	/**
	 * The model containing the original shapes
	 */
	protected Model shapesModel;
	
	/**
	 * A ProgressMonitor (that will store all progress logs in a StringBuffer, or log them in a log stream)
	 */
	protected ProgressMonitor progressMonitor;
	
	public ShaclValidator(Model shapesModel) {
		super();
		
		// stores the original shapes Model
		this.shapesModel = shapesModel;
	}
	
	public Model validate(Model dataModel) throws ShaclValidatorException {
		log.info("Validating data with "+dataModel.size()+" triples...");
			
		Model validatedModel = dataModel;
		
		// Ensure that the SHACL, DASH and TOSH graphs are present in the shapes Model
		Model actualShapesModel = ModelFactory.createDefaultModel();
		actualShapesModel.add(shapesModel);
		
		if(!actualShapesModel.contains(TOSH.hasShape, RDF.type, (RDFNode)null)) { // Heuristic
			Model unionModel = org.topbraid.shacl.util.SHACLSystemModel.getSHACLModel();
			MultiUnion unionGraph = new MultiUnion(new Graph[] {
				unionModel.getGraph(),
				actualShapesModel.getGraph()
			});
			actualShapesModel = ModelFactory.createModelForGraph(unionGraph);
		}
		
		// Make sure all sh:Functions are registered
		SHACLFunctions.registerFunctions(actualShapesModel);
		
		// Create Dataset that contains both the data model and the shapes model
		// (here, using a temporary URI for the shapes graph)
		URI shapesGraphURI = URI.create("urn:x-shacl-shapes-graph:" + UUID.randomUUID().toString());
		Dataset dataset = ARQFactory.get().getDataset(validatedModel);
		dataset.addNamedModel(shapesGraphURI.toString(), actualShapesModel);
		
		// Run the validator
		ShapesGraph shapesGraph = new ShapesGraph(actualShapesModel);
		
		ValidationEngine engine = ValidationEngineFactory.get().create(
				// the Dataset to validate
				dataset,
				// the URI of the shapes graph in the dataset
				shapesGraphURI,
				// the shapes graph
				shapesGraph,
				// an optional Report resource
				null);
		
//		ValidationEngineConfiguration config = new ValidationEngineConfiguration();
//		// set this to improve details of AndConstraintComponent or OrConstraintComponent
//		config.setReportDetails(true);
//		config.setValidateShapes(false);
//		engine.setConfiguration(config);
		
		// set this to improve details of AndConstraintComponent or OrConstraintComponent
		AbstractSPARQLExecutor.createDetails = true;
		
		// set custom label function to properly display lists
		engine.setLabelFunction(v -> {
			if(v.isResource() && v.canAs( RDFList.class )) {
				return "["+v.as( RDFList.class ).asJavaList().stream().map(node -> RDFLabels.get().getNodeLabel(node)).collect(Collectors.joining(", "))+"]";
			}
			return RDFLabels.get().getNodeLabel(v);
		});
		
		// sets the progress monitor
		engine.setProgressMonitor(this.progressMonitor);
		
		try {
			Resource report = engine.validateAll();
			Model results = report.getModel();
			
			// register prefixes for nice validation report output in ttl
			results.setNsPrefixes(validatedModel.getNsPrefixMap());
			shapesModel.getNsPrefixMap().entrySet().stream().forEach(e -> { results.setNsPrefix(e.getKey(), e.getValue()); });
			
			// Number of validation results : results.listSubjectsWithProperty(RDF.type, SH.ValidationResult).toList().size()
			log.info("Done validating data with "+dataModel.size()+" triples. Validation results contains "+results.size()+" triples.");
			
			return results;			
			
		} catch (InterruptedException e) {
			throw new ShaclValidatorException();
		}
	}

	public void setProgressMonitor(ProgressMonitor progressMonitor) {
		this.progressMonitor = progressMonitor;
	}
	
}
