<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
    xmlns:isni="http://isni.org/ontology#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4"
    xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:xl="http://www.w3.org/2008/05/skos-xl#"
    xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
    xmlns:an="http://data.archives-nationales.culture.gouv.fr/"
    exclude-result-prefixes="xs xd eac iso-thes rdf dct xl xlink skos isni foaf ginco dc an" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 4, 2017, checked and updated Dec. 8, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 13, 2019</xd:p>
            
            <xd:p>Step 7 : generating RDF files for handling the record sets quoted in the resource relations in the EAC files. </xd:p>
           <xd:p>Very simple output. To be used only if the EAD finding aids concerning these record sets are not provided.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>
    
    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of
            select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"
        />
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>
    <xsl:variable name="apos" select="'&#x2bc;'"/>

    
   
    <xsl:variable name="prov-rels" select="document('rdf/relations/FRAN_originationRelations.rdf')/rdf:RDF"/>
    
  
    
    <xsl:template match="/vide">
       
     
        <xsl:variable name="AN-not-described-record-sets">
            <an:record-sets>
                <xsl:for-each select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType='creatorOf' and normalize-space(@xlink:href)!='']">
                    <xsl:variable name="link" select="normalize-space(@xlink:href)"/>
                    <xsl:variable name="recId" select="ancestor::eac:eac-cpf/eac:control/eac:recordId"/>
                    <xsl:variable name="entType">
                        <xsl:choose>
                            <xsl:when test="ancestor::eac:cpfDescription/eac:identity/eac:entityType='person'">person</xsl:when>
                            <xsl:when test="ancestor::eac:cpfDescription/eac:identity/eac:entityType='corporateBody'">corporateBody</xsl:when>
                            <xsl:when test="ancestor::eac:cpfDescription/eac:identity/eac:entityType='family'">family</xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                  
                        <an:record-set>
                            <xsl:attribute name="reference">
                              
                                <xsl:choose>
                                    <xsl:when test="contains($link, '#')">
                                        <xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/UD/', substring-before($link, '#'), '/', substring-after($link, '#'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/IR/', $link)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="URI">
                                <xsl:choose>
                                <xsl:when test="contains($link, '#')">
                                    <xsl:value-of select="concat($baseURL, 'recordSet/', substring-before($link, '#'), '-', substring-after($link, '#'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                   
                                    <xsl:value-of select="concat($baseURL, 'recordSet/', substring-after($link, 'FRAN_IR_'), '-top')"/>
                                </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                           
                            <xsl:variable name="orig">
                                <xsl:value-of select="concat($baseURL, $entType, '/', substring-after($recId, 'FRAN_NP_'))"/>
                            </xsl:variable>
                            <an:origination>
                                <xsl:attribute name="URI" select="$orig"/>
                                 
                            </an:origination>
                          
                                <xsl:if test="normalize-space(eac:relationEntry)!=''">
                                    <an:title>
                                        <xsl:value-of select="normalize-space(eac:relationEntry)"/>
                                    </an:title>
                                </xsl:if>
                                <xsl:if test="normalize-space(eac:descriptiveNote)!=''">
                                    <an:note>
                                        <xsl:value-of select="normalize-space(eac:descriptiveNote)"/>
                                    </an:note>
                                </xsl:if>
                           
                           
                        </an:record-set>
                    
                </xsl:for-each>
            </an:record-sets>
        </xsl:variable>
        <xsl:result-document href="temp/FRAN_not-described-record-sets.xml"  method="xml"
            encoding="utf-8" indent="yes">
            <xsl:copy-of select="$AN-not-described-record-sets"/>
        </xsl:result-document>
        <xsl:result-document href="rdf/recordSets/FRAN_recordSets.rdf"  method="xml"
            encoding="utf-8" indent="yes">
            <rdf:RDF 
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                
                
                >
                <xsl:for-each-group select="$AN-not-described-record-sets/an:record-sets/an:record-set" group-by="@URI">
                    <xsl:sort select="current-grouping-key()"></xsl:sort>
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#RecordSet"/>
                        <xsl:for-each-group select="current-group()" group-by="an:title">
                            <RiC:title xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </RiC:title>
                            <rdfs:label xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </rdfs:label>
                        </xsl:for-each-group>
                    
                        <xsl:for-each-group select="current-group()" group-by="an:note">
                            <RiC:description xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </RiC:description>
                        </xsl:for-each-group>
                     
                       <!-- <xsl:for-each-group select="current-group()" group-by="piaaf:origination/@URI">
                            <RiC:originatedBy>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:attribute>
                            </RiC:originatedBy>
                        </xsl:for-each-group>-->
                      <!--  <xsl:for-each-group select="current-group()" group-by="an:provenanceRel">
                            <RiC:recordResourceIsSourceOfOriginationRelation rdf:resource="{current-grouping-key()}"/>
                        </xsl:for-each-group>-->
                        <xsl:for-each-group select="current-group()" group-by="@reference">
                            <RiC:isMainSubjectOf rdf:resource="{current-grouping-key()}"/>
                            <rdfs:seeAlso rdf:resource="{current-grouping-key()}"/>
                        </xsl:for-each-group>
                    </rdf:Description>
                </xsl:for-each-group>
                
            </rdf:RDF>
        </xsl:result-document>
        
 
        
        
    </xsl:template>
    
    
    
    
    
    
</xsl:stylesheet>
