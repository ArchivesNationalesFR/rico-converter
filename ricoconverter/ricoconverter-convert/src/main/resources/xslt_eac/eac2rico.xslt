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
	xmlns:isni="https://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="eac eac2rico xlink xs xsi xsl"
>
	<!-- Import URI stylesheet -->
	<xsl:import href="eac2rico-uris.xslt" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="eac2rico-builtins.xslt" />

	<xsl:output indent="yes" method="xml" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/agent/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	<xsl:param name="INPUT_FOLDER">.</xsl:param>
	
	<!-- Load Keywords from companion file -->
	<xsl:param name="KEYWORDS_FILE">eac2rico-keywords.xml</xsl:param>
	<xsl:variable name="KEYWORDS" select="document($KEYWORDS_FILE)" />
	
	<!--  Global variable for recordId to reference it in functions -->
	<xsl:variable name="recordId" select="/eac:eac-cpf/eac:control/eac:recordId" />
	<!--  Global variable for the Agent URI -->
	<xsl:variable name="agentUri"><xsl:call-template name="URI-Agent" /></xsl:variable>
	
	<xsl:template match="/">
		<rdf:RDF>
			<!-- Sets xml:base on root this way, so that compilation of XSLT does not fail because it is not a URI -->
			<xsl:attribute name="xml:base" select="$BASE_URI" />
			<xsl:apply-templates />
			<xsl:apply-templates mode="relations" select="eac:eac-cpf/eac:cpfDescription/eac:relations/eac:cpfRelation" />
			<xsl:apply-templates mode="relations" select="eac:eac-cpf/eac:cpfDescription/eac:relations/eac:resourceRelation" />
			<xsl:apply-templates mode="relations" select="eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place" />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="eac:eac-cpf">		
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="eac:control">			
		<rico:Record>
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Record(eac:recordId)" /></xsl:call-template>
			<rico:hasDocumentaryFormType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/documentaryFormTypes#AuthorityRecord" />
			<rico:describesOrDescribed><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:describesOrDescribed>
			
			<xsl:apply-templates />
			<xsl:apply-templates select="../eac:cpfDescription/eac:identity/eac:entityId" mode="description" />
			<xsl:apply-templates select="../eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'identity']" mode="description" />
			
			<rico:hasInstantiation>
	         <rico:Instantiation>
	         	<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Instantiation(eac:recordId)" /></xsl:call-template>
	            <rico:isInstantiationOf rdf:resource="{eac2rico:URI-Record(eac:recordId)}"/>
	            <dc:format xml:lang="en">text/xml</dc:format>
	            <rico:identifier><xsl:value-of select="eac:recordId" /></rico:identifier>
	            <xsl:choose>
					<xsl:when test="starts-with($AUTHOR_URI, $BASE_URI)">
						<rico:hasOrHadHolder rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
					</xsl:when>
					<xsl:otherwise>
						<rico:hasOrHadHolder rdf:resource="{$AUTHOR_URI}" />
					</xsl:otherwise>
				</xsl:choose>
				<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/{/eac:eac-cpf/eac:control/eac:recordId}" />
				<xsl:apply-templates mode="instantiation" />
	         </rico:Instantiation>
	      </rico:hasInstantiation>
		</rico:Record>
	</xsl:template>

	<!-- ***** conventionDeclaration on both the Record and the Instantiation -->

	<!-- Generates rico:isOrWasRegulatedBy with hardcoded values depending on the entity type -->
	<xsl:template match="eac:control/eac:conventionDeclaration">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:control/eac:conventionDeclaration/eac:citation">
		<xsl:variable name="entType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />
		<xsl:choose>
			<xsl:when test="$entType = 'corporateBody' or $entType = 'family'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl001" />
			</xsl:when>
			<xsl:when test="$entType = 'person'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl002" />
			</xsl:when>
		</xsl:choose>
		<rico:isOrWasRegulatedBy rdf:resource="rule/rl003" />
		<rico:isOrWasRegulatedBy rdf:resource="rule/rl004" />
	</xsl:template>
	
	<!-- hardcoded value on the Instantiation that states this is encoded in EAC/CPF -->
	<xsl:template match="eac:control/eac:conventionDeclaration" mode="instantiation">
		<rico:isOrWasRegulatedBy rdf:resource="rule/rl011" />
	</xsl:template>
	
	<xsl:template match="eac:control/eac:otherRecordId[text()]" mode="instantiation">
		<rico:identifier><xsl:value-of select="." /></rico:identifier>
	</xsl:template>
	
	<!-- ***** languageDeclaration ***** -->
	
	<xsl:template match="eac:control/eac:languageDeclaration">
		<rico:hasLanguage rdf:resource="{eac2rico:URI-Language(eac:language/@languageCode)}"/>
	</xsl:template>
	
	<!-- ***** maintenanceHistory and maintenanceEvent -->
	
	<xsl:template match="eac:maintenanceHistory">
		<!-- If an event is 'created', use it for creation date, otherwise use a 'derived' event if exists -->
		<xsl:choose>
			<xsl:when test="eac:maintenanceEvent[eac:eventType = 'created']">
	             <rico:creationDate>
		             <xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime"/>
		            </xsl:call-template>
	             </rico:creationDate>
	         </xsl:when>
	         <xsl:when test="eac:maintenanceEvent[eac:eventType = 'derived']">
	             <rico:creationDate>
	             	<xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime"/>
		            </xsl:call-template>
	             </rico:creationDate>
	         </xsl:when>
         </xsl:choose>
         <!-- sort on the eventDateTime to make sure we pick up the last one to generated lastModificationDate -->
         <xsl:for-each select="eac:maintenanceEvent[eac:eventType = 'updated' or eac:eventType = 'revised' or eac:eventType = 'derived']">
            <xsl:sort select="eac:eventDateTime" data-type="text" order="descending"/>
            <!-- process only the first one, most recent date -->
            <xsl:if test="position()=1">
                <rico:lastModificationDate>
              	  	<xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="./eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="./eac:eventDateTime"/>
		            </xsl:call-template>
              </rico:lastModificationDate>
            </xsl:if>
        </xsl:for-each>
          
          <xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="eac:maintenanceEvent">	
	   <rico:isOrWasAffectedBy>
	      <rico:Activity>
	      	 <xsl:apply-templates />
	      </rico:Activity>
	   </rico:isOrWasAffectedBy>
	</xsl:template>
	
	<xsl:template match="eac:eventDateTime">
		<rico:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="." /></rico:date>
	</xsl:template>
	<xsl:template match="eac:eventType">
	  <xsl:variable name="eventTypeLabel">
	   	<xsl:choose>
	   		<xsl:when test="text() = 'created'">Création</xsl:when>
	   		<xsl:when test="text() = 'updated'">Modification</xsl:when>
	   		<xsl:when test="text() = 'revised'">Révision</xsl:when>
	   		<xsl:when test="text() = 'derived'">Dérivation</xsl:when>
	   		<xsl:otherwise>Autre</xsl:otherwise>
	   	</xsl:choose>
	   </xsl:variable>
	   
	   <xsl:variable name="agentLabel">
	   	<xsl:choose>
	   		<xsl:when test="../eac:agentType = 'machine'"><xsl:value-of select="../eac:agent" /></xsl:when>
	   		<xsl:otherwise>par <xsl:value-of select="../eac:agent" /></xsl:otherwise>
	   	</xsl:choose>
	   </xsl:variable>
	   
	   <rico:name xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$eventTypeLabel" /> (<xsl:value-of select="$agentLabel" />)</rico:name>
	</xsl:template>
	<xsl:template match="eac:eventDescription">
		<rico:descriptiveNote xml:lang="{$LITERAL_LANG}"><xsl:value-of select="." /></rico:descriptiveNote> 
	</xsl:template>
	
	<!-- *** sources/source/sourceEntry *** -->
	
	<xsl:template match="eac:sources">			
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:source[eac:sourceEntry]">			
		<xsl:choose>
			<!--  if sourceEntry is an http URI, generates a rico:hasSource -->
			<xsl:when test="starts-with(eac:sourceEntry,'http') and not(contains(eac:sourceEntry, ' '))">
				<rico:hasSource rdf:resource="{normalize-space(eac:sourceEntry)}" />
			</xsl:when>
			<!-- Otherwise, generates a rico:source -->
			<xsl:otherwise>
				<rico:source xml:lang="{$LITERAL_LANG}">
					<!-- If the value starts with an hyphen, remove it -->
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space(eac:sourceEntry), '-')">
							<xsl:value-of select="normalize-space(substring-after(eac:sourceEntry, '-'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(eac:sourceEntry)" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="@xlink:href[normalize-space(.) != '']">
                        <xsl:value-of select="concat(' (', normalize-space(@xlink:href), ')')"/>
                    </xsl:if>
				</rico:source>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	<xsl:template match="eac:source[eac:descriptiveNote and not(eac:sourceEntry)]">			
		<xsl:for-each select="eac:descriptiveNote/eac:p">
			<rico:source  rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}">
				<xsl:apply-templates select="node()"></xsl:apply-templates>
			</html:p></rico:source>

			<!--  In addition to the generation of the literal value, we extract certain URI and generate rico:hasSource to these URIs -->
			  <xsl:analyze-string select="." regex="(http|https)://catalogue.bnf.fr/[^\s)\]\.;,]*">		
			    <xsl:matching-substring>
			      <rico:hasSource rdf:resource="{regex-group(0)}" />
			    </xsl:matching-substring>		
			  </xsl:analyze-string>
	
			  <xsl:analyze-string select="." regex="(http|https)://fr.wikipedia.org/wiki/[^\s)\]\.;,]*">		
			    <xsl:matching-substring>
			      <rico:hasSource rdf:resource="{regex-group(0)}" />
			    </xsl:matching-substring>		
			  </xsl:analyze-string>

		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="eac:maintenanceAgency">
		<xsl:choose>
			<xsl:when test="starts-with($AUTHOR_URI, $BASE_URI)">
				<rico:hasCreator rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
			</xsl:when>
			<xsl:otherwise>
				<rico:hasCreator rdf:resource="{$AUTHOR_URI}" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<!-- ***** cpfDescription -> rico:Agent ***** -->
	
	<xsl:template match="eac:cpfDescription">
		<rico:Agent>
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
			<xsl:choose>
				<xsl:when test="eac:identity/eac:entityType = 'person'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Person" /></xsl:when>
				<xsl:when test="eac:identity/eac:entityType = 'corporateBody'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#CorporateBody" /></xsl:when>
				<xsl:when test="eac:identity/eac:entityType = 'family'"><rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Family" /></xsl:when>
				<!-- TODO : error message -->
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
			<rico:isOrWasDescribedBy><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Record(../eac:control/eac:recordId)" /></xsl:call-template></rico:isOrWasDescribedBy>
			<xsl:apply-templates />	
		</rico:Agent>	
	</xsl:template>
	
	<xsl:template match="eac:identity">			
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- *** identity/entityId *** -->
	<xsl:template match="eac:entityId">
		<xsl:choose>
			<xsl:when test="starts-with(text(), 'ISNI')">
				<!-- Removes whitespace and potential column after "ISNI :" -->
				<!-- Encode the value just in case -->
				<owl:sameAs rdf:resource="https://isni.org/isni/{encode-for-uri(translate(substring-after(text(), 'ISNI'), ' :', ''))}" />
			</xsl:when>
			<xsl:when test="@localType = 'ISNI'">
				<!-- Encode the value just in case -->
				<owl:sameAs rdf:resource="https://isni.org/isni/{encode-for-uri(translate(text(), ' ', ''))}" />
			</xsl:when>
			<xsl:when test="starts-with(text(), 'SIRET')">
				<!-- Removes whitespace and potential column after "SIRET :" -->
				<rico:identifier>SIRET <xsl:value-of select="normalize-space(translate(substring-after(text(), 'SIRET'), ':', ''))" /></rico:identifier>
			</xsl:when>
			<xsl:when test="@localType = 'SIRET'">
				<rico:identifier>SIRET <xsl:value-of select="text()" /></rico:identifier>
			</xsl:when>
			<xsl:when test="starts-with(text(), 'SIREN')">
				<!-- Removes whitespace and potential column after "SIREN :" -->
				<rico:identifier>SIREN <xsl:value-of select="normalize-space(translate(substring-after(text(), 'SIREN'), ':', ''))" /></rico:identifier>
			</xsl:when>
			<xsl:when test="@localType = 'SIREN'">
				<rico:identifier>SIREN <xsl:value-of select="text()" /></rico:identifier>
			</xsl:when>
			<xsl:otherwise>
				<!-- output a warning ? -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="eac:entityId" mode="description">
		<xsl:choose>
			<xsl:when test="starts-with(text(), 'ISNI')">
				<!-- Removes whitespace and potential column after "ISNI :" -->
				<rdfs:seeAlso rdf:resource="https://isni.org/isni/{encode-for-uri(translate(substring-after(text(), 'ISNI'), ' :', ''))}" />
			</xsl:when>
			<xsl:when test="@localType = 'ISNI'">
				<rdfs:seeAlso rdf:resource="https://isni.org/isni/{encode-for-uri(translate(text(), ' ', ''))}" />
			</xsl:when>
			<xsl:otherwise>
				<!-- output a warning ? -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<!-- ** nameEntry ** -->
	<xsl:template match="eac:nameEntry[@localType = 'autorisée']">
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
		<rico:hasOrHadAgentName>
			<rico:AgentName>				
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($recordId, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
				<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
				<rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rico:textualValue>
				<rico:isOrWasAgentNameOf><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:isOrWasAgentNameOf>
				<!-- Authorized name are linked to the regulation depending on entityType -->
				<xsl:choose>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody' or /eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'family'">
						<rico:isOrWasRegulatedBy rdf:resource="rule/rl001" />
					</xsl:when>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
						<rico:isOrWasRegulatedBy rdf:resource="rule/rl002" />
					</xsl:when>
				</xsl:choose>
				<rico:type xml:lang="fr">nom d'agent : forme préférée</rico:type>
				<xsl:apply-templates />
			</rico:AgentName>
		</rico:hasOrHadAgentName>
	</xsl:template>
	
	<xsl:template match="eac:nameEntry[not(@localType != '')]">
		<rico:hasOrHadAgentName>
			<rico:AgentName>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($recordId, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
				<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
				<rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rico:textualValue>
				<rico:isOrWasAgentNameOf><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:isOrWasAgentNameOf>
				<xsl:apply-templates />
			</rico:AgentName>
		</rico:hasOrHadAgentName>
	</xsl:template>
	
	<xsl:template match="eac:description">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:existDates">
		<xsl:if test="not(contains(string-join(eac:descriptiveNote/eac:p), 'dates d''exercice') or contains(string-join(eac:descriptiveNote/eac:p), 'dates d''activité'))">
			<xsl:apply-templates select="eac:dateRange" />
		</xsl:if>		
	</xsl:template>
	<xsl:template match="eac:useDates">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="eac:dateRange" mode="#all">
		<xsl:apply-templates />
	</xsl:template>
	<!-- Processing the fromDate / toDate for death and birth of Persons. Note the higher @priority, otherwise the generic templates below for fromDate/toDate will be used -->
	<xsl:template match="eac:existDates/eac:dateRange/eac:fromDate[@standardDate and /eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person']" priority="2">
		<rico:birthDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:birthDate>
	</xsl:template>
	<xsl:template match="eac:existDates/eac:dateRange/eac:toDate[@standardDate and /eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person']" priority="2">
		<rico:deathDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:deathDate>
	</xsl:template>
	<!--  Processing the fromDate / toDate of nameEntry ; note again the higher priority so that this template is picked up before the other one -->
	<xsl:template match="eac:nameEntry/eac:useDates/eac:dateRange/eac:fromDate[@standardDate]" priority="2">
		<rico:usedFromDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:usedFromDate>
	</xsl:template>
	<xsl:template match="eac:nameEntry/eac:useDates/eac:dateRange/eac:toDate[@standardDate]" priority="2">
		<rico:usedToDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:usedToDate>
	</xsl:template>
	
	<xsl:template match="eac:fromDate[@standardDate]">
		<rico:beginningDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:beginningDate>
	</xsl:template>
	<xsl:template match="eac:toDate[@standardDate]">
		<rico:endDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:endDate>
	</xsl:template>
	<!-- Ensure the element is not totally empty -->
	<xsl:template match="eac:fromDate[not(@standardDate) and text()]">
		<rico:beginningDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="text()"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:beginningDate>
	</xsl:template>
	<!-- Ensure the element is not totally empty -->
	<xsl:template match="eac:toDate[not(@standardDate) and text()]">
		<rico:endDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="text()"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:endDate>
	</xsl:template>
	
	<xsl:template match="eac:biogHist[not(eac:chronList) and normalize-space(.) != '']">
		<rico:history rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<xsl:apply-templates />
			</html:div>
		</rico:history>
	</xsl:template>
	
	<xsl:template match="eac:structureOrGenealogy[normalize-space(.) != '']">
		<rico:descriptiveNote rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<h4>Organisation interne ou généalogie</h4>
				<xsl:apply-templates />
			</html:div>
		</rico:descriptiveNote>
	</xsl:template>
	
	<xsl:template match="eac:generalContext[normalize-space(.) != '']">
		<rico:history rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<h4>Contexte général</h4>
				<xsl:apply-templates />
			</html:div>
		</rico:history>
	</xsl:template>
	
	
	
	<xsl:template match="eac:mandates">
		<xsl:apply-templates />
	</xsl:template>
	<!-- Case where there is an explicit @xlink:href -->
	<xsl:template match="eac:mandate[eac:citation/@xlink:href]">		
		<xsl:variable name="ruleId" select="eac2rico:URI-MandateFromEli(eac:citation/@xlink:href)" />		
		<xsl:choose>
			<!-- Known reference in the referential -->
			<xsl:when test="$ruleId != ''">
				<rico:agentIsTargetOfMandateRelation>
					<rico:MandateRelation>
						<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-RelationToMandate($recordId, $ruleId, eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></xsl:call-template>
						<rico:mandateRelationHasTarget rdf:resource="{$agentUri}"/>
						<rico:mandateRelationHasSource rdf:resource="{$ruleId}"/>           	
		            	<xsl:apply-templates />
					</rico:MandateRelation>
				</rico:agentIsTargetOfMandateRelation>
				<rico:authorizedBy rdf:resource="{$ruleId}" />
			</xsl:when>
			<!-- Unknown reference in the referential -->
			<xsl:otherwise>			
				<rico:agentIsTargetOfMandateRelation>
					<rico:MandateRelation>
						<rico:mandateRelationHasTarget rdf:resource="{$agentUri}"/>
						<rico:mandateRelationHasSource> 
							<rico:Mandate rdf:nodeID="_Mandate-{generate-id()}">
								<rico:title><xsl:value-of select="eac:citation/text()" /></rico:title>
								<rdfs:seeAlso rdf:resource="{eac:citation/@xlink:href}" />
							</rico:Mandate>
						</rico:mandateRelationHasSource>
		            	<xsl:apply-templates />
					</rico:MandateRelation>
				</rico:agentIsTargetOfMandateRelation>
				<rico:authorizedBy rdf:nodeID="_Mandate-{generate-id()}" />		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Case where there is a citation, but no @xlink:href -->
	<xsl:template match="eac:mandate[eac:citation[not(@xlink:href)]]">				
		<rico:agentIsTargetOfMandateRelation>
			<rico:MandateRelation>
				<rico:mandateRelationHasTarget rdf:resource="{$agentUri}"/>
            	<rico:mandateRelationHasSource>
            		<rico:Mandate rdf:nodeID="_Mandate-{generate-id()}">
            			<rico:title><xsl:value-of select="eac:citation/text()" /></rico:title>
            		</rico:Mandate>
            	</rico:mandateRelationHasSource>
            	<xsl:apply-templates />
			</rico:MandateRelation>
		</rico:agentIsTargetOfMandateRelation>
		<rico:authorizedBy rdf:nodeID="_Mandate-{generate-id()}" />
	</xsl:template>
	<xsl:template match="eac:mandate[not(eac:citation) and eac:descriptiveNote[count(eac:p) = 1]]">
		
		<xsl:variable name="theMandate" select="." />
		<xsl:variable name="theDescriptiveNote" select="eac:descriptiveNote" />
		
		<xsl:choose>
			<!-- if the <p> contains an ELI (based on a regex match)... -->
			<xsl:when test="matches(eac:descriptiveNote/eac:p[last()], 'https?://www.legifrance\.gouv\.fr/eli/[^.)\] ]*')">
				<!-- Then find all occurrence of the ELI... -->
				<xsl:analyze-string select="eac:descriptiveNote/eac:p[last()]" regex="https?://www.legifrance\.gouv\.fr/eli/[^.)\] ]*">
				  <xsl:matching-substring>
				  		<!-- For each ELI value in the text apply the same process as above -->
				  		<xsl:variable name="ruleId" select="eac2rico:URI-MandateFromEli(.)" />
				  		
				  		<xsl:choose>
							<!-- Known reference in the referential -->
							<xsl:when test="$ruleId != ''">
								<rico:agentIsTargetOfMandateRelation>
									<rico:MandateRelation>
										<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-RelationToMandate($recordId, $ruleId, $theMandate/eac:dateRange/eac:fromDate, $theMandate/eac:dateRange/eac:toDate)" /></xsl:call-template>
										<rico:mandateRelationHasTarget rdf:resource="{$agentUri}"/>									
						            	<rico:mandateRelationHasSource rdf:resource="{$ruleId}"/>
						            	<!-- Don't process the descriptiveNote as normal -->
						            	<xsl:apply-templates select="$theMandate/*[local-name() != descriptiveNote]" />
									</rico:MandateRelation>
								</rico:agentIsTargetOfMandateRelation>		
								<rico:authorizedBy rdf:resource="{$ruleId}" />	
							</xsl:when>
							<!-- Unknown reference in the referential -->
							<xsl:otherwise>			
								<rico:agentIsTargetOfMandateRelation>
									<rico:MandateRelation>
										<rico:mandateRelationHasTarget rdf:resource="{$agentUri}"/>
										<rico:mandateRelationHasSource> 
											<rico:Mandate rdf:nodeID="_Mandate-{encode-for-uri(.)}">
												<rico:title><xsl:value-of select="$theDescriptiveNote" /></rico:title>
												<rdfs:seeAlso rdf:resource="{.}" />
											</rico:Mandate>
										</rico:mandateRelationHasSource>
						            	<!-- Don't process the descriptiveNote as normal -->
						            	<xsl:apply-templates select="$theMandate/*[local-name() != descriptiveNote]" />
									</rico:MandateRelation>
								</rico:agentIsTargetOfMandateRelation>
								<rico:authorizedBy rdf:nodeID="_Mandate-{encode-for-uri(.)}" />		
							</xsl:otherwise>
						</xsl:choose>
				  </xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<rico:authorizingMandate rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="eac:descriptiveNote/eac:p[last()]/node()" /></html:p></rico:authorizingMandate>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!-- Case where there is no citation, but a descriptiveNote with inner p's -->
	<xsl:template match="eac:mandate[not(eac:citation) and eac:descriptiveNote[count(eac:p) > 1]]">
		<xsl:variable name="fullString" select="normalize-space(string-join(./eac:descriptiveNote/eac:p/text(), ' '))" />
		<xsl:variable name="warningString" select="concat(substring($fullString, 1, 15), '...')" />
		<!-- Output a warning -->
		<xsl:value-of select="eac2rico:warning($recordId, 'MULTIPLE_P_IN_MANDATE', $warningString)" />
	</xsl:template>	
	
	<!-- *** Functions *** -->
	<xsl:template match="eac:functions">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:function">		
		<rico:agentIsTargetOfPerformanceRelation>
			<rico:PerformanceRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-PerformanceRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:performanceRelationHasTarget>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:performanceRelationHasTarget>
				<rico:performanceRelationHasSource>
					<rico:Activity rdf:nodeID="_Activity-{encode-for-uri(.)}">
						<rico:activityIsSourceOfPerformanceRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-PerformanceRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
						</rico:activityIsSourceOfPerformanceRelation>
						<rico:hasActivityType>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-ActivityType(eac:term/@vocabularySource)" /></xsl:call-template>
						</rico:hasActivityType>
					</rico:Activity>					
				</rico:performanceRelationHasSource>
				<xsl:apply-templates />
			</rico:PerformanceRelation>
		</rico:agentIsTargetOfPerformanceRelation>
		<rico:performsOrPerformed rdf:nodeID="_Activity-{encode-for-uri(.)}" />
	</xsl:template>
	
	<!-- *** Occupations / Activities *** -->
	<xsl:template match="eac:occupations">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:occupation">
		<rico:agentIsTargetOfPerformanceRelation>
			<rico:PerformanceRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-PerformanceRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:performanceRelationHasTarget>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:performanceRelationHasTarget>
				<rico:performanceRelationHasSource>
					<rico:Activity rdf:nodeID="_Activity-{encode-for-uri(.)}">
						<rico:activityIsSourceOfPerformanceRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-PerformanceRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
						</rico:activityIsSourceOfPerformanceRelation>
						<!-- ***** Note : this is not conformant to RiC-O 0.1 as an OccupationType is currently not a subclass of ActivityType ***** -->
						<!-- This will be fixed in RiC-O 0.2 -->
						<rico:hasActivityType>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-OccupationType(eac:term/@vocabularySource)" /></xsl:call-template>
						</rico:hasActivityType>
					</rico:Activity>					
				</rico:performanceRelationHasSource>
				<xsl:apply-templates />
			</rico:PerformanceRelation>
		</rico:agentIsTargetOfPerformanceRelation>
		<rico:performsOrPerformed rdf:nodeID="_Activity-{encode-for-uri(.)}" />
	</xsl:template>
	
	<!-- *** LegalStatuses *** -->
	<xsl:template match="eac:legalStatuses">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:legalStatus[not(eac:dateRange/eac:fromDate) and not(eac:dateRange/eac:toDate) and not(eac:descriptiveNote)]">
		<xsl:choose>
			<xsl:when test="not(eac:term/@vocabularySource)">
				<xsl:value-of select="eac2rico:warning($recordId, 'MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS', ./eac:term/text())" />
			</xsl:when>
			<xsl:otherwise>
				<rico:hasLegalStatus><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-LegalStatus(eac:term/@vocabularySource)" /></xsl:call-template></rico:hasLegalStatus>		
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	<xsl:template match="eac:legalStatus[eac:dateRange/eac:fromDate or eac:dateRange/eac:toDate or eac:descriptiveNote]">
		<xsl:if test="not(eac:term/@vocabularySource)">
			<xsl:value-of select="eac2rico:warning($recordId, 'MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS', ./eac:term/text())" />
		</xsl:if>
		
		<rico:thingIsTargetOfTypeRelation>
			<rico:TypeRelation>
				<xsl:call-template name="rdf-about">
	        		<xsl:with-param name="uri" select="eac2rico:URI-RelationToType(
	        			$recordId,
	        			eac:term/@vocabularySource,
	        			eac:dateRange/eac:fromDate/@standardDate,
	        			eac:dateRange/eac:toDate/@standardDate )"
	        		/>	
	        	</xsl:call-template>
	            <rico:typeRelationHasTarget>
	            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
	            </rico:typeRelationHasTarget>
	            <rico:typeRelationHasSource>
	            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-LegalStatus(eac:term/@vocabularySource)" /></xsl:call-template>
	            </rico:typeRelationHasSource>
            
            <xsl:apply-templates />
         	</rico:TypeRelation>
      </rico:thingIsTargetOfTypeRelation>
	  <rico:hasOrHadCategory>
		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-LegalStatus(eac:term/@vocabularySource)" /></xsl:call-template>
	  </rico:hasOrHadCategory>
		
	</xsl:template>

	<!-- *** RELATIONS *** -->
	
	<xsl:template match="eac:relations">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='identity' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'identity']">
		<xsl:choose>
			<xsl:when test="starts-with(normalize-space(@xlink:href), 'http') and not(contains(@xlink:href, ' '))">
				<owl:sameAs>
		        	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri">
		        		<xsl:call-template name="URI-cpfRelationIdentity">
		        			<xsl:with-param name="lnk" select="normalize-space(@xlink:href)" />
		        			<xsl:with-param name="entityType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />
		        		</xsl:call-template>
		        	</xsl:with-param></xsl:call-template>
		        </owl:sameAs>
			</xsl:when>
			<xsl:otherwise>
		        <xsl:value-of select="eac2rico:warning($recordId, 'INVALID_URL_IN_HREF', normalize-space(@xlink:href))" />		
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'identity']" mode="description">
        <xsl:if test="contains(@xlink:href, 'wikipedia.org')">
        	<rdfs:seeAlso rdf:resource="{@xlink:href}" />
        </xsl:if>
	</xsl:template>	
	
	<!-- Output a warning for relations where href is not found -->
	<xsl:template match="eac:cpfRelation[
		exists(index-of(('hierarchical-child', 'hierarchical-parent', 'associative', 'family', 'temporal-later', 'temporal-earlier'), @cpfRelationType))
		and
		not(document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))
	]">
		<xsl:value-of select="eac2rico:warning($recordId, 'HREF_FILE_NOT_FOUND', concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	</xsl:template>			
	
	
	<!-- cpfRelation cpfRelationType ='hierarchical-child' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-child' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
		<xsl:variable name="type">
			<xsl:call-template name="hierarchicalRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>

        <xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isSourceOfProperty}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentHierarchicalRelation(
        			$recordId,
        			@xlink:href,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </xsl:element>

		<!-- shortcut property -->
		<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsSourceOfRelation}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))"/>	
        	</xsl:call-template>
        </xsl:element>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-child' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations">
       	<rico:AgentHierarchicalRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentHierarchicalRelation(
        			$recordId,
        			@xlink:href,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	
        	<xsl:variable name="type">
				<xsl:call-template name="hierarchicalRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
        	</xsl:variable>
        	
        	<xsl:if test="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/extraType != ''">
        		<rdf:type rdf:resource="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/extraType}" />
        	</xsl:if>
        	
        	<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/targetProperty}">
        		<!-- Note : in hierarchical relations we always set the entity type to corporateBody -->
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" /></xsl:call-template>
        	</xsl:element>
        	<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/sourceProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</xsl:element>
        	
        	<xsl:variable name="thisName" select="normalize-space(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/label" /> entre "<xsl:value-of select="$thisName" />" et "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentHierarchicalRelation>        
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='hierarchical-parent' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-parent' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
        <xsl:variable name="type">
			<xsl:call-template name="hierarchicalRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>
       	
       	<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isTargetOfProperty}">
       		<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentHierarchicalRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
       	</xsl:element>
		<!-- shortcut property -->
		<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsTargetOfRelation}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))"/>	
        	</xsl:call-template>
        </xsl:element>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-parent' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations">
       	<rico:AgentHierarchicalRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentHierarchicalRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
 
         	<xsl:variable name="type">
				<xsl:call-template name="hierarchicalRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
        	</xsl:variable>
        	
        	<xsl:if test="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/extraType != ''">
        		<rdf:type rdf:resource="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/extraType}" />
        	</xsl:if>
        	
        	<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/targetProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</xsl:element>
        	<xsl:element name="{$HIERARCHICAL_RELATION_CONFIG/*[local-name() = normalize-space($type)]/sourceProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" /></xsl:call-template>        		
        	</xsl:element>
        	
        	<xsl:variable name="thisName" select="normalize-space(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/label" /> entre "<xsl:value-of select="$thatName" />" et "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentHierarchicalRelation>
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='temporal-later' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-later' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
        <xsl:variable name="relationUri" select="eac2rico:URI-AgentTemporalRelation(
        			$recordId,
        			@xlink:href,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )" />

		<rico:agentIsSourceOfAgentTemporalRelation rdf:resource="{$relationUri}" />
		<rico:hasSuccessor rdf:resource="{eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))}" />
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-later' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations">
       	<rico:AgentTemporalRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentTemporalRelation(
        			$recordId,
        			@xlink:href,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	<rico:agentTemporalRelationHasTarget>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" /></xsl:call-template>
        	</rico:agentTemporalRelationHasTarget>
        	<rico:agentTemporalRelationHasSource>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</rico:agentTemporalRelationHasSource>
        	<xsl:variable name="thisName" select="normalize-space(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}">Relation temporelle entre le précédent "<xsl:value-of select="$thisName" />" et le suivant "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentTemporalRelation>        
	</xsl:template>


	<!-- cpfRelation cpfRelationType ='temporal-earlier' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-earlier' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
        <xsl:variable name="relationUri" select="eac2rico:URI-AgentTemporalRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )" />
		
		<rico:agentIsTargetOfAgentTemporalRelation rdf:resource="{$relationUri}" />
		<rico:isSuccessorOf rdf:resource="{eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))}" />
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-earlier' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations">
       	<rico:AgentTemporalRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentTemporalRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	<rico:agentTemporalRelationHasTarget>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</rico:agentTemporalRelationHasTarget>
        	<rico:agentTemporalRelationHasSource>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" /></xsl:call-template>     		
        	</rico:agentTemporalRelationHasSource>
        	<xsl:variable name="thisName" select="normalize-space(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}">Relation temporelle entre le précédent "<xsl:value-of select="$thatName" />" et le suivant "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentTemporalRelation>        
	</xsl:template>


	<!-- cpfRelation cpfRelationType ='assocative' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'associative' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
		<!--  determine source and target of the relation to forge its URI -->
		<xsl:variable name="type">
			<xsl:call-template name="associativeRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>
       	<xsl:variable name="sourceEntity">
       		<xsl:call-template name="associativeOrFamilyRelationSourceEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>       	
       	<xsl:variable name="targetEntity">
			<xsl:call-template name="associativeOrFamilyRelationTargetEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable> 
	
		<!-- If current entity is the source, generate an "isSourceOf" property, otherwise generate "isTargetOf" property -->
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isSourceOfProperty" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isTargetOfProperty" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
        <xsl:element name="{$elementName}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentRelation(
        			$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = $type]/baseType,
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </xsl:element>

		<!-- shortcut property -->
		<xsl:variable name="shortcutElementName">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsSourceOfRelation" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsTargetOfRelation" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="agentURI">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<!-- if this one was the source, pickup the target as shortcut value -->
					<xsl:value-of select="$targetEntity" />
				</xsl:when>
				<xsl:otherwise>
					<!-- if this one was the target, pickup the source as shortcut value -->
					<xsl:value-of select="$sourceEntity" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Generates shortcut directly to the other connected agent -->
		<xsl:element name="{$shortcutElementName}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="$agentURI" />	
        	</xsl:call-template>
        </xsl:element>

	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'associative' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations">
      	<!-- determine type, source and target of the relation -->
      	<xsl:variable name="type">
			<xsl:call-template name="associativeRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>
       	<xsl:variable name="sourceEntity">
       		<xsl:call-template name="associativeOrFamilyRelationSourceEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>       	
       	<xsl:variable name="targetEntity">
			<xsl:call-template name="associativeOrFamilyRelationTargetEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>       	
       	
       	<xsl:element name="{$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = $type]/baseType}">
       		<!-- URI is always "source-target-dates" -->
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentRelation(
        			$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = $type]/baseType,
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),        			
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	
        	<!--  insert extra type if needed -->
        	<xsl:if test="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/extraType != ''">
        		<rdf:type rdf:resource="{$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = $type]/extraType}" />
        	</xsl:if>
        	
        	<!--  insert source and target -->
        	<xsl:element name="{$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/sourceProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$sourceEntity" /></xsl:call-template>
        	</xsl:element>
        	<xsl:element name="{$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/targetProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$targetEntity" /></xsl:call-template>        		
        	</xsl:element>
        	
        	<!--  generate the label : always put the source label first, then target label second -->
        	<xsl:variable name="thisName" select="normalize-space(//eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<xsl:choose>
        		<xsl:when test="$agentUri = $sourceEntity">
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thisName" />" et "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>	
        		</xsl:when>
        		<xsl:otherwise>
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thatName" />" et "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        		</xsl:otherwise>
        	</xsl:choose>        	
        	
        	<xsl:apply-templates />
       	</xsl:element>        
	</xsl:template>


	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'family' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]">
		<!--  determine source and target of the relation to forge its URI -->
		<xsl:variable name="type">
			<xsl:call-template name="familyRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>
       	<xsl:variable name="sourceEntity">
       		<xsl:call-template name="associativeOrFamilyRelationSourceEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>       	
       	<xsl:variable name="targetEntity">
			<xsl:call-template name="associativeOrFamilyRelationTargetEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable> 
	
		<!-- If current entity is the source, generate an "isSourceOf" property, otherwise generate "isTargetOf" property -->
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isSourceOfProperty" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/isTargetOfProperty" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
        <xsl:element name="{$elementName}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-FamilyRelation(
        			$FAMILY_RELATION_CONFIG/*[local-name() = $type]/type,
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </xsl:element>

		<!-- shortcut property -->
		<xsl:variable name="shortcutElementName">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsSourceOfRelation" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/shortcutIfSubjectIsTargetOfRelation" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="agentURI">
			<xsl:choose>
				<xsl:when test="$agentUri = $sourceEntity">
					<!-- if this one was the source, pickup the target as shortcut value -->
					<xsl:value-of select="$targetEntity" />
				</xsl:when>
				<xsl:otherwise>
					<!-- if this one was the target, pickup the source as shortcut value -->
					<xsl:value-of select="$sourceEntity" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Generates shortcut directly to the other connected agent -->
		<xsl:element name="{$shortcutElementName}">
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="$agentURI" />	
        	</xsl:call-template>
        </xsl:element>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'family' and document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))]" mode="relations"> 
      	<!-- determine type, source and target of the relation -->
      	<xsl:variable name="type">
			<xsl:call-template name="familyRelationType"><xsl:with-param name="relation" select="." /></xsl:call-template>      	
       	</xsl:variable>
       	<xsl:variable name="sourceEntity">
       		<xsl:call-template name="associativeOrFamilyRelationSourceEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>       	
       	<xsl:variable name="targetEntity">
			<xsl:call-template name="associativeOrFamilyRelationTargetEntity"><xsl:with-param name="relation" select="." /><xsl:with-param name="type" select="$type" /></xsl:call-template> 
       	</xsl:variable>    

		<!-- tag name depends on the type of relation determined above -->
		<xsl:element name="{$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/type}">
       		<!-- URI is always "source-target-dates" -->
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-FamilyRelation(
        			$FAMILY_RELATION_CONFIG/*[local-name() = $type]/type,
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),        			
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	
        	<!--  insert source and target -->
        	<xsl:element name="{$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/sourceProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$sourceEntity" /></xsl:call-template>
        	</xsl:element>
        	<xsl:element name="{$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/targetProperty}">
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$targetEntity" /></xsl:call-template>        		
        	</xsl:element>
        	
        	<!--  generate the label : always put the source label first, then target label second -->
        	<xsl:variable name="thisName" select="normalize-space(//eac:nameEntry[@localType = 'autorisée']/eac:part)" />
        	<xsl:variable name="otherName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:variable name="thatName" select="if($otherName != '') then $otherName else eac:relationEntry" />
        	<xsl:choose>
        		<xsl:when test="$agentUri = $sourceEntity">
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thisName" />" et "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>	
        		</xsl:when>
        		<xsl:otherwise>
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thatName" />" et "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        		</xsl:otherwise>
        	</xsl:choose>  
 	
        	
        	<xsl:apply-templates />
       	</xsl:element>        
	</xsl:template>

	<!-- resourceRelation -->
	<xsl:template match="eac:resourceRelation[@resourceRelationType = 'creatorOf' and @xlink:href != '']">
        <rico:agentIsTargetOfAgentOriginationRelation>
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-OriginationRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </rico:agentIsTargetOfAgentOriginationRelation>
        <rico:isProvenanceOf>
        	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-RecordResource(@xlink:href)" /></xsl:call-template>
        </rico:isProvenanceOf>
	</xsl:template>
	<xsl:template match="eac:resourceRelation[@resourceRelationType = 'creatorOf' and @xlink:href != '']" mode="relations">
        <rico:AgentOriginationRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-OriginationRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	<rico:agentOriginationRelationHasSource>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-RecordResource(@xlink:href)" /></xsl:call-template>
        	</rico:agentOriginationRelationHasSource>
        	<rico:agentOriginationRelationHasTarget>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</rico:agentOriginationRelationHasTarget>
        	<xsl:apply-templates />
        </rico:AgentOriginationRelation>
	</xsl:template>
	
	<!--  This is externalized in a separate file for maintainability -->
	<xsl:include href="eac2rico-relations.xslt" />


	<!-- *** PLACES *** -->

	<xsl:template match="eac:places">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Place in Paris -->
	
	<!--  Case 1, 2, 3 and 4 in the unit tests -->
	<!-- Either there is a single reference to an entry in the authority lists, or there are multiple ones, but only one of type 'voie' -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu de Paris' and
		eac:placeEntry/@localType='nomLieu' and
		(
			count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) = 1
			or
			(
			count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) > 1
			and
			count(eac:placeEntry[@localType = 'voie' and @vocabularySource]) = 1
			)
		)
	]">

       	<xsl:choose>
       		<!-- Match on indéterminé without accents -->
       		<xsl:when test="not(contains(replace(normalize-unicode(lower-case(eac:placeEntry[@localType='nomLieu']),'NFKD'),'\P{IsBasicLatin}',''), 'indetermine'))">

       		  <rico:thingIsTargetOfPlaceRelation>
		         <rico:PlaceRelation>
		            <rico:placeRelationHasTarget>
		            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
		            </rico:placeRelationHasTarget>
		            <rico:placeRelationHasSource>
		            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" /></xsl:call-template>           	
		            </rico:placeRelationHasSource>
		            
		            <!--  dates + descriptiveNote -->
		      		<xsl:apply-templates />
		         </rico:PlaceRelation>
		      </rico:thingIsTargetOfPlaceRelation>
		      
		      <!-- Additionnally, generate the direct link hasOrHadLocation to the Place -->
		      <rico:hasOrHadLocation>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" /></xsl:call-template>
			  </rico:hasOrHadLocation>
       			
       		</xsl:when>
       		<xsl:otherwise>
       			<!--  Case 3 -->
	       		  <rico:thingIsTargetOfPlaceRelation>
			         <rico:PlaceRelation>
			            <rico:placeRelationHasTarget>
			            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
			            </rico:placeRelationHasTarget>
			            <rico:placeRelationHasSource>
			            	<rico:Place>
			       				<rdfs:label xml:lang="{$LITERAL_LANG}">Lieu dont l'adresse précise est indéterminée</rdfs:label>
			       				<xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
			       			</rico:Place>
			            </rico:placeRelationHasSource>
			            
			            <!--  dates + descriptiveNote -->
			      		<xsl:apply-templates />
			         </rico:PlaceRelation>
			      </rico:thingIsTargetOfPlaceRelation>
			      
			      <!-- Additionnally, generate the direct link hasLocation to the Place -->
				  <xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
       		</xsl:otherwise>
       	</xsl:choose>  
	</xsl:template>
	
	<!--  Case 6 in the unit tests -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu de Paris' and
		not(eac:placeEntry/@localType='nomLieu') and
		count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) = 1
	]">
	
		<xsl:variable name="placeEntry" select="eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]" />
	
		<!-- Output a warning -->
		<xsl:value-of select="eac2rico:warning($recordId, 'PLACE_WITHOUT_NOMLIEU_WITH_SINGLE_REFERENCE_TO_AUTHORITY_LIST', concat('''', $placeEntry/@localType, '''=', $placeEntry/@vocabularySource))" />
	
		<rico:thingIsTargetOfPlaceRelation>
         <rico:PlaceRelation>
            <rico:placeRelationHasTarget>
            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
            </rico:placeRelationHasTarget>
            <rico:placeRelationHasSource>
            	<xsl:call-template name="rdf-resource">
					<xsl:with-param name="uri" select="eac2rico:URI-Place-hasLocation($placeEntry/@vocabularySource, $placeEntry/@localType)" />
				</xsl:call-template>            	
            </rico:placeRelationHasSource>
            
            <!--  dates + descriptiveNote -->
      		<xsl:apply-templates />
         </rico:PlaceRelation>
      </rico:thingIsTargetOfPlaceRelation>
      
      <!-- Additionnally, generate the direct link hasLocation to the Place -->
      <xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
	</xsl:template>


	<!--  Case 7 and 8 in the unit tests -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu de Paris' and
		eac:placeEntry/@localType='nomLieu' and
		count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) = 0
	]">
		<!-- Output a warning -->
		<xsl:value-of select="eac2rico:warning($recordId, 'PLACE_WITHOUT_REFERENCE_TO_AUTHORITY_LIST', concat('nomLieu=''', eac:placeEntry[@localType='nomLieu'] ,''''))" />
	</xsl:template>
	
	<!--  Case 5 in the unit tests -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu de Paris' and
		eac:placeEntry/@localType='nomLieu' and
		count(eac:placeEntry[@localType = 'voie' and @vocabularySource]) > 1
	]">
		<!-- Output a warning -->
		<xsl:variable name="voieLabels" select="string-join(eac:placeEntry[@localType = 'voie' and @vocabularySource]/text(), ', ')" />
		<xsl:value-of select="eac2rico:warning($recordId, 'PLACE_WITH_MORE_THAN_ONE_VOIE', $voieLabels)" />
	</xsl:template>
	
	<!-- Generates the rico:Place instance -->
	<!-- Note that the test on "indetermine" is the same as above. This should not be produced when the nomLieu contains "indéterminé" -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu de Paris' and
		eac:placeEntry/@localType='nomLieu' and
		not(contains(replace(normalize-unicode(lower-case(eac:placeEntry[@localType='nomLieu']),'NFKD'),'\P{IsBasicLatin}',''), 'indetermine')) and
		(
			count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) = 1
			or
			(
			count(eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]) > 1
			and
			count(eac:placeEntry[exists(index-of(('voie'), @localType)) and @vocabularySource]) = 1
			)
		)
	]"
	mode="relations">
	   <rico:Place>
	   	  <xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" /></xsl:call-template>
	      <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:placeEntry[@localType='nomLieu']/text()" /></rdfs:label>
	      <xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
	   </rico:Place>
	</xsl:template>
	
	
	<!-- Place outside Paris -->
	
	<!-- CASE A : no 'nomLieu' -->
	
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu général' and
		not(eac:placeEntry/@localType='nomLieu')
	]">
	  <!-- Warning if more than 1 -->
	  <xsl:if test="count(eac:placeEntry) > 1">
	  	<xsl:variable name="placeEntries" select="string-join(eac:placeEntry/text(), ', ')" />
	  	<xsl:value-of select="eac2rico:warning($recordId, 'MORE_THAN_ONE_PLACEENTRY', $placeEntries)" />
	  </xsl:if>
	  
	  <!-- generates the RelationToPlace -->
	  <xsl:apply-templates select="eac:placeEntry" mode="noNomLieu" />    
      <!-- Additionnally, generate the direct link hasLocation to the referential -->
      <xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
	</xsl:template>
	
	<xsl:template 
		match="eac:placeEntry[@localType = 'lieu' and @vocabularySource]"
		mode="noNomLieu"
	>
		<rico:thingIsTargetOfPlaceRelation>
         <rico:PlaceRelation>
            <rico:placeRelationHasTarget>
            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
            </rico:placeRelationHasTarget>
            <rico:placeRelationHasSource>
            	<xsl:call-template name="rdf-resource">
					<xsl:with-param name="uri" select="eac2rico:URI-Place-hasLocation(@vocabularySource, @localType)" />
				</xsl:call-template>         	
            </rico:placeRelationHasSource>
            
            <!--  dates + descriptiveNote -->
      		<xsl:apply-templates select="../*[local-name() != 'placeEntry']" />
         </rico:PlaceRelation>
      </rico:thingIsTargetOfPlaceRelation>
	</xsl:template>
	
	<!-- CASE B : with 'nomLieu' -->

	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu général' and
		eac:placeEntry/@localType='nomLieu'
	]">
	  <!-- Warning if more than 1 -->
	  <xsl:if test="count(eac:placeEntry[@localType != 'nomLieu']) > 1">
	  	<xsl:variable name="placeEntries" select="string-join(eac:placeEntry[@localType != 'nomLieu']/text(), ', ')" />
	  	<xsl:value-of select="eac2rico:warning($recordId, 'MORE_THAN_ONE_PLACEENTRY', $placeEntries)" />
	  </xsl:if>
	  
	  <!-- generates the RelationToPlace -->
	  
	  <rico:thingIsTargetOfPlaceRelation>
         <rico:PlaceRelation>
            <rico:placeRelationHasTarget>
            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
            </rico:placeRelationHasTarget>
            <rico:placeRelationHasSource>
            	<xsl:call-template name="rdf-resource">
					<xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" />
				</xsl:call-template>         	
            </rico:placeRelationHasSource>
            
            <!--  dates + descriptiveNote -->
      		<xsl:apply-templates />
         </rico:PlaceRelation>
      </rico:thingIsTargetOfPlaceRelation>	  
	  
	  <!-- Additionnally, generate the direct link hasLocation to the referential -->
      <rico:hasOrHadLocation>
			<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" /></xsl:call-template>
	  </rico:hasOrHadLocation>
      
	</xsl:template>


	<!-- Generates the rico:Place instance -->
	<xsl:template match="eac:place[
		eac:placeRole = 'Lieu général' and
		eac:placeEntry/@localType='nomLieu' and
		eac:placeEntry[@localType = 'lieu' and @vocabularySource]
	]"
	mode="relations">
	   <rico:Place>
	   	  <xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Place(eac:placeEntry[@localType='nomLieu']/text())" /></xsl:call-template>
	      <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:placeEntry[@localType='nomLieu']/text()" /></rdfs:label>
	      <xsl:apply-templates select="eac:placeEntry" mode="hasLocation" />
	   </rico:Place>
	</xsl:template>
	
	<xsl:template 
		match="eac:placeEntry[exists(index-of(('voie', 'edifice', 'commune_rattachee', 'paroisse', 'quartier', 'arrondissement_actuel', 'arrondissement_ancien'), @localType)) and @vocabularySource]"
		mode="hasLocation"	
	>
		<rico:hasOrHadLocation>
			<xsl:call-template name="rdf-resource">
				<xsl:with-param name="uri" select="eac2rico:URI-Place-hasLocation(@vocabularySource, @localType)" />
			</xsl:call-template>
		</rico:hasOrHadLocation>
	</xsl:template>
	
	<!-- This is for a Place outside Paris -->
	<xsl:template 
		match="eac:placeEntry[@localType = 'lieu' and @vocabularySource]"
		mode="hasLocation"	
	>
		<rico:hasOrHadLocation>
			<xsl:call-template name="rdf-resource">
				<xsl:with-param name="uri" select="eac2rico:URI-Place-hasLocation(@vocabularySource, @localType)" />
			</xsl:call-template>
		</rico:hasOrHadLocation>
	</xsl:template>
	<!-- Processing of formatting elements p, list, item, span -->
	
	<!-- If we have a single 'p', don't wrap with a div -->
	<xsl:template match="eac:descriptiveNote[count(eac:p) = 1]">
		<rico:descriptiveNote rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="eac:p/node()" /></html:p></rico:descriptiveNote>
	</xsl:template>
	<xsl:template match="eac:descriptiveNote[count(eac:p) > 1]">
		<rico:descriptiveNote rdf:parseType="Literal"><html:div xml:lang="{$LITERAL_LANG}"><xsl:apply-templates /></html:div></rico:descriptiveNote>
	</xsl:template>
	
	<!-- This one detects all 'p' that have only one child element and that child is a span -->
	<xsl:template match="eac:p[count(eac:span)=1 and count(child::node())=1]">
		<!--  Generate a title -->
		<html:h2><xsl:value-of select="normalize-space(eac:span)" /></html:h2>
	</xsl:template>
	<xsl:template match="eac:p">
		<html:p><xsl:apply-templates /></html:p>
	</xsl:template>
	<xsl:template match="eac:p/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:list">
		<html:ul><xsl:apply-templates /></html:ul>
	</xsl:template>
	<xsl:template match="eac:list/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:item">
		<html:li><xsl:apply-templates /></html:li>
	</xsl:template>
	<xsl:template match="eac:item/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:span[@style='underline']">
		<html:u><xsl:apply-templates /></html:u>
	</xsl:template>
	<xsl:template match="eac:span[@style='bold']">
		<html:b><xsl:apply-templates /></html:b>
	</xsl:template>
	<xsl:template match="eac:span[@style='italic']">
		<html:i><xsl:apply-templates /></html:i>
	</xsl:template>
	<xsl:template match="eac:span/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<!-- Matching of text that is directly inserted under a tag that can contain mixed content -->
	<xsl:template match="eac:descriptiveNote/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:biogHist/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:structureOrGenealogy/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="eac:generalContext/text()"><xsl:value-of select="normalize-space(.)" /></xsl:template>

	

<!-- ************** Support templates and functions ************** -->
<!-- Anything below does not match actual XML tags in the input. -->

	
	<!-- Output a date value with the proper datatype based on the date format -->
	<xsl:template name="outputDate">
        <xsl:param name="date"/>
        <xsl:param name="stdDate"/>

		<xsl:variable name="dateToUse">
			<xsl:choose>
				<xsl:when test="normalize-space($stdDate) != ''"><xsl:value-of select="normalize-space($stdDate)" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space($date)" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
            <xsl:when test="matches($dateToUse,'^[0-9][0-9][0-9][0-9]$')">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches($dateToUse,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]$')">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches($dateToUse,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$')">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>

		<xsl:value-of select="normalize-space($dateToUse)"/>

    </xsl:template>

	
	<!-- Generates human readable label from a date range -->
	<xsl:function name="eac2rico:dateRangeLabel">
		<xsl:param name="fromDate" />
		<xsl:param name="toDate" />
		<xsl:choose>
			<xsl:when test="$fromDate != '' and $toDate != ''">
				<xsl:value-of select="concat(', ', 'début : ', $fromDate, ', fin : ', $toDate)" />
			</xsl:when>
			<xsl:when test="$fromDate != ''">
				<xsl:value-of select="concat(', ', 'début : ', $fromDate)" />
			</xsl:when>
			<xsl:when test="$toDate != ''">
				<xsl:value-of select="concat(', ', 'fin : ', $toDate)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text></xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
		
</xsl:stylesheet>