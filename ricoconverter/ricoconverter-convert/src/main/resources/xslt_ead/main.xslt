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
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl"
>
	<xsl:output indent="yes" method="xml" />

	<!-- ***** Stylesheet Parameters ***** -->

	<!-- Pattern to be used to detect RecordSet from the @otherlevel attribute -->
	<xsl:param name="OTHERLEVEL_RECORDSET_PATTERN">dossier|fonds|serie|série|articles|groupe-de-pieces|collection|subgrp|sbgrp</xsl:param>
	
	<!-- Indicates the root of the URI that will be generated -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>

	<!-- Indicates the URI to be used as value for authors -->
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/agent/005061</xsl:param>

	<!-- Indicates the language code that will be inserted for literal values. -->
	<xsl:param name="LITERAL_LANG">fr</xsl:param>

	<!-- Indicates the base URL to use when processing relative links -->
	<xsl:param name="BASE_URL_FOR_RELATIVE_LINKS">https://www.siv.archives-nationales.culture.gouv.fr/mm/media/download/</xsl:param>

	<xsl:param name="VOCABULARY_LANGUAGES">../vocabularies/referentiel_languages.rdf</xsl:param>

	<xsl:param name="VOCABULARY_DOCUMENTARY_FORM_TYPES">../vocabularies/FRAN_RI_001_documentaryFormTypes.rdf</xsl:param>

	<xsl:param name="VOCABULARY_RECORD_STATES">../vocabularies/FRAN_RI_001_recordStates.rdf</xsl:param>

	<xsl:param name="VOCABULARY_RECORD_SET_TYPES">../vocabularies/FRAN_RI_001_recordSetTypes.rdf</xsl:param>

	<!-- 
		This is the entry point stylesheet to convert EAD to RiC-O.
		By default this XSLT does nothing by itself, and imports ead2rico.xslt which contains
		all the conversion logic.
		This stylesheet can be used to overwrite the behavior of certain templates from the
		ead2rico.xslt stylesheet (template rules in an imported stylesheet have lower import precedence than template rules in the importing stylesheet).
	-->
	<!-- Import ead2rico stylesheet -->
	<xsl:import href="ead2rico.xslt" />
		
	<!-- HERE : you can overwrite certain templates from ead2rico.xslt -->
	<!-- For example, you could decide that "dimensions" mathes rico:carrierExtent with a <span>
	instead of a <p> in the ead2rico stylesheet : -->

	<!--
	<xsl:template match="dimensions[normalize-space(.)]" mode="instantiation">
		<rico:carrierExtent rdf:parseType="Literal">
            <html:span xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:span>
        </rico:carrierExtent>
	</xsl:template>
	-->

</xsl:stylesheet>