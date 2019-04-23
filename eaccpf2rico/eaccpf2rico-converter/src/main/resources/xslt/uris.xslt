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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
	xmlns:eac="urn:isbn:1-931666-33-4"
>
			
	<!-- Load LegalStatuses from companion file -->
	<xsl:param name="LEGAL_STATUSES_FILE">FRAN_RI_104_Ginco_legalStatuses.rdf</xsl:param>
	<xsl:variable name="LEGAL_STATUSES" select="document($LEGAL_STATUSES_FILE)" />
	
	<!-- We have both a template and a function 'URI-Agent'. The template works on the current notice, the function is used to compute the URI is relation values -->
	<xsl:template name="URI-Agent">
		<xsl:value-of select="eac2rico:URI-Agent(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType, /eac:eac-cpf/eac:control/eac:recordId)" />
	</xsl:template>	
	<xsl:function name="eac2rico:URI-Agent">
		<xsl:param name="entityType" />
		<xsl:param name="recordId" />		
		<xsl:value-of select="concat($entityType, '/', substring-after($recordId, 'FRAN_NP_'))" />
	</xsl:function>	
	
	<!-- URI for an Agent described in an external file : lookup the file of this Agent based on its ID in the input folder, and reads the entityType in it -->
	<xsl:function name="eac2rico:URI-AgentExternal">
		<xsl:param name="externalEntityId" />
		<xsl:param name="externalEntityDescription" />

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
				<xsl:value-of select="concat('agentName/', substring-after($recordId, 'FRAN_NP_'), '-', encode-for-uri($label), '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('agentName/', substring-after($recordId, 'FRAN_NP_'), '-', encode-for-uri($label), '-', translate($fromDate, '-', ''), '-', '*')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('agentName/', substring-after($recordId, 'FRAN_NP_'), '-', encode-for-uri($label), '-', '*', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('agentName/', substring-after($recordId, 'FRAN_NP_'), '-', encode-for-uri($label))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-ActivityRealizationRelation">
		<xsl:param name="recordId" />
		<xsl:param name="functionId" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('activityRealizationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $functionId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('activityRealizationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $functionId, '-', translate($fromDate, '-', ''), '-', '*')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('activityRealizationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $functionId, '-', '*', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('activityRealizationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $functionId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-ActivityType">
		<xsl:param name="vocabularySource" />
		<xsl:value-of select="concat('http://data.archives-nationales.culture.gouv.fr', '/activityType/', 'FRAN_RI_011-', $vocabularySource)" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-OccupationRelation">
		<xsl:param name="recordId" />
		<xsl:param name="occupationId" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('occupationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $occupationId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('occupationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $occupationId, '-', translate($fromDate, '-', ''), '-', '*')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('occupationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $occupationId, '-', '*', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('occupationRelation/', substring-after($recordId, 'FRAN_NP_'), '-', $occupationId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-OccupationType">
		<xsl:param name="vocabularySource" />
		<xsl:value-of select="concat('http://data.archives-nationales.culture.gouv.fr', '/occupationType/', 'FRAN_RI_010-', $vocabularySource)" />
	</xsl:function>
	
	<xsl:function name="eac2rico:URI-AgentHierarchicalRelation">
		<xsl:param name="parent" />
		<xsl:param name="child" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:variable name="parentId" select="substring-after($parent, 'FRAN_NP_')" />
		<xsl:variable name="childId" select="substring-after($child, 'FRAN_NP_')" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('agentHierarchicalRelation/', $parentId, '-', $childId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('agentHierarchicalRelation/', $parentId, '-', $childId, '-', translate($fromDate, '-', ''), '-', '*')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('agentHierarchicalRelation/', $parentId, '-', $childId, '-', '*', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('agentHierarchicalRelation/', $parentId, '-', $childId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="eac2rico:URI-AgentTemporalRelation">
		<xsl:param name="before" />
		<xsl:param name="after" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:variable name="beforeId" select="substring-after($before, 'FRAN_NP_')" />
		<xsl:variable name="afterId" select="substring-after($after, 'FRAN_NP_')" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('agentTemporalRelation/', $beforeId, '-', $afterId, '-', translate($fromDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('agentTemporalRelation/', $beforeId, '-', $afterId, '-', translate($fromDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<!-- TODO : in theory this is not a possible case - issue a warning message ? -->
				<xsl:value-of select="concat('agentTemporalRelation/', $beforeId, '-', $afterId, '-', 'unknown', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('agentTemporalRelation/', $beforeId, '-', $afterId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="eac2rico:URI-AgentRelation">
		<xsl:param name="firstAlphabetical" />
		<xsl:param name="secondAlphabetical" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:variable name="firstId" select="substring-after($firstAlphabetical, 'FRAN_NP_')" />
		<xsl:variable name="secondId" select="substring-after($secondAlphabetical, 'FRAN_NP_')" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('agentRelation/', $firstId, '-', $secondId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('agentRelation/', $firstId, '-', $secondId, '-', translate($fromDate, '-', ''), '-', 'unknown')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('agentRelation/', $firstId, '-', $secondId, '-', 'unknown', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('agentRelation/', $firstId, '-', $secondId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="eac2rico:URI-OriginationRelation">
		<xsl:param name="recordResource" />
		<xsl:param name="entity" />
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		
		<xsl:variable name="recordResourceId" select="substring-after($recordResource, 'FRAN_IR_')" />
		<xsl:variable name="entityId" select="substring-after($entity, 'FRAN_NP_')" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat('originationRelation/', $recordResourceId, '-', $entityId, '-', translate($fromDate, '-', ''), '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat('originationRelation/', $recordResourceId, '-', $entityId, '-', translate($fromDate, '-', ''), '-', 'unknown')" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat('originationRelation/', $recordResourceId, '-', $entityId, '-', 'unknown', '-', translate($toDate, '-', ''))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('originationRelation/', $recordResourceId, '-', $entityId)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	
	<xsl:function name="eac2rico:URI-LegalStatus">
		<xsl:param name="vocabularySource" />
		<xsl:variable name="gincoId" select="concat('FRAN_RI_104.xml#', $vocabularySource)" />
		<xsl:value-of select="$LEGAL_STATUSES/rdf:RDF/skos:Concept[ginco:id = $gincoId]/@rdf:about" />
	</xsl:function>
	
	<!-- Should be checked and completed, specially for wikidata -->
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
           <xsl:when test="contains($lnk, 'bnf.fr')">
               <xsl:choose>
                   <xsl:when test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and contains($lnk, '/PUBLIC')">
                     <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                     <xsl:value-of select="substring-before(substring-after($lnk, 'http://catalogue.bnf.fr/ark:/12148/'), '/PUBLIC')"/>
                     <xsl:text>#about</xsl:text>
                   </xsl:when>
                   <xsl:when test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and not(contains($lnk, '/PUBLIC'))">
                     <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                     <xsl:value-of select="substring-after($lnk, 'http://catalogue.bnf.fr/ark:/12148/')"/>
                     <xsl:text>#about</xsl:text>
                   </xsl:when>
                   <xsl:when test="contains($lnk, 'http://data.bnf.fr/ark:/12148/')">
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
		<xsl:value-of select="concat('recordSet', '/', substring-after($recordResourceId, 'FRAN_IR_'), '-top')" />
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