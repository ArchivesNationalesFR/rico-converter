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
	exclude-result-prefixes="eac eac2rico xlink xs xsi xsl"
>
	<xsl:output indent="yes" method="xml" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="INPUT_FOLDER">/home/thomas/sparna/00-Clients/AN-FlorenceClavaud/02-ConversionNotices/20-Sources/input</xsl:param>
	<xsl:param name="OUTPUT_AGENTS_FOLDER">agents</xsl:param>
	<xsl:param name="OUTPUT_RELATIONS_FOLDER">relations</xsl:param>
	<xsl:param name="OUTPUT_PLACES_FOLDER">places</xsl:param>


	<!-- Match the root of dummy input file -->
	<xsl:template match="/">
		<xsl:message>Arranging input folder <xsl:value-of select="$INPUT_FOLDER" /></xsl:message>
		<xsl:variable name="inputCollection" select="collection(concat($INPUT_FOLDER, '?recurse=yes;on-error=warning'))" />
		
		<!-- Fetch the base URI from the first doc in the collection -->
		<xsl:variable name="BASE_URI" select="$inputCollection[position() = 1]/rdf:RDF/@xml:base" />
		
		<!-- Generate a single output document to gather rico:AgentHierarchicalRelation... -->
		<xsl:message>Arranging rico:AgentHierarchicalRelation...</xsl:message>
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_agentHierarchicalRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentHierarchicalRelation -->
					<xsl:apply-templates select="rdf:RDF/rico:AgentHierarchicalRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>
		
		<!-- Generate a single output document to gather rico:AgentTemporalRelation... -->
		<xsl:message>Arranging rico:AgentTemporalRelation...</xsl:message>
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_agentTemporalRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentTemporalRelation -->
					<xsl:apply-templates select="rdf:RDF/rico:AgentTemporalRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>

		<!-- Generate a single output document to gather rico:MembershipRelation... -->
		<xsl:message>Arranging rico:MembershipRelation...</xsl:message>
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_membershipRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentTemporalRelation -->
					<xsl:apply-templates select="rdf:RDF/rico:MembershipRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>
		
		<!-- Generate a single output document to gather rico:WorkRelation... -->
		<xsl:message>Arranging rico:WorkRelation...</xsl:message>
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_workRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:WorkRelation -->
					<xsl:apply-templates select="rdf:RDF/rico:WorkRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>

		<!-- Generate a single output document to gather rico:FamilyRelation... -->
		<xsl:message>Arranging rico:FamilyRelation...</xsl:message>
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_familyRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentToAgentRelations -->
					<xsl:apply-templates select="rdf:RDF/rico:FamilyRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>

		<!-- Generate a single output document to gather rico:AgentToAgentRelation... -->
		<xsl:message>Arranging rico:AgentToAgentRelation...</xsl:message>	
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_agentToAgentRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentToAgentRelations -->
					<xsl:apply-templates select="rdf:RDF/rico:AgentToAgentRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>
		
		<!-- Generate a single output document to gather rico:AgentOriginationRelation... -->
		<xsl:message>Arranging rico:AgentOriginationRelation...</xsl:message>	
		<xsl:result-document href="{concat($OUTPUT_RELATIONS_FOLDER, '/', 'FRAN_agentOriginationRelations.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:AgentOriginationRelation -->
					<xsl:apply-templates select="rdf:RDF/rico:AgentOriginationRelation" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>

		<!-- Generate a single output document to gather rico:Place... -->
		<xsl:message>Arranging rico:Place...</xsl:message>	
		<xsl:result-document href="{concat($OUTPUT_PLACES_FOLDER, '/', 'FRAN_places.rdf')}" method="xml" encoding="utf-8" indent="yes">
			<rdf:RDF>
				<xsl:attribute name="xml:base" select="$BASE_URI" />
				<!-- Iterate again... -->
				<xsl:for-each select="$inputCollection">		
					<!-- Collect all nodes rico:Place -->
					<xsl:apply-templates select="rdf:RDF/rico:Place" mode="copyMe"/>						
				</xsl:for-each>
			</rdf:RDF>
		</xsl:result-document>

		<!-- Iterate on each file in the input folder... -->
		<xsl:message>Copying files excluding relations and places...</xsl:message>
		<xsl:for-each select="$inputCollection">	
			<!-- Generate a document with the same name in the output folder -->	
			<xsl:result-document href="{concat($OUTPUT_AGENTS_FOLDER, '/', tokenize(document-uri(.),'/')[last()])}" method="xml" encoding="utf-8" indent="yes">
				<!-- Copy everything except relations in that document, and places -->
				<xsl:apply-templates mode="copyAllExceptRelationsAndPlaces"/>
			</xsl:result-document>
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="*" mode="copyAllExceptRelationsAndPlaces">
		<xsl:copy>
			<xsl:copy-of select="attribute::*"/>
			<xsl:copy-of select="node()[
				not(self::rico:AgentToAgentRelation) and
				not(self::rico:AgentHierarchicalRelation) and
			 	not(self::rico:AgentTemporalRelation) and
			 	not(self::rico:FamilyRelation) and
			 	not(self::rico:MembershipRelation) and
			 	not(self::rico:WorkRelation) and
			 	not(self::rico:AgentOriginationRelation) and
			 	not(self::rico:Place)
			]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*" mode="copyMe">
		<xsl:copy-of select="."/>
	</xsl:template>
		
</xsl:stylesheet>