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
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="if(../subtitle) then concat(., ' : ', ../subtitle) else ." /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="if(../subtitle) then concat(., ' : ', ../subtitle) else ." /></rdfs:label>
	</xsl:template>
	<xsl:template match="author" mode="findingaid">
		<rico:authoredBy xml:lang="{$LITERAL_LANG}"><xsl:value-of select="." /></rico:authoredBy>
	</xsl:template>
	
	<xsl:template match="editionstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="edition" mode="findingaid">
		<rico:editionstmt rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates mode="html" /></html:p></rico:editionstmt>
	</xsl:template>	
	
	<xsl:template match="publicationstmt" mode="#all">
		<xsl:apply-templates  mode="#current" />
	</xsl:template>
	<xsl:template match="publisher" mode="findingaid">
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
	<xsl:template match="note" mode="findingaid">
		<rico:note rdf:parseType="Literal"><html:p xml:lang="{$LITERAL_LANG}"><xsl:apply-templates select="p/node()" mode="html" /></html:p></rico:note>
	</xsl:template>
	
	<!-- ***** profiledesc processing ***** -->
	
	<xsl:template match="profiledesc" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="creation" mode="instantiation">
		<rico:history xml:lang="{$LITERAL_LANG}"><xsl:value-of select="." /></rico:history>
	</xsl:template>
	<xsl:template match="langusage" mode="findingaid">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	<xsl:template match="language" mode="findingaid">
		<rico:hasLanguage rdf:resource="{ead2rico:URI-Language(@langcode)}"/>
	</xsl:template>
	<xsl:template match="descrules" mode="instantiation">
		<rico:isRegulatedBy rdf:resource="rule/rl010"/>
	</xsl:template>
	<xsl:template match="descrules" mode="findingaid">
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
            <rico:description xml:lang="{$LITERAL_LANG}"><xsl:value-of select="item" /></rico:description>
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
			<xsl:apply-templates select="@* | (node() except (dsc | daogrp))" />

			<!-- The instantiation of the RecordResource -->
			<rico:hasInstantiation>
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp" mode="reference" />
					<xsl:apply-templates select="node() except (daogrp)" mode="instantiation" />
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
			<xsl:apply-templates select="@* | (node() except (c | daogrp))" />
			
			<!--  The instantiation of this RecordResource -->
			<rico:hasInstantiation>
				<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
					<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
					<!-- references to other digital copies -->
					<xsl:apply-templates select="daogrp" mode="reference" />
					<xsl:apply-templates select="node() except (daogrp)" mode="instantiation" />
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
		<xsl:apply-templates mode="#current" />
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
		
		<rico:hasInstantiation>
			<rico:Instantiation rdf:about="{ead2rico:URI-Instantiation($instantiationId)}">
				<rico:instantiates rdf:resource="{ead2rico:URI-RecordResource($recordResourceId)}" />
				
				<!-- custodhist is explicitely excluded from subsequent instantiations -->
				<xsl:apply-templates select="(ancestor::*[self::c or self::archdesc])[last()]/*[not(self::daogrp) and not(self::custodhist)]" mode="instantiation" />
				
				<!-- We know it is a digital copy of the first instantiation -->
				<rico:isDigitalCopyOf rdf:resource="{ead2rico:URI-Instantiation(concat($recordResourceId, '-i1'))}"/>
				<rico:hasProductionTechniqueType rdf:resource="http://data.culture.fr/thesaurus/page/ark:/67717/a243a805-beb9-4f48-b537-18d1e11be48f"/>	
				<rico:identifier><xsl:value-of select="replace(@href, '.msp', '')" /></rico:identifier>			
				<rico:encodingFormat xml:lang="en">image/jpeg</rico:encodingFormat>
				<xsl:if test="not(contains(@href, '#'))">
					<rdfs:seeAlso rdf:resource="https://www.siv.archives-nationales.culture.gouv.fr/siv/media/FRAN_IR_003666/{(ancestor::*[self::c or self::archdesc])[last()]/@id}/{replace(@href, '.msp', '')}"/>
				</xsl:if>
			</rico:Instantiation>
		</rico:hasInstantiation>
	</xsl:template>


	<!-- ***** scopecontent processing ***** -->
	
	<xsl:template match="scopecontent">
		<rico:scopeAndContent rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<xsl:for-each select="p">
					<html:p><xsl:value-of select="." /></html:p>
				</xsl:for-each>
			</html:div>
		</rico:scopeAndContent>
	</xsl:template>

	<!-- ***** accessrestrict for archdesc/c and instantiation (2 templates) ***** -->
	
	<xsl:template match="accessrestrict">
		<rico:conditionsOfAccess rdf:parseType="Literal">
			<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="p" /></html:p>
        </rico:conditionsOfAccess>
	</xsl:template>
	<xsl:template match="accessrestrict" mode="instantiation">
		<rico:conditionsOfAccess rdf:parseType="Literal">
			<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="p" /></html:p>
        </rico:conditionsOfAccess>
	</xsl:template>

	<!-- ***** userestrict for archdesc/c and instantiation (2 templates) ***** -->
	
	<xsl:template match="userestrict">
		<rico:conditionsOfUse rdf:parseType="Literal">
			<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="p" /></html:p>
        </rico:conditionsOfUse>
	</xsl:template>
	<xsl:template match="userestrict" mode="instantiation">
		<rico:conditionsOfUse rdf:parseType="Literal">
			<html:p xml:lang="{$LITERAL_LANG}"><xsl:value-of select="p" /></html:p>
        </rico:conditionsOfUse>
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
			    <!-- rico recordSetTypes :
		        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Collection
		        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#File
		        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Fonds
		        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Series
		        http://www.ica.org/standards/RiC/vocabularies/recordSetTypes#Sub-fonds-->
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

	<!-- ***** custodhist processing for instantiation only ***** -->
	
	<xsl:template match="custodhist" mode="instantiation">
		<rico:history rdf:parseType="Literal">
			<html:div xml:lang="{$LITERAL_LANG}">
				<xsl:for-each select="p">
					<html:p><xsl:value-of select="." /></html:p>
				</xsl:for-each>
			</html:div>
        </rico:history>
	</xsl:template>
	
	<!-- ***** did section ***** -->
	<xsl:template match="did" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	<!-- ***** did/unitid processing for instantiation only ***** -->
	
	<xsl:template match="unitid" mode="instantiation">
		<xsl:choose>
			<xsl:when test="@type ='cote-de-consultation' and ((following-sibling::unitid | preceding-sibling::unitid)[@type = 'pieces'])">
				<rico:identifier><xsl:value-of select="concat(text(), ' ', ((following-sibling::unitid | preceding-sibling::unitid)[@type = 'pieces'])/text())" /></rico:identifier>
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
	
	<xsl:template match="unittitle" mode="#all">
		<rico:title xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rico:title>
		<rdfs:label xml:lang="{$LITERAL_LANG}"><xsl:value-of select="normalize-space(.)" /></rdfs:label>
		<!--  Also searches for potential embedded unitdate -->
		<xsl:apply-templates select="unitdate" />
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
				        <rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(@normal)">
						<!-- Single date in @normal and a text -->
						<rico:date><xsl:call-template name="outputDate"><xsl:with-param name="text" select="@normal" /></xsl:call-template></rico:date>
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:date>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			
			<xsl:when test="not(@normal) and text()">
				<!-- no @normal, but some text() -->
				<xsl:choose>
					<xsl:when test="ead2rico:isDateRange(text())">
						<!-- Date range in text() -->
						<rico:beginningDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-before(text(), '/'))" /></xsl:call-template></rico:beginningDate>
        				<rico:endDate><xsl:call-template name="outputDate"><xsl:with-param name="text" select="normalize-space(substring-after(text(), '/'))" /></xsl:call-template></rico:endDate>
        				<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:date>
					</xsl:when>
					<xsl:when test="ead2rico:isDate(text())">
						<!-- Single date in text() and a text -->
						<rico:date><xsl:call-template name="outputDate"><xsl:with-param name="text" select="text()" /></xsl:call-template></rico:date>
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:date>
					</xsl:when>
					<xsl:otherwise>
						<rico:date xml:lang="{$LITERAL_LANG}"><xsl:value-of select="text()" /></rico:date>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="not(@normal) and not(text())">
				<!-- empty unitdate : output nothing -->
			</xsl:when>		
		</xsl:choose>
	</xsl:template>

	<!-- ***** Processing of formatting elements p, list, item, span ***** -->
	
	<xsl:template match="p" mode="html">
		<html:p><xsl:apply-templates mode="html" /></html:p>
	</xsl:template>
	<xsl:template match="emph[@render = 'super']" mode="html">
		<html:sup><xsl:apply-templates mode="html" /></html:sup>
	</xsl:template>
	<xsl:template match="text()" mode="html"><xsl:value-of select="." /></xsl:template>

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