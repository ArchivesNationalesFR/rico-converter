<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#" xmlns:isni="http://isni.org/ontology#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:eac="urn:isbn:1-931666-33-4" xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
     
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:xl="http://www.w3.org/2008/05/skos-xl#"
    xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
    exclude-result-prefixes="xs xd eac iso-thes rdf foaf dct xl dc ginco xlink isni skos"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 3, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>

            <xd:p>Step 3 : generating an RDF file for handling the agent names.</xd:p>

        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>


    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>

    <xsl:variable name="AN-rules" select="document('rdf/rules/FRAN_rules.rdf')/rdf:RDF"/>

    <xsl:template match="/vide">



        <xsl:result-document href="rdf/agentNames/FRAN_agentNames.rdf" method="xml" encoding="utf-8"
            indent="yes">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">

                <xsl:for-each-group
                    select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[normalize-space(eac:part) != '' and normalize-space(eac:part) != 'indéterminé']"
                    group-by="
                        
                        concat(normalize-space(eac:part), ' -- ', parent::eac:identity/eac:entityType, ' | ', @localType)
                        
                        
                        
                        
                        ">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:variable name="num" select="format-number(number(position()), '#000')"/>
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">


                            <xsl:value-of
                                select="concat($baseURL, 'agentName/', substring-after(current-group()[1]/@xml:id, 'agentName_'))"/>



                        </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#AgentName"/>


                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="substring-before(current-grouping-key(), ' --')"/>
                        </rdfs:label>
                        <RiC:textualValue xml:lang="fr">
                            <xsl:value-of select="substring-before(current-grouping-key(), ' --')"/>
                        </RiC:textualValue>
                        <xsl:choose>
                            <xsl:when test="contains(current-grouping-key(), 'person | autorisée')">
                                <RiC:type xml:lang="fr">nom d'agent : forme préférée</RiC:type>
                                <RiC:isRegulatedBy>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$AN-rules/rdf:Description[rdfs:label = 'AFNOR Z44-061']/@rdf:about"
                                        />
                                    </xsl:attribute>
                                </RiC:isRegulatedBy>
                            </xsl:when>
                            <xsl:when
                                test="contains(current-grouping-key(), 'corporateBody | autorisée')">
                                <RiC:type xml:lang="fr">nom d'agent : forme préférée</RiC:type>
                                <RiC:isRegulatedBy>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$AN-rules/rdf:Description[rdfs:label = 'AFNOR Z44-060']/@rdf:about"
                                        />
                                    </xsl:attribute>
                                </RiC:isRegulatedBy>
                            </xsl:when>
                            <xsl:when test="contains(current-grouping-key(), 'family | autorisée')">
                                <RiC:type xml:lang="fr">nom d'agent : forme préférée</RiC:type>
                                <RiC:isRegulatedBy>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$AN-rules/rdf:Description[rdfs:label = 'AFNOR Z44-060']/@rdf:about"
                                        />
                                    </xsl:attribute>
                                </RiC:isRegulatedBy>
                            </xsl:when>
                        </xsl:choose>
                        <!--
                        <xsl:for-each-group select="current-group()" group-by="ancestor::eac:eac-cpf/eac:control/eac:recordId">
                                <RiC:isAgentNameOf>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$baseURL"/>
                                        
                                        <xsl:choose>
                                            <xsl:when test="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType='person'">
                                                <xsl:text>person/</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType='corporateBody'">
                                                <xsl:text>corporateBody/</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType='family'">
                                                <xsl:text>family/</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:value-of select="substring-after(current-grouping-key(), 'FRAN_NP_')"/>  
                                    </xsl:attribute>
                                </RiC:isAgentNameOf>
                              
                            </xsl:for-each-group>-->


                    </rdf:Description>
                </xsl:for-each-group>



            </rdf:RDF>
        </xsl:result-document>

    </xsl:template>

</xsl:stylesheet>
