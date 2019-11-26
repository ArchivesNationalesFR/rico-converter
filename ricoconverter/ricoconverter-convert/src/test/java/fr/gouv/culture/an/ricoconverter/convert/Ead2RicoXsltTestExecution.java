package fr.gouv.culture.an.ricoconverter.convert;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.StringWriter;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.Node;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.ComparisonResult;
import org.xmlunit.diff.Diff;
import org.xmlunit.diff.Difference;

import fr.gouv.culture.an.ricoconverter.RicoConverterException;
import fr.gouv.culture.an.ricoconverter.ead.convert.Ead2RicoConverter;
import fr.sparna.commons.xml.TransformerBuilder;
import junit.framework.AssertionFailedError;
import junit.framework.Test;
import junit.framework.TestResult;

/**
 * Don't rename this class otherwise it could be picked up by Maven plugin to execute test.
 * @author thomas
 *
 */
public class Ead2RicoXsltTestExecution implements Test {

	protected File testFolder;
	protected Ead2RicoConverter converter;
	
	public Ead2RicoXsltTestExecution(File testFolder) {
		super();
		this.testFolder = testFolder;
		
		// read the XSLT
		InputStream xsltSource = this.getClass().getResourceAsStream("/xslt_ead/ead2rico.xslt");
		
		try {
			Transformer t = TransformerBuilder.createSaxonProcessor().setUriResolver(new URIResolver() {

				@Override
				public Source resolve(String href, String base) throws TransformerException {
					// if we are given an absolute path, then read it as a File/URL, instead of classpath resource
					if(href.startsWith("file://")) {
						try {
							URL fileUrl = new URL(href);
							return new StreamSource(fileUrl.openStream());
						} catch (Exception e) {
							throw new TransformerException(e);
						}
					} else {
						return new StreamSource(Ead2RicoXsltTestExecution.class.getResourceAsStream("/xslt_ead/"+href));
					}
					
				}
				
			}).createTransformer(new StreamSource(xsltSource));

			URI relative = this.getClass().getResource("/xslt_ead/ead2rico.xslt").toURI().relativize(this.testFolder.toURI());
			System.out.println(new File(relative).getAbsolutePath());
			t.setParameter("INPUT_FOLDER", "file://"+new File(relative).getAbsolutePath());
			
			this.converter = new Ead2RicoConverter(t);
		} catch (TransformerConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	public int countTestCases() {
		return 1;
	}

	@Override
	public void run(TestResult result) {
		result.startTest(this);
		final File input = new File(this.testFolder, "input.xml");
		final File expected = new File(this.testFolder, "expected.xml");
		System.out.println("Testing "+input.getAbsolutePath());
		try {
			if(expected.exists()) {
				InputStream inputTest = new FileInputStream(input);
				DOMResult domResult = new DOMResult();
				try {
					converter.convert(new StreamSource(inputTest), domResult);
				} catch (RicoConverterException e) {
					result.addError(this, e);
				}
			
				System.out.println(nodeToString(domResult.getNode()));
				DiffBuilder builder = 
				DiffBuilder
						.compare(Input.fromFile(expected).build())
						.ignoreWhitespace()
						.ignoreComments()
						.checkForSimilar()
						.withTest(Input.fromNode(domResult.getNode()).build());
				
				// ignore rdfs:seeAlso always
				builder.withNodeFilter(node -> {
					return (
							node.getNodeType() != Node.ELEMENT_NODE
							||
							!node.getLocalName().equals("seeAlso")
					);
				});
				
				// ignore FindingAid if not on first unit test
				if(!this.testFolder.getName().contains("FindingAid")) {
					builder.withNodeFilter(node -> {
						return (
								node.getNodeType() != Node.ELEMENT_NODE
								||
								!node.getLocalName().equals("FindingAid")
						);
					});
				}
				
				// ignore heldBy except on repository tests
				if(!this.testFolder.getName().contains("repository")) {
					builder.withNodeFilter(node -> {
						return (
								node.getNodeType() != Node.ELEMENT_NODE
								||
								!node.getLocalName().equals("heldBy")
						);
					});
				}
				
				Diff diff = builder.build();
				
				List<Difference> differences = new ArrayList<>();
				diff.getDifferences().forEach(differences::add);
				
				// ignore differences in tags ordering
				if(differences.stream().anyMatch(d -> d.getResult() == ComparisonResult.DIFFERENT)) {
					result.addFailure(this, new AssertionFailedError("Test failed on "+this.testFolder+":\n"+diff.toString()));
				}
			} else {
				result.endTest(this);
			}
		} catch (FileNotFoundException e1) {
			result.addError(this, e1);
		}
		result.endTest(this);
	}
	
	private String nodeToString(Node node) {
		StringWriter sw = new StringWriter();
		try {
			Transformer t = TransformerFactory.newInstance().newTransformer();
			t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
			t.setOutputProperty(OutputKeys.INDENT, "yes");
			t.transform(new DOMSource(node), new StreamResult(sw));
		} catch (TransformerException te) {
			System.out.println("nodeToString Transformer Exception");
		}
		return sw.toString();
	}

	@Override
	public String toString() {
		return testFolder.getName();
	}
	
	

}
