package fr.sparna.commons.xml;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;

public class TransformerBuilder {

	protected String factoryClassName;
	protected URIResolver uriResolver;
	
	// private constructor
	private TransformerBuilder() {	
	}
	
	/**
	 * Creates a processor with JVM default processor
	 * @return
	 */
	public static TransformerBuilder createDefaultProcessor() {
		TransformerBuilder p = new TransformerBuilder();
		return p;
	}
	
	public static TransformerBuilder createSaxonProcessor() {
		TransformerBuilder p = new TransformerBuilder();
		p.factoryClassName = "net.sf.saxon.TransformerFactoryImpl";
		
		return p;
	}

	
	public Transformer createTransformer(Source xsltSource) 
	throws TransformerConfigurationException {
		TransformerFactory factory;
		if(this.factoryClassName != null) {
			factory = TransformerFactory.newInstance(this.factoryClassName, this.getClass().getClassLoader());
		} else {
			factory = TransformerFactory.newInstance();
		}
		
		if(this.uriResolver != null) {
			factory.setURIResolver(this.uriResolver);
		}		
		
		Transformer t = factory.newTransformer(xsltSource);
		// set indent to true
		t.setOutputProperty(OutputKeys.INDENT, "yes");
		// necessaire pour avoir une indentation (avec l'implementation par defaut)
		// see http://stackoverflow.com/questions/1384802/java-how-to-indent-xml-generated-by-transformer
		t.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
		return t;
	}

	public String getFactoryClassName() {
		return factoryClassName;
	}

	public void setFactoryClassName(String factoryClassName) {
		this.factoryClassName = factoryClassName;
	}

	public URIResolver getUriResolver() {
		return uriResolver;
	}

	public TransformerBuilder setUriResolver(URIResolver uriResolver) {
		this.uriResolver = uriResolver;
		return this;
	}
	
}
