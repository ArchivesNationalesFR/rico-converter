<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="eac eac2rico xlink xs xsi xsl"
>

	<xsl:output indent="no" method="text" />
	
	<xsl:template match="/">
declare -a arr=(
<xsl:apply-templates select="properties/property" />)
	</xsl:template>

	<xsl:template match="property">
		<xsl:if test="NEW_OBJECT_PROPERTY_NAME">"<xsl:value-of select="object_property_name" />|<xsl:value-of select="NEW_OBJECT_PROPERTY_NAME" />"<xsl:text>&#xa;</xsl:text></xsl:if>
	</xsl:template>
		
</xsl:stylesheet>