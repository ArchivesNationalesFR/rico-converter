<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
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
            <xd:p>Revised on March 8, 2019 and on June 2019</xd:p>

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
        <xsl:value-of select="'../../rdf/places/'"/>
    </xsl:variable>
    <xsl:template match="/r">
        <xsl:variable name="departs" select="d[@id = 'd3ntb6zxjb--1k1thm4e2xtmv']"/>
        <xsl:variable name="communes" select="d[@id = 'd3m08zhht0k--tkyaw3csd7xn']"/>
        <xsl:variable name="pays" select="d[@id = 'd3ntxjw7uv--i2pfm9dxkxx1']"/>
        <xsl:variable name="etrangers" select="d[@id = 'd3ntxm58dl-15htmdy8i12g1']"/>
        <xsl:variable name="geo" select="d[@id = 'd3ntxq2com--jc179longt6u']"/>
        <xsl:variable name="buildings" select="d[@id = 'd5bdpnvb54--17bp5oifctr0f']"/>
        <xsl:variable name="lieux-dits" select="d[@id = 'd-6u6pcaufx--k8zh79mnvye']"/>

        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-out}FRAN_pays.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dct="http://purl.org/dc/terms/" xmlns:html="http://www.w3.org/1999/xhtml"
                xml:base="http://data.archives-nationales.culture.gouv.fr/">

                <xsl:for-each select="$pays/d">

                    <xsl:variable name="id" select="@id"/>

                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/', $ANVocabId, '-', $id)"/>

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

                        
                        <rico:hasPlaceType rdf:resource="placeType/pays"/>
                        <!--  <terme>Vietnam (République du , 1955-1975)</terme>-->
                        <!-- traitement très rapide et simpliste des dates ; à reprendre avec regexp-->
                        <xsl:if test="contains(terme, '(')">
                            <xsl:variable name="myString"
                                select="normalize-space(substring-before(substring-after(terme, '('), ')'))"/>

                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($myString, '1') or starts-with($myString, '2')">
                                    <rico:beginningDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>



                                        <xsl:value-of select="substring-before($myString, '-')"/>




                                    </rico:beginningDate>
                                    <rico:endDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="substring-after($myString, '-')"/>

                                    </rico:endDate>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>

                        <xsl:if test="def[normalize-space(.) != '']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>


                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </rico:identifier>

                    </rico:Place>
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
                xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dct="http://purl.org/dc/terms/" xmlns:html="http://www.w3.org/1999/xhtml"
                xml:base="http://data.archives-nationales.culture.gouv.fr/">
                <xsl:for-each select="$etrangers/d">

                    <xsl:variable name="id" select="@id"/>



                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/', $ANVocabId, '-', $id)"/>

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

                        <rico:type xml:lang="fr">territoire ou ville étranger</rico:type>
                        <!--  <terme>Vietnam (République du , 1955-1975)</terme>-->
                        <!-- traitement très rapide et simpliste des dates ; à reprendre avec regexp-->
                        <xsl:if test="contains(terme, '(')">
                            <xsl:variable name="myString"
                                select="normalize-space(substring-before(substring-after(terme, '('), ')'))"/>

                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($myString, '1') or starts-with($myString, '2')">
                                    <rico:beginningDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>



                                        <xsl:value-of select="substring-before($myString, '-')"/>




                                    </rico:beginningDate>
                                    <rico:endDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="substring-after($myString, '-')"/>

                                    </rico:endDate>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="$pays/d[normalize-space(terme) = $myString]">
                                        <rico:isWithin>
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                  select="concat('place/', $ANVocabId, '-', $pays/d[normalize-space(terme) = $myString]/@id)"
                                                />
                                            </xsl:attribute>
                                        </rico:isWithin>
                                    </xsl:if>

                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>

                       <!-- <xsl:if test="def[normalize-space(.) != '']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>-->

                        <xsl:variable name="myDef" select="normalize-space(def)"/>
                        <xsl:for-each
                            select="tokenize($myDef, '\|')[normalize-space(.) != '']">
                            
                            <xsl:choose>
                                <xsl:when test="starts-with(normalize-space(.), 'Type')"/>
                                <xsl:when test="starts-with(normalize-space(.), 'GeoNames ')">
                                    <!-- http://sws.geonames.org/2986214/-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://sws.geonames.org/', normalize-space(substring-after(., 'geonames.org/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikidata ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://www.wikidata.org/entity/', normalize-space(substring-after(., 'wikidata.org/wiki/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikipédia ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <rdfs:seeAlso>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="normalize-space(substring-after(., 'Wikipédia :'))"
                                            />
                                        </xsl:attribute>
                                        
                                    </rdfs:seeAlso>
                                    
                                </xsl:when>
                                <xsl:when test="contains(., 'géolocalisé')">
                                    <rico:note xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:note>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rico:description xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:description>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:for-each>
                        
                        
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </rico:identifier>


                    </rico:Place>
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
                xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dct="http://purl.org/dc/terms/" xmlns:html="http://www.w3.org/1999/xhtml"
                xml:base="http://data.archives-nationales.culture.gouv.fr/">
                <xsl:for-each select="$geo/d/d">

                    <xsl:variable name="id" select="@id"/>

                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/', $ANVocabId, '-', $id)"/>

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

                       
                        <rico:hasPlaceType>
                            <xsl:attribute name="rdf:resource">
                            <xsl:choose>
                                <xsl:when
                                    test="normalize-space(parent::d/terme) = 'Aires géographiques'">
                                    <xsl:text>placeType/aire%20g%C3%A9ographique%20naturelle</xsl:text>
                                </xsl:when>
                                <xsl:when test="normalize-space(parent::d/terme) = 'Hydrographie'">
                                    <xsl:text>placeType/%C3%A9l%C3%A9ment%20d%27hydrographie</xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="normalize-space(parent::d/terme) = 'Zones naturelles'">
                             <xsl:variable name="type" select="normalize-space(substring-before(substring-after(def, 'Type :'), '|'))"/>       <!--<xsl:text>placeType/zone%20naturelle</xsl:text>-->
                                    <xsl:choose>
                                        <xsl:when test="$type='forêt'"><xsl:text>placeType/for%C3%AAt</xsl:text></xsl:when>
                                        <xsl:when test="$type='col'"><xsl:text>placeType/col</xsl:text></xsl:when>
                                        <xsl:when test="$type='plage'"><xsl:text>placeType/plage</xsl:text></xsl:when>
                                        <xsl:when test="$type='volcan'"><xsl:text>placeType/volcan</xsl:text></xsl:when>
                                        <xsl:when test="$type='cap'"><xsl:text>placeType/cap</xsl:text></xsl:when>
                                        <xsl:when test="$type='pointe'"><xsl:text>placeType/pointe</xsl:text></xsl:when>
                                        <xsl:otherwise>placeType/zone%20naturelle</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                            </xsl:attribute>
                            
                        </rico:hasPlaceType>

                        <xsl:if test="contains(terme, 'France')">
                            <rico:isWithin
                                rdf:resource="place/FRAN_RI_005-d3ntxkl6yf-1f01iiij7xnld"/>



                        </xsl:if>
                        <xsl:if test="noticel/insee">
                            <xsl:variable name="ins" select="normalize-space(noticel/insee)"/>
                            <xsl:if test="$communes/d[normalize-space(noticel/insee)=$ins]">
                                <rico:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat('place/FRAN_RI_005-',$communes/d[normalize-space(noticel/insee)=$ins]/@id)"/>
                                    </xsl:attribute>
                                </rico:isWithin>
                            </xsl:if>
                            
                        </xsl:if>

                        <xsl:variable name="myDef" select="normalize-space(def)"/>
                        <xsl:for-each
                            select="tokenize($myDef, '\|')[normalize-space(.) != '']">
                            
                            <xsl:choose>
                                <xsl:when test="starts-with(normalize-space(.), 'Type')"/>
                                <xsl:when test="starts-with(normalize-space(.), 'GeoNames ')">
                                    <!-- http://sws.geonames.org/2986214/-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://sws.geonames.org/', normalize-space(substring-after(., 'geonames.org/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikidata ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://www.wikidata.org/entity/', normalize-space(substring-after(., 'wikidata.org/wiki/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikipédia ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <rdfs:seeAlso>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="normalize-space(substring-after(., 'Wikipédia :'))"
                                            />
                                        </xsl:attribute>
                                        
                                    </rdfs:seeAlso>
                                    
                                </xsl:when>
                                <xsl:when test="contains(., 'géolocalisé')">
                                    <rico:note xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:note>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rico:description xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:description>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:for-each>
                        
                        

                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </rico:identifier>


                    </rico:Place>
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
                xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dct="http://purl.org/dc/terms/" xmlns:html="http://www.w3.org/1999/xhtml"
                xml:base="http://data.archives-nationales.culture.gouv.fr/">
                <xsl:for-each select="$buildings/d">

                    <xsl:variable name="id" select="@id"/>
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat( 'place/', $ANVocabId, '-', $id)"/>

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

                       
                        <rico:hasPlaceType>
                            <xsl:variable name="type" select="normalize-space(substring-before(substring-after(def, 'Type :'), '|'))"/>      
                            <xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                   
                                   
                                    <xsl:when test="$type='abbaye'"><xsl:text>placeType/abbaye</xsl:text></xsl:when>
                                            <xsl:when test="$type='château'"><xsl:text>placeType/ch%C3%A2teau</xsl:text></xsl:when>
                                            <xsl:when test="$type='prison'"><xsl:text>placeType/prison</xsl:text></xsl:when>
                                            <xsl:when test="$type='hôpital'"><xsl:text>placeType/h%C3%B4pital</xsl:text></xsl:when>
                                            <xsl:when test="$type='maison royale de santé'"><xsl:text>placeType/maison%20royale%20de%20sant%C3%A9</xsl:text></xsl:when>
                                            <xsl:when test="$type='canal'"><xsl:text>placeType/canal</xsl:text></xsl:when>
                                    <xsl:when test="$type='station de ski'"><xsl:text>placeType/station%20de%20ski</xsl:text></xsl:when>
                                    <xsl:when test="$type='aérodrome'"><xsl:text>placeType/a%C3%A9rodrome</xsl:text></xsl:when> 
                                    <xsl:when test="$type='pont'"><xsl:text>placeType/pont</xsl:text></xsl:when>                      <xsl:when test="$type='barrage'"><xsl:text>placeType/barrage</xsl:text></xsl:when>                    
                
                                    <xsl:when test="$type='port'"><xsl:text>placeType/port</xsl:text></xsl:when>
                                    <xsl:when test="$type='phare'"><xsl:text>placeType/phare</xsl:text></xsl:when>
                                    <xsl:when test="$type='station balnéaire'"><xsl:text>placeType/station%20baln%C3%A9aire</xsl:text></xsl:when>
                                    <xsl:when test="$type='gare ferroviaire'"><xsl:text>placeType/gare%20ferroviaire</xsl:text></xsl:when>
                                    <xsl:when test="$type='cité sanitaire'"><xsl:text>placeType/cit%C3%A9%20sanitaire</xsl:text></xsl:when>     
                                    
                                    <xsl:otherwise>placeType/am%C3%A9nagement%20ou%20construction</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            
                        </rico:hasPlaceType>
                        <xsl:if test="contains(terme, ',')">
                            <xsl:variable name="mySubstring">
                                <xsl:value-of
                                    select="normalize-space(substring-before(substring-after(terme, '('), ','))"/>

                            </xsl:variable>
                            <!--   <test><xsl:value-of select="$mySubstring"/></test>-->
                            <xsl:if
                                test="$departs/d[starts-with(normalize-space(terme), concat($mySubstring, ' ('))]">
                                <rico:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('place/', $ANVocabId, '-', $departs/d[starts-with(normalize-space(terme), concat($mySubstring, ' ('))]/@id)"
                                        />
                                    </xsl:attribute>
                                </rico:isWithin>
                            </xsl:if>
                        </xsl:if>
                        <xsl:if test="noticel/insee">
                            <xsl:variable name="ins" select="normalize-space(noticel/insee)"/>
                            <xsl:if test="$communes/d[normalize-space(noticel/insee)=$ins]">
                                <rico:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat('place/FRAN_RI_005-',$communes/d[normalize-space(noticel/insee)=$ins]/@id)"/>
                                    </xsl:attribute>
                                </rico:isWithin>
                            </xsl:if>
                            
                        </xsl:if>
                       <!-- <xsl:if test="def[normalize-space(.) != '']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>-->
                        <xsl:variable name="myDef" select="normalize-space(def)"/>
                        <xsl:for-each
                            select="tokenize($myDef, '\|')[normalize-space(.) != '']">
                            
                            <xsl:choose>
                                <xsl:when test="starts-with(normalize-space(.), 'Type')"/>
                                <xsl:when test="starts-with(normalize-space(.), 'GeoNames ')">
                                    <!-- http://sws.geonames.org/2986214/-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://sws.geonames.org/', normalize-space(substring-after(., 'geonames.org/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikidata ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://www.wikidata.org/entity/', normalize-space(substring-after(., 'wikidata.org/wiki/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikipédia ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <rdfs:seeAlso>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="normalize-space(substring-after(., 'Wikipédia :'))"
                                            />
                                        </xsl:attribute>
                                        
                                    </rdfs:seeAlso>
                                    
                                </xsl:when>
                                <xsl:when test="contains(., 'géolocalisé')">
                                    <rico:note xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:note>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rico:description xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:description>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:for-each>
                        

                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </rico:identifier>


                    </rico:Place>
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
            href="{$chemin-out}FRAN_lieux-dits.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dct="http://purl.org/dc/terms/" xmlns:html="http://www.w3.org/1999/xhtml"
                xml:base="http://data.archives-nationales.culture.gouv.fr/">
                <xsl:for-each select="$lieux-dits/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    
                    
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/', $ANVocabId, '-', $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>
                        </skos:prefLabel>
                        <xsl:for-each
                            select="
                            noticel/forms/f[not(matches(., '\d+'))]
                            
                            ">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>
                        
                        <rico:hasPlaceType rdf:resource="placeType/lieu-dit"/>
                        
                        <xsl:variable name="myDef" select="normalize-space(def)"/>
                        <xsl:for-each
                            select="tokenize($myDef, '\|')[normalize-space(.) != '']">
                            
                            <xsl:choose>
                                <xsl:when test="starts-with(normalize-space(.), 'Type')"/>
                                <xsl:when test="starts-with(normalize-space(.), 'GeoNames ')">
                                    <!-- http://sws.geonames.org/2986214/-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://sws.geonames.org/', normalize-space(substring-after(., 'geonames.org/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikidata ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <owl:sameAs>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('http://www.wikidata.org/entity/', normalize-space(substring-after(., 'wikidata.org/wiki/')))"
                                            />
                                        </xsl:attribute>
                                        
                                    </owl:sameAs>
                                    
                                </xsl:when>
                                <xsl:when
                                    test="starts-with(normalize-space(.), 'Wikipédia ')">
                                    <!-- RI : https://www.wikidata.org/wiki/Q432005 cible : http://www.wikidata.org/entity/Q432005-->
                                    <rdfs:seeAlso>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="normalize-space(substring-after(., 'Wikipédia :'))"
                                            />
                                        </xsl:attribute>
                                        
                                    </rdfs:seeAlso>
                                    
                                </xsl:when>
                                <xsl:when test="contains(., 'géolocalisé')">
                                    <rico:note xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:note>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rico:description xml:lang="fr">
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </rico:description>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:for-each>
                        
                        <xsl:if test="noticel/dpt">
                          <xsl:variable name="myDpt" select="normalize-space(noticel/dpt)"/>  
                            <xsl:if
                                test="$departs/d[starts-with(normalize-space(terme), concat($myDpt, ' ('))]">
                                <rico:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('place/', $ANVocabId, '-', $departs/d[starts-with(normalize-space(terme), concat($myDpt, ' ('))]/@id)"
                                        />
                                    </xsl:attribute>
                                </rico:isWithin>
                            </xsl:if>  
                        </xsl:if>
                        
                        <xsl:if test="noticel/insee">
                            <xsl:variable name="ins" select="normalize-space(noticel/insee)"/>
                            <xsl:if test="$communes/d[normalize-space(noticel/insee)=$ins]">
                                <rico:isWithin>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat('place/FRAN_RI_005-',$communes/d[normalize-space(noticel/insee)=$ins]/@id)"/>
                                    </xsl:attribute>
                                </rico:isWithin>
                            </xsl:if>
                            
                        </xsl:if>
                        
                        <!--  <terme>Vietnam (République du , 1955-1975)</terme>-->
                        <!-- traitement très rapide et simpliste des dates ; à reprendre avec regexp-->
                        <!--<xsl:if test="contains(terme, '(')">
                            <xsl:variable name="myString"
                                select="normalize-space(substring-before(substring-after(terme, '('), ')'))"/>
                            
                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($myString, '1') or starts-with($myString, '2')">
                                    <rico:beginningDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        
                                        
                                        
                                        <xsl:value-of select="substring-before($myString, '-')"/>
                                        
                                        
                                        
                                        
                                    </rico:beginningDate>
                                    <rico:endDate>
                                        <xsl:attribute name="rdf:datatype">
                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="substring-after($myString, '-')"/>
                                        
                                    </rico:endDate>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="$pays/d[normalize-space(terme) = $myString]">
                                        <rico:isWithin>
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                    select="concat('place/', $ANVocabId, '-', $pays/d[normalize-space(terme) = $myString]/@id)"
                                                />
                                            </xsl:attribute>
                                        </rico:isWithin>
                                    </xsl:if>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>-->
                        
                       <!-- <xsl:if test="def[normalize-space(.) != '']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>-->
                        
                        
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </rico:identifier>
                        
                        
                    </rico:Place>
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
