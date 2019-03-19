<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
>
	<xsl:output indent="yes" method="text" />
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="ErrorCodes">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="ErrorCode">
## <xsl:value-of select="@code"></xsl:value-of>
  - code : <xsl:value-of select="@code"></xsl:value-of>
  - message : <xsl:value-of select="message"></xsl:value-of>
	</xsl:template>
	
</xsl:stylesheet>