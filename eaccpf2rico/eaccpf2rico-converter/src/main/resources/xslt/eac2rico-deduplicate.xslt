<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
>

	<!-- Import builtins stylesheet -->
	<xsl:import href="eac2rico-builtins.xslt" />

	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<xsl:apply-templates />	
	</xsl:template>
	
	<xsl:template match="rdf:RDF">
		<xsl:copy>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="rdf:RDF/*">
		<xsl:variable name="thisUri" select="@rdf:about" />
		<xsl:choose>
			<!-- copy only if it is the first element in the file -->
			<xsl:when test="count(preceding-sibling::*[@rdf:about = $thisUri]) = 0">
				<xsl:copy-of select="." />
				
				<xsl:choose>
					<!-- if this is the only relation with an inverse missing, issue a warning -->
					<xsl:when test="count(following-sibling::*[@rdf:about = $thisUri]) = 0">
						<xsl:value-of select="eac2rico:warning('', 'RELATION_IN_ONE_DIRECTION_ONLY', $thisUri)" />
					</xsl:when>
					<!-- if the relation is in the file more than twice, issued a warning -->
					<xsl:when test="count(following-sibling::*[@rdf:about = $thisUri]) > 1">
						<xsl:value-of select="eac2rico:warning('', 'MORE_THAN_TWO_RELATIONS', $thisUri)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning('', 'RELATION_SUCCESSFULLY_DEDUPLICATED', $thisUri)" />
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<xsl:otherwise>
			
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
</xsl:stylesheet>