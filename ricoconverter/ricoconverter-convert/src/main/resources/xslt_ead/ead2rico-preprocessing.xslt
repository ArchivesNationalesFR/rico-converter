<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Preprocesses the input EAD files before the actual conversion to RiC-O is done.
	This filters out the elements based on the @audience attribute; other preprocessings could be applied as well.
	The result of the preprocessing is sent to the conversion.
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
	
	<xsl:param name="FILTER_INTERNAL">true</xsl:param>
	<xsl:param name="FILTER_EXTERNAL">false</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:choose>
			<xsl:when test="@audience='internal' and $FILTER_INTERNAL = true()">
				<!-- Don't copy node is audience is internal -->
			</xsl:when>
			<xsl:when test="@audience='external' and $FILTER_EXTERNAL = true()">
				<!-- Don't copy node if audience is external and we were asked to filter out external audiences -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="attribute::*"/>
					<xsl:apply-templates />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
			
</xsl:stylesheet>