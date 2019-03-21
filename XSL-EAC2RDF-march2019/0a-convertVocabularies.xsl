<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:xl="http://www.w3.org/2008/05/skos-xl#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    exclude-result-prefixes="xs xd iso-thes xl" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 29, 2018</xd:p>
            <xd:p>Revised on March 8, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Generating RDF files from the XML vocabularies files created by the
                Archives nationales de France</xd:p>
            <xd:p>This XSL will convert all these files, except the vocabulary for legal statuses,
                which has been authored using Ginco (FRAN_RI_104_Ginco_legalStatuses.rdf), and the
                gazetteers, which are converted using another XSL.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>
   
    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <xsl:variable name="chemin-vocabs">
        <xsl:value-of select="concat('src/RI/vocabs/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="chemin-vocabs-out">
        <xsl:value-of select="'rdf/vocabularies/'"/>
    </xsl:variable>
    <xsl:variable name="vocabs" select="collection($chemin-vocabs)"/>

    <xsl:template match="/vide">
        <xsl:for-each select="$vocabs/r">
            <xsl:variable name="myId" select="@id"/>
            <xsl:variable name="RiC-Class">
                <xsl:choose>
                    <xsl:when test="@type = 'TD'">DocumentaryFormType</xsl:when>
                    <xsl:when test="@type = 'MT'">Thing</xsl:when>
                    <xsl:when test="@type = 'FO'">ActivityType</xsl:when>
                    <xsl:when test="@type = 'AC'">OccupationType</xsl:when>

                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="path">

                <xsl:choose>
                    <xsl:when test="@type = 'TD'">documentaryFormType</xsl:when>
                    <xsl:when test="@type = 'MT'">thing</xsl:when>
                    <xsl:when test="@type = 'FO'">activityType</xsl:when>
                    <xsl:when test="@type = 'AC'">occupationType</xsl:when>

                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="title">
                <xsl:choose>
                    <xsl:when test="@type = 'TD'">Thésaurus des types de documents des Archives
                        nationales</xsl:when>
                    <xsl:when test="@type = 'MT'">Thésaurus des mots-matières des Archives
                        nationales</xsl:when>
                    <xsl:when test="@type = 'FO'">Thésaurus des domaines et actions des
                        collectivités des Archives nationales</xsl:when>
                    <xsl:when test="@type = 'AC'">Thésaurus des fonctions, métiers et professions
                        des personnes des Archives nationales</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:result-document href="{$chemin-vocabs-out}{$myId}_{$path}s.rdf" method="xml"
                encoding="utf-8" indent="yes">
                <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:dct="http://purl.org/dc/terms/"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                    <skos:conceptScheme>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, $path, 's')"/>
                        </xsl:attribute>
                        <dc:description>
                            <xsl:value-of select="$title"/>
                            <xsl:text>. Résulte de la simple conversion automatique en RDF, conforme à SKOS et RiC-O, du référentiel XML correspondant.
                            Il s'agit donc d'une VERSION RDF PROVISOIRE. Des enrichissements, modifications de structure et alignements sont prévus.
                       </xsl:text>
                        </dc:description>
                        <dc:title>
                            <xsl:value-of select="$title"/>
                        </dc:title>
                        <dc:creator>
                            <foaf:Organization>
                                <foaf:mbox>referentiels.archives-nationales@culture.gouv.fr</foaf:mbox>
                                <foaf:homepage>http://www.archives-nationales.culture.gouv.fr/</foaf:homepage>
                                <foaf:name>Archives nationales (France). Mission
                                    référentiels</foaf:name>
                            </foaf:Organization>
                        </dc:creator>
                        <dct:created>
                            <!--2018-07-12T12:12:23+02:00-->
                            <xsl:value-of select="current-dateTime()"/>
                        </dct:created>
                        <dc:coverage>du Moyen Âge à nos jours</dc:coverage>
                        <dc:language>fr-FR</dc:language>
                        <dc:type>Thésaurus</dc:type>
                        <xsl:for-each select="child::d">
                            <xsl:variable name="childId" select="@id"/>
                            <skos:hasTopConcept>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat($baseURL, $path, '/', $myId, '-', $childId)"
                                    />
                                </xsl:attribute>
                            </skos:hasTopConcept>
                        </xsl:for-each>
                    </skos:conceptScheme>



                    <xsl:for-each select="descendant::d">
                        <xsl:variable name="dId" select="@id"/>
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat($baseURL, $path, '/', $myId, '-', $dId)"/>
                            </xsl:attribute>
                            <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
                            <rdf:type
                                rdf:resource="http://www.ica.org/standards/RiC/ontology#{$RiC-Class}"/>
                            <skos:inScheme>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="concat($baseURL, $path, 's')"/>
                                </xsl:attribute>
                            </skos:inScheme>
                            <xsl:apply-templates select="terme"/>
                            <xsl:apply-templates select="interdits"/>
                            <xsl:apply-templates select="def"/>
                            <xsl:apply-templates select="app"/>
                            <xsl:apply-templates select="associes">
                                <xsl:with-param name="myId" select="$myId"/>
                                <xsl:with-param name="path" select="$path"/>
                                <xsl:with-param name="RiC-Class" select="$RiC-Class"/>
                            </xsl:apply-templates>

                            <xsl:if test="parent::d">
                                <xsl:variable name="parentId" select="parent::d/@id"/>
                                <skos:broader>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, $path, '/', $myId, '-', $parentId)"
                                        />
                                    </xsl:attribute>
                                </skos:broader>
                            </xsl:if>

                            <xsl:for-each select="child::d">
                                <xsl:variable name="childId" select="@id"/>
                                <skos:narrower>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, $path, '/', $myId, '-', $childId)"
                                        />
                                    </xsl:attribute>
                                </skos:narrower>
                            </xsl:for-each>


                        </rdf:Description>
                    </xsl:for-each>




                </rdf:RDF>
            </xsl:result-document>

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="terme">
        <skos:prefLabel xml:lang="fr">
            <xsl:value-of select="normalize-space(.)"/>
        </skos:prefLabel>
    </xsl:template>
    <xsl:template match="interdits">
        <xsl:for-each select="i">
            <skos:altLabel xml:lang="fr">
                <xsl:value-of select="normalize-space(.)"/>
            </skos:altLabel>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="def">
        <xsl:choose>
            <xsl:when test="not(starts-with(., 'Terme employé également dans le'))">
                <skos:definition xml:lang="fr">
                    <xsl:value-of select="normalize-space(.)"/>
                </skos:definition>
            </xsl:when>
            <xsl:otherwise><skos:note xml:lang="fr">
                <xsl:value-of select="."/>
            </skos:note></xsl:otherwise>
        </xsl:choose>
      
    </xsl:template>
    <xsl:template match="app">
        <xsl:choose>
            <xsl:when test="not(starts-with(., 'Terme employé également dans le'))">
                <skos:scopeNote xml:lang="fr">
                    <xsl:value-of select="normalize-space(.)"/>
                </skos:scopeNote>
            </xsl:when>
            <xsl:otherwise><skos:note xml:lang="fr">
                <xsl:value-of select="."/>
            </skos:note></xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
   
    <xsl:template match="associes">
        <xsl:param name="myId"/>
        <xsl:param name="path"/>

        <xsl:for-each select="a">
            <xsl:variable name="target" select="@href"/>
            <skos:related>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat($baseURL, $path, '/', $myId, '-', $target)"/>
                </xsl:attribute>
            </skos:related>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
