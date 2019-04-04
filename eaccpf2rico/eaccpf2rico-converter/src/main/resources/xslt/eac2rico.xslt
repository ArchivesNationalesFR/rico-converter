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
	xmlns:html="http://www.w3.org/1999/xhtml"
>
	<xsl:output indent="yes" method="xml" />
	
	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xslt" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/corporateBody/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	
	<!-- Load Error Codes from companion file -->
	<xsl:param name="ERROR_CODES_FILE">eac2rico-errorCodes.xml</xsl:param>
	<xsl:variable name="ERROR_CODES" select="document($ERROR_CODES_FILE)" />
	
	<!--  Global variable for the Agent URI -->
	<xsl:variable name="agentUri"><xsl:call-template name="URI-Agent" /></xsl:variable>
	
	<xsl:template match="/">
		<rdf:RDF>
			<!-- Sets xml:base on root this way, so that compilation of XSLT does not fail because it is not a URI -->
			<xsl:attribute name="xml:base" select="$BASE_URI" />
			<xsl:apply-templates />
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
				<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl001" />
			</xsl:when>
			<xsl:when test="$entType = 'person'">
				<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl002" />
			</xsl:when>
		</xsl:choose>
		<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl003" />
		<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl004" />
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
			<rico:isDescribedBy><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-Description(../eac:control/eac:recordId)" /></xsl:call-template></rico:isDescribedBy>
			
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
				<rico:identifier><xsl:value-of select="normalize-space(translate(substring-after(text(), 'SIRET'), ':', ''))" /></rico:identifier>
			</xsl:when>
			<xsl:when test="@localType = 'SIRET'">
				<rico:identifier><xsl:value-of select="text()" /></rico:identifier>
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
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($agentUri, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
				<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rdfs:label>
				<rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="eac:part" /></rico:textualValue>
				<rico:isAgentNameOf><xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template></rico:isAgentNameOf>
				<!-- Authorized name are linked to the regulation depending on entityType -->
				<xsl:choose>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody' or /eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'family'">
						<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl001" />
					</xsl:when>
					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
						<rico:isRegulatedBy rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl002" />
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
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-AgentName($agentUri, eac:part, eac:useDates/eac:dateRange/eac:fromDate//@standardDate, eac:useDates/eac:dateRange/eac:toDate//@standardDate)" /></xsl:call-template>
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
	<xsl:template match="eac:dateRange">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Processing the fromDate / toDate for death and birth of Persons - otherwise the generic templates below for fromDate/toDate will be used -->
	<xsl:template match="eac:existDates/eac:dateRange/eac:fromDate[/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person']">
		<rico:birthDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:birthDate>
	</xsl:template>
	<xsl:template match="eac:existDates/eac:dateRange/eac:toDate[/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person']">
		<rico:deathDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:deathDate>
	</xsl:template>

	
	<xsl:template match="eac:fromDate">
		<rico:beginningDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:beginningDate>
	</xsl:template>
	<xsl:template match="eac:toDate">
		<rico:endDate>
			<xsl:call-template name="outputDate">
               <xsl:with-param name="stdDate" select="@standardDate"/>
               <xsl:with-param name="date" select="text()"/>
            </xsl:call-template>
		</rico:endDate>
	</xsl:template>
	
	<xsl:template match="eac:biogHist[not(eac:chronList) and normalize-space(.) != '']">
		<rico:history rdf:parseType="Literal">
			<xsl:apply-templates />
		</rico:history>
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
	
	<xsl:template match="eac:maintenanceAgency">
		<rico:authoredBy rdf:resource="{$AUTHOR_URI}" />
	</xsl:template>
	
	
	<!-- ** Functions ** -->
	<xsl:template match="eac:functions">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:function">
		
		<rico:agentIsSourceOfActivityRealizationRelation>
			<rico:ActivityRealizationRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-ActivityRealizationRelation($agentUri, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:activityRealizationRelationHasSource>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:activityRealizationRelationHasSource>
				<rico:activityRealizationRelationHasTarget>
					<rico:Activity>
						<rico:activityIsTargetOfActivityRealizationRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-ActivityRealizationRelation($agentUri, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
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
	
	<!-- ** Occupations ** -->
	<xsl:template match="eac:occupations">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="eac:occupation">
		<rico:personIsSourceOfOccupationRelation>
			<rico:OccupationRelation>
				<xsl:call-template name="rdf-about"><xsl:with-param name="uri" select="eac2rico:URI-OccupationRelation($agentUri, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
				<rico:relationToOccupationHasSource>
					<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="$agentUri" /></xsl:call-template>
				</rico:relationToOccupationHasSource>
				<rico:relationToOccupationHasTarget>
					<rico:Occupation>
						<rico:occupationIsTargetOfOccupationRelation>
							<xsl:call-template name="rdf-resource"><xsl:with-param name="uri" select="eac2rico:URI-OccupationRelation($agentUri, eac:term/@vocabularySource, eac:dateRange/eac:fromDate/@standardDate, eac:dateRange/eac:toDate/@standardDate )" /></xsl:call-template>
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

	<xsl:template match="eac:descriptiveNote">
		<rico:description rdf:parseType="Literal"><xsl:apply-templates /></rico:description>
	</xsl:template>

	<!-- Traitement des balises de mise en forme p, list, item, span -->
	<xsl:template match="eac:p">
		<html:p><xsl:apply-templates /></html:p>
	</xsl:template>
	<xsl:template match="eac:p/text()"><xsl:value-of select="." /></xsl:template>
	<xsl:template match="eac:list">
		<html:ul><xsl:apply-templates /></html:ul>
	</xsl:template>
	<xsl:template match="eac:list/text()"><xsl:value-of select="." /></xsl:template>
	<xsl:template match="eac:item">
		<html:li><xsl:apply-templates /></html:li>
	</xsl:template>
	<xsl:template match="eac:item/text()"><xsl:value-of select="." /></xsl:template>
	<xsl:template match="eac:span[@style='underline']">
		<html:u><xsl:apply-templates /></html:u>
	</xsl:template>
	<xsl:template match="eac:span[@style='bold']">
		<html:b><xsl:apply-templates /></html:b>
	</xsl:template>
	<xsl:template match="eac:span[@style='italic']">
		<html:em><xsl:apply-templates /></html:em>
	</xsl:template>
	<xsl:template match="eac:span/text()"><xsl:value-of select="." /></xsl:template>
	
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
	
	<xsl:function name="eac2rico:error">
		<xsl:param name="code" />
		<xsl:value-of select="error(
			xs:QName(concat('eac2rico:', $code)),
			concat($ERROR_CODES/ErrorCodes/ErrorCode[@code = $code]/message, ' (code : ', $code, ')')
		)">
		</xsl:value-of>
	</xsl:function>	
	
	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<xsl:template match="*" />
	
	<!-- Overwrite built-in template to match all text nodes -->
	<!-- Otherwise line breaks are inserted in resulting XML files -->
	<xsl:template match="text()|@*"></xsl:template>
	
</xsl:stylesheet>