<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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
    exclude-result-prefixes="xs xd iso-thes rdf dct xl  xlink  skos isni foaf ginco an dc xsi"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 17, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>

            <xd:p>Step 4 : generating RDF files for handling the places. This is complex because the
                EAC files include not consistent place elements (elements with no content, elements
                related to several distinct places specified in the gazetteers... This XSL has to be
                carefully reviewed, and as the inconsistencies will be fixed, should probably be
                updated.</xd:p>


        </xd:desc>
    </xd:doc>


    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>


    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>

    <xsl:variable name="chemin-AN-places-paris">
        <xsl:value-of
            select="concat('src/RI/places/', '?select=*lieuxParis*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-places-paris" select="collection($chemin-AN-places-paris)/r"/>

    <xsl:variable name="lieux-general" select="document('src/RI/places/FRAN_RI_005.xml')/r"/>


    <xsl:template match="/vide">
        <!-- places apart from Parisian ones -->
        <xsl:variable name="generalPlacesWithString">
            <an:general-places-by-placeString>
                <!-- places that have a name and existence but are not related to any resource in the gazetteers-->
                <xsl:for-each
                    select="
                        $collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place
                        [
                        eac:placeRole = 'Lieu général'
                        and
                        eac:placeEntry[@localType = 'nomLieu' and normalize-space() != '']
                        and
                        
                        not(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != ''])]">
                    <xsl:sort select="eac:placeEntry[@localType = 'nomLieu']"/>
                    <an:place>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="stringValue"
                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu'])"/>
                        <xsl:apply-templates select="eac:placeEntry[@localType = 'nomLieu']"/>


                        <xsl:apply-templates select="eac:descriptiveNote"/>
                        <xsl:apply-templates select="eac:dateRange"/>

                    </an:place>
                </xsl:for-each>


                <!-- places that have a name and existence, and are related to one to many resources in the gazetteers-->
                <xsl:for-each
                    select="
                        $collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place
                        [
                        eac:placeRole = 'Lieu général'
                        and
                        eac:placeEntry[@localType = 'nomLieu' and normalize-space() != '']
                        and
                        
                        eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']
                        
                        ]">
                    <xsl:sort select="eac:placeEntry[@localType = 'nomLieu']"/>
                    <an:place>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="stringValue"
                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu'])"/>
                        <xsl:apply-templates select="eac:placeEntry[@localType = 'nomLieu']"/>


                        <xsl:apply-templates select="eac:descriptiveNote"/>
                        <xsl:apply-templates select="eac:dateRange"/>
                        <xsl:if
                            test="eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']">
                            <an:stdplaceEntries>
                                <xsl:for-each
                                    select="eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']">
                                    <xsl:value-of
                                        select="concat(., ' [', @localType, '] /', @vocabularySource)"/>

                                    <xsl:text> % </xsl:text>

                                </xsl:for-each>
                            </an:stdplaceEntries>
                        </xsl:if>
                    </an:place>
                </xsl:for-each>
            </an:general-places-by-placeString>

        </xsl:variable>
        <!-- Parisian districts, parrishes, buildings and streets -->
        <xsl:variable name="parisPlacesWithString">
            <an:places-by-placeString>
                <!--places that have a name and existence but are not related to any resource in the gazetteers-->

                <xsl:for-each
                    select="
                        $collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place
                        [
                        eac:placeRole = 'Lieu de Paris'
                        and
                        eac:placeEntry[@localType = 'nomLieu' and (normalize-space() != '' and normalize-space() != 'adresse indéterminée' and normalize-space(.) != 'indéterminée' and normalize-space() != 'indeterminée')]
                        and
                        
                        not(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != ''])]">
                    <xsl:sort select="eac:placeEntry[@localType = 'nomLieu']"/>
                    <an:place>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="stringValue"
                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu'])"/>
                        <xsl:apply-templates select="eac:placeEntry[@localType = 'nomLieu']"/>


                        <xsl:apply-templates select="eac:descriptiveNote"/>
                        <xsl:apply-templates select="eac:dateRange"/>

                    </an:place>
                </xsl:for-each>
                <!-- places with their own name + a relation or many relations to the gazetteers. Partially treated for now-->
                <xsl:for-each
                    select="
                        $collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place
                        [
                        eac:placeRole = 'Lieu de Paris'
                        and
                        eac:placeEntry[@localType = 'nomLieu' and (normalize-space() != '' and normalize-space() != 'adresse indéterminée' and normalize-space(.) != 'indéterminée' and normalize-space() != 'indeterminée')]
                        and
                        (
                        count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) = 1 or (count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) &gt; 1 and not(contains(eac:placeEntry[@localType = 'nomLieu'], ','))
                        
                        ))
                        ]">
                    <xsl:sort select="eac:placeEntry[@localType = 'nomLieu']"/>
                    <an:place>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="stringValue"
                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu'])"/>
                        <xsl:apply-templates select="eac:placeEntry[@localType = 'nomLieu']"/>


                        <xsl:apply-templates select="eac:descriptiveNote"/>
                        <xsl:apply-templates select="eac:dateRange"/>

                        <an:stdplaceEntries>
                            <xsl:for-each select="eac:placeEntry[@localType != 'nomLieu']">
                                <xsl:value-of
                                    select="concat(., ' [', @localType, '] /', @vocabularySource)"/>

                                <xsl:text> % </xsl:text>

                            </xsl:for-each>
                        </an:stdplaceEntries>

                    </an:place>
                </xsl:for-each>
                <!-- places that have no precise address but are connected once to the gazetteer. There are some which are connected more than once; not treated here... -->
             <!--   <xsl:for-each
                    select="
                        $collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place
                        [
                        eac:placeRole = 'Lieu de Paris'
                        and
                        eac:placeEntry[@localType = 'nomLieu' and (normalize-space() = 'adresse indéterminée' or normalize-space(.) = 'indéterminée' or normalize-space() = 'indeterminée')]
                        and
                        (
                        count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) = 1
                        
                        )
                        ]">
                    <xsl:sort select="eac:placeEntry[@localType = 'nomLieu']"/>
                    <an:place>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="stringValue"
                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu'])"/>
                        <xsl:apply-templates select="eac:placeEntry[@localType = 'nomLieu']"/>


                        <xsl:apply-templates select="eac:descriptiveNote"/>
                        <xsl:apply-templates select="eac:dateRange"/>

                        <an:stdplaceEntries>
                            <xsl:for-each select="eac:placeEntry[@localType != 'nomLieu']">
                                <xsl:value-of
                                    select="concat(., ' [', @localType, '] /', @vocabularySource)"/>

                                <xsl:text> % </xsl:text>

                            </xsl:for-each>
                        </an:stdplaceEntries>

                    </an:place>
                </xsl:for-each>-->
            </an:places-by-placeString>

        </xsl:variable>
        <xsl:result-document href="temp/Paris-places-with-string.xml" indent="yes">
            <xsl:copy-of select="$parisPlacesWithString/*"/>
        </xsl:result-document>
        <xsl:result-document href="temp/general-places-with-string.xml" indent="yes">
            <xsl:copy-of select="$generalPlacesWithString/*"/>
        </xsl:result-document>
        <xsl:result-document href="rdf/places/FRAN_places_Paris.rdf" method="xml" encoding="utf-8"
            indent="yes">

            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">



                <xsl:for-each-group
                    select="$parisPlacesWithString/an:places-by-placeString/an:place"
                    group-by="concat(@stringValue, '#', an:stdplaceEntries)">



                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:variable name="stdEntries">
                        <xsl:value-of
                            select="normalize-space(substring-after(current-grouping-key(), '#'))"/>
                    </xsl:variable>

                    <rdf:Description>
                        <xsl:attribute name="rdf:about">


                            <xsl:value-of
                                select="concat($baseURL, 'place/', substring-after(current-group()[1]/@xml:id, '_place_'))"/>


                        </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>


                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="substring-before(current-grouping-key(), '#')"/>
                        </rdfs:label>
                        <xsl:if test="$stdEntries != ''">
                            <xsl:for-each
                                select="tokenize($stdEntries, '%')[normalize-space(.) != '']">
                                <xsl:variable name="stdPlaceId"
                                    select="normalize-space(substring-after(., '/'))"/>
                                <RiC:isAssociatedWithPlace>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat($baseURL, 'place/')"/>
                                        <xsl:value-of
                                            select="$collection-places-paris[d[@id = $stdPlaceId]]/@id"/>
                                        <xsl:value-of select="concat('-', $stdPlaceId)"/>
                                    </xsl:attribute>
                                </RiC:isAssociatedWithPlace>
                            </xsl:for-each>

                        </xsl:if>


                    </rdf:Description>






                </xsl:for-each-group>



            </rdf:RDF>
        </xsl:result-document>

        <xsl:result-document href="rdf/places/FRAN_places.rdf" method="xml" encoding="utf-8"
            indent="yes">

            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">



                <xsl:for-each-group
                    select="$generalPlacesWithString/an:general-places-by-placeString/an:place"
                    group-by="concat(@stringValue, '#', an:stdplaceEntries)">



                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:variable name="stdEntries">
                        <xsl:value-of
                            select="normalize-space(substring-after(current-grouping-key(), '#'))"/>
                    </xsl:variable>

                    <rdf:Description>
                        <xsl:attribute name="rdf:about">


                            <xsl:value-of
                                select="concat($baseURL, 'place/', substring-after(current-group()[1]/@xml:id, '_place_'))"/>


                        </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>


                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="substring-before(current-grouping-key(), '#')"/>
                        </rdfs:label>
                        <xsl:if test="$stdEntries != ''">
                            <xsl:for-each
                                select="tokenize($stdEntries, '%')[normalize-space(.) != '']">
                                <xsl:variable name="stdPlaceId"
                                    select="normalize-space(substring-after(., '/'))"/>
                                <RiC:isAssociatedWithPlace>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat($baseURL, 'place/')"/>
                                        <xsl:value-of
                                            select="$lieux-general[descendant::d[@id = $stdPlaceId]]/@id"/>
                                        <xsl:value-of select="concat('-', $stdPlaceId)"/>
                                    </xsl:attribute>
                                </RiC:isAssociatedWithPlace>
                                <!-- <test><xsl:value-of select="$lieux-general/@id"/></test>-->
                            </xsl:for-each>

                        </xsl:if>


                    </rdf:Description>






                </xsl:for-each-group>



            </rdf:RDF>
        </xsl:result-document>
    </xsl:template>
     <xsl:template match="* | text() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="* | text() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
