package fr.gouv.culture.an.eaccpf2rico.convert;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.StringWriter;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.Node;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

import fr.gouv.culture.an.eaccpf2rico.Eac2RicoConverterException;
import fr.sparna.commons.xml.TransformerBuilder;
import junit.framework.AssertionFailedError;
import junit.framework.Test;
import junit.framework.TestResult;

/**
 * Don't rename this class otherwise it could be picked up by Maven plugin to execute test.
 * @author thomas
 *
 */
public class Eac2RicoXsltTestExecution implements Test {

	protected File testFolder;
	protected Eac2RicoConverter converter;
	
	public Eac2RicoXsltTestExecution(File testFolder) {
		super();
		this.testFolder = testFolder;
		
		// read the XSLT
		InputStream xsltSource = this.getClass().getResourceAsStream("/xslt/eac2rico.xslt");
		
		try {
			this.converter = new Eac2RicoConverter(TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(xsltSource)));
		} catch (TransformerConfigurationException e) {
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
			InputStream inputTest = new FileInputStream(input);
			DOMResult domResult = new DOMResult();
			try {
				converter.convert(new StreamSource(inputTest), domResult);
			} catch (Eac2RicoConverterException e) {
				result.addError(this, e);
			}
			System.out.println(nodeToString(domResult.getNode()));
			Diff diff = DiffBuilder
					.compare(Input.fromNode(domResult.getNode()).build())
					.ignoreWhitespace()
					.ignoreComments()
					.checkForSimilar()
					.withTest(Input.fromFile(expected).build())
					.build();
			if(diff.hasDifferences()) {
				result.addFailure(this, new AssertionFailedError(diff.toString()));
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

}
