<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
	xmlns:eaccpf="urn:isbn:1-931666-33-4"
>
	<xsl:output indent="yes" method="xml" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/corporateBody/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	
	<!-- Load Error Codes from companion file -->
	<xsl:param name="ERROR_CODES_FILE">eac2rico-errorCodes.xml</xsl:param>
	<xsl:variable name="ERROR_CODES">
		<xsl:value-of select="document($ERROR_CODES_FILE)" />
	</xsl:variable>
	
	<xsl:template match="/">
		<rdf:RDF>
			<!-- Sets xml:base on root this way, so that compilation of XSLT does not fail because it is not a URI -->
			<xsl:attribute name="xml:base" select="$BASE_URI" />
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="eaccpf:eac-cpf">		
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="eaccpf:control">			
		<!--  Example error triggering from XSLT -->
		<xsl:if test="not(eaccpf:recordId != '')">
			<xsl:value-of select="eac2rico:error('MISSING_RECORD_ID')" />
		</xsl:if>
		<rico:Description>
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Description(eaccpf:recordId)" /></xsl:call-template>
			<rico:describes><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Agent(eaccpf:recordId)" /></xsl:call-template></rico:describes>
			
			<xsl:apply-templates />
		</rico:Description>
	</xsl:template>
	
	<xsl:template match="eaccpf:cpfDescription">			
		<rdf:Description>
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Agent(../eaccpf:control/eaccpf:recordId)" /></xsl:call-template>
			<rico:isDescribedBy><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Description(../eaccpf:control/eaccpf:recordId)" /></xsl:call-template></rico:isDescribedBy>
			
			<xsl:apply-templates />
		</rdf:Description>
	</xsl:template>
	
	<xsl:template match="eaccpf:identity">			
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="eaccpf:entityType">
		<rdf:type>			
			<xsl:choose>
				<xsl:when test="text() = 'person'">
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri">http://www.ica.org/standards/RiC/ontology#Person</xsl:with-param></xsl:call-template>
				</xsl:when>
				<xsl:when test="text() = 'corporateBody'">
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri">http://www.ica.org/standards/RiC/ontology#CorporateBody</xsl:with-param></xsl:call-template>
				</xsl:when>
				<xsl:when test="text() = 'family'">
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri">http://www.ica.org/standards/RiC/ontology#Family</xsl:with-param></xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
				
				</xsl:otherwise>
			</xsl:choose>
		</rdf:type>
	</xsl:template>
	
	<xsl:template match="eaccpf:sources">			
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eaccpf:source">			
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eaccpf:sourceEntry">			
		<rico:source xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:source>
	</xsl:template>
	
	<xsl:template match="eaccpf:maintenanceAgency">
		<rico:authoredBy rdf:resource="{$AUTHOR_URI}" />
	</xsl:template>
		
		
	<xsl:function name="eac2rico:error">
		<xsl:param name="code" />
		<xsl:value-of select="error(
			xs:QName(concat('eac2rico:', $code)),
			concat($ERROR_CODES/ErrorCodes/ErrorCode[@code = $code]/message, ' (code :', $code, ')'))">
		</xsl:value-of>
	</xsl:function>	
		
	<xsl:function name="eac2rico:URI-Agent">
		<xsl:param name="recordId" />
		<xsl:value-of select="substring-after($recordId, 'FRAN_NP_')" />
	</xsl:function>	
		
	<xsl:function name="eac2rico:URI-Description">
		<xsl:param name="recordId" />
		<xsl:value-of select="concat('description/',substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>
	
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
	
	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<xsl:template match="*" />
	
	<!-- Overwrite built-in template to match all text nodes -->
	<!-- Otherwise line breaks are inserted in resulting XML files -->
	<xsl:template match="text()|@*"></xsl:template>
	
</xsl:stylesheet>