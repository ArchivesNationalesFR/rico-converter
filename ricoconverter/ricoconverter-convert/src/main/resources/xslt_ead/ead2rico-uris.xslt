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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
>
	
	<xsl:function name="ead2rico:URI-FindingAid">
		<xsl:param name="faId" />
		<xsl:value-of select="concat('findingAid/', $faId)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-RecordResource">
		<xsl:param name="recordResourceId" />
		<xsl:value-of select="concat('recordResource/', $recordResourceId)" />
	</xsl:function>	

	<xsl:function name="ead2rico:URI-Instantiation">
		<xsl:param name="instantiationId" />
		<xsl:value-of select="concat('instantiation/', $instantiationId)" />
	</xsl:function>	
	
	<xsl:template name="recordResourceId">
		<xsl:param name="faId" />
		<xsl:param name="recordResourceId" />
		
        <xsl:value-of
            select="concat($faId, '-', (if ($recordResourceId) then $recordResourceId else 'top') )"
        />		
	</xsl:template>
	
	<xsl:template name="rdf-about">
		<xsl:param name="uri" />
		<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:value-of select="normalize-space($uri)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="rdf-resource">
		<xsl:param name="uri" />
		<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:value-of select="normalize-space($uri)" />
		</xsl:attribute>
	</xsl:template>
	
</xsl:stylesheet>