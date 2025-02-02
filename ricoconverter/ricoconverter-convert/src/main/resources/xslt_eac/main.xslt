<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:ead2rico="https://rdf.archives-nationales.culture.gouv.fr/ead2rico/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:isni="https://isni.org/ontology#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl"
>
	<xsl:output indent="yes" method="xml" />

	<!-- ***** Stylesheet parameters ***** -->

	<!-- Indicates the root of the URI that will be generated -->
	<xsl:param name="BASE_URI">https://rdf.archives-nationales.culture.gouv.fr/</xsl:param>

	<!-- Indicates the URI to be used as value for authors -->
	<xsl:param name="AUTHOR_URI">https://rdf.archives-nationales.culture.gouv.fr/agent/005061</xsl:param>	

	<!-- Indicates the language code that will be inserted for literal values -->
	<xsl:param name="LITERAL_LANG">fr</xsl:param>

	<!-- default language to use if the record has no language -->
	<xsl:param name="DEFAULT_LANGUAGE_IF_NO_LANGUAGECODE">fre</xsl:param>

	<!-- Indicates the path to the vocabulary file of rules, relative to the XSLT -->
	<xsl:param name="VOCABULARY_RULES">../vocabularies/referentiel_rules.rdf</xsl:param>

	<!-- Indicates the path to the vocabulary file of languages, relative to the XSLT -->
	<xsl:param name="VOCABULARY_LANGUAGES">../vocabularies/FRAN_RI_100_languages.rdf</xsl:param>

	<!-- 
		This is the entry point stylesheet to convert EAC to RiC-O.
		By default this XSLT does nothing by itself, and imports eac2rico.xslt which contains
		all the conversion logic.
		This stylesheet can be used to overwrite the behavior of certain templates from the
		eac2rico.xslt stylesheet (template rules in an imported stylesheet have lower import precedence than template rules in the importing stylesheet).
	-->
	<!-- Import eac2rico stylesheet -->
	<xsl:import href="eac2rico.xslt" />
		
	<!-- HERE : you can overwrite certain templates -->
	<!-- For example, you could decide that cpfRelation to wikipedia yield a rdfs:comment with
	a piece of text instead of a rdfs:seeAlso : -->

	<!--
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'identity']" mode="description">
        <xsl:if test="contains(@xlink:href, 'wikipedia.org')">
        	<rdfs:comment>Link to Wikipedia : <xsl:value-of select="@xlink:href" /></rdfs:comment>
        </xsl:if>
	</xsl:template>
	-->

</xsl:stylesheet>