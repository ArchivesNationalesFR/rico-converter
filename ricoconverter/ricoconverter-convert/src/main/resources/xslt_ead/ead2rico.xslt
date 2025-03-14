<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	The main stylesheet to convert Archives Nationales EAD files to RiC-O.
	This relies on other stylesheets for URI generation, error codes and built-ins.
	It makes an extensive use of XSLT template "modes" to select appropriate template for the same input
	elements based on whether the element needs to be output in the RecordResource or the Instantiation.
	By definition the mode "#all" for a template means this template is applicable in all modes.
 -->
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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	exclude-result-prefixes="ead2rico xlink xs xsi xsl skos"
>
	<!-- Import URI stylesheet -->
	<xsl:import href="ead2rico-uris.xslt" />
	<!-- Import builtins stylesheet -->
	<xsl:import href="ead2rico-builtins.xslt" />

	<xsl:output indent="yes" method="xml" />

	<!--  Global variable for faId to reference it in functions -->
	<xsl:variable name="faId" select="if(starts-with(/ead/eadheader/eadid, 'FRAN_IR_')) then substring-after(/ead/eadheader/eadid, 'FRAN_IR_') else encode-for-uri(translate(/ead/eadheader/eadid,' ','_'))" />
	
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
		<rico:Record rdf:about="{ead2rico:URI-FindingAid($faId)}">	
			<rico:hasDocumentaryFormType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/documentaryFormTypes#FindingAid" />
	
			<!--  Turn the attributes into isRegulatedBy pointing to Rules -->
			<xsl:if test="@countryencoding = 'iso3166-1'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl005"/>
			</xsl:if>
			<xsl:if test="@dateencoding = 'iso8601'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl004"/>
			</xsl:if>
			<xsl:if test="@langencoding = 'iso639-2b'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl006"/>
			</xsl:if>
			<xsl:if test="@repositoryencoding = 'iso15511'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl007"/>
			</xsl:if>
			<xsl:if test="@scriptencoding = 'iso15924'">
				<rico:isOrWasRegulatedBy rdf:resource="rule/rl008"/>
			</xsl:if>
			<!-- Reference to ISAD(G), to be changed if you don't follow the ISAD(G) model -->
			<rico:isOrWasRegulatedBy rdf:resource="rule/rl009"/>
	
			<!-- process child elements in mode 'findingaid' -->
			<xsl:apply-templates mode="findingaid" />
	
			<!-- Generates an Instantiation of the FindingAid in a child element -->
			<xsl:apply-templates select="../archdesc" mode="reference" />
			<!-- Since this is an XML we use the generic rico:hasOrHadDigitalInstantiation on the finding aid -->
			<rico:hasOrHadDigitalInstantiation>
				<!--  FindingAid Instantiation -->
			    <rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($fiInstantiationId)}">
			      <!-- link back to parent URI -->
			      <rico:isOrWasDigitalInstantiationOf rdf:resource="{ead2rico:URI-FindingAid($faId)}"/>
			      <!-- process child elements again but this time in mode 'instantiation' -->
			      <xsl:apply-templates mode="instantiation" />
			      <!-- Always insert this regulatedBy on FindingAid's Instantiation in case of AN -->
			      <rico:isOrWasRegulatedBy rdf:resource="rule/rl010"/>
			      <dc:format xml:lang="en">text/xml</dc:format>
			      <rico:identifier><xsl:value-of select="eadid" /></rico:identifier>	      
			      <!-- Turn author URI into relative URI -->
			      <xsl:choose>
					<xsl:when test="starts-with($AUTHOR_URI, $BASE_URI)">
						<rico:hasOrHadHolder rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
					</xsl:when>
					<xsl:otherwise>
						<rico:hasOrHadHolder rdf:resource="{$AUTHOR_URI}" />
					</xsl:otherwise>
				  </xsl:choose>
            <!-- output rdfs:seeAlso only for IR coming from ANF, based on eadid structure -->
					  <xsl:if test="starts-with(eadid,'FRAN_IR_')">
			        <rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/{eadid}"/> 
            </xsl:if>
			    </rico:Instantiation>
			</rico:hasOrHadDigitalInstantiation>
		</rico:Record>
		
	</xsl:template>
	
	<xsl:template match="filedesc" mode="findingaid">
		<!-- Don't process editionstmt since it is processed in rico:history below -->
		<!-- titlestmt/author is still processed since it generates a createdBy with the AUTOR_URI -->
		<xsl:apply-templates select="* except editionstmt" mode="#current" />
		
		<!-- rico:history if necessary -->
		<xsl:if test="editionstmt/edition[normalize-space(.)] or titlestmt/author[normalize-space(.)]">
			<rico:history rdf:parseType="Literal">
				<xsl:if test="titlestmt/author[normalize-space(.)]">
					<html:div>
			            <html:h4>auteur(s)</html:h4>
			            <html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(titlestmt/author)" /></html:p>
			         </html:div>
				</xsl:if>
				<xsl:if test="editionstmt/edition[normalize-space(.)]">
					<html:div>
						<html:h4>mention d’édition</html:h4>
						<html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="editionstmt/edition[text()]/node()" mode="html" /></html:p>
					</html:div>
				</xsl:if>
			</rico:history>
		</xsl:if>
	</xsl:template>	
	<!-- For Instantiation just navigate down, don't generate rico:history -->
	<xsl:template match="filedesc" mode="instantiation">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<xsl:template match="titlestmt" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="titleproper[normalize-space(.)]" mode="findingaid instantiation">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(if(../subtitle) then concat(., ' : ', ../subtitle) else .)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(if(../subtitle) then concat(., ' : ', ../subtitle) else .)" /></rdfs:label>
	</xsl:template>
	
	<xsl:template match="author" mode="findingaid">
		<!-- rico:hasCreator is an object property -->
		<!-- <rico:hasCreator xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:hasCreator>  -->
		<rico:hasCreator rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
	</xsl:template>
	
	<xsl:template match="editionstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="edition[normalize-space(.)]" mode="findingaid">
		<rico:history rdf:parseType="Literal">
			<html:div>
				<html:h4>mention d’édition</html:h4>
				<html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates mode="html" /></html:p>
			</html:div>
		</rico:history>
	</xsl:template>	
	
	<xsl:template match="publicationstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="publisher[normalize-space(.)]" mode="findingaid">
		<rico:hasPublisher rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
	</xsl:template>
	<xsl:template match="date[@normal]" mode="findingaid">		
		<xsl:choose>
			<xsl:when test="ead2rico:isDateRange(@normal)">
				<!-- Date range in @normal -->
				<rico:publicationDate><xsl:call-template name="outputDateFromDateRange"><xsl:with-param name="normal" select="@normal"/></xsl:call-template></rico:publicationDate>
				<!-- If the date spans multiple years, also output it as a Literal -->
				<xsl:if test="ead2rico:isDateRangeSpanningDifferentYears(@normal)">
					<rico:publicationDate xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:publicationDate>
				</xsl:if>
			</xsl:when>
			<xsl:when test="ead2rico:isDate(@normal)">
				<!-- Single date in @normal -->
				<rico:publicationDate><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="@normal" /></xsl:call-template></rico:publicationDate>
			</xsl:when>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="notestmt" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="note[normalize-space(.)]" mode="findingaid">
		<rico:note rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="p/node()" mode="html" /></html:p></rico:note>
	</xsl:template>
	
	<!-- ***** profiledesc processing ***** -->
	
	<xsl:template match="profiledesc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="creation[normalize-space(.)]" mode="instantiation">
		<rico:history xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:history>
	</xsl:template>
	<xsl:template match="langusage" mode="findingaid">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="language[@langcode]" mode="findingaid">
		<rico:hasOrHadLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
	</xsl:template>
	
	<!-- The rico:isOrWasRegulatedBy is inserted systematically on the FindingAid + its Instantiation -->
	<!--
	<xsl:template match="descrules[normalize-space(.)]" mode="instantiation">
		<rico:isOrWasRegulatedBy rdf:resource="rule/rl010"/>
	</xsl:template>
	<xsl:template match="descrules[normalize-space(.)]" mode="findingaid">
		Reference to ISAD(G), to be changed if you don't follow the ISAD(G) model
		<rico:isOrWasRegulatedBy rdf:resource="rule/rl009"/>
	</xsl:template>
	-->
	
	<!-- ***** revisiondesc processing ***** -->
	
	<xsl:template match="revisiondesc" mode="findingaid">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<!-- Don't process change for which the item is empty -->
	<xsl:template match="change[item/text()]" mode="findingaid">
	  <rico:isOrWasAffectedBy>
         <rico:Activity>
            <rico:date>
            	<xsl:choose>
	            	<xsl:when test="ead2rico:isDateRange(date/@normal)">
						<xsl:call-template name="outputDateFromDateRange"><xsl:with-param name="normal" select="date/@normal"/></xsl:call-template>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(date/@normal)">
						<xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="date/@normal"/></xsl:call-template>
					</xsl:when>
				</xsl:choose>
            </rico:date>
            <rico:generalDescription xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(item)" /></rico:generalDescription>
         </rico:Activity>
      </rico:isOrWasAffectedBy>
	</xsl:template>
	
	<!-- ***** archdesc processing ***** -->
	
	<xsl:template match="archdesc" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="top" />
			</xsl:call-template>
		</xsl:variable>	
	
		<rico:describesOrDescribed rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
	</xsl:template>
	<xsl:template match="archdesc">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="top" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i1')" />
	
		<!-- Generates the top RecordResource corresponding to the archdesc -->
		<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">
			<rico:isOrWasDescribedBy rdf:resource="{ead2rico:URI-FindingAid($faId)}" />
			
			<!--  dsc is processed later, outside of RecordResource. Note we process the element with a special mode to test on its type. -->
			<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
			<!--  Note that originalsloc is still processed here to match inner ref -->
			<xsl:apply-templates select="." mode="level" />
			<xsl:apply-templates select="@otherlevel | (node() except (dsc | daogrp | processinfo | appraisal | originalsloc[not(descendant::ref)]))" />

			<!-- process everything that needs to go inside a rico:history -->
			<xsl:variable name="historyContent">
				<xsl:apply-templates select="processinfo" />
				<xsl:apply-templates select="appraisal" />
				<xsl:apply-templates select="did/origination" />
				<xsl:apply-templates select="originalsloc[not(descendant::ref)]" />
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="count($historyContent/*) > 1">
					<!-- if more than one children, encapsulate in a div -->
					<rico:history rdf:parseType="Literal">
						<html:div>
							<xsl:copy-of select="$historyContent" />
						</html:div>
					</rico:history>
				</xsl:when>
				<xsl:when test="count($historyContent/*) = 1">
					<rico:history rdf:parseType="Literal">
						<xsl:copy-of select="$historyContent" />
					</rico:history>
				</xsl:when>
			</xsl:choose>
			
			<!-- if archdesc has no repository, output the default one -->
			<xsl:if test="not(did/repository)">
				<rico:hasOrHadHolder rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
			</xsl:if>

			<!-- The instantiation of the RecordResource -->

			<xsl:variable name="instantiationLink">
				<predicates>
					<xsl:choose>
						<!-- This value ending by isx indicates that it is a digital archive. So we use a specific link to the Instantiation -->
						<xsl:when test="did/physdesc/physfacet[@type = 'd3nd9y3c6o-iu0j3xsmoisx']">
							<resourceToInstantiation>rico:hasOrHadDigitalInstantiation</resourceToInstantiation>
							<instantiationToResource>rico:isOrWasDigitalInstantiationOf</instantiationToResource>
						</xsl:when>
						<xsl:otherwise>
							<resourceToInstantiation>rico:hasOrHadInstantiation</resourceToInstantiation>
							<instantiationToResource>rico:isOrWasInstantiationOf</instantiationToResource>						
						</xsl:otherwise>
					</xsl:choose>
				</predicates>
			</xsl:variable>

			<xsl:element name="{$instantiationLink/predicates/resourceToInstantiation}">
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<xsl:element name="{$instantiationLink/predicates/instantiationToResource}">
						<xsl:attribute name="rdf:resource"><xsl:value-of select="ead2rico:URI-RecordResource($recordResourceId)" /></xsl:attribute>
					</xsl:element>

					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp | did/daogrp" mode="reference" />
					<!--  Recurse down. Note that origination is still processed here to match inner persname/corpname/famname -->
					<xsl:apply-templates select="node() except (daogrp | custodhist | acqinfo | processinfo | appraisal)" mode="instantiation" />
					
					<!-- everything that goes in the 'rico:history' section -->
					<xsl:variable name="instantiationHistoryContent">
						<!-- We want them in this order -->
						<xsl:apply-templates select="custodhist"  mode="instantiation" />
						<xsl:apply-templates select="acqinfo" mode="instantiation" />
						<xsl:apply-templates select="processinfo" mode="instantiation" />
						<xsl:apply-templates select="appraisal" mode="instantiation" />
						<xsl:apply-templates select="did/origination" mode="instantiation" />
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="count($instantiationHistoryContent/*) > 1">
							<!-- if more than one children, encapsulate in a div -->
							<rico:history rdf:parseType="Literal">
								<html:div>
									<xsl:copy-of select="$instantiationHistoryContent" />
								</html:div>
							</rico:history>
						</xsl:when>
						<xsl:when test="count($instantiationHistoryContent/*) = 1">
							<rico:history rdf:parseType="Literal">
								<xsl:copy-of select="$instantiationHistoryContent" />
							</rico:history>
						</xsl:when>
					</xsl:choose>
					
					<!-- if archdesc has no repository, output the default one -->
					<xsl:if test="not(did/repository)">
						<rico:hasOrHadHolder rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}" />
					</xsl:if>
					<!-- this line would be what we could generate when the information system of the ANF handles such a permalink for the archdesc description unit, which is not the case yet <rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/{/ead/eadheader/eadid}/top" />-->
				</rico:Instantiation>
			</xsl:element>		
						
			<!-- generates other Instantiations if any -->
			<xsl:apply-templates select="daogrp" />
			
			<!--  references to RecordResources, generates rico:directlyIncludes -->
			<xsl:apply-templates select="dsc" mode="reference" />
		</rico:RecordResource>
		
		<!-- Recurse down in all RecordResources -->
		<xsl:apply-templates select="dsc" />
	</xsl:template>
	
	<xsl:template match="dsc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<!-- Processes c under archdesc -->
	<xsl:template match="c" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
	
		<!-- We suppose that by default all archdesc are RecordSets, so always use directlyIncludes -->
		<rico:directlyIncludes rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
		
	</xsl:template>
	
	<!-- ***** c processing : generates corresponding RecordResource and Instantiation ***** -->
	
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
				<xsl:with-param name="recordResourceId" select="ancestor::*[local-name() = 'c' or local-name() = 'archdesc'][1]/@id" />
			</xsl:call-template>
		</xsl:variable>

		<!-- RecordResource -->
		<rico:RecordResource rdf:about="{ead2rico:URI-RecordResource($recordResourceId)}">

			<!-- The inverse link to the parent depends on the incoming link, which depends on the type of the parent -->
			<xsl:choose>
				<xsl:when test="ead2rico:isRicoRecordSet(ancestor::*[local-name() = 'c' or local-name() = 'archdesc'][1])">
					<rico:isDirectlyIncludedIn rdf:resource="{ead2rico:URI-RecordResource($parentRecordResourceId)}" />	
				</xsl:when>
				<xsl:when test="ead2rico:isRicoRecord(ancestor::*[local-name() = 'c' or local-name() = 'archdesc'][1])">
					<rico:isOrWasConstituentOf rdf:resource="{ead2rico:URI-RecordResource($parentRecordResourceId)}" />	
				</xsl:when>
				<xsl:otherwise>
					<rico:isOrWasPartOf rdf:resource="{ead2rico:URI-RecordResource($parentRecordResourceId)}" />					
				</xsl:otherwise>
			</xsl:choose>

			<!-- link to siblings of the RecordResource -->
			<xsl:apply-templates select="preceding-sibling::c[1]" mode="preceding-sibling" />
			<xsl:apply-templates select="following-sibling::c[1]" mode="following-sibling" />
						
			<!-- child c's and daogrp are processed after. Note that the current element is processed here with a special mode to determine its type -->
			<!--  Note that origination is still processed here to match inner persname/corpname/famname -->
			<!--  Note that originalsloc is still processed here to match inner ref -->
			<xsl:apply-templates select="." mode="level" />
			<xsl:apply-templates select="@otherlevel | (node() except (c | daogrp | processinfo | appraisal | originalsloc[not(descendant::ref)]))" />
			
			
			<!-- everything that goes in the 'rico:history' section -->
			<xsl:variable name="historyContent">
				<!-- We want them in this order -->
				<xsl:apply-templates select="processinfo" />
				<xsl:apply-templates select="appraisal" />
				<xsl:apply-templates select="did/origination" />
				<xsl:apply-templates select="originalsloc[not(descendant::ref)]" />
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="count($historyContent/*) > 1">
					<!-- if more than one children, encapsulate in a div -->
					<rico:history rdf:parseType="Literal">
						<html:div>
							<xsl:copy-of select="$historyContent" />
						</html:div>
					</rico:history>
				</xsl:when>
				<xsl:when test="count($historyContent/*) = 1">
					<rico:history rdf:parseType="Literal">
						<xsl:copy-of select="$historyContent" />
					</rico:history>
				</xsl:when>
			</xsl:choose>
			
			<!--  The instantiation of this RecordResource -->
			<xsl:variable name="instantiationLink" >
				<predicates>
					<xsl:choose>
						<!-- This value ending by isx indicates that it is a digital archive. So we use a specific link to the Instantiation -->
						<xsl:when test="did/physdesc/physfacet[@type = 'd3nd9y3c6o-iu0j3xsmoisx']">
							<resourceToInstantiation>rico:hasOrHadDigitalInstantiation</resourceToInstantiation>
							<instantiationToResource>rico:isOrWasDigitalInstantiationOf</instantiationToResource>
						</xsl:when>
						<xsl:otherwise>
							<resourceToInstantiation>rico:hasOrHadInstantiation</resourceToInstantiation>
							<instantiationToResource>rico:isOrWasInstantiationOf</instantiationToResource>						
						</xsl:otherwise>
					</xsl:choose>
				</predicates>
			</xsl:variable>

			<xsl:element name="{$instantiationLink/predicates/resourceToInstantiation}">
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<xsl:element name="{$instantiationLink/predicates/instantiationToResource}">
						<xsl:attribute name="rdf:resource"><xsl:value-of select="ead2rico:URI-RecordResource($recordResourceId)" /></xsl:attribute>
					</xsl:element>
					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp | did/daogrp" mode="reference" />
					<!--  recurse down. Note that origination is still processed here to match inner persname/corpname/famname -->
					<xsl:apply-templates select="node() except (daogrp | custodhist | acqinfo | processinfo | appraisal)" mode="instantiation" />
					
					
					<!-- everything that goes in the 'rico:history' section -->
					<xsl:variable name="instantiationHistoryContent">
						<!-- We want them in this order -->
						<xsl:apply-templates select="custodhist"  mode="instantiation" />
						<xsl:apply-templates select="acqinfo" mode="instantiation" />
						<xsl:apply-templates select="processinfo" mode="instantiation" />
						<xsl:apply-templates select="appraisal" mode="instantiation" />
						<xsl:apply-templates select="did/origination" mode="instantiation" />
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="count($instantiationHistoryContent/*) > 1">
							<!-- if more than one children, encapsulate in a div -->
							<rico:history rdf:parseType="Literal">
								<html:div>
									<xsl:copy-of select="$instantiationHistoryContent" />
								</html:div>
							</rico:history>
						</xsl:when>
						<xsl:when test="count($instantiationHistoryContent/*) = 1">
							<rico:history rdf:parseType="Literal">
								<xsl:copy-of select="$instantiationHistoryContent" />
							</rico:history>
						</xsl:when>
					</xsl:choose>
					<!-- output rdfs:seeAlso only for IR coming from ANF, based on eadid structure -->
					<xsl:if test="starts-with(/ead/eadheader/eadid,'FRAN_IR_')">
						<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/{/ead/eadheader/eadid}/{@id}" />
					</xsl:if>
				</rico:Instantiation>
			</xsl:element>
			
			<!-- generates other Instantiations -->
			<xsl:apply-templates select="daogrp" />
			
			<!-- children c's : generate directlyIncludes/hasOrHadConstituent/hasOrHadPart recursively (contrary to first level archdesc) -->
			<!-- predicate depends on type of Record -->
			<xsl:variable name="currentC" select="." />
			<xsl:for-each select="c">
				<xsl:choose>
					<xsl:when test="ead2rico:isRicoRecordSet($currentC)">
						<rico:directlyIncludes>
							<xsl:apply-templates select="." />
						</rico:directlyIncludes>
					</xsl:when>
					<xsl:when test="ead2rico:isRicoRecord($currentC)">
						<rico:hasOrHadConstituent>
							<xsl:apply-templates select="." />
						</rico:hasOrHadConstituent>
					</xsl:when>
					<xsl:otherwise>
						<rico:hasOrHadPart>
							<xsl:apply-templates select="." />
						</rico:hasOrHadPart>
						<!--
						This is outputting a lot of messages, commenting for now
						<xsl:value-of select="ead2rico:warning($faId, 'UNKNOWN_RESOURCE_TYPE_OF_C', $currentC/@level)" />
						-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</rico:RecordResource>
	</xsl:template>

	<!-- link to siblings of the RecordResource -->
	<xsl:template match="c" mode="following-sibling">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
	
		<rico:directlyPrecedesInSequence rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
	</xsl:template>

	<!-- link to siblings of the RecordResource -->
	<xsl:template match="c" mode="preceding-sibling">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<xsl:with-param name="recordResourceId" select="@id" />
			</xsl:call-template>
		</xsl:variable>
	
		<rico:directlyFollowsInSequence rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
	</xsl:template>

	<!-- ***** daogrp and daoloc processing : generates other Instantiations ***** -->

	<xsl:template match="daogrp" mode="reference">
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<!-- Note how [last()] selects the nearest ancestor -->
				<xsl:with-param name="recordResourceId" select="(ancestor::*[self::c or self::archdesc])[last()]/@id" />
			</xsl:call-template>
		</xsl:variable>
		<!-- Add +2 to the offset of this daogrp element to build instantiation ID -->
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i', count(preceding-sibling::daogrp)+2)" />
		<rico:hasOrHadDerivedInstantiation rdf:resource="{ead2rico:URI-Instantiation($instantiationId)}"/>
	</xsl:template>
	
	<xsl:template match="daogrp">

		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$faId" />
				<!-- Note how [last()] selects the nearest ancestor -->
				<xsl:with-param name="recordResourceId" select="(ancestor::*[self::c or self::archdesc])[last()]/@id" />
			</xsl:call-template>
		</xsl:variable>
		<!-- Add +2 to the offset of this daogrp element to build instantiation ID -->
		<xsl:variable name="instantiationId" select="concat($recordResourceId, '-i', count(preceding-sibling::daogrp)+2)" />
		
		<!-- Inside this other Instantiation we only pick selected EAD elements, we don't reprocess all elements -->
		<!-- We are inside a daogrp, this is necessarily a digital instantiation -->
		<rico:hasOrHadDigitalInstantiation>
			<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
				<rico:isOrWasDigitalInstantiationOf rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
				
				<!-- the image legend -->
				<xsl:apply-templates select="daodesc" />
				
				<!-- pick only the unittitle in the other Instantiations -->
				<!-- Finally, don't pick it :-) -->
				<!-- 
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/unittitle" mode="instantiation" />
				-->
				
				<!-- pick also accessrestrict -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/accessrestrict" mode="instantiation" />
				
				<!-- pick also userestrict -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/userestrict" mode="instantiation" />
				
				<!-- pick also did/repository or did/unitid -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/repository" mode="instantiation" />
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/did/unitid" mode="instantiation" />
				
				<!-- We know it is a digital copy of the first instantiation -->
				<rico:isOrWasDerivedFromInstantiation rdf:resource="{ead2rico:URI-Instantiation(concat($recordResourceId, '-i1'))}"/>
				<rico:hasProductionTechniqueType rdf:resource="http://data.culture.fr/thesaurus/page/ark:/67717/a243a805-beb9-4f48-b537-18d1e11be48f"/>	
				
				<xsl:choose>
					<xsl:when test="count(daoloc) = 1">
						<rico:identifier><xsl:value-of select="replace(tokenize(daoloc/@href, '/')[last()], '.msp', '')" /></rico:identifier>	
					</xsl:when>
					<xsl:when test="count(daoloc) = 2">
						<rico:identifier><xsl:value-of select="replace(tokenize(daoloc[1]/@href, '/')[last()], '.msp', '')" />#<xsl:value-of select="replace(tokenize(daoloc[2]/@href, '/')[last()], '.msp', '')" /></rico:identifier>
					</xsl:when>
					<xsl:otherwise>
						<!-- More than 2 daoloc ? we don't know how to deal with that -->	
					</xsl:otherwise>
				</xsl:choose>
						
				<dc:format xml:lang="en">image/jpeg</dc:format>
				<!-- here the creator is by default the archival institution: it either produced the digital instantiation image by its own, or asked a private company to produce it and then got it and aggregated it into its own archives -->
                <rico:hasOrganicProvenance rdf:resource="{replace($AUTHOR_URI, $BASE_URI, '')}"/>
				
				<xsl:apply-templates select="daoloc" />
			</rico:Instantiation>
		</rico:hasOrHadDigitalInstantiation>

	</xsl:template>
	
	<xsl:template match="daoloc">
		<xsl:if test="contains(@href, ' ')">
			<xsl:value-of select="ead2rico:warning($faId, 'DAOLOC_CONTAINS_SPACE', @href)" />
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="starts-with(@href, 'http')">
				<rdfs:seeAlso rdf:resource="{@href}"/>
			</xsl:when>
			<xsl:when test="not(contains(@href, '#'))">
				<!-- output the rdfs:seeAlso only in the case the IR comes from ANF, based on eadid structure -->
				<xsl:if test="starts-with(/ead/eadheader/eadid, 'FRAN_IR_')">
					<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/media/{/ead/eadheader/eadid}/{(ancestor::*[self::c or self::archdesc])[last()]/@id}/{replace(replace(@href, '.msp', ''), ' ', '%20')}"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- We assume we have a file range like FRAN_0118_274_L.msp#FRAN_0118_350_L.msp and we can't generate an rdfs:seeAlso -->
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="daodesc[child::node()]">
		<rico:generalDescription rdf:parseType="Literal">
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
		</rico:generalDescription>
	</xsl:template>


	<!-- ***** scopecontent processing ***** -->
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="scopecontent[normalize-space(.)]">
		<rico:scopeAndContent rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1 and not(
					p[1]/ref and not(p[1]/*[local-name(.) != 'ref']) and not(p[1]/text()[normalize-space()])
				)">
					<html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="p/*" mode="html" /></html:p>
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
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="accessrestrict[normalize-space(.)]" mode="#all">
		<rico:conditionsOfAccess rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<xsl:if test="normalize-space(p)">
						<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
					</xsl:if>
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
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="userestrict[normalize-space(.)]" mode="#all">
		<rico:conditionsOfUse rdf:parseType="Literal">
			<xsl:choose>
				<xsl:when test="count(p) = 1">
					<xsl:if test="normalize-space(p)">
						<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(p)" /></html:p>
					</xsl:if>
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

	<!-- need at least some non-empty content  -->
	<xsl:template match="arrangement[normalize-space(.)]" mode="#all">
		<rico:structure rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<xsl:apply-templates mode="html" />
			</html:div>
        </rico:structure>
	</xsl:template>

	<!-- ***** level processing on both c or archdesc ***** -->

	<xsl:template match="c | archdesc" mode="level">
		<xsl:choose>
			<xsl:when test="ead2rico:isRicoRecord(.)">
				<rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Record"/>
			</xsl:when>
			<xsl:when test="ead2rico:isRicoRecordSet(.)">
				<rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#RecordSet"/>
			    <!-- 
				    RiC-O recordSetTypes :
				    
			        https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection
			        https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File
			        https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds
			        https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series
		        -->
		        <xsl:choose>
		        	<xsl:when test="@level = 'fonds'">
		        		<rico:hasRecordSetType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds"/>
		        	</xsl:when>
		        	<xsl:when test="@level = 'subfonds'">
		        		<!--  nothing -->
		        	</xsl:when>
		        	<xsl:when test="@level = 'series'">
		        		<rico:hasRecordSetType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series"/>
		        	</xsl:when>
		        	<xsl:when test="@level = 'subseries'">
		        		<rico:hasRecordSetType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series"/>
		        	</xsl:when>
		        	<xsl:when test="@level = 'recordgrp'">
		        		<!--  nothing -->
		        	</xsl:when>
		        	<xsl:when test="@level = 'subgrp'">
		        		<!--  nothing -->
		        	</xsl:when>
		        	<xsl:when test="@level = 'file'">
		        		<rico:hasRecordSetType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File"/>
		        	</xsl:when>
		        	<xsl:when test="@level = 'collection'">
		        		<rico:hasRecordSetType rdf:resource="https://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection"/>
		        	</xsl:when>
		        	<!--  'otherlevel' is already matched above -->
		        </xsl:choose>
			</xsl:when>
			<xsl:when test="ead2rico:isRicoRecordPart(.)">
				<rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#RecordPart"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- nothing -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ***** @otherlevel processing : this is used when determining the type in a function ***** -->
	<!-- ***** but we need to generate a dc:type + rico:type systematically ***** -->
	<xsl:template match="@otherlevel">
		<dc:type><xsl:value-of select="." /></dc:type>
		<rico:type><xsl:value-of select="." /></rico:type>
	</xsl:template>

	<!-- ***** custodhist / acqinfo processing for instantiation only ***** -->
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="custodhist[normalize-space(.)]" mode="instantiation">	
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Historique de la conservation</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<!-- need at least some non-empty content  -->
	<xsl:template match="acqinfo[normalize-space(.)]" mode="instantiation">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur les modalités d’entrée</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<!-- ***** processinfo is for RecordResource also ***** -->
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="processinfo[normalize-space(.)]" mode="#all">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur le traitement</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>

	<!-- ***** appraisal is for RecordResource also ***** -->
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="appraisal[normalize-space(.)]" mode="#all">
		<html:div  xml:lang="{$LITERAL_LANG}">
            <html:h4>Informations sur l'évaluation</html:h4>
            <xsl:apply-templates mode="html" />
        </html:div>
	</xsl:template>
	
	<!-- ***** accruals ***** -->
	
	<!-- need at least some non-empty content  -->
	<xsl:template match="accruals[normalize-space(.)]">
		<rico:accruals rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
	            <xsl:apply-templates mode="html" />
	        </html:div>
        </rico:accruals>
	</xsl:template>
	
	<!-- ***** otherfindaid ***** -->
	
	<xsl:template match="otherfindaid[list/item or p]">
		<rico:generalDescription rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Autre(s) instrument(s) de recherche</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:generalDescription>
		<!-- look for archref -->
		<xsl:apply-templates select="descendant::archref | descendant::extref" />
	</xsl:template>
	<xsl:template match="archref[ancestor::otherfindaid] | extref[ancestor::otherfindaid and ancestor::ref[@role='IR']]">
		<xsl:variable name="otherFaId">
			<!--  Extract everything before # if needed -->
			<xsl:value-of select="if(contains(@href, '#')) then substring-before(substring-after(@href, 'FRAN_IR_'), '#') else substring-after(@href, 'FRAN_IR_')" />
		</xsl:variable> 

		<!-- just make sure we don't output anything if FA id parsing fails -->		
		<xsl:if test="$otherFaId">
			<xsl:variable name="recordResourceId">
				<xsl:call-template name="recordResourceId">
					<xsl:with-param name="faId" select="$otherFaId" />
					<!-- This will insert 'top-' if recordResourceId is empty -->
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
			<rico:isOrWasSubjectOf rdf:resource="{$findingAidUri}"/>
			<rdfs:seeAlso rdf:resource="{$seeAlsoUrl}"/>
		</xsl:if>
	</xsl:template>


	<!-- ***** relatedmaterial ***** -->
	
	<xsl:template match="relatedmaterial[list/item or p]">
		<rico:generalDescription rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Document(s) en relation</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:generalDescription>
		<!-- look for archref -->
		<xsl:apply-templates select="descendant::archref" />
		<xsl:apply-templates select="descendant::extref" />
		<xsl:apply-templates select="descendant::ref" />
	</xsl:template>
	<!-- Surprinsingly the same template works for archref or extref or ref -->
	<xsl:template match="archref | extref[starts-with(@href, 'https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/')] | ref[@role='WEB' and starts-with(@href, 'https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/')]">
		<xsl:variable name="otherFaId">
			<!--  Extract everything before # if needed -->
			<xsl:value-of select="if(contains(@href, '#')) then substring-before(substring-after(@href, 'FRAN_IR_'), '#') else substring-after(@href, 'FRAN_IR_')" />
		</xsl:variable> 
		
		<xsl:variable name="recordResourceId">
			<xsl:call-template name="recordResourceId">
				<xsl:with-param name="faId" select="$otherFaId" />
				<!-- This will insert 'top-' if recordResourceId is empty -->
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
		<rico:generalDescription rdf:parseType="Literal">
            <html:div xml:lang="{$LITERAL_LANG}">
            	<html:h4>Document(s) séparé(s)</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
		</rico:generalDescription>
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
	
	<xsl:template match="unitid[normalize-space(.)]" mode="instantiation">
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

		<!-- add hasOrHadHolder if code is FRDAFAN - there is a corresponding template for record resources below -->
		<xsl:if test="@repositorycode = 'FRDAFAN'">
			<rico:hasOrHadHolder rdf:resource="agent/005061"/>
		</xsl:if>
	</xsl:template>
	
	<!-- ***** did/unittitle for RecordResource and Instantiations ***** -->
	
	<xsl:template match="unittitle[normalize-space(.)]">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		<!--  Also searches for potential embedded unitdate -->
		<xsl:apply-templates select="unitdate" />
		<!-- Search for embedded geogname only in the case we are procesing unittitle for a RecordResource, not an instantiation -->
		<xsl:apply-templates select="geogname | persname | corpname | famname | genreform | subject" />
	</xsl:template>
	
	<xsl:template match="unittitle[normalize-space(.)]" mode="instantiation">
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
						<xsl:choose>
							<xsl:when test="normalize-space(substring-before(@normal, '/')) = normalize-space(substring-after(@normal, '/'))">
								<!-- single rico:date if the begin and end date are the same -->
								<rico:date><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space(substring-before(@normal, '/'))" /></xsl:call-template></rico:date>
							</xsl:when>
							<xsl:otherwise>
								<!-- Date range in @normal and a text() -->
								<rico:beginningDate><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space(substring-before(@normal, '/'))" /></xsl:call-template></rico:beginningDate>
        						<rico:endDate><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space(substring-after(@normal, '/'))" /></xsl:call-template></rico:endDate>
							</xsl:otherwise>
						</xsl:choose>
				        <!-- we may find emph inside the text(), so we join before normalize -->
				        <rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(string-join(text(), ' '))" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(@normal)">
						<!-- Single date in @normal and a text -->
						<rico:date><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="@normal" /></xsl:call-template></rico:date>
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
						<rico:beginningDate><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space(substring-before(text(), '-'))" /></xsl:call-template></rico:beginningDate>
        				<rico:endDate><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space(substring-after(text(), '-'))" /></xsl:call-template></rico:endDate>
        				<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(text())" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(text())">
						<!-- Single date in text() -->
						<rico:date><xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="text()" /></xsl:call-template></rico:date>
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
		<rico:hasOrganicProvenance rdf:resource="{ead2rico:URI-AgentFromFRAN_NP(@authfilenumber)}"/>
	</xsl:template>

	<!-- origination reference without an @authfilenumber -->
	<xsl:template match="(origination/corpname | origination/persname | origination/famname)[not(@authfilenumber)]">
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="self::corpname">https://www.ica.org/standards/RiC/ontology#CorporateBody</xsl:when>
				<xsl:when test="self::persname">https://www.ica.org/standards/RiC/ontology#Person</xsl:when>
				<xsl:when test="self::famname">https://www.ica.org/standards/RiC/ontology#Family</xsl:when>
				<xsl:otherwise>https://www.ica.org/standards/RiC/ontology#Agent</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<rico:hasOrganicProvenance>
            <rico:Agent>
                <rdf:type rdf:resource="{$type}"/>
                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                <rico:hasOrHadAgentName>
                    <rico:AgentName>
                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
                    </rico:AgentName>
                </rico:hasOrHadAgentName>
            </rico:Agent>
        </rico:hasOrganicProvenance>
	</xsl:template>

	<!-- ***** did/repository or unitid[@repositorycode = 'FRDAFAN'] ***** -->
	
	<xsl:template match="repository[normalize-space(.)]" mode="#all">
		<xsl:choose>
			<xsl:when test="matches(normalize-space(.), 'Archives nationales de France', 'i') or matches(normalize-space(.), 'Archives nationales', 'i')">
				<rico:hasOrHadHolder rdf:resource="agent/005061"/>
			</xsl:when>
			<xsl:otherwise>
				<rico:hasOrHadHolder>
                    <rico:Agent>
                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                        <rico:hasOrHadAgentName>
                            <rico:AgentName>
                                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
                                <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
                            </rico:AgentName>
                        </rico:hasOrHadAgentName>
                    </rico:Agent>
                </rico:hasOrHadHolder> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="unitid[@repositorycode = 'FRDAFAN']">
		<rico:hasOrHadHolder rdf:resource="agent/005061"/>
	</xsl:template>


	<!-- ***** did/langmaterial (only on RecordResource) ***** -->
	
	<xsl:template match="langmaterial">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="language[@langcode]">
		<xsl:choose>
			<xsl:when test="ead2rico:isRicoRecord(../../..)">
				<!-- Record : always hasOrHadLanguage -->
				<rico:hasOrHadLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
			</xsl:when>
			<xsl:when test="ead2rico:isRicoRecordSet(../../..)">
				<!-- RecordSet : either a hasOrHadAllMembersWithLanguage if only a single value, or a someMembers property if there are multiple -->
				<xsl:choose>
					<xsl:when test="count(../language[@langcode]) = 1">
						<rico:hasOrHadAllMembersWithLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
					</xsl:when>
					<xsl:otherwise>
						<rico:hasOrHadSomeMembersWithLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Unknown : use a generic, non RiC-O property -->
				<dc:language rdf:resource="{ead2rico:URI-Language(@langcode)}" />
			</xsl:otherwise>
		</xsl:choose>
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
                	<rico:generalDescription xml:lang="{$LITERAL_LANG}">Lien : <xsl:value-of select="extref/@href" /></rico:generalDescription>
                </xsl:if>
                
            </rico:RecordResource>
        </rico:hasGeneticLinkToRecordResource>	
	</xsl:template>

	<!-- ***** controlaccess ***** -->

	<xsl:template match="controlaccess">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<xsl:template match="genreform[@authfilenumber]">
		
		<xsl:choose>
			<xsl:when test="ead2rico:isRicoRecord(../..)">
				<xsl:choose>
					<!-- if provided genreform is a documentary form type, use corresponding property -->				
					<xsl:when test="ead2rico:isDocumentaryFormType(.)">
						<rico:hasDocumentaryFormType rdf:resource="{ead2rico:URI-DocumentaryFormType(@authfilenumber, @source)}"/>
					</xsl:when>
					<!-- if provided genreform is a record state, use corresponding property -->				
					<xsl:when test="ead2rico:isRecordState(.)">
						<rico:hasRecordState rdf:resource="{ead2rico:URI-RecordState(@authfilenumber, @source)}"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- Output a default property and generate a warning -->
						<dc:type><xsl:value-of select="text()" /></dc:type>
						<rico:type><xsl:value-of select="text()" /></rico:type>
						<xsl:value-of select="ead2rico:warning($faId, 'UNKNOWN_GENREFORM', @authfilenumber)" />
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<xsl:when test="ead2rico:isRicoRecordSet(../..)">

				<xsl:choose>
					<!-- if provided genreform is a documentary form type, use corresponding property -->				
					<xsl:when test="ead2rico:isDocumentaryFormType(.)">
						<!-- someMembers property as we are not sure all children have the same dft -->
						<rico:hasOrHadSomeMembersWithDocumentaryFormType rdf:resource="{ead2rico:URI-DocumentaryFormType(@authfilenumber, @source)}"/>
					</xsl:when>
					<!-- if provided genreform is a record set type, use corresponding property -->				
					<xsl:when test="ead2rico:isRecordSetType(.)">
						<rico:hasRecordSetType rdf:resource="{ead2rico:URI-RecordSetType(@authfilenumber, @source)}"/>
					</xsl:when>
					<!-- if provided genreform is a record state, use corresponding property -->				
					<xsl:when test="ead2rico:isRecordState(.)">
						<rico:hasOrHadSomeMembersWithRecordState rdf:resource="{ead2rico:URI-RecordState(@authfilenumber, @source)}"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- Output a default property and generate a warning -->
						<dc:type><xsl:value-of select="text()" /></dc:type>
						<rico:type><xsl:value-of select="text()" /></rico:type>
						<xsl:value-of select="ead2rico:warning($faId, 'UNKNOWN_GENREFORM', @authfilenumber)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- we don't know if this is a Record or a RecordSet. Output a generic dc:type property -->
				<dc:type><xsl:value-of select="text()" /></dc:type>
				<rico:type><xsl:value-of select="text()" /></rico:type>
				<xsl:value-of select="ead2rico:warning($faId, 'UNKNOWN_RESOURCE_TYPE_IN_GENREFORM', ../../@level)" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="geogname[@authfilenumber]">
		<rico:hasOrHadSubject rdf:resource="{ead2rico:URI-Place(@authfilenumber, @source)}"/>
	</xsl:template>
	
	<xsl:template match="subject[@authfilenumber]">
		<rico:hasOrHadSubject rdf:resource="{ead2rico:URI-Thing(@authfilenumber, @source)}"/>
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
						<rico:hasOrHadSubject>
							<rico:Agent rdf:about="{$agentUri}">
								<rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Person"/>
								<xsl:apply-templates select="../occupation[@authfilenumber and @source]" mode="persname" />
				            </rico:Agent>
			            </rico:hasOrHadSubject>
					</xsl:when>
					<xsl:otherwise>
						<!--  no occupation, plain reference to the Agent -->
						<rico:hasOrHadSubject rdf:resource="{$agentUri}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasOrHadSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Person"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasOrHadAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasOrHadAgentName>
		                <!-- Assign occupations to persons only if there was a single person declared -->
						<xsl:if test="../occupation[@authfilenumber and @source] and (count(../persname) = 1)">
							<xsl:apply-templates select="../occupation[@authfilenumber and @source]" mode="persname" />
						</xsl:if>
		            </rico:Agent>
		        </rico:hasOrHadSubject>	
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
				<rico:hasOrHadSubject rdf:resource="{$agentUri}"/>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasOrHadSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#CorporateBody"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasOrHadAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasOrHadAgentName>
		                <!-- TODO : handle functions similar to occupations ? -->
		            </rico:Agent>
		        </rico:hasOrHadSubject>	
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
			
				<rico:hasOrHadSubject rdf:resource="{$agentUri}"/>
			</xsl:when>
			
			<!-- agent without a known identifier -->
			<xsl:otherwise>
				<rico:hasOrHadSubject>
		            <rico:Agent>
		                <rdf:type rdf:resource="https://www.ica.org/standards/RiC/ontology#Family"/>
		                <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
						<rico:hasOrHadAgentName>
		                    <rico:AgentName>
		                        <rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		                        <rico:textualValue xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:textualValue>
		                    </rico:AgentName>
		                </rico:hasOrHadAgentName>
		            </rico:Agent>
		        </rico:hasOrHadSubject>	
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	
	<!-- occupation that we can linked to a persname. The template is called from within the persname template -->
	<xsl:template match="occupation[@authfilenumber and @source]" mode="persname">
		<rico:performsOrPerformed>
            <rico:Activity>
                <rico:hasActivityType rdf:resource="{ead2rico:URI-OccupationType(@authfilenumber, @source)}"/>
            </rico:Activity>
        </rico:performsOrPerformed> 
	</xsl:template>

	<!-- occupation that we cannot link to a person. The template is called directly from controlaccess -->
	<xsl:template match="occupation[@authfilenumber and @source and (count(../persname) != 1)]">
		<rico:isRelatedTo>
            <rico:Activity>
                <rico:hasActivityType rdf:resource="{ead2rico:URI-OccupationType(@authfilenumber, @source)}" />
            </rico:Activity>
        </rico:isRelatedTo> 
	</xsl:template>

	<xsl:template match="function">
        <rico:documents>
            <rico:Activity>
                <rico:hasActivityType rdf:resource="{ead2rico:URI-ActivityType(@authfilenumber, @source)}"/>
            </rico:Activity>
        </rico:documents>
	</xsl:template>	


	<!-- ***** physdesc ***** -->

	<xsl:template match="physdesc" mode="instantiation">
		<!-- Output only if we have some text inside -->
		<xsl:if test="normalize-space(string-join(text())) != ''">
	        <rico:physicalCharacteristicsNote rdf:parseType="Literal">
	        	<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
	        </rico:physicalCharacteristicsNote>
        </xsl:if>
        <xsl:apply-templates mode="#current" />
	</xsl:template>	
	
	<xsl:template match="extent[normalize-space(.)]" mode="instantiation">
		<rico:instantiationExtent  rdf:parseType="Literal">
            <html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
        </rico:instantiationExtent>
	</xsl:template>

	<xsl:template match="dimensions[normalize-space(.)]" mode="instantiation">
		<rico:carrierExtent rdf:parseType="Literal">
            <html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></html:p>
        </rico:carrierExtent>
	</xsl:template>
	
	<!-- This first value ending by isx indicate that it is a digital archive. So use hasOrHadDigitalInstantiation to link the RR to the Instantiation -->
	<xsl:template match="physfacet[@type = 'd3nd9y3c6o-iu0j3xsmoisx' or @type = 'd3nd9xpopj-ckdrv6ljeqeg']" mode="instantiation">
		<rico:hasRepresentationType rdf:resource="{ead2rico:URI-RepresentationOrCarrierType(@type, @source)}"/>   
	</xsl:template>
	<xsl:template match="physfacet[not(@type = 'd3nd9y3c6o-iu0j3xsmoisx' or @type = 'd3nd9xpopj-ckdrv6ljeqeg')]" mode="instantiation">
		<rico:hasCarrierType rdf:resource="{ead2rico:URI-RepresentationOrCarrierType(@type, @source)}"/>   
	</xsl:template>

	<!--  ***** altformavail ***** -->
	
	<xsl:template match="altformavail" >
		<rico:generalDescription rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<html:h4>Documents de substitution</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
       </rico:generalDescription>
	</xsl:template>
	
	<!--  ***** physloc : only for Instantiation ***** -->
	
	<xsl:template match="physloc[normalize-space(.)]" mode="instantiation">
		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="matches(normalize-space(.), 'Pierrefitte', 'i')">place/FRAN_RI_005-d3ntxf5186--sga9u2l9iboc</xsl:when>
				<xsl:when test="matches(normalize-space(.), 'Pierrefitte-sur-Seine', 'i')">place/FRAN_RI_005-d3ntxf5186--sga9u2l9iboc</xsl:when>
				<xsl:when test="matches(normalize-space(.), 'Fontainebleau', 'i')">place/FRAN_RI_005-d3nttf3j17--1blvnjnk2kli0</xsl:when>
				<xsl:when test="matches(normalize-space(.), 'Paris', 'i')">place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0</xsl:when>
				<xsl:otherwise><xsl:value-of select="ead2rico:warning($faId, 'UNEXPECTED_PHYSLOC', text())" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<rico:hasOrHadLocation rdf:resource="{$value}"/>
	</xsl:template>
	
	<!--  ***** bibliography ***** -->
	
	<xsl:template match="bibliography[normalize-space(.)]">
		<rico:generalDescription rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<html:h4>Bibliographie</html:h4>
				<xsl:apply-templates mode="html" />
			</html:div>
       </rico:generalDescription>
	</xsl:template>

	<!-- ***** Processing of formatting elements p, list, item, span ***** -->
	
	<xsl:template match="p[normalize-space(.)]" mode="html">
		<xsl:choose>
			<!-- If p contains a ref and only refs... -->
			<xsl:when test="ref and not(*[local-name(.) != 'ref']) and not(text()[normalize-space()])">
				<!-- it is ignored, the refs below will generate their own p -->
				<xsl:apply-templates mode="html" />
			</xsl:when>
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
	<!-- Note how the extra space is preserved within mixed-content, at beginning or end -->
	<xsl:template match="text()" mode="html"><xsl:if test="starts-with(., ' ') and not(position() = 1)"><xsl:value-of select="' '" /></xsl:if><xsl:value-of select="normalize-space(.)" /><xsl:if test="ends-with(., ' ') and not(position() = last())"><xsl:value-of select="' '" /></xsl:if></xsl:template>
	<!-- These are only for the bibliography, or scopecontent -->
	<xsl:template match="head" mode="html">
		<html:h5><xsl:value-of select="normalize-space(.)" /></html:h5>
	</xsl:template>
	<xsl:template match="bibref" mode="html">
		<html:p><xsl:apply-templates mode="html" /></html:p>
	</xsl:template>
	<xsl:template match="persname" mode="html">
		<html:span class="persname_auteur"><xsl:apply-templates mode="html" /></html:span>
	</xsl:template>
	<xsl:template match="title" mode="html">
		<html:cite><xsl:apply-templates mode="html" /></html:cite>
	</xsl:template>
	<xsl:template match="bibseries" mode="html">
		<html:cite><xsl:apply-templates mode="html" /></html:cite>
	</xsl:template>
	<xsl:template match="imprint" mode="html">
		<html:span class="imprint"><xsl:apply-templates mode="html" /></html:span>
	</xsl:template>
	<xsl:template match="date" mode="html">
		<html:time><xsl:apply-templates mode="html" /></html:time>
	</xsl:template>
	<xsl:template match="note" mode="html">
		<xsl:apply-templates mode="html" />
	</xsl:template>
	<!-- inner scopecontent generate div -->
	<xsl:template match="scopecontent" mode="html">
		<html:div>
			<xsl:apply-templates mode="html" />
		</html:div>
	</xsl:template>
	
	<!-- a ref that is under a p that contains only refs -->
	<!-- use priority to desambiguate with template immediately following -->
	<xsl:template match="ref[parent::p[ref and not(*[local-name(.) != 'ref']) and not(text()[normalize-space()]) ]]" mode="html" priority="0.5">
		<html:p><xsl:apply-templates mode="html" /></html:p>
	</xsl:template>
	<!-- higher priority than template immediatly above, so that this one wins -->
	<xsl:template match="ref[@role='WEB' and starts-with(@href, 'https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/')]" mode="html"  priority="0.51">
		<html:p><html:a href="{@href}"><xsl:apply-templates mode="html" /></html:a></html:p>
	</xsl:template>
	<!-- a normal ref not under a p with only refs -->
	<xsl:template match="ref" mode="html">
		<xsl:apply-templates mode="html" />
	</xsl:template>
	<xsl:template match="archref | extref[ancestor::ref[@role = 'IR']]" mode="html">
		<xsl:variable name="href" select="ead2rico:URL-IRorUD(@href)" />
		<xsl:choose>
			<xsl:when test="not(contains($href, ' '))">
				<html:a href="{$href}"><xsl:apply-templates mode="html" /></html:a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="html" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	<xsl:template match="extref[ancestor::ref[@role = 'web' or @role = 'WEB' or @role = 'ANX' or @role='anx']]" mode="html">
		<!--  we resolve relative links to a base URL -->
		<xsl:variable name="href" select="
			if(not(starts-with(@href, 'http'))) then 
				concat($BASE_URL_FOR_RELATIVE_LINKS, @href)
			else 
				@href" />
		<xsl:choose>
			<xsl:when test="not(contains($href, ' '))">
				<html:a href="{if(ends-with($href,'.')) then substring($href, 1, string-length($href)-1) else $href}"><xsl:apply-templates mode="html" /></html:a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="html" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
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
				<xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="$begin" /></xsl:call-template>
			</xsl:when>
			<xsl:when test="($begin != $end) and ($beginYearMonth = $endYearMonth)">
				<xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="$beginYearMonth" /></xsl:call-template>
			</xsl:when>
			<xsl:when test="($begin != $end) and ($beginYearMonth != $endYearMonth) and ($beginYear = $endYear)">
				<xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="$beginYear" /></xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="dateWithDatatype"><xsl:with-param name="text" select="normalize-space($begin)" /></xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>
		
	<!-- Tests if a c or archdesc element corresponds to a Record -->
	<xsl:function name="ead2rico:isRicoRecord" as="xs:boolean">
		<xsl:param name="cOrArchdesc"/>
		<xsl:sequence select="$cOrArchdesc/@level = 'item'"/>  
	</xsl:function>

	<!-- Tests if a c or archdesc element corresponds to a RecordSet -->
	<xsl:function name="ead2rico:isRicoRecordSet" as="xs:boolean">
		<xsl:param name="cOrArchdesc"/>

		<!-- if archdesc without an explicit level, consider it a RecordSet -->
		<xsl:sequence select="
			(local-name($cOrArchdesc) = 'archdesc' and not($cOrArchdesc/@level))
			or
			(
				$cOrArchdesc/@level
				and
				$cOrArchdesc/@level != 'item'
				and
				(
					$cOrArchdesc/@level != 'otherlevel'
					or
					matches($cOrArchdesc/@otherlevel,$OTHERLEVEL_RECORDSET_PATTERN)
				)
			)
		"/>  
	</xsl:function>

	<!-- Tests if a c or archdesc element corresponds to a RecordPart -->
	<xsl:function name="ead2rico:isRicoRecordPart" as="xs:boolean">
		<xsl:param name="cOrArchdesc"/>

		<!-- if archdesc without an explicit level, consider it a RecordSet -->
		<xsl:sequence select="
			$cOrArchdesc/@level = 'otherlevel'
			and
			$cOrArchdesc/@otherlevel
			and
			matches($cOrArchdesc/@otherlevel,$OTHERLEVEL_RECORDPART_PATTERN)
		"/>  
	</xsl:function>

		
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
	
	<xsl:function name="ead2rico:isDateRangeSpanningDifferentYears" as="xs:boolean">
		<xsl:param name="normal"/>
        
        <xsl:variable name="begin" select="normalize-space(substring-before($normal, '/'))" />
        <xsl:variable name="end" select="normalize-space(substring-after($normal, '/'))" />

		<xsl:variable name="beginYearMonth" select="normalize-space(substring($begin, 1, 7))" />
		<xsl:variable name="endYearMonth" select="normalize-space(substring($end, 1, 7))" />
		
		<xsl:variable name="beginYear" select="normalize-space(substring-before($beginYearMonth, '-'))" />
		<xsl:variable name="endYear" select="normalize-space(substring-before($endYearMonth, '-'))" />
		
		<xsl:sequence select="$beginYear != $endYear" />
	</xsl:function>
	
	<!-- Output a date value with the proper datatype based on the date format -->
	<xsl:template name="dateWithDatatype">
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