<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Splits an RDF/XML RICO file into multiple files.
	This can be launched directly by gving the input RDF/XML file as an input (the RDF/XML file must be an output of the ricoconverter).
 -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:ead2rico="http://data.archives-nationales.culture.gouv.fr/ead2rico/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl"
>
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="rdf:RDF">
		<xsl:variable name="outputFile" select="concat('RecordResource_', tokenize(rico:RecordResource[1]/@rdf:about,'/')[last()], '.rdf')" />
		<xsl:result-document href="{$outputFile}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:copy-of select="attribute::*"/>
				<xsl:copy-of select="rico:Record" />
				<xsl:copy-of select="rico:RecordResource[1]" />
			</rdf:RDF>
		</xsl:result-document>
		
		<xsl:apply-templates select="rico:RecordResource[position() > 1]" />
	</xsl:template>
	
	<xsl:template match="rico:RecordResource">
		<xsl:variable name="outputFile" select="concat('RecordResource_', tokenize(@rdf:about,'/')[last()], '.rdf')" />
		<xsl:message>Splitting in output file <xsl:value-of select="$outputFile" /></xsl:message>
		<xsl:result-document href="{$outputFile}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:copy-of select="/rdf:RDF/attribute::*"/>
				<xsl:copy-of select="." />
			</rdf:RDF>
		</xsl:result-document>
	</xsl:template>
		
</xsl:stylesheet>