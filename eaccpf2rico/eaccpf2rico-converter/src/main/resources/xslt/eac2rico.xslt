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
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output indent="yes" method="xml" />
	
	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xslt" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/corporateBody/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	<xsl:param name="INPUT_FOLDER">.</xsl:param>
	
	
	<!-- Load Codes from companion file -->
	<xsl:param name="CODES_FILE">eac2rico-codes.xml</xsl:param>
	<xsl:variable name="CODES" select="document($CODES_FILE)" />
	
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
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="eac:eac-cpf">		
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="eac:control">			
		<!--  Example error triggering from XSLT -->
		<xsl:if test="not(eac:recordId != '')">
			<xsl:value-of select="eac2rico:error('MISSING_RECORD_ID')" />
		</xsl:if>
		<rico:Description>
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-Description(eac:recordId)" /></xsl:call-template>
			<rico:describes><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:describes>
			
			<xsl:apply-templates />
			<xsl:apply-templates select="../eac:cpfDescription/eac:identity/eac:entityId" mode="description" />
			<xsl:apply-templates select="../eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'identity']" mode="description" />
		</rico:Description>
	</xsl:template>

	<!-- Generates rico:isRegulatedBy with hardcoded values depending on the entity type -->
	<xsl:template match="eac:control/eac:conventionDeclaration">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:control/eac:conventionDeclaration/eac:citation">
		<xsl:variable name="entType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />
		<xsl:choose>
			<xsl:when test="$entType = 'corporateBody' or $entType = 'family'">
				<rico:isRegulatedBy rdf:resource="rule/rl001" />
			</xsl:when>
			<xsl:when test="$entType = 'person'">
				<rico:isRegulatedBy rdf:resource="rule/rl002" />
			</xsl:when>
		</xsl:choose>
		<rico:isRegulatedBy rdf:resource="rule/rl003" />
		<rico:isRegulatedBy rdf:resource="rule/rl004" />
	</xsl:template>
	
	<xsl:template match="eac:maintenanceHistory">
		<!-- If an event is 'created', use it for creation date, otherwise use a 'derived' event if exists -->
		<xsl:choose>
			<xsl:when test="eac:maintenanceEvent[eac:eventType = 'created']">
	             <rico:wasCreatedAtDate>
		             <xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime"/>
		            </xsl:call-template>
	             </rico:wasCreatedAtDate>
	         </xsl:when>
	         <xsl:when test="eac:maintenanceEvent[eac:eventType = 'derived']">
	             <rico:wasCreatedAtDate>
	             	<xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime"/>
		            </xsl:call-template>
	             </rico:wasCreatedAtDate>
	         </xsl:when>
         </xsl:choose>
         <!-- If an event is 'updated', use the last one for the lastUpdateDate -->
         <!-- TODO : we could sort on the eventDateTime to make sure we pick up the last one ? -->
         <xsl:if test="eac:maintenanceEvent[eac:eventType = 'updated']">
              <rico:lastUpdateDate>
              	  	<xsl:call-template name="outputDate">
		               <xsl:with-param name="stdDate" select="eac:maintenanceEvent[eac:eventType = 'updated'][last()]/eac:eventDateTime/@standardDateTime"/>
		               <xsl:with-param name="date" select="eac:maintenanceEvent[eac:eventType = 'updated'][last()]/eac:eventDateTime"/>
		            </xsl:call-template>
              </rico:lastUpdateDate>
          </xsl:if>
	</xsl:template>
	
	<xsl:template match="eac:cpfDescription">
		<!-- Generates the description element based on the entityType -->	
		<xsl:variable name="descriptionElement">
			<xsl:choose>
				<xsl:when test="eac:identity/eac:entityType = 'person'">rico:Person</xsl:when>
				<xsl:when test="eac:identity/eac:entityType = 'corporateBody'">rico:CorporateBody</xsl:when>
				<xsl:when test="eac:identity/eac:entityType = 'family'">rico:Family</xsl:when>
				<!-- TODO : error message -->
				<xsl:otherwise>rdf:Description</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	
	
		<xsl:element name="{$descriptionElement}">
			<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
			<rico:describedBy><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Description(../eac:control/eac:recordId)" /></xsl:call-template></rico:describedBy>
			
			<xsl:apply-templates />		
		</xsl:element>
	
	</xsl:template>
	
	<xsl:template match="eac:identity">			
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- *** identity/entityId *** -->
	<xsl:template match="eac:entityId">
		<xsl:choose>
			<xsl:when test="starts-with(text(), 'ISNI')">
				<!-- Removes whitespace and potential column after "ISNI :" -->
				<isni:ISNIAssigned><xsl:value-of select="translate(substring-after(text(), 'ISNI'), ' :', '')" /></isni:ISNIAssigned>
			</xsl:when>
			<xsl:when test="@localType = 'ISNI'">
				<isni:ISNIAssigned><xsl:value-of select="translate(text(), ' ', '')" /></isni:ISNIAssigned>
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
				<rdfs:seeAlso rdf:resource="http://isni.org/isni/{translate(substring-after(text(), 'ISNI'), ' :', '')}" />
			</xsl:when>
			<xsl:when test="@localType = 'ISNI'">
				<rdfs:seeAlso rdf:resource="http://isni.org/isni/{translate(text(), ' ', '')}" />
			</xsl:when>
			<xsl:otherwise>
				<!-- output a warning ? -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<!-- ** nameEntry ** -->
	<xsl:template match="eac:nameEntry[@localType = 'autorisée']">
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
		<rico:hasAgentName>
			<rico:AgentName>				
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($recordId, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
				<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
				<rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rico:textualValue>
				<rico:isAgentNameOf><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:isAgentNameOf>
				<!-- Authorized name are linked to the regulation depending on entityType -->
				<xsl:choose>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody' or /eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'family'">
						<rico:isRegulatedBy rdf:resource="rule/rl001" />
					</xsl:when>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
						<rico:isRegulatedBy rdf:resource="rule/rl002" />
					</xsl:when>
				</xsl:choose>
				<rico:type xml:lang="fr">nom d'agent : forme préférée</rico:type>
				<xsl:apply-templates />
			</rico:AgentName>
		</rico:hasAgentName>
	</xsl:template>
	
	<xsl:template match="eac:nameEntry[not(@localType != '')]">
		<rico:hasAgentName>
			<rico:AgentName>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($recordId, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
				<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
				<rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rico:textualValue>
				<rico:isAgentNameOf><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:isAgentNameOf>
				<xsl:apply-templates />
			</rico:AgentName>
		</rico:hasAgentName>
	</xsl:template>
	
	<xsl:template match="eac:description">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:existDates">
		<xsl:apply-templates />
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
	<xsl:template match="eac:fromDate[not(@standardDate)]">
		<rico:beginningDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="text()"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:beginningDate>
	</xsl:template>
	<xsl:template match="eac:toDate[not(@standardDate)]">
		<rico:endDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="text()"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:endDate>
	</xsl:template>
	
	<xsl:template match="eac:biogHist[not(eac:chronList) and normalize-space(.) != '']">
		<rico:history rdf:parseType="Literal">
			<xsl:apply-templates />
		</rico:history>
	</xsl:template>
	
	
	<xsl:template match="eac:mandates">
		<xsl:apply-templates />
	</xsl:template>
	<!-- Case where there is an explicit @xlink:href -->
	<xsl:template match="eac:mandate[eac:citation/@xlink:href]">		
		<xsl:variable name="ruleId" select="eac2rico:URI-RuleFromEli(eac:citation/@xlink:href)" />
		<xsl:variable name="ruleToUse">
			<xsl:choose>
				<!-- Known reference in the referential -->
				<xsl:when test="$ruleId != ''"><xsl:value-of select="$ruleId" /></xsl:when>
				<!-- Unknown reference in the referential -->
				<xsl:otherwise><xsl:value-of select="eac:citation/@xlink:href" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<rico:thingIsSourceOfRegulationRelation>
			<rico:RelationToRule>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-RelationToRule($recordId, $ruleToUse)" /></xsl:call-template>
				<rico:relationToRuleHasSource rdf:resource="{$agentUri}"/>
            	<rico:relationToRuleHasTarget rdf:resource="{$ruleToUse}"/>
            	<xsl:apply-templates />
			</rico:RelationToRule>
		</rico:thingIsSourceOfRegulationRelation>
	</xsl:template>
	<!-- Case where there is a citation, but no @xlink:href -->
	<xsl:template match="eac:mandate[eac:citation[not(@xlink:href)]]">				
		<rico:thingIsSourceOfRegulationRelation>
			<rico:RelationToRule>
				<rico:relationToRuleHasSource rdf:resource="{$agentUri}"/>
            	<rico:relationToRuleHasTarget>
            		<rico:Rule>
            			<rico:title><xsl:value-of select="eac:citation/text()" /></rico:title>
            		</rico:Rule>
            	</rico:relationToRuleHasTarget>
            	<xsl:apply-templates />
			</rico:RelationToRule>
		</rico:thingIsSourceOfRegulationRelation>
	</xsl:template>
	<!-- Case where there is no citation, but a descriptiveNote with inner p's -->
	<xsl:template match="eac:mandate[not(eac:citation) and eac:descriptiveNote]">			
		<xsl:variable name="theMandate" select="." />
		<xsl:for-each select="eac:descriptiveNote/eac:p">
			<xsl:choose>
				<!-- if the <p> contains an ELI (based on a regex match)... -->
				<xsl:when test="matches(., 'https?://www.legifrance\.gouv\.fr/eli/[^.)\] ]*')">
					<!-- Then find all occurrence of the ELI... -->
					<xsl:analyze-string select="." regex="https?://www.legifrance\.gouv\.fr/eli/[^.)\] ]*">
					  <xsl:matching-substring>
					  		<!-- For each ELI value in the text apply the same process as above -->
					  		<xsl:variable name="ruleId" select="eac2rico:URI-RuleFromEli(.)" />
							<xsl:variable name="ruleToUse">
								<xsl:choose>
									<!-- Known reference in the referential -->
									<xsl:when test="$ruleId != ''"><xsl:value-of select="$ruleId" /></xsl:when>
									<!-- Unknown reference in the referential -->
									<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
					  
					  		<rico:thingIsSourceOfRegulationRelation>
								<rico:RelationToRule>
									<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-RelationToRule($recordId, $ruleToUse)" /></xsl:call-template>
									<rico:relationToRuleHasSource rdf:resource="{$agentUri}"/>
					            	<rico:relationToRuleHasTarget rdf:resource="{$ruleToUse}"/>
					            	<!-- Don't process the descriptiveNote as normal -->
					            	<xsl:apply-templates select="$theMandate/*[local-name() != descriptiveNote]" />
								</rico:RelationToRule>
							</rico:thingIsSourceOfRegulationRelation>

					  </xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<rico:ruleFollowed rdf:parseType="Literal"><xsl:apply-templates select="." /></rico:ruleFollowed>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:for-each>
	</xsl:template>
	
	<!-- *** sources/source/sourceEntry *** -->
	
	<xsl:template match="eac:sources">			
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:source[eac:sourceEntry]">			
		<xsl:choose>
			<!--  if sourceEntry is an http URI, generates a rico:hasSource -->
			<xsl:when test="starts-with(eac:sourceEntry,'http')">
				<rico:hasSource rdf:resource="{eac:sourceEntry}" />
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
			<rico:source  rdf:parseType="Literal" xml:lang="{$LITERAL_LANG}">
				<xsl:apply-templates select="."></xsl:apply-templates>
			</rico:source>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="eac:maintenanceAgency">
		<xsl:choose>
			<xsl:when test="starts-with($AUTHOR_URI, $BASE_URI)">
				<rico:authoredBy rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
			</xsl:when>
			<xsl:otherwise>
				<rico:authoredBy rdf:resource="{$AUTHOR_URI}" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<!-- *** Functions *** -->
	<xsl:template match="eac:functions">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:function">
		
		<rico:agentIsSourceOfActivityRealizationRelation>
			<rico:ActivityRealizationRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-ActivityRealizationRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:activityRealizationRelationHasSource>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:activityRealizationRelationHasSource>
				<rico:activityRealizationRelationHasTarget>
					<rico:Activity>
						<rico:activityIsTargetOfActivityRealizationRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-ActivityRealizationRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
						</rico:activityIsTargetOfActivityRealizationRelation>
						<rico:hasActivityType>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-ActivityType(eac:term/@vocabularySource)" /></xsl:call-template>
						</rico:hasActivityType>
					</rico:Activity>					
				</rico:activityRealizationRelationHasTarget>
				<xsl:apply-templates />
			</rico:ActivityRealizationRelation>
		</rico:agentIsSourceOfActivityRealizationRelation>
	</xsl:template>
	
	<!-- *** Occupations *** -->
	<xsl:template match="eac:occupations">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:occupation">
		<rico:personIsSourceOfOccupationRelation>
			<rico:OccupationRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-OccupationRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:relationToOccupationHasSource>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:relationToOccupationHasSource>
				<rico:relationToOccupationHasTarget>
					<rico:Occupation>
						<rico:occupationIsTargetOfOccupationRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-OccupationRelation($recordId, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
						</rico:occupationIsTargetOfOccupationRelation>
						<rico:hasOccupationType>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-OccupationType(eac:term/@vocabularySource)" /></xsl:call-template>
						</rico:hasOccupationType>
					</rico:Occupation>					
				</rico:relationToOccupationHasTarget>
				<xsl:apply-templates />
			</rico:OccupationRelation>
		</rico:personIsSourceOfOccupationRelation>
	</xsl:template>
	
	<!-- *** LegalStatuses *** -->
	<xsl:template match="eac:legalStatuses">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:legalStatus[not(eac:dateRange/eac:fromDate) and not(eac:dateRange/eac:toDate) and not(eac:descriptiveNote)]">
		<xsl:if test="not(eac:term/@vocabularySource)">
			<xsl:value-of select="eac2rico:warning('MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS')" />
		</xsl:if>
		<rico:hasLegalStatus><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-LegalStatus(eac:term/@vocabularySource)" /></xsl:call-template></rico:hasLegalStatus>
	</xsl:template>
	<xsl:template match="eac:legalStatus[eac:dateRange/eac:fromDate or eac:dateRange/eac:toDate or eac:descriptiveNote]">
		<xsl:if test="not(eac:term/@vocabularySource)">
			<xsl:value-of select="eac2rico:warning('MISSING_VOCABULARYSOURCE_ON_LEGAL_STATUS')" />
		</xsl:if>
		
		<rico:thingIsSourceOfRelationToType>
			<rico:RelationToType rdf:about="relationToType/005061-d5blonaxbw--1mt8t42bokzts-18500101-20061223">
				<xsl:call-template name="rdf-about">
	        		<xsl:with-param name="uri" select="eac2rico:URI-RelationToType(
	        			$recordId,
	        			eac:term/@vocabularySource,
	        			eac:dateRange/eac:fromDate/@standardDate,
	        			eac:dateRange/eac:toDate/@standardDate )"
	        		/>	
	        	</xsl:call-template>
	            <rico:relationToTypeHasSource>
	            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
	            </rico:relationToTypeHasSource>
	            <rico:relationToTypeHasTarget>
	            	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-LegalStatus(eac:term/@vocabularySource)" /></xsl:call-template>
	            </rico:relationToTypeHasTarget>
            
            <xsl:apply-templates />
         	</rico:RelationToType>
      </rico:thingIsSourceOfRelationToType>
		
	</xsl:template>

	<!-- *** RELATIONS *** -->
	<xsl:template match="eac:relations">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='identity' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'identity']">
        <owl:sameAs>
        	<xsl:call-template name="rdf-resource"><xsl:with-param name="uri">
        		<xsl:call-template name="URI-cpfRelationIdentity">
        			<xsl:with-param name="lnk" select="normalize-space(@xlink:href)" />
        			<xsl:with-param name="entityType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />
        		</xsl:call-template>
        	</xsl:with-param></xsl:call-template>
        </owl:sameAs>
	</xsl:template>
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'identity']" mode="description">
        <xsl:if test="contains(@xlink:href, 'wikipedia.org')">
        	<rdfs:seeAlso rdf:resource="{@xlink:href}" />
        </xsl:if>
	</xsl:template>
	
	
	<!-- cpfRelation cpfRelationType ='hierarchical-child' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-child']">
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
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-child']" mode="relations">
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/label" /> entre le parent "<xsl:value-of select="$thisName" />" et l'enfant "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentHierarchicalRelation>        
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='hierarchical-parent' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-parent']">
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
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'hierarchical-parent']" mode="relations">
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$HIERARCHICAL_RELATION_CONFIG/*[local-name() = $type]/label" /> entre le parent "<xsl:value-of select="$thatName" />" et l'enfant "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentHierarchicalRelation>
	</xsl:template>
	
	<!-- cpfRelation cpfRelationType ='temporal-later' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-later']">
        <rico:agentIsSourceOfAgentTemporalRelation>
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentTemporalRelation(
        			$recordId,
        			@xlink:href,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </rico:agentIsSourceOfAgentTemporalRelation>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-later']" mode="relations">
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}">Relation temporelle entre le précédent "<xsl:value-of select="$thisName" />" et le suivant "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentTemporalRelation>        
	</xsl:template>


	<!-- cpfRelation cpfRelationType ='temporal-earlier' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-earlier']">
        <rico:agentIsTargetOfAgentTemporalRelation>
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentTemporalRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </rico:agentIsTargetOfAgentTemporalRelation>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'temporal-earlier']" mode="relations">
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<rdfs:label xml:lang="{$LITERAL_LANG}">Relation temporelle entre le précédent "<xsl:value-of select="$thatName" />" et le suivant "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        	<xsl:apply-templates />
       	</rico:AgentTemporalRelation>        
	</xsl:template>


	<!-- cpfRelation cpfRelationType ='assocative' -->
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'associative']">
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
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </xsl:element>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'associative']" mode="relations">
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
       	
       	<rico:AgentRelation>
       		<!-- URI is always "source-target-dates" -->
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-AgentRelation(
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
        	<xsl:choose>
        		<xsl:when test="$agentUri = $sourceEntity">
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thisName" />" et "<xsl:value-of select="$thatName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>	
        		</xsl:when>
        		<xsl:otherwise>
        			<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="$ASSOCIATIVE_RELATION_CONFIG/*[local-name() = normalize-space($type)]/label" /> entre "<xsl:value-of select="$thatName" />" et "<xsl:value-of select="$thisName" />"<xsl:value-of select="eac2rico:dateRangeLabel(eac:dateRange/eac:fromDate, eac:dateRange/eac:toDate)" /></rdfs:label>
        		</xsl:otherwise>
        	</xsl:choose>        	
        	
        	<xsl:apply-templates />
       	</rico:AgentRelation>        
	</xsl:template>


	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'family']">
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
        			$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/uriPrefix,
        			eac2rico:AgentIdFromURI($sourceEntity),
        			eac2rico:AgentIdFromURI($targetEntity),
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </xsl:element>
	</xsl:template>	
	<xsl:template match="eac:cpfRelation[@cpfRelationType = 'family']" mode="relations"> 
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
        			$FAMILY_RELATION_CONFIG/*[local-name() = normalize-space($type)]/uriPrefix,
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
        	<xsl:variable name="thatName" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part" />
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
	<xsl:template match="eac:resourceRelation[@resourceRelationType = 'creatorOf']">
        <rico:thingIsTargetOfOriginationRelation>
        	<xsl:call-template name="rdf-resource">
        		<xsl:with-param name="uri" select="eac2rico:URI-OriginationRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        </rico:thingIsTargetOfOriginationRelation>
	</xsl:template>
	<xsl:template match="eac:resourceRelation[@resourceRelationType = 'creatorOf']" mode="relations">
        <rico:OriginationRelation>
        	<xsl:call-template name="rdf-about">
        		<xsl:with-param name="uri" select="eac2rico:URI-OriginationRelation(
        			@xlink:href,
        			$recordId,
        			eac:dateRange/eac:fromDate/@standardDate,
        			eac:dateRange/eac:toDate/@standardDate )"
        		/>	
        	</xsl:call-template>
        	<rico:originationRelationHasSource>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-RecordResource(@xlink:href)" /></xsl:call-template>
        	</rico:originationRelationHasSource>
        	<rico:originationRelationHasTarget>
        		<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
        	</rico:originationRelationHasTarget>
        	<xsl:apply-templates />
        </rico:OriginationRelation>
	</xsl:template>

	<xsl:template match="eac:descriptiveNote">
		<rico:description rdf:parseType="Literal"><xsl:apply-templates /></rico:description>
	</xsl:template>

	<!-- Processing of formatting elements p, list, item, span -->
	
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

	<!-- Configuration of the types and properties for the possible types of hierarchical relations -->
	<xsl:variable name="HIERARCHICAL_RELATION_CONFIG">
		<AgentHierarchicalRelation>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:hierarchicalRelationHasTarget</targetProperty>
			<sourceProperty>rico:hierarchicalRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:agentIsTargetOfHierarchicalRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsSourceOfHierarchicalRelation</isSourceOfProperty>
			<label>Relation hiérarchique</label>
		</AgentHierarchicalRelation>
		<GroupSubdivisionRelation>
			<extraType>http://www.ica.org/standards/RiC/ontology#GroupSubdivisionRelation</extraType>
			<targetProperty>rico:groupSubdivisionRelationHasTarget</targetProperty>
			<sourceProperty>rico:groupSubdivisionRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfGroupSubdivisionRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:groupIsSourceOfGroupSubdivisionRelation</isSourceOfProperty>
			<label>Relation de subdivision</label>
		</GroupSubdivisionRelation>
		<AgentControlRelation>
			<extraType>http://www.ica.org/standards/RiC/ontology#AgentControlRelation</extraType>
			<targetProperty>rico:agentControlRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentControlRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:agentIsTargetOfAgentControlRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsSourceOfAgentControlRelation</isSourceOfProperty>
			<label>Relation de contrôle</label>
		</AgentControlRelation>
	</xsl:variable>
	
	<!-- Determine the type of a hierarchicalRelation; the type corresponds to the possible types in $HIERARCHICAL_RELATION_CONFIG -->
	<xsl:template name="hierarchicalRelationType" as="xs:string">
		<xsl:param name="relation"  as="element()?"/>
		<xsl:choose>
	       	<!-- If we are processing a "Service d'Administration Centrale"... -->
	       	<xsl:when test="eac2rico:isServiceCentral(/eac:eac-cpf)">
	       		<!-- ...read the description of the referenced entity... -->
	       		<xsl:variable name="externalEntityDescription" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	       		<!-- ...and if it is _also_ a "Service d'Administration Central", then add an extra type to the relation -->
	       		<xsl:choose>
	       		<xsl:when test="eac2rico:isServiceCentral($externalEntityDescription/eac:eac-cpf)">GroupSubdivisionRelation</xsl:when>
	       		<xsl:otherwise>AgentHierarchicalRelation</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:when test="eac2rico:denotesAgentControlRelation(eac:descriptiveNote)">AgentControlRelation</xsl:when>
	       	
	       	<xsl:otherwise>AgentHierarchicalRelation</xsl:otherwise>
      	</xsl:choose>		
	</xsl:template>
	
	<xsl:variable name="ASSOCIATIVE_RELATION_CONFIG">
		<AgentRelation>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:agentRelationConnects</targetProperty>
			<sourceProperty>rico:agentRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:agentIsConnectedToAgentRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsConnectedToAgentRelation</isSourceOfProperty>
			<label>Relation associative</label>
		</AgentRelation>
		<LeadershipRelation>
			<extraType>http://www.ica.org/standards/RiC/ontology#LeadershipRelation</extraType>
			<targetProperty>rico:leadershipRelationHasTarget</targetProperty>
			<sourceProperty>rico:leadershipRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfLeadershipRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfLeadershipRelation</isSourceOfProperty>
			<label>Relation de direction (leadership)</label>
		</LeadershipRelation>
	</xsl:variable>
	
	<!-- Determine the type of an associativeRelation; the type corresponds to the possible types in $ASSOCIATIVE_RELATION_CONFIG -->
	<xsl:template name="associativeRelationType" as="xs:string">
		<xsl:param name="relation"  as="element()?"/>
		<xsl:choose>
	       	<!-- If we detect a specific keyword in the description... -->
	       	<xsl:when test="eac2rico:denotesLeadershipRelation(eac:descriptiveNote)">
	       		<!-- ...read the description of the referenced entity... -->
	       		<xsl:variable name="externalEntityDescription" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	       		<!-- ...and if one entity is a person and the other is the corporateBody, then this is a LeadershipRelation -->
	       		<xsl:choose>
	       			<xsl:when test="
	       				(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person' and $externalEntityDescription/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody')
	       				or
	       				(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody' and $externalEntityDescription/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person')
	       			">LeadershipRelation</xsl:when>
	       			<xsl:otherwise>AgentRelation</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:otherwise>AgentRelation</xsl:otherwise>
      	</xsl:choose>		
	</xsl:template>
	
	<!-- Determine source entity of an associative or family relation : 
		if this is a LeadershipRelation/AgentMembershipRelation, this is necessarily the person, otherwise this is the entity with the lowest ID -->
	<xsl:template name="associativeOrFamilyRelationSourceEntity">
		<xsl:param name="relation"  as="element()"/>
		<xsl:param name="type"  as="xs:string"/>
		
		<xsl:choose>
   			<xsl:when test="(normalize-space($type) = 'LeadershipRelation' or normalize-space($type) = 'AgentMembershipRelation')">
   				<xsl:choose>
   					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
   						<xsl:value-of select="$agentUri" />
   					</xsl:when>
   					<xsl:otherwise>
   						<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
   					</xsl:otherwise>
   				</xsl:choose>
   			</xsl:when>
   			<xsl:otherwise>
   				<xsl:choose>
   					<xsl:when test="@xlink:href &gt; /eac:eac-cpf/eac:control/eac:recordId">
   						<xsl:value-of select="$agentUri" />
   					</xsl:when>
   					<xsl:otherwise>
   						<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
   					</xsl:otherwise>
   				</xsl:choose>
   			</xsl:otherwise>
   		</xsl:choose>
	</xsl:template>
	
	<!-- Determine target entity of an associative or family relation : 
		if this is a LeadershipRelation/AgentMembershipRelation, this is necessarily the corporateBody/family, otherwise this is the entity with the highest ID -->
	<xsl:template name="associativeOrFamilyRelationTargetEntity">
		<xsl:param name="relation"  as="element()"/>
		<xsl:param name="type"  as="xs:string"/>
	
		<xsl:choose>
			<xsl:when
				test="(normalize-space($type) = 'LeadershipRelation' or normalize-space($type) = 'AgentMembershipRelation')">
				<xsl:choose>
					<xsl:when
						test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType != 'person'">
						<xsl:value-of select="$agentUri" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when
						test="@xlink:href &lt; /eac:eac-cpf/eac:control/eac:recordId">
						<xsl:value-of select="$agentUri" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="FAMILY_RELATION_CONFIG">
		<FamilyRelation>
			<type>rico:FamilyRelation</type>
			<targetProperty>rico:familyRelationConnects</targetProperty>
			<sourceProperty>rico:familyRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:personHasFamilyRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personHasFamilyRelation</isSourceOfProperty>
			<label>Relation familiale</label>
			<uriPrefix>familyRelation</uriPrefix>
		</FamilyRelation>
		<AgentMembershipRelation>
			<type>rico:AgentMembershipRelation</type>
			<targetProperty>rico:agentMembershipRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentMembershipRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfAgentMembershipRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfAgentMembershipRelation</isSourceOfProperty>
			<label>Relation familiale</label>
			<uriPrefix>agentMembershipRelation</uriPrefix>
		</AgentMembershipRelation>
		<AgentRelation>
			<type>rico:AgentRelation</type>
			<targetProperty>rico:agentRelationConnects</targetProperty>
			<sourceProperty>rico:agentRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:agentIsConnectedToAgentRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsConnectedToAgentRelation</isSourceOfProperty>
			<label>Relation entre les familles</label>
			<uriPrefix>agentRelation</uriPrefix>
		</AgentRelation>
	</xsl:variable>


	<!-- Determine the type of a family relation; the type corresponds to the possible types in $FAMILY_RELATION_CONFIG -->
	<xsl:template name="familyRelationType">
		<xsl:param name="relation"  as="element()?"/>

		<xsl:variable name="entityType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />		
		<xsl:variable name="externalEntityType" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />

		<xsl:choose>
	       	<xsl:when test="$entityType = 'person'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">FamilyRelation</xsl:when>
					<xsl:when test="$externalEntityType = 'family'">AgentMembershipRelation</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning('UNEXPECTED_RELATED_ENTITY_TYPE')" />
						AgentRelation
					</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:when test="$entityType = 'family'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">AgentMembershipRelation</xsl:when>
					<xsl:when test="$externalEntityType = 'family'">AgentRelation</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning('UNEXPECTED_RELATED_ENTITY_TYPE')" />
						AgentRelation
					</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:otherwise>
	       		<xsl:value-of select="eac2rico:warning('UNEXPECTED_RELATED_ENTITY_TYPE')" />
				AgentRelation
	       	</xsl:otherwise>
      	</xsl:choose>		
	</xsl:template>	
	

	<!-- Tests if a legalStatus on the entity has the value 'Service d'administration centrale' -->
	<xsl:function name="eac2rico:isServiceCentral" as="xs:boolean">
		<xsl:param name="entityDescriptionRoot"  as="element()?"/>
		<xsl:sequence select="$entityDescriptionRoot/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:term/@vocabularySource='d5blonaxbw--1mt8t42bokzts'" />
	</xsl:function>
	
	<!-- Tests if a relation descriptiveNote indicates an AgentControlRelation. We look if the descriptiveNote contains specific keywords -->
	<xsl:function name="eac2rico:denotesAgentControlRelation" as="xs:boolean">
		<xsl:param name="descriptiveNote"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/Keywords/AgentControlRelation/Keyword[contains(
			replace(normalize-unicode(lower-case($descriptiveNote),'NFKD'),'\P{IsBasicLatin}',''),
			replace(normalize-unicode(lower-case(text()),'NFKD'),'\P{IsBasicLatin}','')
		)] != ''" />
	</xsl:function>
	
	<!-- Tests if a relation descriptiveNote indicates a LeadershipRelation. We look if the descriptiveNote contains specific keywords -->
	<xsl:function name="eac2rico:denotesLeadershipRelation" as="xs:boolean">
		<xsl:param name="descriptiveNote"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/Keywords/LeadershipRelation/Keyword[contains(
			replace(normalize-unicode(lower-case($descriptiveNote),'NFKD'),'\P{IsBasicLatin}',''),
			replace(normalize-unicode(lower-case(text()),'NFKD'),'\P{IsBasicLatin}','')
		)] != ''" />
	</xsl:function>
	
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

	<!-- Outputs an error message -->
	<xsl:function name="eac2rico:error">
		<xsl:param name="code" />
		<xsl:value-of select="error(
			xs:QName(concat('eac2rico:', $code)),
			concat($recordId, ' - ', $CODES/Codes/Code[@code = $code]/message, ' (code : ', $code, ')')
		)">
		</xsl:value-of>
	</xsl:function>	
	
	<!-- Output a warning message, basically an xsl:message with a code -->
	<xsl:function name="eac2rico:warning">
		<xsl:param name="code" />
		<xsl:message><xsl:value-of select="concat($recordId, ' - ', $CODES/Codes/Code[@code = $code]/message)" /></xsl:message>
	</xsl:function>
	
	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<!-- Note the #all special keyword to apply this template to all modes -->
	<xsl:template match="*" mode="#all" />
	
	<!-- Overwrite built-in template to match all text nodes -->
	<!-- Otherwise line breaks are inserted in resulting XML files -->
	<!-- Note the #all special keyword to apply this template to all modes -->
	<xsl:template match="text()|@*" mode="#all"></xsl:template>
		
</xsl:stylesheet>