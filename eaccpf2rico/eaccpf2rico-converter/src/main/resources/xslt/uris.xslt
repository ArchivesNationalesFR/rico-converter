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
>
		
	<xsl:function name="eac2rico:URI-Agent">
		<xsl:param name="recordId" />
		<xsl:value-of select="substring-after($recordId, 'FRAN_NP_')" />
	</xsl:function>	
		
	<xsl:function name="eac2rico:URI-Description">
		<xsl:param name="recordId" />
		<xsl:value-of select="concat('description/',substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-AgentName">
		<xsl:param name="recordId" />
		<xsl:param name="label" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', encode-for-uri($label), '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', encode-for-uri($label), '-', translate($fromDate, '-', ''), '-', 'unknown')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', encode-for-uri($label), '-', 'unknown', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', encode-for-uri($label))" />
			</xsl:otherwise>
		</xsl:choose>
		<!--
		<xsl:choose>
			<xsl:when test="$authorized = true()">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', 'authorized')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/AgentName/', $offset)" />
			</xsl:otherwise>
		</xsl:choose>
		 -->
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-ActivityRealizationRelation">
		<xsl:param name="recordId" />
		<xsl:param name="functionId" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/ActivityRealizationRelation/', $functionId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/ActivityRealizationRelation/', $functionId, '-', translate($fromDate, '-', ''), '-', 'unknown')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/ActivityRealizationRelation/', $functionId, '-', 'unknown', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(substring-after($recordId, 'FRAN_NP_'), '/ActivityRealizationRelation/', $functionId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-ActivityType">
		<xsl:param name="vocabularySource" />
		<xsl:value-of select="concat('http://data.archives-nationales.culture.gouv.fr', '/activityType/', 'FRAN_RI_', $vocabularySource)" />
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
	
</xsl:stylesheet>