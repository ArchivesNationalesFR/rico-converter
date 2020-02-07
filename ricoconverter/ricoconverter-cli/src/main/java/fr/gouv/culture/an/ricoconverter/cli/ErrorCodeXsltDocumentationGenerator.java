package fr.gouv.culture.an.ricoconverter.cli;

import java.io.ByteArrayOutputStream;
import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.io.FileUtils;

import fr.sparna.commons.xml.TransformerBuilder;

public class ErrorCodeXsltDocumentationGenerator {

	public static void main(String[] args) throws Exception {
		
		StringBuffer sb = new StringBuffer();
		sb.append("[_Home_](index.html) > EAC XSLT Error Codes"+"\n");
		sb.append("# EAC 2 RiC-O XSLT Error Codes"+"\n");
		sb.append("_note : this file is automatically generated from the XML eac2rico-codes.xml file._"+"\n");
		sb.append("\n");
		
		Transformer transformer = TransformerBuilder.createSaxonProcessor().createTransformer(new StreamSource(ErrorCodeXsltDocumentationGenerator.class.getResourceAsStream("/errorCodes2md.xslt")));
		ByteArrayOutputStream resultBa = new ByteArrayOutputStream();
		
		transformer.transform(
				new StreamSource(ErrorCodeXsltDocumentationGenerator.class.getResourceAsStream("/xslt_eac/eac2rico-codes.xml")),
				new StreamResult(resultBa)
		);
		sb.append(resultBa.toString());

		File outputFile = new File(args[0]);
		FileUtils.write(outputFile, sb.toString(), "UTF-8");
		
		
		StringBuffer sb2 = new StringBuffer();
		sb2.append("[_Home_](index.html) > EAD XSLT Error Codes"+"\n");
		sb2.append("# EAD 2 RiC-O XSLT Error Codes"+"\n");
		sb2.append("_note : this file is automatically generated from the XML ead2rico-codes.xml file._"+"\n");
		sb2.append("\n");
		
		ByteArrayOutputStream resultBa2 = new ByteArrayOutputStream();
		
		transformer.transform(
				new StreamSource(ErrorCodeXsltDocumentationGenerator.class.getResourceAsStream("/xslt_ead/ead2rico-codes.xml")),
				new StreamResult(resultBa2)
		);
		sb2.append(resultBa2.toString());

		File outputFile2 = new File(args[1]);
		FileUtils.write(outputFile2, sb2.toString(), "UTF-8");
	}
	
}
