<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:ead2rico="http://data.archives-nationales.culture.gouv.fr/ead2rico/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl"
>
	<!-- Import URI stylesheet -->
	<xsl:import href="ead2rico-uris.xslt" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="ead2rico-builtins.xslt" />

	<xsl:output indent="yes" method="xml" />
	
	<!-- Stylesheet Parameters -->
	<xsl:param name="BASE_URI">http://data.archives-nationales.culture.gouv.fr/</xsl:param>
	<xsl:param name="AUTHOR_URI">http://data.archives-nationales.culture.gouv.fr/agent/005061</xsl:param>
	<xsl:param name="LITERAL_LANG">fr</xsl:param>
	<xsl:param name="INPUT_FOLDER">.</xsl:param>
	<xsl:param name="BASE_URL_FOR_RELATIVE_LINKS">https://www.siv.archives-nationales.culture.gouv.fr/mm/media/download/</xsl:param>

	<!--  Global variable for faId to reference it in functions -->
	<xsl:variable name="faId" select="substring-after(/ead/eadheader/eadid, 'FRAN_IR_')" />
	
	<xsl:template match="/">
		<rdf:RDF>
			<!-- Sets xml:base on root this way, so that compilation of XSLT does not fail because it is not a URI -->
			<xsl:attribute name="xml:base" select="$BASE_URI" />
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="ead">
		<!-- Process header -->
		<xsl:apply-templates select="eadheader" />
		
	    <!-- Then process archdesc -->
		<xsl:apply-templates select="archdesc" />
	</xsl:template>
	
	<!-- ***** eadheader processing ***** -->
	
	<xsl:template match="eadheader">
		<xsl:variable name="fiInstantiationId" select="concat($faId, '-i1')" />
		
		<!--  FindingAid object -->
		<rico:FindingAid rdf:about="{ead2rico:URI-FindingAid($faId)}">	
	
			<!--  Turn the attributes into isRegulatedBy pointing to Rules -->
			<xsl:if test="@countryencoding = 'iso3166-1'">
				<rico:isRegulatedBy rdf:resource="rule/rl005"/>
			</xsl:if>
			<xsl:if test="@dateencoding = 'iso8601'">
				<rico:isRegulatedBy rdf:resource="rule/rl004"/>
			</xsl:if>
			<xsl:if test="@langencoding = 'iso639-2b'">
				<rico:isRegulatedBy rdf:resource="rule/rl006"/>
			</xsl:if>
			<xsl:if test="@repositoryencoding = 'iso15511'">
				<rico:isRegulatedBy rdf:resource="rule/rl007"/>
			</xsl:if>
			<xsl:if test="@scriptencoding = 'iso15924'">
				<rico:isRegulatedBy rdf:resource="rule/rl008"/>
			</xsl:if>
	
			<xsl:apply-templates mode="findingaid" />
	
			<xsl:apply-templates select="../archdesc" mode="reference" />
			<rico:hasInstantiation>
				<!--  FindingAid Instantiation -->
			    <rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($fiInstantiationId)}">
			      <rico:instantiates rdf:resource="{ead2rico:URI-FindingAid($faId)}"/>
			      <xsl:apply-templates mode="instantiation" />
			      <rico:encodingFormat xml:lang="en">text/xml</rico:encodingFormat>
			      <dc:format xml:lang="en">text/xml</dc:format>
			      <rico:identifier><xsl:value-of select="eadid" /></rico:identifier>	      
			      <xsl:choose>
					<xsl:when test="starts-with($AUTHOR_URI, $BASE_URI)">
						<rico:heldBy rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
					</xsl:when>
					<xsl:otherwise>
						<rico:heldBy rdf:resource="{$AUTHOR_URI}" />
					</xsl:otherwise>
				  </xsl:choose>
			      <rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/{eadid}"/> 
			    </rico:Instantiation>
			</rico:hasInstantiation>
		</rico:FindingAid>
		
	</xsl:template>
	
	<xsl:template match="filedesc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>	
	<xsl:template match="titlestmt" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="titleproper" mode="findingaid instantiation">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(if(../subtitle) then concat(., ' : ', ../subtitle) else .)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(if(../subtitle) then concat(., ' : ', ../subtitle) else .)" /></rdfs:label>
	</xsl:template>
	<xsl:template match="author" mode="findingaid">
		<rico:authoredBy xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:authoredBy>
	</xsl:template>
	
	<xsl:template match="editionstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="edition[text()]" mode="findingaid">
		<rico:editionstmt rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates mode="html" /></html:p></rico:editionstmt>
	</xsl:template>	
	
	<xsl:template match="publicationstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="publisher[text()]" mode="findingaid">
		<rico:publishedBy rdf:resource="agent/005061" />
	</xsl:template>
	<xsl:template match="date" mode="findingaid">
		<rico:publicationDate>
			<xsl:call-template name="outputDateFromDateRange"><xsl:with-param name="normal" select="@normal"/></xsl:call-template>
        </rico:publicationDate>
	</xsl:template>	
	
	<xsl:template match="notestmt" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="note[text()]" mode="findingaid">
		<rico:note rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="p/node()" mode="html" /></html:p></rico:note>
	</xsl:template>
	
	<!-- ***** profiledesc processing ***** -->
	
	<xsl:template match="profiledesc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="creation[text()]" mode="instantiation">
		<rico:history xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:history>
	</xsl:template>
	<xsl:template match="langusage" mode="findingaid">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="language[@langcode]" mode="findingaid">
		<rico:hasLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
	</xsl:template>
	<xsl:template match="descrules[text()]" mode="instantiation">
		<rico:isRegulatedBy rdf:resource="rule/rl010"/>
	</xsl:template>
	<xsl:template match="descrules[text()]" mode="findingaid">
		<!-- Reference to ISAD(G), to be changed if you don't follow the ISAD(G) model -->
		<rico:isRegulatedBy rdf:resource="rule/rl009"/>
	</xsl:template>
	
	<!-- ***** revisiondesc processing ***** -->
	
	<xsl:template match="revisiondesc" mode="findingaid">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<!-- Don't process change for which the item is empty -->
	<xsl:template match="change[item/text()]" mode="findingaid">
	  <rico:affectedBy>
         <rico:Activity>
            <rico:date><xsl:call-template name="outputDateFromDateRange"><xsl:with-param name="normal" select="date/@normal"/></xsl:call-template></rico:date>
            <rico:description xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(item)" /></rico:description>
         </rico:Activity>
      </rico:affectedBy>
	</xsl:template>
	
	<!-- ***** archdesc processing ***** -->
	
	<xsl:template match="archdesc" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="top" />
			</xsl:call-template>
		</xsl:variable>	
	
		<rico:hasMainSubject rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
	</xsl:template>
	<xsl:template match="archdesc">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="top" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i1')" />
	
		<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">
			<rico:isMainSubjectOf rdf:resource="{ead2rico:URI-FindingAid($faId)}" />
			
			<!--  dsc is processed later, outside of RecordResource. Note we process also attributes to match @level -->
			<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
			<!--  Note that originalsloc is still processed here to match inner ref -->
			<xsl:apply-templates select="@* | (node() except (dsc | daogrp | processinfo | appraisal | originalsloc[not(descendant::ref)]))" />

			<!-- everything that needs to go inside rico:history -->
			<xsl:if test="processinfo or appraisal or did/origination[normalize-space(string-join(text()))] or originalsloc[not(descendant::ref)]">
				<rico:history rdf:parseType="Literal">
					<xsl:apply-templates select="processinfo" />
					<xsl:apply-templates select="appraisal" />
					<xsl:apply-templates select="did/origination" />
					<xsl:apply-templates select="originalsloc" />
				</rico:history>
			</xsl:if>
			
			<!-- if archdesc has no repository, output the default one -->
			<xsl:if test="not(did/repository)">
				<rico:heldBy rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
			</xsl:if>

			<!-- The instantiation of the RecordResource -->
			<rico:hasInstantiation>
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp" mode="reference" />
					<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
					<xsl:apply-templates select="node() except (daogrp | custodhist | acqinfo | processinfo | appraisal)" mode="instantiation" />
					<!-- all the 'history' section -->
					<xsl:if test="custodhist or acqinfo or processinfo or appraisal or did/origination[normalize-space(string-join(text()))]">
						<rico:history rdf:parseType="Literal">
							<!-- We want them in this order -->
							<xsl:apply-templates select="custodhist"  mode="instantiation" />
							<xsl:apply-templates select="acqinfo" mode="instantiation" />
							<xsl:apply-templates select="processinfo" mode="instantiation" />
							<xsl:apply-templates select="appraisal" mode="instantiation" />
							<xsl:apply-templates select="did/origination" mode="instantiation" />
						</rico:history>
					</xsl:if>
					<!-- if archdesc has no repository, output the default one -->
					<xsl:if test="not(did/repository)">
						<rico:heldBy rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
					</xsl:if>
					<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/{/ead/eadheader/eadid}/top" />
				</rico:Instantiation>
			</rico:hasInstantiation>			
						
			<!-- generates other Instantiations -->
			<xsl:apply-templates select="daogrp" />
			
			<!--  references to RecordResources, generates rico:hasMember -->
			<xsl:apply-templates select="dsc" mode="reference" />
		</rico:RecordResource>
		
		<!-- All RecordResources -->
		<xsl:apply-templates select="dsc" />
	</xsl:template>
	
	<xsl:template match="dsc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<xsl:template match="c" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
	
		<rico:hasMember rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
	</xsl:template>
	
	<xsl:template match="c">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i1')" />
		
		<xsl:variable name="parentRecordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="parent::*/@id" />
			</xsl:call-template>
		</xsl:variable>

		<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">
			<rico:isMemberOf rdf:resource="{ead2rico:URI-RecordResource($parentRecordResourceId)}" />			
						
			<!-- child c's and daogrp are processed after. Note we process also attributes to match @level -->
			<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
			<!--  Note that originalsloc is still processed here to match inner ref -->
			<xsl:apply-templates select="@* | (node() except (c | daogrp | processinfo | appraisal | originalsloc[not(descendant::ref)]))" />
			
			<!-- everything that needs to go inside rico:history -->
			<xsl:if test="processinfo or appraisal or did/origination[normalize-space(string-join(text()))] or originalsloc[not(descendant::ref)]">
				<rico:history rdf:parseType="Literal">
					<xsl:apply-templates select="processinfo" />
					<xsl:apply-templates select="appraisal" />
					<xsl:apply-templates select="did/origination" />
					<xsl:apply-templates select="originalsloc" />
				</rico:history>
			</xsl:if>
			
			<!--  The instantiation of this RecordResource -->
			<rico:hasInstantiation>
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp" mode="reference" />
					<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
					<xsl:apply-templates select="node() except (daogrp | custodhist | acqinfo | processinfo | appraisal)" mode="instantiation" />
					<!-- all the 'history' section -->
					<xsl:if test="custodhist or acqinfo or processinfo or appraisal or did/origination[normalize-space(string-join(text()))]">
						<rico:history rdf:parseType="Literal">
							<!-- We want them in this order -->
							<xsl:apply-templates select="custodhist"  mode="instantiation" />
							<xsl:apply-templates select="acqinfo" mode="instantiation" />
							<xsl:apply-templates select="processinfo" mode="instantiation" />
							<xsl:apply-templates select="appraisal" mode="instantiation" />
							<xsl:apply-templates select="did/origination" mode="instantiation" />
						</rico:history>
					</xsl:if>
					<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/{/ead/eadheader/eadid}/{@id}" />
				</rico:Instantiation>
			</rico:hasInstantiation>
			
			<!-- generates other Instantiations -->
			<xsl:apply-templates select="daogrp" />
			
			<!-- children c's : generate hasMember recursively (contrary to first level archdesc) -->
			<xsl:for-each select="c">
				<rico:hasMember>
					<xsl:apply-templates select="." />
				</rico:hasMember>
			</xsl:for-each>
		</rico:RecordResource>
	</xsl:template>


	<!-- ***** daogrp and daoloc processing ***** -->

	<xsl:template match="daogrp" mode="#all">
		<!-- Don't process daodesc here -->
		<xsl:apply-templates mode="#current" select="daoloc" />
	</xsl:template>
	<xsl:template match="daoloc" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<!-- Note how [last()] selects the nearest ancestor -->
				<xsl:with-param name="recordResourceId" select="(ancestor::*[self::c or self::archdesc])[last()]/@id" />
			</xsl:call-template>
		</xsl:variable>
		<!-- Add +2 to the offset of this daoloc element to build instantiation ID -->
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i', count(preceding-sibling::daoloc)+2)" />
		<rico:hasDigitalCopy rdf:resource="{ead2rico:URI-Instantiation($instantiationId)}"/>		
	</xsl:template>
	<xsl:template match="daoloc">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<!-- Note how [last()] selects the nearest ancestor -->
				<xsl:with-param name="recordResourceId" select="(ancestor::*[self::c or self::archdesc])[last()]/@id" />
			</xsl:call-template>
		</xsl:variable>
		<!-- Add +2 to the offset of this daoloc element to build instantiation ID -->
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i', count(preceding-sibling::daoloc)+2)" />
		
		<xsl:if test="contains(@href, ' ')">
			<xsl:value-of select="ead2rico:warning($faId, 'DAOLOC_CONTAINS_SPACE', @href)" />
		</xsl:if>
		
		<rico:hasInstantiation>
			<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
				<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
				
				<!-- the image legend -->
				<xsl:apply-templates select="../daodesc" />
				
				<!-- pick only the unittitle in the other Instantiations -->
				
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/unittitle" mode="instantiation" />
				
				<!-- pick also accessrestrict -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/accessrestrict" mode="instantiation" />
				
				<!-- pick also userestrict -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/userestrict" mode="instantiation" />
				
				<!-- pick also did/repository or did/unitid[@repositorycode = 'FRDAFAN'] -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/repository" mode="instantiation" />
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/unitid[@repositorycode = 'FRDAFAN']" mode="instantiation" />
				
				<!-- We know it is a digital copy of the first instantiation -->
				<rico:isDigitalCopyOf rdf:resource="{ead2rico:URI-Instantiation(concat($recordResourceId, '-i1'))}"/>
				<rico:hasProductionTechniqueType rdf:resource="http://data.culture.fr/thesaurus/page/ark:/67717/a243a805-beb9-4f48-b537-18d1e11be48f"/>	
				<rico:identifier><xsl:value-of select="replace(@href, '.msp', '')" /></rico:identifier>			
				<rico:encodingFormat xml:lang="en">image/jpeg</rico:encodingFormat>
				<!-- here the creator is by default the archival institution: it either produced the digital instantiation image by its own, or asked a private company to produce it and then got it and aggregated it into its own archives -->
                <rico:hasProvenance rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}"/>
				<xsl:if test="not(contains(@href, '#'))">
					<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/media/{/ead/eadheader/eadid}/{(ancestor::*[self::c or self::archdesc])[last()]/@id}/{replace(replace(@href, '.msp', ''), ' ', '%20')}"/>
				</xsl:if>
			</rico:Instantiation>
		</rico:hasInstantiation>
	</xsl:template>

	<xsl:template match="daodesc">
		<rico:descriptiveNote rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
				</xsl:when>
				<xsl:otherwise>
					<html:div xml:lang="{$LITERAL_LANG}">
						<xsl:apply-templates mode="html" />
					</html:div>
				</xsl:otherwise>
			</xsl:choose>
		</rico:descriptiveNote>
	</xsl:template>


	<!-- ***** scopecontent processing ***** -->
	
	<xsl:template match="scopecontent[child::node()]">
		<rico:scopeAndContent rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
				</xsl:when>
				<xsl:otherwise>
					<html:div xml:lang="{$LITERAL_LANG}">
						<xsl:apply-templates mode="html" />
					</html:div>
				</xsl:otherwise>
			</xsl:choose>
		</rico:scopeAndContent>
	</xsl:template>

	<!-- ***** accessrestrict for archdesc/c and instantiation ***** -->
	
	<xsl:template match="accessrestrict[child::node()]" mode="#all">
		<rico:conditionsOfAccess rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
				</xsl:when>
				<xsl:otherwise>
					<html:div xml:lang="{$LITERAL_LANG}">
						<xsl:apply-templates mode="html" />
					</html:div>
				</xsl:otherwise>
			</xsl:choose>
        </rico:conditionsOfAccess>
	</xsl:template>

	<!-- ***** userestrict for archdesc/c and instantiation ***** -->
	
	<xsl:template match="userestrict[child::node()]" mode="#all">
		<rico:conditionsOfUse rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
				</xsl:when>
				<xsl:otherwise>
					<html:div xml:lang="{$LITERAL_LANG}">
						<xsl:apply-templates mode="html" />
					</html:div>
				</xsl:otherwise>
			</xsl:choose>
        </rico:conditionsOfUse>
	</xsl:template>
	
	<!-- arrangement for archdesc/c -->

	<xsl:template match="arrangement[child::node()]" mode="#all">
		<rico:structure rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<xsl:apply-templates mode="html" />
			</html:div>
        </rico:structure>
	</xsl:template>

	<!-- ***** @level processing ***** -->
	
	<xsl:template match="@level">
		<xsl:choose>
			<xsl:when test=". = 'item'">
				<rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Record"/>
			</xsl:when>
			<xsl:when test=". = 'otherlevel'">
				<!-- nothing -->
			</xsl:when>
			<xsl:otherwise>
				<rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#RecordSet"/>
			    <!-- 
				    RiC-O recordSetTypes :
				    
			        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection
			        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File
			        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds
			        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series
			        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Sub-fonds
		        -->
		        <xsl:choose>
		        	<xsl:when test=". = 'fonds'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'subfonds'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Sub-fonds"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'series'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'subseries'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'recordgrp'">
		        		<!--  nothing -->
		        	</xsl:when>
		        	<xsl:when test=". = 'subgrp'">
		        		<!--  nothing -->
		        	</xsl:when>
		        	<xsl:when test=". = 'file'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'collection'">
		        		<rico:hasRecordSetType rdf:resource="http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection"/>
		        	</xsl:when>
		        	<xsl:when test=". = 'otherlevel'">
		        		<!--  nothing (already matched above anyway) -->
		        	</xsl:when>
		        </xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ***** custodhist / acqinfo processing for instantiation only ***** -->
	
	<xsl:template match="custodhist[child::node()]" mode="instantiation">	
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Historique de la conservation</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<xsl:template match="acqinfo[child::node()]" mode="instantiation">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur les modalités d’entrée</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<!-- ***** processinfo is for RecordResource also ***** -->
	
	<xsl:template match="processinfo[child::node()]" mode="#all">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur le traitement</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<!-- ***** appraisal is for RecordResource also ***** -->
	
	<xsl:template match="appraisal[child::node()]" mode="#all">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur l'évaluation</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>
	
	<!-- ***** accruals ***** -->
	
	<xsl:template match="accruals[child::node()]">
		<rico:accrual rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
	            <xsl:apply-templates mode="html" />
	        </html:div>
        </rico:accrual>
	</xsl:template>
	
	<!-- ***** otherfindaid ***** -->
	
	<xsl:template match="otherfindaid[list/item or p]">
		<rico:descriptiveNote rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Autre(s) instrument(s) de recherche</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:descriptiveNote>
		<!-- look for archref -->
		<xsl:apply-templates select="descendant::archref" />
	</xsl:template>
	<xsl:template match="archref[ancestor::otherfindaid]">
		<xsl:variable name="otherFaId">
			<!--  Extract everything before # if needed -->
			<xsl:value-of select="if(contains(@href, '#')) then substring-before(substring-after(@href, 'FRAN_IR_'), '#') else substring-after(@href, 'FRAN_IR_')" />
		</xsl:variable> 
		
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$otherFaId" />
				<!-- This will insert '-top' if recordResourceId is empty -->
				<xsl:with-param name="recordResourceId" select="if(contains(@href, '#')) then substring-after(@href, '#') else ''" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="recordResourceUri">
			<xsl:value-of select="ead2rico:URI-RecordResource($recordResourceId)" />
		</xsl:variable>
		<xsl:variable name="findingAidUri">
			<xsl:value-of select="ead2rico:URI-FindingAid($otherFaId)" />
		</xsl:variable>
		<xsl:variable name="seeAlsoUrl">
			<!-- Add extra path to URL if the recordResourceId is known -->
			<xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/FRAN_IR_', $otherFaId, (if(contains(@href, '#')) then concat('/', substring-after(@href, '#')) else ''))" />
		</xsl:variable>
		
		<rico:isRecordResourceAssociatedWithRecordResource rdf:resource="{$recordResourceUri}"/>
        <rico:isSubjectOf rdf:resource="{$findingAidUri}"/>
        <rdfs:seeAlso rdf:resource="{$seeAlsoUrl}"/>
	</xsl:template>
	
	<!-- ***** relatedmaterial ***** -->
	
	<xsl:template match="relatedmaterial[list/item or p]">
		<rico:descriptiveNote rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Document(s) en relation</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:descriptiveNote>
		<!-- look for archref -->
		<xsl:apply-templates select="descendant::archref" />
		<xsl:apply-templates select="descendant::extref" />
	</xsl:template>
	<!-- Surprinsingly the same template works for archref or extref -->
	<xsl:template match="archref | extref[starts-with(@href, 'https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/')]">
		<xsl:variable name="otherFaId">
			<!--  Extract everything before # if needed -->
			<xsl:value-of select="if(contains(@href, '#')) then substring-before(substring-after(@href, 'FRAN_IR_'), '#') else substring-after(@href, 'FRAN_IR_')" />
		</xsl:variable> 
		
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$otherFaId" />
				<!-- This will insert '-top' if recordResourceId is empty -->
				<xsl:with-param name="recordResourceId" select="if(contains(@href, '#')) then substring-after(@href, '#') else ''" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="recordResourceUri">
			<xsl:value-of select="ead2rico:URI-RecordResource($recordResourceId)" />
		</xsl:variable>
		
		<rico:isRecordResourceAssociatedWithRecordResource rdf:resource="{$recordResourceUri}"/>
	</xsl:template>
	
	
	<!-- ***** separatedmaterial ***** -->
	
	<xsl:template match="separatedmaterial[list/item or p]">
		<rico:descriptiveNote rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Document(s) séparé(s)</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:descriptiveNote>
		<!-- look for archref -->
		<xsl:apply-templates select="descendant::archref" />
		<xsl:apply-templates select="descendant::extref" />
	</xsl:template>
	
	<!-- ***** did section ***** -->
	
	<xsl:template match="did" mode="#all">
		<!-- origination with text only is processed separately in archdesc or c templates -->
		<xsl:apply-templates select="* except origination" mode="#current" />
		<xsl:apply-templates select="origination/persname | origination/corpname | origination/famname" />
	</xsl:template>
	
	<!-- ***** did/unitid processing for instantiation only ***** -->
	
	<xsl:template match="unitid" mode="instantiation">
		<xsl:choose>
			<xsl:when test="@type ='cote-de-consultation' and ((following-sibling::unitid | preceding-sibling::unitid)[@type = 'pieces'])">
			<!-- join before normalize, in odd case where there are multiple unitid type="pieces" -->
				<rico:identifier><xsl:value-of select="concat(text(), ' ', string-join( ((following-sibling::unitid | preceding-sibling::unitid)[@type = 'pieces'])/text(), ' ' ))" /></rico:identifier>
			</xsl:when>
			<xsl:when test="@type ='pieces' and ((following-sibling::unitid | preceding-sibling::unitid)[@type = 'cote-de-consultation'])">
				<!-- don't output anything -->
			</xsl:when>
			<xsl:otherwise>
				<rico:identifier><xsl:value-of select="." /></rico:identifier>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ***** did/unittitle for RecordResource and Instantiations ***** -->
	
	<xsl:template match="unittitle[text()]">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		<!--  Also searches for potential embedded unitdate -->
		<xsl:apply-templates select="unitdate" />
		<!-- Search for embedded geogname only in the case we are procesing unittitle for a RecordResource, not an instantiation -->
		<xsl:apply-templates select="geogname | persname | corpname | famname | genreform | subject" />
	</xsl:template>
	
	<xsl:template match="unittitle[text()]" mode="instantiation">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		<!--  Also searches for potential embedded unitdate -->
		<xsl:apply-templates select="unitdate" />
		<!-- Don't process embedded controlaccess tags -->
	</xsl:template>
	
	<!-- ***** did/unitdate for RecordResource and Instantiations ***** -->
	<xsl:template match="unitdate" mode="#all">
		<xsl:choose>
			
			<xsl:when test="@normal and text()">
				<!-- both @normal and text() are present -->
				<xsl:choose>
					<xsl:when test="ead2rico:isDateRange(@normal)">
						<!-- Date range in @normal and a text() -->
						<rico:beginningDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-before(@normal, '/'))" /></xsl:call-template></rico:beginningDate>
        				<rico:endDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-after(@normal, '/'))" /></xsl:call-template></rico:endDate>
				        <!-- we may find emph inside the text(), so we join before normalize -->
				        <rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(string-join(text(), ' '))" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(@normal)">
						<!-- Single date in @normal and a text -->
						<rico:date><xsl:call-template name="outputDate"><xsl:with-param name="text" select="@normal" /></xsl:call-template></rico:date>
						<!-- we may find emph inside the text(), so we join before normalize -->
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(string-join(text(), ' '))" /></rico:date>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			
			<xsl:when test="not(@normal) and text()">
				<!-- no @normal, but some text() -->
				<xsl:choose>
					<xsl:when test="ead2rico:isTextDateRange(text())">
						<!-- Date range in text() -->
						<rico:beginningDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-before(text(), '-'))" /></xsl:call-template></rico:beginningDate>
        				<rico:endDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-after(text(), '-'))" /></xsl:call-template></rico:endDate>
        				<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(text())" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(text())">
						<!-- Single date in text() -->
						<rico:date><xsl:call-template name="outputDate"><xsl:with-param name="text" select="text()" /></xsl:call-template></rico:date>
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(text())" /></rico:date>
					</xsl:when>
					<xsl:otherwise>
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(text())" /></rico:date>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="not(@normal) and not(text())">
				<!-- empty unitdate : output nothing -->
			</xsl:when>		
		</xsl:choose>
	</xsl:template>

	<!-- ***** did/origination ***** -->
	
	<xsl:template match="origination[normalize-space(string-join(text()))]" mode="#all">
		<html:div xml:lang="{$LITERAL_LANG}">
            <html:h4>Origine</html:h4>
            <html:p><xsl:value-of select="normalize-space(.)" /></html:p>
        </html:div>
	</xsl:template>
	
	<!-- origination reference with an @authfilenumber -->
	<xsl:template match="(origination/corpname | origination/persname | origination/famname)[@authfilenumber]">
		<rico:hasProvenance rdf:resource="{ead2rico:URI-AgentFromFRAN_NP(@authfilenumber)}"/>
	</xsl:template>

	<!-- origination reference without an @authfilenumber -->
	<xsl:template match="(origination/corpname | origination/persname | origination/famname)[not(@authfilenumber)]">
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="self::corpname">http://www.ica.org/standards/RiC/ontology#CorporateBody</xsl:when>
				<xsl:when test="self::persname">http://www.ica.org/standards/RiC/ontology#Person</xsl:when>
				<xsl:when test="self::famname">http://www.ica.org/standards/RiC/ontology#Family</xsl:when>
				<xsl:otherwise>http://www.ica.org/standards/RiC/ontology#Agent</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<rico:hasProvenance>
            <rico:Agent>
                <rdf:type rdf:resource="{$type}"/>
                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                <rico:hasAgentName>
                    <rico:AgentName>
                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
                    </rico:AgentName>
                </rico:hasAgentName>
            </rico:Agent>
        </rico:hasProvenance>
	</xsl:template>

	<!-- ***** did/repository or unitid[@repositorycode = 'FRDAFAN'] ***** -->
	
	<xsl:template match="repository" mode="#all">
		<xsl:choose>
			<xsl:when test="matches(text(), 'Archives nationales de France', 'i') or matches(text(), 'Archives nationales', 'i')">
				<rico:heldBy rdf:resource="agent/005061"/>
			</xsl:when>
			<xsl:otherwise>
				<rico:heldBy>
                    <rico:Agent>
                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                        <rico:hasAgentName>
                            <rico:AgentName>
                                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                                <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
                            </rico:AgentName>
                        </rico:hasAgentName>
                    </rico:Agent>
                </rico:heldBy> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="unitid[@repositorycode = 'FRDAFAN']" mode="#all">
		<rico:heldBy rdf:resource="agent/005061"/>
	</xsl:template>


	<!-- ***** did/langmaterial (only on RecordResource) ***** -->
	
	<xsl:template match="langmaterial">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="language">
		<rico:hasLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
	</xsl:template>

	<!--  ***** originalsloc (only for RecordResource) ***** -->

	<xsl:template match="originalsloc[not(descendant::ref)]">
		<xsl:if test="matches(normalize-space(.), '[A-Z]:\\.*')">
			<xsl:value-of select="ead2rico:warning($faId, 'ORIGINALSLOC_LOOKS_LIKE_A_FILE_PATH', normalize-space(.))" />
		</xsl:if>
		<html:div xml:lang="{$LITERAL_LANG}">
            <html:h4>Existence et lieu de conservation des documents originaux</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<xsl:template match="originalsloc[descendant::ref]">
		<xsl:apply-templates select="descendant::ref" />
	</xsl:template>
	<xsl:template match="ref[ancestor::originalsloc]">
		<rico:hasGeneticLinkToRecordResource>
            <rico:RecordResource>
                <rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:title>
                <xsl:if test="extref/@href">
                	<rico:descriptiveNote xml:lang="{$LITERAL_LANG}">Lien : <xsl:value-of select="extref/@href" /></rico:descriptiveNote>
                </xsl:if>
                
            </rico:RecordResource>
        </rico:hasGeneticLinkToRecordResource>	
	</xsl:template>

	<!-- ***** controlaccess ***** -->

	<xsl:template match="controlaccess">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<xsl:template match="genreform">
		<rico:hasDocumentaryForm rdf:resource="{ead2rico:URI-DocumentaryForm(@authfilenumber, @source)}"/>
	</xsl:template>
	
	<xsl:template match="geogname">
		<rico:hasSubject rdf:resource="{ead2rico:URI-Place(@authfilenumber, @source)}"/>
	</xsl:template>
	
	<xsl:template match="subject">
		<rico:hasSubject rdf:resource="{ead2rico:URI-Thing(@authfilenumber, @source)}"/>
	</xsl:template>
	
	<xsl:template match="persname">
		<xsl:choose>
			<!-- agent with a known identifier -->
			<xsl:when test="(@authfilenumber and @source) or (starts-with(@authfilenumber, 'FRAN_'))">
			
				<!-- if @authfilenumber starts with FRAN_, generate a reference to authority URI -->
				<xsl:variable name="agentUri">
					<xsl:choose>
						<xsl:when test="starts-with(@authfilenumber, 'FRAN_')">
							<xsl:value-of select="ead2rico:URI-AgentFromFRAN_NP(@authfilenumber)" />							
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ead2rico:URI-Agent(@authfilenumber, @source)" />							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
			
				<!--  When there is also an occupation, declare it on the Agent.  -->
				<xsl:choose>
					<xsl:when test="../occupation[@authfilenumber and @source] and (count(../persname) = 1)">
						<!-- Assign occupations to persons only if there was a single person declared -->
						<rico:hasSubject>
							<rico:Agent rdf:about="{$agentUri}">
								<rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Person"/>
								<xsl:apply-templates select="../occupation[@authfilenumber and @source]" mode="persname" />
				            </rico:Agent>
			            </rico:hasSubject>
					</xsl:when>
					<xsl:otherwise>
						<!--  no occupation, plain reference to the Agent -->
						<rico:hasSubject rdf:resource="{$agentUri}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Person"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasAgentName>
		                <!-- Assign occupations to persons only if there was a single person declared -->
						<xsl:if test="../occupation[@authfilenumber and @source] and (count(../persname) = 1)">
							<xsl:apply-templates select="../occupation[@authfilenumber and @source]" mode="persname" />
						</xsl:if>
		            </rico:Agent>
		        </rico:hasSubject>	
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>


	<xsl:template match="corpname">
		<xsl:choose>
			<!-- agent with a known identifier -->
			<xsl:when test="(@authfilenumber and @source) or (starts-with(@authfilenumber, 'FRAN_'))">
			
				<!-- if @authfilenumber starts with FRAN_, generate a reference to authority URI -->
				<xsl:variable name="agentUri">
					<xsl:choose>
						<xsl:when test="starts-with(@authfilenumber, 'FRAN_')">
							<xsl:value-of select="ead2rico:URI-AgentFromFRAN_NP(@authfilenumber)" />							
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ead2rico:URI-Agent(@authfilenumber, @source)" />							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
			
				<!-- TODO : handle function similar to occupations ? -->
				<rico:hasSubject rdf:resource="{$agentUri}"/>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#CorporateBody"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasAgentName>
		                <!-- TODO : handle functions similar to occupations ? -->
		            </rico:Agent>
		        </rico:hasSubject>	
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="famname">
		<xsl:choose>
			<!-- agent with a known identifier -->
			<xsl:when test="(@authfilenumber and @source) or (starts-with(@authfilenumber, 'FRAN_'))">
			
				<!-- if @authfilenumber starts with FRAN_, generate a reference to authority URI -->
				<xsl:variable name="agentUri">
					<xsl:choose>
						<xsl:when test="starts-with(@authfilenumber, 'FRAN_')">
							<xsl:value-of select="ead2rico:URI-AgentFromFRAN_NP(@authfilenumber)" />							
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ead2rico:URI-Agent(@authfilenumber, @source)" />							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
			
				<rico:hasSubject rdf:resource="{$agentUri}"/>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Family"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasAgentName>
		            </rico:Agent>
		        </rico:hasSubject>	
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	
	<!-- occupation that we can linked to a persname. The template is called from within the persname template -->
	<xsl:template match="occupation[@authfilenumber and @source]" mode="persname">
		<rico:performs>
            <rico:Activity>
                <rico:hasOccupationType rdf:resource="{ead2rico:URI-OccupationType(@authfilenumber, @source)}"/>
            </rico:Activity>
        </rico:performs> 
	</xsl:template>

	<!-- occupation that we cannot link to a person. The template is called directly from controlaccess -->
	<xsl:template match="occupation[@authfilenumber and @source and (count(../persname) != 1)]">
		<rico:isRelatedTo>
            <rico:Activity>
                <rico:hasOccupationType rdf:resource="{ead2rico:URI-OccupationType(@authfilenumber, @source)}" />
            </rico:Activity>
        </rico:isRelatedTo> 
	</xsl:template>

	<xsl:template match="function">
        <rico:isDocumentationOf>
            <rico:Activity>
                <rico:hasActivityType rdf:resource="{ead2rico:URI-ActivityType(@authfilenumber, @source)}"/>
            </rico:Activity>
        </rico:isDocumentationOf>
	</xsl:template>	


	<!-- ***** physdesc ***** -->

	<xsl:template match="physdesc" mode="instantiation">
		<!-- Output only if we have some text inside -->
		<xsl:if test="normalize-space(string-join(text())) != ''">
	        <rico:noteOnPhysicalCharacteristics rdf:parseType="Literal">
	        	<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
	        </rico:noteOnPhysicalCharacteristics>
        </xsl:if>
        <xsl:apply-templates mode="#current" />
	</xsl:template>	
	
	<xsl:template match="extent" mode="instantiation">
		<rico:instantiationExtent  rdf:parseType="Literal">
            <html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
        </rico:instantiationExtent>
	</xsl:template>

	<xsl:template match="dimensions" mode="instantiation">
		<rico:carrierExtent rdf:parseType="Literal">
            <html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
        </rico:carrierExtent>
	</xsl:template>
	
	<xsl:template match="physfacet[@type = 'd3nd9y3c6o-iu0j3xsmoisx' or @type = 'd3nd9xpopj-ckdrv6ljeqeg']" mode="instantiation">
		<rico:hasRepresentationType rdf:resource="{ead2rico:URI-RepresentationType(@type, @source)}"/>   
	</xsl:template>
	<xsl:template match="physfacet[not(@type = 'd3nd9y3c6o-iu0j3xsmoisx' or @type = 'd3nd9xpopj-ckdrv6ljeqeg')]" mode="instantiation">
		<rico:hasCarrierType rdf:resource="{ead2rico:URI-RepresentationType(@type, @source)}"/>   
	</xsl:template>

	<!--  ***** altformavail ***** -->
	
	<xsl:template match="altformavail" >
		<rico:noteOnAlternativeFormAvailable rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
				</xsl:when>
				<xsl:otherwise>
					<html:div xml:lang="{$LITERAL_LANG}">
						<xsl:apply-templates mode="html" />
					</html:div>
				</xsl:otherwise>
			</xsl:choose>
       </rico:noteOnAlternativeFormAvailable>
	</xsl:template>
	
	<!--  ***** physloc : only for Instantiation ***** -->
	
	<xsl:template match="physloc[text()]" mode="instantiation">
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="matches(text(), 'Pierrefitte', 'i')">place/FRAN_RI_005-d3ntxf5186--sga9u2l9iboc</xsl:when>
				<xsl:when test="matches(text(), 'Pierrefitte-sur-Seine', 'i')">place/FRAN_RI_005-d3ntxf5186--sga9u2l9iboc</xsl:when>
				<xsl:when test="matches(text(), 'Fontainebleau', 'i')">place/FRAN_RI_005-d3nttf3j17--1blvnjnk2kli0</xsl:when>
				<xsl:when test="matches(text(), 'Paris', 'i')">place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0</xsl:when>
				<xsl:otherwise><xsl:value-of select="ead2rico:warning($faId, 'UNEXPECTED_PHYSLOC', text())" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<rico:hasLocation rdf:resource="{$value}"/>
	</xsl:template>

	<!-- ***** Processing of formatting elements p, list, item, span ***** -->
	
	<xsl:template match="p" mode="html">
		<xsl:choose>
			<!-- if we have a list inside a p -->
			<xsl:when test="list">
				<xsl:for-each select="*|text()">
					<xsl:choose>
						<!-- Then put all text of that list in a paragraph before the list -->
						<xsl:when test=". instance of text()">
							<html:p><xsl:apply-templates mode="html" select="." /></html:p>
						</xsl:when>
						<!-- Then output the list -->
						<xsl:otherwise>
							<xsl:apply-templates mode="html" select="." />
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<html:p><xsl:apply-templates mode="html" /></html:p>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	<xsl:template match="emph[@render = 'super']" mode="html">
		<html:sup><xsl:apply-templates mode="html" /></html:sup>
	</xsl:template>
	<xsl:template match="emph[@render = 'sub']" mode="html">
		<html:sub><xsl:apply-templates mode="html" /></html:sub>
	</xsl:template>
	<xsl:template match="emph[@render = 'italic']" mode="html">
		<html:i><xsl:apply-templates mode="html" /></html:i>
	</xsl:template>
	<xsl:template match="emph[@render = 'bold']" mode="html">
		<html:b><xsl:apply-templates mode="html" /></html:b>
	</xsl:template>
	<xsl:template match="emph[@render = 'underline']" mode="html">
		<html:u><xsl:apply-templates mode="html" /></html:u>
	</xsl:template>
	<xsl:template match="list" mode="html">
		<html:ul><xsl:apply-templates mode="html" /></html:ul>
	</xsl:template>
	<xsl:template match="list/text()" mode="html"><xsl:value-of select="normalize-space(.)" /></xsl:template>
	<xsl:template match="item" mode="html">
		<html:li><xsl:apply-templates mode="html" /></html:li>
	</xsl:template>
	<xsl:template match="lb" mode="html">
		<html:br />
	</xsl:template>
	<xsl:template match="ref" mode="html">
		<xsl:apply-templates mode="html" />
	</xsl:template>
	<xsl:template match="archref" mode="html">
		<html:a href="{ead2rico:URL-IRorUD(@href)}"><xsl:apply-templates mode="html" /></html:a>
	</xsl:template>
	<xsl:template match="extref" mode="html">
		<!--  we resolve relative links to a base URL -->
		<html:a href="{if(not(starts-with(@href, 'http'))) then concat($BASE_URL_FOR_RELATIVE_LINKS, @href) else @href}"><xsl:apply-templates mode="html" /></html:a>
	</xsl:template>
	<!-- Note how the extra space is preserved within mixed-content -->
	<xsl:template match="text()" mode="html"><xsl:value-of select="normalize-space(.)" /><xsl:if test="ends-with(., ' ') and not(position() = last())"><xsl:value-of select="' '" /></xsl:if></xsl:template>

	<!-- ***** Date ***** -->
		
	<!-- Output a date value with the proper datatype based on the date format -->
	<xsl:template name="outputDateFromDateRange">
        <xsl:param name="normal"/>
        
        <xsl:variable name="begin" select="normalize-space(substring-before($normal, '/'))" />
        <xsl:variable name="end" select="normalize-space(substring-after($normal, '/'))" />

		<xsl:variable name="beginYearMonth" select="normalize-space(substring($begin, 1, 7))" />
		<xsl:variable name="endYearMonth" select="normalize-space(substring($end, 1, 7))" />
		
		<xsl:variable name="beginYear" select="normalize-space(substring-before($beginYearMonth, '-'))" />
		<xsl:variable name="endYear" select="normalize-space(substring-before($endYearMonth, '-'))" />
		
<!-- 		<xsl:message><xsl:value-of select="concat($begin, ' vs. ', $end,', ', $beginYearMonth, ' vs. ', $endYearMonth, ', ', $beginYear, ' vs. ', $endYear)" /></xsl:message> -->
		
		<xsl:choose>
			<xsl:when test="$begin = $end">
				<xsl:call-template name="outputDate"><xsl:with-param name="text" select="$begin" /></xsl:call-template>
			</xsl:when>
			<xsl:when test="($begin != $end) and ($beginYearMonth = $endYearMonth)">
				<xsl:call-template name="outputDate"><xsl:with-param name="text" select="$beginYearMonth" /></xsl:call-template>
			</xsl:when>
			<xsl:when test="($begin != $end) and ($beginYearMonth != $endYearMonth) and ($beginYear = $endYear)">
				<xsl:call-template name="outputDate"><xsl:with-param name="text" select="$beginYear" /></xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($begin)"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>
		
		
	<xsl:function name="ead2rico:isDateRange" as="xs:boolean">
		<xsl:param name="text"/>
		<xsl:sequence select="
			contains($text, '/')
			and
			ead2rico:isDate(normalize-space(substring-before($text, '/')))
			and
			ead2rico:isDate(normalize-space(substring-after($text, '/')))
		"/>  
	</xsl:function>
	
	<xsl:function name="ead2rico:isTextDateRange" as="xs:boolean">
		<xsl:param name="text"/>
		<xsl:sequence select="
			contains($text, '-')
			and
			ead2rico:isDate(normalize-space(substring-before($text, '-')))
			and
			ead2rico:isDate(normalize-space(substring-after($text, '-')))
		"/>  
	</xsl:function>
	
	<xsl:function name="ead2rico:isDate" as="xs:boolean">
		<xsl:param name="text"/>
		<xsl:sequence select="
				matches($text,'^[0-9][0-9][0-9][0-9]$')
				or
				matches($text,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]$')
				or
				matches($text,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$')
		"/>  
	</xsl:function>
	
	<!-- Output a date value with the proper datatype based on the date format -->
	<xsl:template name="outputDate">
        <xsl:param name="text"/>

		<xsl:choose>
			<xsl:when test="matches($text,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$')">
				<xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($text)"/>
			</xsl:when>
			<xsl:when test="matches($text,'^[0-9][0-9][0-9][0-9]-[0-9][0-9]$')">
				<xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($text)"/>
			</xsl:when>
			<xsl:when test="matches($text,'^[0-9][0-9][0-9][0-9]$')">
				<xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($text)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($text)"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>
		
</xsl:stylesheet>