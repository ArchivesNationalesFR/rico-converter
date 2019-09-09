<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:ead2rico="http://data.archives-nationales.culture.gouv.fr/ead2rico/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl"
>
	<!-- Import URI stylesheet -->
	<xsl:import href="ead2rico-uris.xslt" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="ead2rico-builtins.xslt" />

	<xsl:output indent="yes" method="xml" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/agent/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	<xsl:param name="INPUT_FOLDER">.</xsl:param>

	<!--  Global variable for faId to reference it in functions -->
	<xsl:variable name="faId" select="substring-after(/ead/eadheader/eadid, 'FRAN_IR_')" />
	
	<xsl:template match="/">
		<rdf:RDF>
			<!-- Sets xml:base on root this way, so that compilation of XSLT does not fail because it is not a URI -->
			<xsl:attribute name="xml:base" select="$BASE_URI" />
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="ead">
		<rico:FindingAid rdf:about="{ead2rico:URI-FindingAid($faId)}">			
			<xsl:apply-templates select="archdesc" />
		</rico:FindingAid>
	</xsl:template>
	
	<xsl:template match="archdesc">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>	
	
		<rico:hasMainSubject>
			<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">
				<rico:isMainSubjectOf rdf:resource="{ead2rico:URI-FindingAid($faId)}" />
				
				<rico:hasInstantiation>
					<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($recordResourceId)}">
						<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					</rico:Instantiation>
				</rico:hasInstantiation>
				
				<xsl:apply-templates select="dsc" />
			</rico:RecordResource>
		</rico:hasMainSubject>
	</xsl:template>
	
	<xsl:template match="dsc">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="c">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="parentRecordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="parent::*/@id" />
			</xsl:call-template>
		</xsl:variable>
	
		<rico:hasMember>
			<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">
				<rico:isMemberOf rdf:resource="{ead2rico:URI-RecordResource($parentRecordResourceId)}" />
				
				<rico:hasInstantiation>
					<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($recordResourceId)}">
						<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					</rico:Instantiation>
				</rico:hasInstantiation>
				
				<xsl:apply-templates />
			</rico:RecordResource>
		</rico:hasMember>
	</xsl:template>
		
</xsl:stylesheet>