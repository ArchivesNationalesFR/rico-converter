<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:xl="http://www.w3.org/2008/05/skos-xl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:insee-geo="http://rdf.insee.fr/def/geo#" xmlns:geofla="http://data.ign.fr/def/geofla#"
    xmlns:sparql="http://www.w3.org/2005/sparql-results#"
    xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs xd dcterms xl dc sparql" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> September, 20th 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 8, 2019</xd:p>

            <xd:p>Generating RDF files from the XML files created by the Archives nationales de
                France, and describing places : processing the branches on countries, foreign cities
                and districts, physical geographical objects and buildings </xd:p>
            <xd:p>Main reference ontology : RiC-O</xd:p>


        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <!-- l'identifiant du référentiel AN source -->
    <xsl:param name="ANVocabId">FRAN_RI_005</xsl:param>
    <xsl:param name="folder">rdf-AN</xsl:param>

    <xsl:variable name="chemin-out">

        <xsl:value-of select="'../../../rdf/places/'"/>

    </xsl:variable>
    <xsl:template match="/r">
        <xsl:variable name="departs" select="d[@id = 'd3ntb6zxjb--1k1thm4e2xtmv']"/>
        <xsl:variable name="pays" select="d[@id = 'd3ntxjw7uv--i2pfm9dxkxx1']"/>
        <xsl:variable name="etrangers" select="d[@id = 'd3ntxm58dl-15htmdy8i12g1']"/>
        <xsl:variable name="geo" select="d[@id = 'd3ntxq2com--jc179longt6u']"/>
        <xsl:variable name="buildings" select="d[@id = 'd5bdpnvb54--17bp5oifctr0f']"/>

        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-out}FRAN_pays.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                <xsl:for-each select="$pays/d">

                    <xsl:variable name="id" select="@id"/>

                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <xsl:for-each
                            select="
                                interdits/i[not(matches(., '\d+'))]
                                
                                ">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>

                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                        <RiC:type xml:lang="fr">pays</RiC:type>
                        <!--  <terme>Vietnam (République du , 1955-1975)</terme>-->
                        <!-- traitement très rapide et simpliste des dates ; à reprendre avec regexp-->
                        <xsl:if test="contains(terme, '(')">
                            <xsl:variable name="myString"
                                select="normalize-space(substring-before(substring-after(terme, '('), ')'))"/>

                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($myString, '1') or starts-with($myString, '2')">
                                    <RiC:beginningDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>



                                        <xsl:value-of select="substring-before($myString, '-')"/>




                                    </RiC:beginningDate>
                                    <RiC:endDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="substring-after($myString, '-')"/>

                                    </RiC:endDate>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>

                        <xsl:if test="def[normalize-space(.) != '']">
                            <RiC:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </RiC:history>
                        </xsl:if>


                        <RiC:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </RiC:identifier>

                    </rdf:Description>
                    <!-- les noms. uniquement pour le terme pour l'instant -->
                    <!--<rdf:Description>
                        <xsl:attribute name="rdf:about"
                            select="concat($baseURL, 'place-name/', $ANVocabId, '-', $id)"> </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#PlaceName"/>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <RiC:textualValue xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </RiC:textualValue>
                        <RiC:isPlaceNameOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                            </xsl:attribute>
                        </RiC:isPlaceNameOf>

                    </rdf:Description>-->

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-out}FRAN_etranger.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                <xsl:for-each select="$etrangers/d">

                    <xsl:variable name="id" select="@id"/>



                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <xsl:for-each
                            select="
                                interdits/i[not(matches(., '\d+'))]
                                
                                ">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>

                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                        <RiC:type xml:lang="fr">territoire ou ville étranger</RiC:type>
                        <!--  <terme>Vietnam (République du , 1955-1975)</terme>-->
                        <!-- traitement très rapide et simpliste des dates ; à reprendre avec regexp-->
                        <xsl:if test="contains(terme, '(')">
                            <xsl:variable name="myString"
                                select="normalize-space(substring-before(substring-after(terme, '('), ')'))"/>

                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($myString, '1') or starts-with($myString, '2')">
                                    <RiC:beginningDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>



                                        <xsl:value-of select="substring-before($myString, '-')"/>




                                    </RiC:beginningDate>
                                    <RiC:endDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="substring-after($myString, '-')"/>

                                    </RiC:endDate>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="$pays/d[normalize-space(terme) = $myString]">
                                        <RiC:isWithin>
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                  select="concat($baseURL, 'place/', $ANVocabId, '-', $pays/d[normalize-space(terme) = $myString]/@id)"
                                                />
                                            </xsl:attribute>
                                        </RiC:isWithin>
                                    </xsl:if>

                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>

                        <xsl:if test="def[normalize-space(.) != '']">
                            <RiC:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </RiC:history>
                        </xsl:if>


                        <RiC:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </RiC:identifier>


                    </rdf:Description>
                    <!-- les noms. uniquement pour le terme pour l'instant -->
                    <!--<rdf:Description>
                        <xsl:attribute name="rdf:about"
                            select="concat($baseURL, 'place-name/', $ANVocabId, '-', $id)"> </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#PlaceName"/>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <RiC:textualValue xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </RiC:textualValue>
                        <RiC:isPlaceNameOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                            </xsl:attribute>
                        </RiC:isPlaceNameOf>

                    </rdf:Description>-->

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-out}FRAN_geographiePhysique.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                <xsl:for-each select="$geo/d/d">

                    <xsl:variable name="id" select="@id"/>

                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <xsl:for-each
                            select="
                                interdits/i[not(matches(., '\d+'))]
                                
                                ">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>

                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                        <RiC:type xml:lang="fr">
                            <xsl:choose>
                                <xsl:when
                                    test="normalize-space(parent::d/terme) = 'Aires géographiques'">
                                    <xsl:text>aire géographique</xsl:text>
                                </xsl:when>
                                <xsl:when test="normalize-space(parent::d/terme) = 'Hydrographie'">
                                    <xsl:text>objet spatial hydrographique</xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="normalize-space(parent::d/terme) = 'Zones naturelles'">
                                    <xsl:text>zone naturelle</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </RiC:type>

                        <xsl:if test="contains(terme, 'France')">
                            <RiC:isWithin
                                rdf:resource="{$baseURL}place/FRAN_RI_005-d3ntxkl6yf-1f01iiij7xnld"/>



                        </xsl:if>

                        <xsl:if test="def[normalize-space(.) != '']">
                            <RiC:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </RiC:history>
                        </xsl:if>


                        <RiC:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </RiC:identifier>


                    </rdf:Description>
                    <!-- les noms. uniquement pour le terme pour l'instant -->
                    <!--<rdf:Description>
                        <xsl:attribute name="rdf:about"
                            select="concat($baseURL, 'place-name/', $ANVocabId, '-', $id)"> </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#PlaceName"/>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <RiC:textualValue xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </RiC:textualValue>
                        <RiC:isPlaceNameOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                            </xsl:attribute>
                        </RiC:isPlaceNameOf>

                    </rdf:Description>-->

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-out}FRAN_edifices.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                <xsl:for-each select="$buildings/d">

                    <xsl:variable name="id" select="@id"/>
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <xsl:for-each
                            select="
                                interdits/i[not(matches(., '\d+'))]
                                
                                ">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>

                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                        <RiC:type xml:lang="fr">
                            <xsl:text>aménagement ou construction</xsl:text>
                        </RiC:type>
                        <xsl:if test="contains(terme, ',')">
                            <xsl:variable name="mySubstring">
                                <xsl:value-of
                                    select="normalize-space(substring-before(substring-after(terme, '('), ','))"/>

                            </xsl:variable>
                            <!--   <test><xsl:value-of select="$mySubstring"/></test>-->
                            <xsl:if
                                test="$departs/d[starts-with(normalize-space(terme), concat($mySubstring, ' ('))]">
                                <RiC:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'place/', $ANVocabId, '-', $departs/d[starts-with(normalize-space(terme), concat($mySubstring, ' ('))]/@id)"
                                        />
                                    </xsl:attribute>
                                </RiC:isWithin>
                            </xsl:if>
                        </xsl:if>
                        <xsl:if test="def[normalize-space(.) != '']">
                            <RiC:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </RiC:history>
                        </xsl:if>


                        <RiC:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </RiC:identifier>


                    </rdf:Description>
                    <!-- les noms. uniquement pour le terme pour l'instant -->
                    <!--<rdf:Description>
                        <xsl:attribute name="rdf:about"
                            select="concat($baseURL, 'place-name/', $ANVocabId, '-', $id)"> </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#PlaceName"/>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <RiC:textualValue xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </RiC:textualValue>
                        <RiC:isPlaceNameOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', $id)"/>

                            </xsl:attribute>
                        </RiC:isPlaceNameOf>

                    </rdf:Description>-->

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
