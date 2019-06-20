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
    <xd:doc>

        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 30, 2018</xd:p>
            <xd:p>Revised on March 8, 2019, and on June 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Generating RDF files from the XML files created by the Archives nationales de
                France, and describing places : processing the branches on French contemporary
                districts in the main file, FRAN_RI_005.xml. Step 2 : integrating historical data
                from INSEE datasets + some partitive relations. </xd:p>
            <xd:p>Main reference ontology : RiC-O</xd:p>



        </xd:desc>
    </xd:doc>
    <xsl:variable name="chemin-out">
        <xsl:value-of select="'rdf/places/'"/>
    </xsl:variable>
    <xsl:variable name="ANdepts" select="document('temp/FRAN_departements.rdf')/rdf:RDF"/>
    <xsl:variable name="chemin-communes">
        <xsl:value-of
            select="concat('temp/', '?select=FRAN_communes*.rdf;recurse=yes;on-error=warning')"/>
    </xsl:variable>


    <xsl:variable name="communes" select="collection($chemin-communes)"/>
    <xsl:variable name="chemin-arrs">
        <xsl:value-of
            select="concat('temp/', '?select=FRAN_arrondissements*.rdf;recurse=yes;on-error=warning')"
        />
    </xsl:variable>
    <xsl:variable name="arrs" select="collection($chemin-arrs)"/>


    <xsl:variable name="chemin-cantons"
        select="concat('temp/', '?select=FRAN_cantons*.rdf;recurse=yes;on-error=warning')"/>
    <xsl:variable name="cantons" select="collection($chemin-cantons)"/>

    <xsl:variable name="INSEEData"
        select="document('src/places/graphDB-request-mouvementsCommunes-def.xml')/sparql:sparql/sparql:results"/>
    <xsl:variable name="INSEEDataArrs"
        select="document('src/places/graphDB-request-mouvementsArrondissements.xml')/sparql:sparql/sparql:results"/>
    <xsl:variable name="INSEEDataDepts"
        select="document('src/places/graphDB-request-mouvementsDepartements.xml')/sparql:sparql/sparql:results"/>
    <!-- pré-traitement des données INSEE-->
    <xsl:variable name="INSEEdataByCommunes">
        <INSEEdata>
            <xsl:for-each-group select="$INSEEData/sparql:result"
                group-by="concat(sparql:binding[@name = 'commune']/sparql:uri, ' | ', sparql:binding[@name = 'nom']/sparql:literal, ' # ', sparql:binding[@name = 'vivant']/sparql:literal)">
                <commune>
                    <xsl:attribute name="uri">
                        <xsl:value-of select="substring-before(current-grouping-key(), ' |')"/>
                    </xsl:attribute>
                    <xsl:attribute name="nom"
                        select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"/>
                    <xsl:attribute name="etat"
                        select="substring-after(current-grouping-key(), '# ')"/>

                    <xsl:for-each-group select="current-group()"
                        group-by="sparql:binding[@name = 'date']/sparql:literal">
                        <date>
                            <xsl:attribute name="standardValue" select="current-grouping-key()"/>
                            <xsl:for-each-group select="current-group()"
                                group-by="concat(sparql:binding[@name = 'mouvement']/sparql:uri, '| ', sparql:binding[@name = 'typemouvement']/sparql:uri, ' # ', sparql:binding[@name = 'com']/sparql:literal, '%', sparql:binding[@name = 'comment']/sparql:literal)">

                                <evenement>
                                    <xsl:attribute name="idMouvement">
                                        <xsl:value-of
                                            select="substring-before(current-grouping-key(), '| ')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="type">
                                        <xsl:value-of
                                            select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"
                                        />
                                    </xsl:attribute>

                                    <xsl:value-of
                                        select="substring-before(substring-after(current-grouping-key(), ' #'), '%')"/>
                                    <xsl:if test="normalize-space(substring-after(current-grouping-key(), ' %'))!=''">
                                    <xsl:text> | </xsl:text>
                                    </xsl:if>
                                    <xsl:if test="normalize-space(substring-after(current-grouping-key(), ' %'))=''">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of
                                        select="substring-after(current-grouping-key(), ' %')"/>
                                </evenement>

                            </xsl:for-each-group>
                        </date>


                    </xsl:for-each-group>
                </commune>
            </xsl:for-each-group>
        </INSEEdata>

    </xsl:variable>
    <xsl:variable name="INSEEdataByArrs">
        <INSEEdata>
            <xsl:for-each-group select="$INSEEDataArrs/sparql:result"
                group-by="concat(sparql:binding[@name = 'arr']/sparql:uri, ' | ', sparql:binding[@name = 'nom']/sparql:literal, ' # ', sparql:binding[@name = 'vivant']/sparql:literal)">
                <arrondissement>
                    <xsl:attribute name="uri">
                        <xsl:value-of select="substring-before(current-grouping-key(), ' |')"/>
                    </xsl:attribute>
                    <xsl:attribute name="nom"
                        select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"/>
                    <xsl:attribute name="etat"
                        select="substring-after(current-grouping-key(), '# ')"/>

                    <xsl:for-each-group select="current-group()"
                        group-by="sparql:binding[@name = 'date']/sparql:literal">
                        <date>
                            <xsl:attribute name="standardValue" select="current-grouping-key()"/>
                            <!-- <xsl:for-each-group select="current-group()"
                                group-by="concat(sparql:binding[@name = 'comment']/sparql:literal, ' | ', sparql:binding[@name = 'typemouvement']/sparql:uri, ' # ', sparql:binding[@name = 'mouvement']/sparql:uri)">

                                <evenement>

                                    <xsl:attribute name="type">
                                        <xsl:value-of
                                            select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="idMouvement">
                                        <xsl:value-of
                                            select="substring-after(current-grouping-key(), '# ')"/>
                                    </xsl:attribute>
                                    <xsl:value-of
                                        select="substring-before(current-grouping-key(), ' |')"/>

                                </evenement>

                            </xsl:for-each-group>-->
                            <xsl:for-each-group select="current-group()"
                                group-by="concat(sparql:binding[@name = 'mouvement']/sparql:uri, '| ', sparql:binding[@name = 'typemouvement']/sparql:uri, ' # ', sparql:binding[@name = 'com']/sparql:literal, '%', sparql:binding[@name = 'comment']/sparql:literal)">

                                <evenement>
                                    <xsl:attribute name="idMouvement">
                                        <xsl:value-of
                                            select="substring-before(current-grouping-key(), '| ')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="type">
                                        <xsl:value-of
                                            select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"
                                        />
                                    </xsl:attribute>

                                    <xsl:value-of
                                        select="substring-before(substring-after(current-grouping-key(), ' #'), '%')"/>
                                    <xsl:if test="normalize-space(substring-after(current-grouping-key(), ' %'))!=''">
                                        <xsl:text> | </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of
                                        select="substring-after(current-grouping-key(), ' %')"/>
                                </evenement>

                            </xsl:for-each-group>
                        </date>


                    </xsl:for-each-group>
                </arrondissement>
            </xsl:for-each-group>
        </INSEEdata>
    </xsl:variable>
    <xsl:variable name="INSEEdataByDepts">
        <INSEEdata>
            <xsl:for-each-group
                select="$INSEEDataDepts/sparql:result[starts-with(sparql:binding[@name = 'departement']/sparql:uri, 'http://id.insee.fr/geo/departement')]"
                group-by="concat(sparql:binding[@name = 'departement']/sparql:uri, ' | ', sparql:binding[@name = 'nom']/sparql:literal, ' # ', sparql:binding[@name = 'vivant']/sparql:literal, ' % ', sparql:binding[@name = 'cheflieu']/sparql:uri)">
                <departement>
                    <xsl:attribute name="uri">
                        <xsl:value-of select="substring-before(current-grouping-key(), ' |')"/>
                    </xsl:attribute>
                    <xsl:attribute name="nom"
                        select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"/>
                    <xsl:attribute name="etat"
                        select="substring-before(substring-after(current-grouping-key(), '# '), ' %')"/>
                    <xsl:attribute name="cheflieu"
                        select="substring-after(current-grouping-key(), ' % ')"/>
                    <xsl:for-each-group select="current-group()"
                        group-by="sparql:binding[@name = 'date']/sparql:literal">
                        <date>
                            <xsl:attribute name="standardValue" select="current-grouping-key()"/>
                            <!--<xsl:for-each-group select="current-group()"
                                group-by="concat(sparql:binding[@name = 'comment']/sparql:literal, ' | ', sparql:binding[@name = 'typemouvement']/sparql:uri, ' # ', sparql:binding[@name = 'mouvement']/sparql:uri)">

                                <evenement>

                                    <xsl:attribute name="type">
                                        <xsl:value-of
                                            select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="idMouvement">
                                        <xsl:value-of
                                            select="substring-after(current-grouping-key(), '# ')"/>
                                    </xsl:attribute>
                                    <xsl:value-of
                                        select="substring-before(current-grouping-key(), ' |')"/>

                                </evenement>

                            </xsl:for-each-group>-->
                            <xsl:for-each-group select="current-group()"
                                group-by="concat(sparql:binding[@name = 'mouvement']/sparql:uri, '| ', sparql:binding[@name = 'typemouvement']/sparql:uri, ' # ', sparql:binding[@name = 'com']/sparql:literal, '%', sparql:binding[@name = 'comment']/sparql:literal)">

                                <evenement>
                                    <xsl:attribute name="idMouvement">
                                        <xsl:value-of
                                            select="substring-before(current-grouping-key(), '| ')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="type">
                                        <xsl:value-of
                                            select="substring-before(substring-after(current-grouping-key(), '| '), ' #')"
                                        />
                                    </xsl:attribute>

                                    <xsl:value-of
                                        select="substring-before(substring-after(current-grouping-key(), ' #'), '%')"/>
                                    <xsl:if test="normalize-space(substring-after(current-grouping-key(), ' %'))!=''">
                                        <xsl:text> | </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of
                                        select="substring-after(current-grouping-key(), ' %')"/>
                                </evenement>

                            </xsl:for-each-group>
                        </date>


                    </xsl:for-each-group>
                </departement>
            </xsl:for-each-group>
        </INSEEdata>
    </xsl:variable>

    <xsl:template match="/vide">


        <xsl:result-document href="temp/evenementsCommunes.xml">

            <xsl:copy-of select="$INSEEdataByCommunes"/>

        </xsl:result-document>

        <xsl:result-document href="temp/evenementsArrondissements.xml">

            <xsl:copy-of select="$INSEEdataByArrs"/>

        </xsl:result-document>
        <xsl:result-document href="temp/evenementsDepartements.xml">

            <xsl:copy-of select="$INSEEdataByDepts"/>

        </xsl:result-document>
        <xsl:for-each select="$communes">
            <xsl:variable name="deptId">
                <xsl:choose>
                    <xsl:when
                        test="starts-with(/rdf:RDF/rico:Place[1]/insee-geo:codeCommune, '97') or starts-with(/rdf:RDF/rico:Place[1]/insee-geo:codeCommune, '98')">
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeCommune, 1, 3)"/>
                    </xsl:when>
                    <!-- <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>-->
                    <xsl:otherwise>
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeCommune, 1, 2)"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:variable>
            <xsl:result-document href="{$chemin-out}FRAN_communes_{$deptId}.rdf" method="xml"
                encoding="utf-8" indent="yes">
                <!-- <deptId><xsl:value-of select="$deptId"/></deptId>-->
                <!--  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">-->
                <xsl:apply-templates/>

                <!--</rdf:RDF>-->
            </xsl:result-document>


        </xsl:for-each>
        <xsl:for-each select="$arrs">
            <xsl:variable name="deptId">
                <xsl:choose>
                    <xsl:when
                        test="starts-with(/rdf:RDF/rico:Place[1]/insee-geo:codeArrondissement, '97')">
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeArrondissement, 1, 3)"
                        />
                    </xsl:when>
                    <!-- <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>-->
                    <xsl:otherwise>
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeArrondissement, 1, 2)"
                        />
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:variable>
            <xsl:result-document href="{$chemin-out}FRAN_arrondissements_{$deptId}.rdf" method="xml"
                encoding="utf-8" indent="yes">
                <!-- <deptId><xsl:value-of select="$deptId"/></deptId>-->
                <!--  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">-->
                <!--  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">-->
                <xsl:apply-templates/>

                <!--</rdf:RDF>-->

                <!--</rdf:RDF>-->
            </xsl:result-document>


        </xsl:for-each>
        <xsl:for-each select="$cantons">
            <xsl:variable name="deptId">
                <xsl:choose>
                    <xsl:when test="starts-with(/rdf:RDF/rico:Place[1]/insee-geo:codeCanton, '97')">
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeCanton, 1, 3)"/>
                    </xsl:when>
                    <!-- <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>-->
                    <xsl:otherwise>
                        <xsl:value-of
                            select="substring(/rdf:RDF/rico:Place[1]/insee-geo:codeCanton, 1, 2)"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:variable>
            <xsl:result-document href="{$chemin-out}FRAN_cantons_{$deptId}.rdf" method="xml"
                encoding="utf-8" indent="yes">
                <!-- <deptId><xsl:value-of select="$deptId"/></deptId>-->
                <!--  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">-->
                <!--  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">-->
                <xsl:apply-templates>
                    <xsl:with-param name="deptId" select="$deptId"/>
                </xsl:apply-templates>

                <!--</rdf:RDF>-->

                <!--</rdf:RDF>-->
            </xsl:result-document>


        </xsl:for-each>
        <xsl:result-document href="{$chemin-out}FRAN_departements.rdf" method="xml" encoding="utf-8"
            indent="yes">
            <xsl:apply-templates select="$ANdepts"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="* | text() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="* | text() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="rico:Place">
        <xsl:variable name="INSEEUri">
            <!-- <owl:sameAs rdf:resource="http://id.insee.fr/geo/commune/2A001"/>-->
            <xsl:choose>
                <xsl:when test="owl:sameAs[starts-with(@rdf:resource, 'http://id.insee.fr/geo/')]">
                    <xsl:value-of
                        select="owl:sameAs[starts-with(@rdf:resource, 'http://id.insee.fr/geo/')]/@rdf:resource"
                    />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <rico:Place>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="@rdf:about"/>
            </xsl:attribute>
            <xsl:apply-templates/>
            <!-- pour les cantons, ajout d'une relation d'inclusion à l'arrondissement AN -->
            <xsl:if
                test="rdf:type[@rdf:resource = 'http://data.ign.fr/def/geofla#Canton'] and geofla:arr[starts-with(@rdf:resource, 'http://id.insee.fr/geo/')]">
                <xsl:variable name="idArr" select="geofla:arr/@rdf:resource"/>
                <xsl:if test="$arrs/rdf:RDF/rico:Place[owl:sameAs[@rdf:resource = $idArr]]">
                    <geofla:arr>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of
                                select="$arrs/rdf:RDF/rico:Place[owl:sameAs[@rdf:resource = $idArr]]/@rdf:about"
                            />
                        </xsl:attribute>
                    </geofla:arr>
                    <rico:isPartOf>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of
                                select="$arrs/rdf:RDF/rico:Place[owl:sameAs[@rdf:resource = $idArr]]/@rdf:about"
                            />
                        </xsl:attribute>
                    </rico:isPartOf>
                </xsl:if>
            </xsl:if>
            <!-- pour les communes, ajout d'une relation d'inclusion à l'arrondissement AN -->
            <!-- <RiC:note xml:lang="fr">arrondissement : 461</RiC:note>-->
            <!-- <RiC:note xml:lang="fr">canton : Cazals</RiC:note>-->
            <xsl:if test="rdf:type[@rdf:resource = 'http://data.ign.fr/def/geofla#Commune']">
                <xsl:variable name="idArr"
                    select="normalize-space(substring-after(rico:note[starts-with(., 'arrondissement :')], 'arrondissement :'))"/>
                <xsl:variable name="trueIdArr">
                    <xsl:choose>
                        <xsl:when test="string-length($idArr) = 2">
                            <xsl:value-of select="concat('0', $idArr)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$idArr"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="rico:note[starts-with(., 'arrondissement :')]">
                   
                    
                    <xsl:if
                        test="$arrs/rdf:RDF/rico:Place[insee-geo:codeArrondissement = $trueIdArr]">
                        <geofla:arr>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="$arrs/rdf:RDF/rico:Place[insee-geo:codeArrondissement = $trueIdArr]/@rdf:about"
                                />
                            </xsl:attribute>
                        </geofla:arr>
                        <rico:isPartOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="$arrs/rdf:RDF/rico:Place[insee-geo:codeArrondissement = $trueIdArr]/@rdf:about"
                                />
                            </xsl:attribute>
                        </rico:isPartOf>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="rico:note[starts-with(., 'canton :')]">
                    <xsl:variable name="CantName"
                        select="normalize-space(substring-after(rico:note[starts-with(., 'canton :')], 'canton :'))"/>
                    <!--  <geofla:arr rdf:resource="http://id.insee.fr/geo/arrondissement/331"/>-->
                    <xsl:if
                        test="$cantons/rdf:RDF/rico:Place[starts-with(rdfs:label, concat($CantName, ' (')) and geofla:arr[ends-with(@rdf:resource, concat('arrondissement/', $trueIdArr))]]">
                        <geofla:cant>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="$cantons/rdf:RDF/rico:Place[starts-with(rdfs:label, concat($CantName, ' (')) and geofla:arr[ends-with(@rdf:resource, concat('arrondissement/', $trueIdArr))]]/@rdf:about"
                                />
                            </xsl:attribute>
                        </geofla:cant>
                        <rico:isPartOf>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="$cantons/rdf:RDF/rico:Place[starts-with(rdfs:label, concat($CantName, ' (')) and geofla:arr[ends-with(@rdf:resource, concat('arrondissement/', $trueIdArr))]]/@rdf:about"
                                />
                            </xsl:attribute>
                        </rico:isPartOf>
                    </xsl:if>
                </xsl:if>
                <!-- ajout de l'historique INSEE -->

                <xsl:if test="$INSEEdataByCommunes/rdf:INSEEdata/rdf:commune[@uri = $INSEEUri]">

                    <xsl:choose>

                        <xsl:when
                            test="$INSEEdataByCommunes/rdf:INSEEdata/rdf:commune[@uri = $INSEEUri]/@etat = 'false'">
                            <rico:state xml:lang="fr">commune disparue</rico:state>
                        </xsl:when>

                    </xsl:choose>
                    <xsl:if
                        test="$INSEEdataByCommunes/rdf:INSEEdata/rdf:commune[@uri = $INSEEUri]/rdf:date">
                        <rico:history rdf:parseType="Literal">
                            <html:div xml:lang="fr">
                                <xsl:for-each
                                    select="$INSEEdataByCommunes/rdf:INSEEdata/rdf:commune[@uri = $INSEEUri]/rdf:date">
                                    <html:p>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="date" select="@standardValue"/>
                                        </xsl:call-template>

                                        <xsl:text> : </xsl:text>
                                        <xsl:for-each select="rdf:evenement">
                                            <xsl:variable name="valeur" select="normalize-space(.)"/>
                                            <xsl:if
                                                test="not(preceding-sibling::rdf:evenement[normalize-space(.) = $valeur])">
                                                <xsl:value-of select="$valeur"/>
                                            </xsl:if>

                                        </xsl:for-each>
                                    </html:p>
                                </xsl:for-each>
                            </html:div>
                        </rico:history>
                    </xsl:if>
                </xsl:if>
            </xsl:if>

            <!-- arrondissements : ajout de l'historique INSEE -->
            <xsl:if test="$INSEEdataByArrs/rdf:INSEEdata/rdf:arrondissement[@uri = $INSEEUri]">
                <xsl:choose>

                    <xsl:when
                        test="not(rico:state) and $INSEEdataByArrs/rdf:INSEEdata/rdf:arrondissement[@uri = $INSEEUri]/@etat = 'false'">
                        <rico:state xml:lang="fr">arrondissement disparu</rico:state>
                    </xsl:when>

                </xsl:choose>
                <xsl:if
                    test="$INSEEdataByArrs/rdf:INSEEdata/rdf:arrondissement[@uri = $INSEEUri]/rdf:date">
                    <rico:history rdf:parseType="Literal">
                        <html:div xml:lang="fr">
                        <xsl:for-each
                            select="$INSEEdataByArrs/rdf:INSEEdata/rdf:arrondissement[@uri = $INSEEUri]/rdf:date">
                            <html:p>
                            <xsl:call-template name="outputDate">
                                <xsl:with-param name="date" select="@standardValue"/>
                            </xsl:call-template>

                            <xsl:text> : </xsl:text>
                            <xsl:for-each select="rdf:evenement">
                                <xsl:variable name="valeur" select="normalize-space(.)"/>
                                <xsl:if
                                    test="not(preceding-sibling::rdf:evenement[normalize-space(.) = $valeur])">
                                    <xsl:value-of select="$valeur"/>
                                </xsl:if>
                               
                            </xsl:for-each>
                            </html:p>
                        </xsl:for-each>
                        </html:div>
                    </rico:history>
                </xsl:if>
            </xsl:if>
            <!-- départements : ajout de l'historique INSEE -->
            <xsl:if
                test="$INSEEdataByDepts/rdf:INSEEdata/rdf:departement[@uri = $INSEEUri and not(starts-with(@cheflieu, 'http://data.ign.fr/id/geofla/'))]">
                <!-- récupération du chef-lieu et de l'état-->
                <insee-geo:chefLieu>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of
                            select="$INSEEdataByDepts/rdf:INSEEdata/rdf:departement[@uri = $INSEEUri and not(starts-with(@cheflieu, 'http://data.ign.fr/id/geofla/'))]/@cheflieu"
                        />
                    </xsl:attribute>
                </insee-geo:chefLieu>
                <xsl:if
                    test="$INSEEdataByDepts/rdf:INSEEdata/rdf:departement[@uri = $INSEEUri and not(starts-with(@cheflieu, 'http://data.ign.fr/id/geofla/'))]/@etat = 'false'">
                    <rico:state xml:lang="fr">département disparu</rico:state>
                </xsl:if>
                <xsl:if
                    test="$INSEEdataByDepts/rdf:INSEEdata/rdf:departement[@uri = $INSEEUri and not(starts-with(@cheflieu, 'http://data.ign.fr/id/geofla/')) and rdf:date]">


                    <rico:history rdf:parseType="Literal">
                        <html:div xml:lang="fr">
                        <xsl:for-each
                            select="$INSEEdataByDepts/rdf:INSEEdata/rdf:departement[@uri = $INSEEUri and not(starts-with(@cheflieu, 'http://data.ign.fr/id/geofla/'))]/rdf:date">
<html:p>
                            <xsl:call-template name="outputDate">
                                <xsl:with-param name="date" select="@standardValue"/>
                            </xsl:call-template>

                            <xsl:text> : </xsl:text>
                            <xsl:for-each select="rdf:evenement">
                                <xsl:variable name="valeur" select="normalize-space(.)"/>
                                <xsl:if
                                    test="not(preceding-sibling::rdf:evenement[normalize-space(.) = $valeur])">
                                    <xsl:value-of select="$valeur"/>
                                </xsl:if>
                               
                            </xsl:for-each>
</html:p>
                        </xsl:for-each>
                        </html:div>
                    </rico:history>
                </xsl:if>

            </xsl:if>


        </rico:Place>


    </xsl:template>
    <xsl:template name="outputDate">
        <xsl:param name="date"/>
        <xsl:value-of select="day-from-date(xs:date($date))"/>
        <xsl:if test="day-from-date(xs:date($date)) = 1">
            <!--<sup>er</sup>-->
            <xsl:text>er</xsl:text>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="outputMonth">
            <xsl:with-param name="month" select="month-from-date(xs:date($date))"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select="year-from-date(xs:date($date))"/>
    </xsl:template>
    <xsl:template name="outputMonth">
        <xsl:param name="month"/>
        <xsl:choose>
            <xsl:when test="$month = 01">janvier</xsl:when>
            <xsl:when test="$month = 02">février</xsl:when>
            <xsl:when test="$month = 03">mars</xsl:when>
            <xsl:when test="$month = 04">avril</xsl:when>
            <xsl:when test="$month = 05">mai</xsl:when>
            <xsl:when test="$month = 06">juin</xsl:when>
            <xsl:when test="$month = 07">juillet</xsl:when>
            <xsl:when test="$month = 08">août</xsl:when>
            <xsl:when test="$month = 09">septembre</xsl:when>
            <xsl:when test="$month = 10">octobre</xsl:when>
            <xsl:when test="$month = 11">novembre</xsl:when>
            <xsl:when test="$month = 12">décembre</xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
