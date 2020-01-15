<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:ead2rico="http://data.archives-nationales.culture.gouv.fr/ead2rico/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
>

	<!-- Load Codes from companion file -->
	<xsl:param name="CODES_FILE">ead2rico-codes.xml</xsl:param>
	<xsl:variable name="CODES" select="document($CODES_FILE)" />

	<!-- Outputs an error message -->
	<xsl:function name="ead2rico:error">
		<xsl:param name="recordId" />
		<xsl:param name="code" />
		<xsl:value-of select="error(
			QName('http://data.archives-nationales.culture.gouv.fr/eac2rico/', $code),
			concat($recordId, ' - ', $CODES/Codes/Code[@code = $code]/message, ' (code : ', $code, ')')
		)">
		</xsl:value-of>
	</xsl:function>	
	
	<!-- Output a warning message, basically an xsl:message with a code -->
	<xsl:function name="ead2rico:warning">
		<xsl:param name="recordId" />
		<xsl:param name="code" />
		<xsl:param name="message" />
		<xsl:message><xsl:value-of select="concat(if($recordId != '') then concat($recordId, ' - ') else '', $code, ' : ', concat($CODES/Codes/Code[@code = $code]/message, ' : ', $message))" /></xsl:message>
	</xsl:function>
	
	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<!-- Note the #all special keyword to apply this template to all modes -->
	<xsl:template match="*" mode="#all" />
	
	<!-- Overwrite built-in template to match all text nodes -->
	<!-- Otherwise line breaks are inserted in resulting XML files -->
	<!-- Note the #all special keyword to apply this template to all modes -->
	<xsl:template match="text()|@*" mode="#all"></xsl:template>
		
</xsl:stylesheet>