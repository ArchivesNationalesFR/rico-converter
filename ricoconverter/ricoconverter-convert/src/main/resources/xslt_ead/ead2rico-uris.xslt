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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
>
	
	<!-- Load Languages from companion file -->
	<xsl:param name="VOCABULARY_LANGUAGES">../vocabularies/referentiel_languages.rdf</xsl:param>
	<xsl:variable name="LANGUAGES" select="document($VOCABULARY_LANGUAGES)" />
	
	<xsl:function name="ead2rico:URI-FindingAid">
		<xsl:param name="faId" />
		<xsl:value-of select="concat('record/', $faId)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-RecordResource">
		<xsl:param name="recordResourceId" />
		<xsl:value-of select="concat('recordResource/', $recordResourceId)" />
	</xsl:function>	

	<xsl:function name="ead2rico:URI-Instantiation">
		<xsl:param name="instantiationId" />
		<xsl:value-of select="concat('instantiation/', $instantiationId)" />
	</xsl:function>	

	<xsl:function name="ead2rico:URI-Language">
		<xsl:param name="langcode" />
		<xsl:variable name="idlocgov" select="concat('http://id.loc.gov/vocabulary/iso639-2/', $langcode)" />
<!-- 		<xsl:value-of select="$LANGUAGES/rdf:RDF/rico:Language[owl:sameAs/@rdf:resource = $idlocgov]/@rdf:about" /> -->

		<xsl:if test="not( $LANGUAGES/rdf:RDF/rico:Language[owl:sameAs/@rdf:resource = $idlocgov] )">
			<xsl:value-of select="ead2rico:warning($faId, 'UNKNOWN_LANGUAGE', $langcode)" />
		</xsl:if>

		<xsl:value-of select="$LANGUAGES/rdf:RDF/rico:Language[owl:sameAs/@rdf:resource = $idlocgov]/@rdf:about" />
	</xsl:function>

	<xsl:function name="ead2rico:URI-DocumentaryForm">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('documentaryFormType/', $source, '-', $authfilenumber)" />
	</xsl:function>

	<xsl:function name="ead2rico:URI-Place">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('place/', $source, '-', $authfilenumber)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-Thing">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('thing/', $source, '-', $authfilenumber)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-Agent">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('agent/', $source, '-', $authfilenumber)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-AgentFromFRAN_NP">
		<xsl:param name="FRAN_NP" />
		<xsl:value-of select="concat('agent/', substring-after($FRAN_NP, 'FRAN_NP_'))" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-OccupationType">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('occupationType/', $source, '-', $authfilenumber)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-ActivityType">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:value-of select="concat('activityType/', $source, '-', $authfilenumber)" />
	</xsl:function>
	
	<xsl:function name="ead2rico:URI-RepresentationOrCarrierType">
		<xsl:param name="authfilenumber" />
		<xsl:param name="source" />
		<xsl:choose>
			<xsl:when test="$authfilenumber = 'd3nd9y3c6o-iu0j3xsmoisx' or $authfilenumber = 'd3nd9xpopj-ckdrv6ljeqeg'">
				<xsl:value-of select="concat('representationType/', $source, '-', $authfilenumber)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('carrierType/', $source, '-', $authfilenumber)" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<xsl:function name="ead2rico:URL-IRorUD">
		<xsl:param name="href" />
		<xsl:choose>
			<xsl:when test="contains($href, '#')">
				<xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/', substring-before($href, '#'), '/', substring-after($href, '#'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/', $href)" />
			</xsl:otherwise>
		</xsl:choose>
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