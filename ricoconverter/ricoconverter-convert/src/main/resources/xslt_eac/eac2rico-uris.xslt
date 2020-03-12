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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
>
			
	<!-- Load LegalStatuses from companion file -->
	<xsl:param name="VOCABULARY_LEGAL_STATUSES">../vocabularies/FRAN_RI_104_Ginco_legalStatuses.rdf</xsl:param>
	<xsl:variable name="LEGAL_STATUSES" select="document($VOCABULARY_LEGAL_STATUSES)" />
	
	<!-- Load Rules from companion file -->
	<xsl:param name="VOCABULARY_RULES">../vocabularies/referentiel_rules.rdf</xsl:param>
	<xsl:variable name="RULES" select="document($VOCABULARY_RULES)" />
	
	<!-- Load Languages from companion file -->
	<xsl:param name="VOCABULARY_LANGUAGES">../vocabularies/referentiel_languages.rdf</xsl:param>
	<xsl:variable name="LANGUAGES" select="document($VOCABULARY_LANGUAGES)" />
	
	<!-- We have both a template and a function 'URI-Agent'. The template works on the current notice, the function is used to compute the URI is relation values -->
	<xsl:template name="URI-Agent">
<!-- 		<xsl:value-of select="eac2rico:URI-Agent(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType, /eac:eac-cpf/eac:control/eac:recordId)" /> -->
		<xsl:value-of select="eac2rico:URI-Agent('agent', /eac:eac-cpf/eac:control/eac:recordId)" />
	</xsl:template>	
	<xsl:function name="eac2rico:URI-Agent">
		<xsl:param name="entityType" />
		<xsl:param name="recordId" />		
<!-- 		<xsl:value-of select="concat($entityType, '/', substring-after($recordId, 'FRAN_NP_'))" /> -->
		<xsl:value-of select="concat('agent', '/', substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>	
	
	<!-- URI for an Agent described in an external file : lookup the file of this Agent based on its ID in the input folder, and reads the entityType in it -->
	<xsl:function name="eac2rico:URI-AgentExternal">
		<xsl:param name="externalEntityId" />
		<xsl:param name="externalEntityDescription" />

		<!-- Disable the type fetching to built external Agent URI. Keeping always '/agent' -->
		<!--
		<xsl:variable name="externalEntityTypeValue" select="$externalEntityDescription/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />

		<xsl:variable name="externalEntityType">
			<xsl:choose>
				<xsl:when test="$externalEntityTypeValue">
					<xsl:value-of select="$externalEntityTypeValue" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>agent</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="eac2rico:URI-Agent($externalEntityType, $externalEntityId)" />
		-->
		<xsl:value-of select="eac2rico:URI-Agent('agent', $externalEntityId)" />
	</xsl:function>	
	
	<!--  re-extract Agent ID from Agent URI -->
	<xsl:function name="eac2rico:AgentIdFromURI">
		<xsl:param name="AgentURI" />
		<xsl:value-of select="substring-after($AgentURI, '/')" />
	</xsl:function>
		
	<xsl:function name="eac2rico:URI-Record">
		<xsl:param name="recordId" />
		<xsl:value-of select="concat('record/',substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-Instantiation">
		<xsl:param name="recordId" />
		<xsl:value-of select="concat('instantiation/',substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>

	<xsl:function name="eac2rico:URI-Language">
		<xsl:param name="langcode" />
		<xsl:variable name="idlocgov" select="concat('http://id.loc.gov/vocabulary/iso639-2/', $langcode)" />

		<xsl:if test="not( $LANGUAGES/rdf:RDF/rico:Language[owl:sameAs/@rdf:resource = $idlocgov] )">
			<xsl:value-of select="eac2rico:warning($recordId, 'UNKNOWN_LANGUAGE', $langcode)" />
		</xsl:if>

		<xsl:value-of select="$LANGUAGES/rdf:RDF/rico:Language[owl:sameAs/@rdf:resource = $idlocgov]/@rdf:about" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-AgentName">
		<xsl:param name="recordId" />
		<xsl:param name="label" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'agentName',
   			substring-after($recordId, 'FRAN_NP_'),
   			encode-for-uri($label),
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-PerformanceRelation">
		<xsl:param name="recordId" />
		<xsl:param name="functionId" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'performanceRelation',
   			substring-after($recordId, 'FRAN_NP_'),
   			$functionId,
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-ActivityType">
		<xsl:param name="vocabularySource" />
		<xsl:value-of select="concat('activityType/', 'FRAN_RI_011-', $vocabularySource)" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-OccupationType">
		<xsl:param name="vocabularySource" />
		<xsl:value-of select="concat('occupationType/', 'FRAN_RI_010-', $vocabularySource)" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-AgentHierarchicalRelation">
		<xsl:param name="parent" />
		<xsl:param name="child" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'agentHierarchicalRelation',
   			substring-after($parent, 'FRAN_NP_'),
   			substring-after($child, 'FRAN_NP_'),
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>

	<xsl:function name="eac2rico:URI-AgentTemporalRelation">
		<xsl:param name="before" />
		<xsl:param name="after" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'agentTemporalRelation',
   			substring-after($before, 'FRAN_NP_'),
   			substring-after($after, 'FRAN_NP_'),
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>

	<xsl:function name="eac2rico:URI-AgentRelation">
		<xsl:param name="baseType" />
		<xsl:param name="first" />
		<xsl:param name="second" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:choose>
			<xsl:when test="$baseType = 'rico:AgentHierarchicalRelation'">
				<xsl:value-of select="eac2rico:URI-Anything(
					'agentHierarchicalRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:when>
			<xsl:when test="$baseType = 'rico:MembershipRelation'">
				<xsl:value-of select="eac2rico:URI-Anything(
					'membershipRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:when>
			<xsl:when test="$baseType = 'rico:WorkRelation'">
				<xsl:value-of select="eac2rico:URI-Anything(
					'workRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="eac2rico:URI-Anything(
					'agentToAgentRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:otherwise>
		</xsl:choose>
			
	</xsl:function>

	<!-- special case : the URI prefix is passed from the outside and not defined here -->
	<xsl:function name="eac2rico:URI-FamilyRelation">
		<xsl:param name="baseType" />
		<xsl:param name="first" />
		<xsl:param name="second" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		
		<xsl:choose>
			<xsl:when test="$baseType = 'rico:FamilyRelation'">
				<xsl:value-of select="eac2rico:URI-Anything(
					'familyRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:when>
			<xsl:when test="$baseType = 'rico:MembershipRelation'">
				<xsl:value-of select="eac2rico:URI-Anything(
					'membershipRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="eac2rico:URI-Anything(
					'agentToAgentRelation',
		   			$first,
		   			$second,
		   			$fromDate,
		   			$toDate)"
		   		/>
			</xsl:otherwise>
		</xsl:choose>
		

	</xsl:function>


	<xsl:function name="eac2rico:URI-OriginationRelation">
		<xsl:param name="recordResource" />
		<xsl:param name="entity" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<!-- Note how # is changed into '-' -->
		<xsl:variable name="recordResourceId" select="translate(substring-after($recordResource, 'FRAN_IR_'), '#', '-')" />
		<xsl:variable name="entityId" select="substring-after($entity, 'FRAN_NP_')" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'agentOriginationRelation',
   			$recordResourceId,
   			$entityId,
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-RelationToType">
		<xsl:param name="recordId" />
		<xsl:param name="type" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'relationToType',
   			substring-after($recordId, 'FRAN_NP_'),
   			$type,
   			$fromDate,
   			$toDate)"
   		/>
	</xsl:function>

	<xsl:function name="eac2rico:URI-Anything">
		<xsl:param name="prefix" />
		<xsl:param name="first" />
		<xsl:param name="second" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat($prefix, '/', $first, '-', $second, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat($prefix, '/', $first, '-', $second, '-', translate($fromDate, '-', ''), '-', '*')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat($prefix, '/', $first, '-', $second, '-', '*', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($prefix, '/', $first, '-', $second)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	
	<xsl:function name="eac2rico:URI-LegalStatus">
		<xsl:param name="vocabularySource" />
		<xsl:variable name="gincoId" select="concat('FRAN_RI_104.xml#', $vocabularySource)" />
		<xsl:value-of select="$LEGAL_STATUSES/rdf:RDF/skos:Concept[ginco:id = $gincoId]/@rdf:about" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-MandateFromEli">
		<xsl:param name="eli" />
		<xsl:value-of select="$RULES/rdf:RDF/*[owl:sameAs/@rdf:resource = $eli]/@rdf:about" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-RelationToMandate">
		<xsl:param name="recordId" />
		<xsl:param name="eliOrVocabularyId" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:value-of select="eac2rico:URI-Anything(
			'ruleRelation',
   			substring-after($recordId, 'FRAN_NP_'),
   			if(contains($eliOrVocabularyId, 'eli/')) then concat('eli-', translate(substring-after($eliOrVocabularyId, 'eli/'), '/', '-')) else substring-after($eliOrVocabularyId, 'rule/'),
   			$fromDate,
   			$toDate)"
   		/>		
	</xsl:function>
	
    <!--
       http://data.bnf.fr/ark:/12148/cb11863993z
       http://catalogue.bnf.fr/ark:/12148/cb11863993z/PUBLIC
       http://catalogue.bnf.fr/ark:/12148/cb11863993z/PUBLIC
       http://data.bnf.fr/ark:/12148/cb11863993z#foaf:Organization
       http://catalogue.bnf.fr/ark:/12148/cb11904421w
       http://data.bnf.fr/ark:/12148/cb11862469g
    -->
	<xsl:template name="URI-cpfRelationIdentity">
		<xsl:param name="lnk" />
		<xsl:param name="entityType" />
		<xsl:choose>
		   <!-- links to BNF -->
           <xsl:when test="contains($lnk, 'bnf.fr')">
               <xsl:choose>
                   <xsl:when test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and contains($lnk, '/PUBLIC')">
                     <xsl:text>https://data.bnf.fr/ark:/12148/</xsl:text>
                     <xsl:value-of select="substring-before(substring-after($lnk, 'catalogue.bnf.fr/ark:/12148/'), '/PUBLIC')"/>
                     <xsl:text>#about</xsl:text>
                   </xsl:when>
                   <xsl:when test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and not(contains($lnk, '/PUBLIC'))">
                     <xsl:text>https://data.bnf.fr/ark:/12148/</xsl:text>
                     <xsl:value-of select="substring-after($lnk, 'catalogue.bnf.fr/ark:/12148/')"/>
                     <xsl:text>#about</xsl:text>
                   </xsl:when>
                   <xsl:when test="contains($lnk, 'data.bnf.fr/ark:/12148/')">
                   	 <xsl:choose>
                   	 	<xsl:when test="contains($lnk, '#about')">
                   	 		<xsl:value-of select="$lnk"/>
                   	 	</xsl:when>
                   	 	<xsl:otherwise><xsl:value-of select="$lnk"/><xsl:text>#about</xsl:text></xsl:otherwise>
                   	 </xsl:choose>
                   </xsl:when>
               </xsl:choose>
           </xsl:when>
           <!-- links to Wikipedia -->
           <!-- exemple : http://fr.dbpedia.org/page/Henri_Labrouste, https://fr.wikipedia.org/wiki/Henri_Labrouste -->
           <xsl:when test="contains($lnk, 'wikipedia.org')">
               <xsl:text>http://fr.dbpedia.org/resource/</xsl:text>
               <xsl:value-of
                   select="substring-after($lnk, 'https://fr.wikipedia.org/wiki/')"
               />
           </xsl:when>
           <!-- links to Wikidata -->
           <!-- exemple : https://www.wikidata.org/wiki/Q182542, http://www.wikidata.org/entity/Q28114532 -->
           <xsl:when test="contains($lnk, 'wikidata.org/wiki')">
               <xsl:text>http://www.wikidata.org/entity/</xsl:text>
               <xsl:value-of
                   select="substring-after($lnk, 'wikidata.org/wiki/')"
               />
           </xsl:when>

           <xsl:otherwise>
               <xsl:value-of select="$lnk"/>
           </xsl:otherwise>
       </xsl:choose>
	</xsl:template>
	
	<xsl:function name="eac2rico:URI-RecordResource">
		<xsl:param name="recordResourceId" />		
		<!-- Note how # is changed into '-' -->
		<xsl:choose>
			<!--  if there is no anchor, we are referring to the top RecordResource so we add a final '-top' -->
			<xsl:when test="string-length(substring-after($recordResourceId, 'FRAN_IR_')) = 6"> 
				<xsl:value-of select="concat('recordResource', '/', substring-after($recordResourceId, 'FRAN_IR_'), '-top')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('recordResource', '/', translate(substring-after($recordResourceId, 'FRAN_IR_'), '#', '-'))" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-Place">
		<xsl:param name="nomVoie" />		
		<xsl:value-of select="concat('place', '/', encode-for-uri($nomVoie))" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-Place-hasLocation">
		<xsl:param name="vocabularySource" />
		<xsl:param name="localType" />
		
		<xsl:variable name="vocabulary">
			<xsl:choose>
				<xsl:when test="$localType = 'voie'">025</xsl:when>
				<xsl:when test="$localType = 'commune_rattachee'">020</xsl:when>
				<xsl:when test="$localType = 'paroisse'">024</xsl:when>
				<xsl:when test="$localType = 'quartier'">023</xsl:when>
				<xsl:when test="$localType = 'edifice'">026</xsl:when>
				<xsl:when test="$localType = 'arrondissement_actuel'">022</xsl:when>
				<xsl:when test="$localType = 'arrondissement_ancien'">021</xsl:when>
				<xsl:when test="$localType = 'lieu'">005</xsl:when>
				<xsl:otherwise>
					<xsl:message>Unexpected @locaType on place : <xsl:value-of select="$localType" /></xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<xsl:value-of select="concat('place', '/', 'FRAN_RI_', $vocabulary, '-', $vocabularySource)" />
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