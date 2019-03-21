<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#" xmlns:isni="http://isni.org/ontology#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:eac="urn:isbn:1-931666-33-4" xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:an="http://data.archives-nationales.culture.gouv.fr/"
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:xl="http://www.w3.org/2008/05/skos-xl#"
    xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
    exclude-result-prefixes="xs xd eac iso-thes rdf dct xl xlink skos foaf ginco dc an"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 4, 2017, checked and updated Dec. 12, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud (Archives nationales)</xd:p>
            
            <xd:p>Revised on March 19, 2019</xd:p>
            
           
            <xd:p>Step 9 : generating RDF files for any agent quoted in the cpf relations of the EAC files, when an EAC file is not provided for describing it.</xd:p>
          
        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>
    
    <xsl:variable name="baseURL" select="$params/baseURL"/>

    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>
    <xsl:variable name="apos" select="'&#x2bc;'"/>

    <xsl:template match="/vide">


        <xsl:variable name="not-described-agents">
            <an:agents>
                <xsl:for-each
                    select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType != 'identity' and normalize-space(@xlink:href) != '' and not(starts-with(@xlink:href, 'http:/'))]">
                    <xsl:variable name="ancId"
                        select="ancestor::eac:eac-cpf/eac:control/eac:recordId"/>
                    <xsl:variable name="link" select="@xlink:href"/>

                    <xsl:variable name="cpfRel" select="@cpfRelationType"/>
                    <xsl:variable name="entType" select="ancestor::eac:cpfDescription/eac:identity/eac:entityType"/>

                    <xsl:if
                        test="
                            not($collection-EAC-AN[eac:eac-cpf/eac:control/eac:recordId = $link])
                            ">


                        <xsl:variable name="targEntType">
                            <xsl:choose>
                                <!-- relation hiérarchique : entre 2 cbodies -->
                                <xsl:when test="starts-with($cpfRel, 'hierarchical')">
                                    <xsl:text>corporateBody</xsl:text>
                                </xsl:when>
                                <!-- this can be enhanced. left as it is because we lack time...-->
                              <!--  <xsl:when test="contains(eac:descriptiveNote/eac:p, 'isDirectorOf') or contains(eac:descriptiveNote/eac:p, 'isDirected')">
                                    <xsl:choose>
                                        <xsl:when test="$entType='person'">
                                            <xsl:text>corporateBody</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="$entType='corporateBody'">
                                            <xsl:text>person</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                    
                                    
                                </xsl:when>-->
                             
                                <xsl:otherwise>
                                    <xsl:text>agent</xsl:text>
                                </xsl:otherwise>

                            </xsl:choose>
                        </xsl:variable>

                        <!--<xsl:variable name="targEntType">
                              
                              <xsl:choose>
                                  <!-\- relation hiérarchique : entre 2 cbodies -\->
                                  <xsl:when test="starts-with($cpfRel, 'hierarchical')">
                                      <xsl:text>corporate-body</xsl:text>
                                  </xsl:when>
                                  <xsl:when test="contains($arcrole, 'isDirectedBy')">
                                      <xsl:text>person</xsl:text>
                                  </xsl:when>
                                  <xsl:when test="contains($arcrole, 'isDirectorOf')">
                                      <xsl:text>corporate-body</xsl:text>
                                  </xsl:when>
                                  <xsl:when test="contains($arcrole, 'isAssociatedWithForItsControl')">
                                      <xsl:text>corporate-body</xsl:text>
                                  </xsl:when>
                                  <xsl:when
                                      test="contains($arcrole, 'hasMember') or contains($arcrole, 'hasEmployee')">
                                      <xsl:text>person</xsl:text>
                                  </xsl:when>
                                  <xsl:when
                                      test="contains($arcrole, 'isMemberOf') or contains($arcrole, 'isEmployeeOf')">
                                      <xsl:text>corporate-body</xsl:text>
                                  </xsl:when>
                                  <xsl:otherwise>
                                      <xsl:text>agent</xsl:text>
                                  </xsl:otherwise>
                                  
                              </xsl:choose>
                              
                          </xsl:variable>-->
                        <an:agent>
                           

                            <an:name>
                                <xsl:value-of select="eac:relationEntry"/>
                            </an:name>

                            <an:type>
                                <xsl:value-of select="$targEntType"/>
                            </an:type>
                            <an:id>
                                <xsl:value-of select="substring-after($link, 'FRAN_NP_')"/>
                            </an:id>

                        </an:agent>
                    </xsl:if>

                </xsl:for-each>
            </an:agents>
        </xsl:variable>
        
        <xsl:variable name="not-described-agents-reduced">
            <an:agents>

                <xsl:for-each-group select="$not-described-agents/an:agents/an:agent"
                    group-by="an:id">

                    <an:agent>
                       
                        <an:id>
                            <xsl:value-of
                                select="current-grouping-key()"
                            />
                        </an:id>

                      


                        <xsl:for-each-group select="current-group()" group-by="an:type">
                            <an:type>
                                <xsl:value-of select="current-grouping-key()"/>
                            </an:type>
                        </xsl:for-each-group>


                        <xsl:for-each-group select="current-group()" group-by="an:name">
                            <an:name>
                                <xsl:value-of select="current-grouping-key()"/>
                            </an:name>

                        </xsl:for-each-group>
                    </an:agent>

                </xsl:for-each-group>
            </an:agents>
        </xsl:variable>
        <xsl:result-document href="temp/not-described-agents.xml" method="xml" encoding="utf-8"
            indent="yes">
            <xsl:copy-of select="$not-described-agents"/>
        </xsl:result-document>
        <xsl:result-document href="temp/not-described-agents-reduced.xml" method="xml"
            encoding="utf-8" indent="yes">
            <xsl:copy-of select="$not-described-agents-reduced"/>

        </xsl:result-document>
        <xsl:for-each select="$not-described-agents-reduced/an:agents/an:agent">
            <xsl:variable name="URLTrueType">
                <xsl:choose>
                    <xsl:when test="an:type[. = 'corporateBody']">corporateBody</xsl:when>
                    <xsl:otherwise>agent</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="trueType">
                <xsl:choose>
                    <xsl:when test="an:type[. = 'corporateBody']">CorporateBody</xsl:when>
                    <xsl:otherwise>Agent</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>




            <xsl:result-document method="xml" encoding="utf-8" indent="yes"
                href="rdf/agents/{$URLTrueType}_{an:id}.rdf">

                <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">
                    
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                           <xsl:value-of select="concat($baseURL, $URLTrueType, '/', an:id)"/>
                        </xsl:attribute>
                        <rdf:type>
                            <xsl:attribute name="rdf:resource">
                                <xsl:text>http://www.ica.org/standards/RiC/ontology#</xsl:text>
                                <xsl:value-of select="$trueType"/>
                            </xsl:attribute>
                        </rdf:type>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="an:name[1]"/>
                        </rdfs:label>


                        <rdfs:seeAlso>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/FRAN_NP_', an:id)"
                                />
                            </xsl:attribute>
                        </rdfs:seeAlso>
                    </rdf:Description>

                </rdf:RDF>
            </xsl:result-document>

        </xsl:for-each>






    </xsl:template>














</xsl:stylesheet>
