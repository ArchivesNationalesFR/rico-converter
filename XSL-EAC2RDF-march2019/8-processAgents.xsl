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
    exclude-result-prefixes="xs xd iso-thes rdf dct xl xlink skos foaf ginco dc" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 4, 2017, checked and updated Dec. 12, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud (Archives nationales)</xd:p>

            <xd:p>Revised on March 19, 2019</xd:p>

            <xd:p>Step 8 : generating the RDF files for the agents</xd:p>

        </xd:desc>
    </xd:doc>

    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>

    <xsl:variable name="chemin-AN-places">
        <xsl:value-of
            select="concat('rdf/places/', '?select=*.rdf;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-places-rdf" select="collection($chemin-AN-places)/rdf:RDF"/>
    <xsl:variable name="FRAN-places-Paris"
        select="document('rdf/places/FRAN_places_Paris.rdf')/rdf:RDF"/>
    <xsl:variable name="FRAN-places-general" select="document('rdf/places/FRAN_places.rdf')/rdf:RDF"/>

    <xsl:variable name="rules" select="document('rdf/rules/FRAN_rules.rdf')/rdf:RDF"/>
    <xsl:variable name="positions" select="document('rdf/positions/FRAN_positions.rdf')/rdf:RDF"/>
    <xsl:variable name="activityTypes"
        select="document('rdf/vocabularies/FRAN_RI_011_activityTypes.rdf')/rdf:RDF"/>
    <xsl:variable name="occupationTypes"
        select="document('rdf/vocabularies/FRAN_RI_010_occupationTypes.rdf')/rdf:RDF"/>
    <xsl:variable name="legalsts"
        select="document('rdf/vocabularies/FRAN_RI_104_Ginco_legalStatuses.rdf')/rdf:RDF"/>

    <xsl:variable name="agent-names" select="document('rdf/agentNames/FRAN_agentNames.rdf')/rdf:RDF"/>


    <xsl:variable name="fam-relations"
        select="document('rdf/relations/FRAN_familyRelations.rdf')/rdf:RDF"/>
    <xsl:variable name="hier-rels"
        select="document('rdf/relations/FRAN_agentHierarchicalRelations.rdf')/rdf:RDF"/>
    <xsl:variable name="temp-rels"
        select="document('rdf/relations/FRAN_agentTemporalRelations.rdf')/rdf:RDF"/>
    <xsl:variable name="assoc-rels"
        select="document('rdf/relations/FRAN_agentRelations.rdf')/rdf:RDF"/>
    <!--<xsl:variable name="orig-rels"
        select="document('rdf/relations/FRAN_originationRelations.rdf')/rdf:RDF"/>-->
    <xsl:strip-space elements="*"/>
    <xsl:template match="/vide">





        <xsl:for-each select="$collection-EAC-AN/eac:eac-cpf">
            <xsl:variable name="recId" select="normalize-space(eac:control/eac:recordId)"/>
            <xsl:variable name="theGoodRecId" select="substring-after($recId, 'FRAN_NP_')"/>
            <xsl:variable name="entType" select="eac:cpfDescription/eac:identity/eac:entityType"/>
            <xsl:variable name="entTypeName">
                <xsl:choose>
                    <xsl:when test="$entType = 'corporateBody'">corporateBody</xsl:when>
                    <xsl:when test="$entType = 'person'">person</xsl:when>
                    <xsl:when test="$entType = 'family'">family</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="RiCClass">
                <xsl:choose>
                    <xsl:when test="$entType = 'corporateBody'">CorporateBody</xsl:when>
                    <xsl:when test="$entType = 'person'">Person</xsl:when>
                    <xsl:when test="$entType = 'family'">Family</xsl:when>
                </xsl:choose>
            </xsl:variable>


            <xsl:variable name="URI" select="concat($baseURL, $entTypeName, '/', $theGoodRecId)"/>

            <xsl:result-document method="xml" encoding="utf-8" indent="yes"
                href="rdf/agents/{$entTypeName}_{$theGoodRecId}.rdf">

                <rdf:RDF xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:isni="http://isni.org/ontology#"
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="$URI"/>
                        </xsl:attribute>
                        <rdf:type
                            rdf:resource="http://www.ica.org/standards/RiC/ontology#{$RiCClass}"/>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of
                                select="
                                    normalize-space(eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)
                                    
                                    
                                    
                                    "
                            />
                        </rdfs:label>
                        <!-- relation to each name ; the instance of the target RelationToAppellation is generated below, in the same file -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:identity/eac:nameEntry[normalize-space(.) != '']">
                            <RiC:thingIsSourceOfRelationToAppellation>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat($baseURL, 'relationToAppellation/', $theGoodRecId, '_', generate-id())"
                                    />
                                </xsl:attribute>
                            </RiC:thingIsSourceOfRelationToAppellation>
                        </xsl:for-each>
                        <!-- legal status. Concerns the corporate bodies only. For now, the XSLT only takes into account the current case : one legal status, no date nor description. Should be completed (output an instance of RelationToType -->
                        <xsl:if test="$entType = 'corporateBody'">
                            <xsl:for-each
                                select="eac:cpfDescription/eac:description/descendant::eac:legalStatus[normalize-space() != '']">
                                <!-- there also is a bug in the ANF SIA: some legal statuses are recorded without the reference to the concept in the vocabulary...-->
                                <xsl:variable name="myLegStatus"
                                    select="
                                        if (eac:term/@vocabularySource)
                                        then
                                            eac:term/@vocabularySource
                                        else
                                            (
                                            normalize-space(eac:term)
                                            )
                                        "/>
                                <RiC:hasLegalStatus>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="
                                                
                                                if (eac:term/@vocabularySource)
                                                then
                                                    $legalsts/skos:Concept[ginco:id = concat('FRAN_RI_104.xml#', $myLegStatus)]/@rdf:about
                                                else
                                                    (
                                                    
                                                    $legalsts/skos:Concept[upper-case(skos:prefLabel) = upper-case($myLegStatus)]/@rdf:about
                                                    )
                                                
                                                
                                                
                                                "
                                        />
                                    </xsl:attribute>
                                </RiC:hasLegalStatus>
                            </xsl:for-each>
                        </xsl:if>
                        <!-- dates of existence -->
                        <xsl:choose>
                            <xsl:when test="$entType = 'person'">
                                <xsl:if
                                    test="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate">
                                    <RiC:birthDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate"
                                            />
                                        </xsl:call-template>
                                    </RiC:birthDate>
                                </xsl:if>
                                <xsl:if
                                    test="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate">
                                    <RiC:deathDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate"
                                            />
                                        </xsl:call-template>
                                    </RiC:deathDate>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="$entType = 'corporateBody' or $entType = 'family'">
                                <xsl:if
                                    test="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate">
                                    <RiC:beginningDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:fromDate"
                                            />
                                        </xsl:call-template>
                                    </RiC:beginningDate>
                                </xsl:if>
                                <xsl:if
                                    test="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate">
                                    <RiC:endDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:cpfDescription/eac:description/eac:existDates/eac:dateRange/eac:toDate"
                                            />
                                        </xsl:call-template>
                                    </RiC:endDate>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                        <!-- activities of corporate bodies. The instance of the relation is generated below in the same file -->
                        <xsl:if test="$entType = 'corporateBody'">
                            <xsl:for-each
                                select="eac:cpfDescription/eac:description/eac:functions/eac:function[normalize-space(eac:term) != '']">
                                <RiC:agentIsSourceOfActivityRealizationRelation>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'activityRealizationRelation/', $theGoodRecId, substring-after(@xml:id, $theGoodRecId))"
                                        />
                                    </xsl:attribute>

                                </RiC:agentIsSourceOfActivityRealizationRelation>
                            </xsl:for-each>
                        </xsl:if>

                        <!-- occupations of persons. The instance of the relation is generated below in the same file -->
                        <xsl:if test="$entType = 'person'">
                            <xsl:for-each
                                select="eac:cpfDescription/eac:description/eac:occupations/eac:occupation[normalize-space(eac:term) != '']">
                                <RiC:personIsSourceOfOccupationRelation>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'occupationRelation/', $theGoodRecId, substring-after(@xml:id, $theGoodRecId))"
                                        />
                                    </xsl:attribute>
                                </RiC:personIsSourceOfOccupationRelation>

                            </xsl:for-each>
                        </xsl:if>
                        <!-- biogHist. To be enhanced (output some HTML code?)-->
                        <xsl:if
                            test="eac:cpfDescription/eac:description/eac:biogHist/*[not(self::eac:chronList) and normalize-space(.) != '']">
                            <RiC:history xml:lang="fr">
                                <xsl:for-each
                                    select="eac:cpfDescription/eac:description/eac:biogHist/*[not(self::eac:chronList) and normalize-space(.) != '']">
                                    <xsl:apply-templates/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </RiC:history>
                        </xsl:if>
                        <!-- structureOrGenealogy. To be enhanced also (output some HTML code?)-->
                        <xsl:if
                            test="eac:cpfDescription/eac:description/eac:structureOrGenealogy[normalize-space(.) != '']">
                            <RiC:noteOnStructureOrGenealogy xml:lang="fr">
                                <xsl:for-each
                                    select="eac:cpfDescription/eac:description/eac:structureOrGenealogy/*[normalize-space(.) != '']">
                                    <xsl:apply-templates/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </RiC:noteOnStructureOrGenealogy>
                        </xsl:if>

                        <!-- rules -->

                        <xsl:for-each
                            select="eac:cpfDescription/eac:description/descendant::eac:mandate/eac:descriptiveNote/eac:p[normalize-space(.)!='']">
                            <xsl:variable name="descNote" select="normalize-space(.)"/>
                            <xsl:choose>
                                <xsl:when
                                    test="starts-with($descNote, '- Arrêté') or starts-with($descNote, '- Circulaire') or starts-with($descNote, '- Code') or starts-with($descNote, '- Convention') or starts-with($descNote, '- Décision') or starts-with($descNote, '- Déclaration') or starts-with($descNote, '- Décret') or starts-with($descNote, '- Loi') or starts-with($descNote, '- Ordonnance') or starts-with($descNote, '- arrêté') or starts-with($descNote, '- circulaire') or starts-with($descNote, '- décret') or starts-with($descNote, '- instruction') or starts-with($descNote, '- loi') or starts-with($descNote, '- ordonnance') or starts-with($descNote, 'Acte') or starts-with($descNote, 'Arch. nat.') or starts-with($descNote, 'Archives nationales') or starts-with($descNote, 'Arrêté') or starts-with($descNote, 'Avenant') or starts-with($descNote, 'BB/10/') or starts-with($descNote, 'Circulaire') or starts-with($descNote, 'Code') or starts-with($descNote, 'Constitution') or starts-with($descNote, 'Convention') or starts-with($descNote, 'Créé') or starts-with($descNote, 'Décision') or starts-with($descNote, 'Déclaration') or starts-with($descNote, 'Décret') or starts-with($descNote, 'JORF') or starts-with($descNote, 'LOI') or starts-with($descNote, 'Lettre de provision') or starts-with($descNote, 'Lettres de provision') or starts-with($descNote, 'Loi') or starts-with($descNote, 'Ordonnance') or starts-with($descNote, 'Règlement') or starts-with($descNote, 'Statuts') or starts-with($descNote, 'V/1/') or starts-with($descNote, 'décret') or starts-with($descNote, 'loi') or starts-with($descNote, 'ordonnance') or starts-with($descNote, '- Arrêté')">
                                    <xsl:variable name="lab"
                                        select="
                                            if (starts-with($descNote, '- '))
                                            
                                            then
                                                (
                                                
                                                concat(upper-case(substring(normalize-space(substring-after($descNote, '- ')), 1, 1)), substring(normalize-space(substring-after($descNote, '- ')), 2))
                                                
                                                )
                                            else
                                                (
                                                concat(upper-case(substring(normalize-space($descNote), 1, 1)), substring(normalize-space($descNote), 2))
                                                
                                                )"/>
                                    <xsl:if test="$rules/rdf:Description[rdfs:label = $lab]">
                                        <RiC:isRegulatedBy>
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                  select="$rules/rdf:Description[rdfs:label = $lab]/@rdf:about"
                                                />
                                            </xsl:attribute>
                                        </RiC:isRegulatedBy>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!--<xsl:comment><xsl:text>descNote/p=</xsl:text>
                                               <xsl:value-of select="$descNote"/></xsl:comment>
                                    <xsl:comment>pas de rule RDF correspondant</xsl:comment>-->
                                    <RiC:ruleFollowed xml:lang="fr">

                                        <xsl:value-of select="$descNote"/>
                                    </RiC:ruleFollowed>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <!-- <place>
               <placeRole>Lieu de Paris</placeRole>
               <placeEntry localType="quartier" vocabularySource="d3nyvgkuxg-xwxqi5i0uhjf">place maubert (quartier)</placeEntry>
               <placeEntry localType="paroisse" vocabularySource="d3nyvovxws-1r3061wzh7bqc">saint-etienne-du-mont (paroisse)</placeEntry>
               <placeEntry localType="voie" vocabularySource="d3nzd77dba-b9msu4ebt9ur">saint-victor (rue)</placeEntry>
               <placeEntry localType="nomLieu">rue Saint-Victor, près la place Maubert</placeEntry>
            </place>-->
                        <!--  <place>
               <placeRole>Lieu général</placeRole>
               <placeEntry localType="nomLieu">Académie de Reims</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb5qjlg-4hc4majg8u11">Champagne-Ardenne (France , région administrative)</placeEntry>
               <dateRange>
                  <fromDate standardDate="2000-01-01">2000</fromDate>
                  <toDate standardDate="2003-12-31">2003</toDate>
               </dateRange>
               <descriptiveNote>
                  <p>Recteur.</p>
               </descriptiveNote>
            </place>-->
                        <!--  <places>
            <place>
               <placeRole>Lieu général</placeRole>
               <placeEntry localType="lieu" vocabularySource="d3ntxlgwk5-1es7xt1ruo381">Roumanie</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntj4pbuq-498z7fcmxfag">Sully-sur-Loire (Loiret)</placeEntry> !!!!
            </place>
         </places>-->
                        <!-- <place>
               <placeRole>Lieu général</placeRole>
               <placeEntry localType="lieu" vocabularySource="d3ntscvphu-vojho5qjnl9a">Chambéry (Savoie)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb7jsrh-vfhddufur92k">Deux-Sèvres (Poitou-Charentes , département)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb8hf4o-hghezh7crum4">Orne (Basse-Normandie , département)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb7lpqq-1mxfdar3kkm5j">Drôme (Rhône-Alpes , département)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb85kbl-a9i9f62vvrla">Loiret (Centre , département)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb8sizq-czuh14pqglgb">Seine-et-Oise (France , département , 1790-1968)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb74erw-zzvf2h1n9aip">Ardennes (Champagne-Ardenne , département)</placeEntry>
               <placeEntry localType="lieu" vocabularySource="d3ntb7ykjq-tck4tl4rnvai">Ille-et-Vilaine (Bretagne , département)</placeEntry>
            </place>-->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:description/eac:places/eac:place[normalize-space(.) != '']">
                            <xsl:variable name="role" select="eac:placeRole"/>
                            <xsl:variable name="nomLieu">
                                <xsl:choose>
                                    <xsl:when
                                        test="eac:placeEntry[@localType = 'nomLieu' and normalize-space(.) != '']">
                                        <xsl:value-of
                                            select="normalize-space(eac:placeEntry[@localType = 'nomLieu' and normalize-space(.) != ''])"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>rien</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$role = 'Lieu de Paris'">

                                    <xsl:choose>
                                        <!-- 1. If the place has no name -->
                                        <xsl:when test="$nomLieu = 'rien'">


                                            <xsl:choose>
                                                <!-- If it is related to one entry in the gazetter -->
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 1">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <!-- <rdf:Description>
                                                            <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#LocationRelation"/>
                                                            
                                                                
                                                                <rdfs:label xml:lang="fr">
                                                                    
                                                                    <xsl:value-of select="
                                                                        
                                                                        concat('Paris (France) -\- ', eac:placeEntry[@localType!='nomLieu'])
                                                                        
                                                                        
                                                                        
                                                                        "/>
                                                                    
                                                                    
                                                                </rdfs:label>
                                                            
                                                            <xsl:if test="eac:placeEntry[@localType!='nomLieu'][@vocabularySource]">
                                                                <xsl:if test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', eac:placeEntry[@localType!='nomLieu']/@vocabularySource))]">
                                                                    
                                                                <RiC:isWithin>
                                                                    <xsl:attribute name="rdf:resource">
                                                                        <xsl:value-of select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', eac:placeEntry[@localType!='nomLieu']/@vocabularySource))]/@rdf:about"/>
                                                                    </xsl:attribute>
                                                                </RiC:isWithin>
                                                                </xsl:if>
                                                            </xsl:if>
                                                            
                                                            
                                                            <xsl:if test="eac:descriptiveNote[normalize-space(eac:p)!='']">
                                                                <RiC:description xml:lang="fr">
                                                                    <xsl:value-of
                                                                        select="normalize-space(eac:descriptiveNote/eac:p)"
                                                                    />
                                                                </RiC:description>
                                                            </xsl:if>
                                                            <xsl:if test="eac:dateRange/eac:fromDate">
                                                                <RiC:beginningDate>
                                                                    <xsl:call-template name="outputDate">
                                                                        <xsl:with-param name="stdDate"
                                                                            select="eac:dateRange/eac:fromDate/@standardDate"/>
                                                                        <xsl:with-param name="date" select="eac:fromDate"/>
                                                                    </xsl:call-template>
                                                                    
                                                                    
                                                                </RiC:beginningDate>
                                                            </xsl:if>
                                                            <xsl:if test="eac:dateRange/eac:toDate">
                                                                <RiC:endDate>
                                                                    <xsl:call-template name="outputDate">
                                                                        <xsl:with-param name="stdDate"
                                                                            select="eac:dateRange/eac:toDate/@standardDate"/>
                                                                        <xsl:with-param name="date"
                                                                            select="eac:dateRange/eac:toDate"/>
                                                                    </xsl:call-template>
                                                                    
                                                                </RiC:endDate>
                                                            </xsl:if>
                                                        </rdf:Description>-->
                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                </xsl:when>
                                                <!-- if the place is related to 2 entries in the gazeteer: partially treated-->
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 2">

                                                  <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>

                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                  </xsl:for-each>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- 2. the place has no address -->
                                        <xsl:when
                                            test="$nomLieu = 'adresse indéterminée' or $nomLieu = 'indéterminée' or $nomLieu = 'indeterminée'">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="not(eac:placeEntry[@localType != 'nomLieu'])"> </xsl:when>
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu']) = 1">
                                                  <!-- the relation will be made to the gazetteer directly -->

                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:thingIsSourceOfRelationToPlace>


                                                </xsl:when>
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu']) = 2">
                                                  <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu']">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>

                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                  </xsl:for-each>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- 3. if the place has a name -->
                                        <xsl:otherwise>

                                            <xsl:choose>
                                                <!-- if it has no link to an entry in the gazetteer -->
                                                <xsl:when
                                                  test="not(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != ''])">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                </xsl:when>
                                                <!-- if linked to the gazetteer more than once-->
                                                <xsl:when
                                                  test="
                                                        count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) = 1 or (count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) &gt; 1 and not(contains(eac:placeEntry[@localType = 'nomLieu'], ','))
                                                        
                                                        )">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:when>


                                <xsl:otherwise>
                                    <!-- when role is not 'Lieu de Paris' - places elsewhere -->
                                    <xsl:choose>
                                        <!--1. the place has no name -->
                                        <xsl:when test="$nomLieu = 'rien'">

                                            <xsl:choose>
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 1">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>

                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                </xsl:when>
                                                <xsl:when
                                                  test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) &gt; 1">

                                                  <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']">
                                                  <RiC:thingIsSourceOfRelationToPlace>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>

                                                  </RiC:thingIsSourceOfRelationToPlace>
                                                  </xsl:for-each>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- 2. the place has a name -->
                                        <xsl:otherwise>

                                            <RiC:thingIsSourceOfRelationToPlace>
                                                <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"
                                                  />
                                                </xsl:attribute>
                                            </RiC:thingIsSourceOfRelationToPlace>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>

                        <!-- RELATIONS TO OTHER AGENTS. First, identity relations -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'identity']">
                            <!-- Should be checked and completed, specially for wikidata -->
                            <!-- http://data.bnf.fr/ark:/12148/cb11863993z
                            http://catalogue.bnf.fr/ark:/12148/cb11863993z/PUBLIC
                            http://catalogue.bnf.fr/ark:/12148/cb11863993z/PUBLIC
                            http://data.bnf.fr/ark:/12148/cb11863993z#foaf:Organization-->
                            <!-- http://catalogue.bnf.fr/ark:/12148/cb11904421w -->
                            <!-- http://data.bnf.fr/ark:/12148/cb11862469g-->
                            <xsl:variable name="lnk" select="normalize-space(@xlink:href)"/>
                            <owl:sameAs>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:choose>
                                        <xsl:when test="contains($lnk, 'bnf.fr')">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and contains($lnk, '/PUBLIC')">
                                                  <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                                                  <xsl:value-of
                                                  select="substring-before(substring-after($lnk, 'http://catalogue.bnf.fr/ark:/12148/'), '/PUBLIC')"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$RiCClass = 'CorporateBody'">
                                                  <xsl:text>#foaf:Organization</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="$RiCClass = 'Person'">
                                                  <xsl:text>#foaf:Person</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:when>
                                                <xsl:when
                                                  test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and not(contains($lnk, '/PUBLIC'))">
                                                  <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                                                  <xsl:value-of
                                                  select="substring-after($lnk, 'http://catalogue.bnf.fr/ark:/12148/')"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$RiCClass = 'CorporateBody'">
                                                  <xsl:text>#foaf:Organization</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="$RiCClass = 'Person'">
                                                  <xsl:text>#foaf:Person</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:when>
                                                <xsl:when
                                                  test="contains($lnk, 'http://data.bnf.fr/ark:/12148/')">
                                                  <xsl:value-of select="$lnk"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$RiCClass = 'CorporateBody'">
                                                  <xsl:text>#foaf:Organization</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="$RiCClass = 'Person'">
                                                  <xsl:text>#foaf:Person</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:when>

                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- links to Wikipedia -->
                                        <!-- exemple : http://fr.dbpedia.org/page/Henri_Labrouste, https://fr.wikipedia.org/wiki/Henri_Labrouste -->
                                        <xsl:when test="contains($lnk, 'wikipedia.org')">
                                            <xsl:text>http://fr.dbpedia.org/resource/</xsl:text>
                                            <xsl:value-of
                                                select="substring-after($lnk, 'https://fr.wikipedia.org/wiki/')"
                                            />
                                        </xsl:when>

                                        <xsl:otherwise>
                                            <xsl:value-of select="$lnk"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </owl:sameAs>
                        </xsl:for-each>
                        <!-- entityId (when it contains an  ISNI). Has to be checked, as since a few months the SIA has added a @localType attribute to entityId ; in this case, the content of the element may not begin by 'ISNI' -->


                        <xsl:if
                            test="eac:cpfDescription/eac:identity/eac:entityId[starts-with(normalize-space(.), 'ISNI')]">
                            <xsl:variable name="ISNIValue"
                                select="normalize-space(eac:cpfDescription/eac:identity/eac:entityId[starts-with(normalize-space(.), 'ISNI')])"/>
                            <xsl:variable name="ISNIId">
                                <xsl:choose>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI:')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI:'), ' ', '')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI :')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI :'), ' ', '')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI'), ' ', '')"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <!-- http://isni.org/isni/0000000121032683-->
                            <isni:ISNIAssigned>
                                <xsl:value-of select="$ISNIId"/>
                            </isni:ISNIAssigned>
                        </xsl:if>
                        <!-- RELATIONS TO OTHER AGENTS. Other relations -->
                        <!-- For now I will leve below the instructions that use the arcrole attribute. They are of no use for now but may be useful in the future ; they need to be checked and updated-->

                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isControlledBy')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'isControlledBy'"/>
                                <xsl:with-param name="arcToRelName" select="'agentControlledBy'"/>
                                <xsl:with-param name="toAncRelArcName" select="'controlOnAgent'"/>
                                <xsl:with-param name="relName" select="'AgentControlRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'agentControlHeldBy'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isAssociatedWithForItsControl')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType"
                                    select="'isAssociatedWithForItsControl'"/>
                                <xsl:with-param name="arcToRelName" select="'agentControlledBy'"/>
                                <xsl:with-param name="toAncRelArcName" select="'controlOnAgent'"/>
                                <xsl:with-param name="relName" select="'AgentControlRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'agentControlHeldBy'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'controls')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'controls'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'hasAgentControlRelation'"/>
                                <xsl:with-param name="toAncRelArcName" select="'agentControlHeldBy'"/>
                                <xsl:with-param name="relName" select="'AgentControlRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'controlOnAgent'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'hasMember')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'hasMember'"/>
                                <xsl:with-param name="arcToRelName" select="'groupHasMember'"/>
                                <xsl:with-param name="toAncRelArcName" select="'agentMembershipIn'"/>
                                <xsl:with-param name="relName" select="'AgentMembershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'hasAgentMember'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isMemberOf')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'isMemberOf'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentHasMembershipRelation'"/>
                                <xsl:with-param name="toAncRelArcName" select="'hasAgentMember'"/>
                                <xsl:with-param name="relName" select="'AgentMembershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'agentMembershipIn'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'hasEmployee')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'hasEmployee'"/>
                                <xsl:with-param name="arcToRelName" select="'groupHasMember'"/>
                                <xsl:with-param name="toAncRelArcName" select="'agentMembershipIn'"/>
                                <xsl:with-param name="relName" select="'AgentMembershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'hasAgentMember'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isEmployeeOf')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'isEmployeeOf'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentHasMembershipRelation'"/>
                                <xsl:with-param name="toAncRelArcName" select="'hasAgentMember'"/>
                                <xsl:with-param name="relName" select="'AgentMembershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'agentMembershipIn'"/>
                                <!-\- <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <!-\-  <xsl:with-param name="relFromDate"
                                        select="eac:dateRange/eac:fromDate/@standardDate"/>
                                    -\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>

                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!-\- <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isDirectorOf')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'isDirectorOf'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentHasLeadershipRelation'"/>
                                <xsl:with-param name="toAncRelArcName" select="'leadershipBy'"/>
                                <xsl:with-param name="relName" select="'AgentLeadershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'leadershipOn'"/>
                                <!-\-   <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <!-\-<xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>
                                    -\->
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isDirectedBy')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="srcRelType" select="'isDirectedBy'"/>
                                <xsl:with-param name="arcToRelName" select="'leadBy'"/>
                                <xsl:with-param name="toAncRelArcName" select="'leadershipOn'"/>
                                <xsl:with-param name="relName" select="'AgentLeadershipRelation'"/>
                                <xsl:with-param name="relSecondArcName" select="'leadershipBy'"/>
                                <!-\-   <xsl:with-param name="shortcutRelName" select="'controlledBy'"/>-\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <!-\-<xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>
                                    -\->
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>


                        </xsl:for-each>-->
                        <!--<xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[contains(@xlink:arcrole, 'isFunctionallyLinkedTo')]">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="srcRelType" select="'isFunctionallyLinkedTo'"/>
                                <xsl:with-param name="arcToRelName" select="'hasBusinessRelation'"/>
                                <xsl:with-param name="toAncRelArcName"
                                    select="'businessRelationWith'"/>
                                <xsl:with-param name="relName" select="'BusinessRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'businessRelationWith'"/>
                                <!-\-   <xsl:with-param name="shortcutRelName"
                                        select="'functionallyLinkedTo'"/>-\->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <!-\-      <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\->
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <xsl:with-param name="coll" select="$coll"/>
                            </xsl:call-template>

                        </xsl:for-each>-->
                        <!-- Family relations -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'family']">
                            <xsl:choose>
                                <!-- the ones between a person and a family : are in fact associative agent relations ...-->
                                <xsl:when
                                    test="contains(eac:relationEntry, 'famille') or contains(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part, 'famille')">
                                    <xsl:call-template name="outputObjectPropertyForRelation">
                                        <xsl:with-param name="link"
                                            select="
                                                if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                                then
                                                    ('non')
                                                else
                                                    (normalize-space(@xlink:href))
                                                "/>
                                        <xsl:with-param name="recId" select="$theGoodRecId"/>
                                        <xsl:with-param name="relEntry"
                                            select="normalize-space(eac:relationEntry)"/>
                                        <xsl:with-param name="srcRelType" select="'associative'"/>
                                        <xsl:with-param name="arcToRelName"
                                            select="'agentIsConnectedToAgentRelation'"/>
                                        <xsl:with-param name="toAncRelArcName"
                                            select="'agentRelationConnects'"/>
                                        <xsl:with-param name="relName" select="'AgentRelation'"/>
                                        <xsl:with-param name="uriRelName"
                                            >agentRelation</xsl:with-param>
                                        <xsl:with-param name="relSecondArcName"
                                            select="'agentRelationConnects'"/>
                                        <!-- <!-\\-    <xsl:with-param name="shortcutRelName" select="'predecessorOf'"/>-\\->-->
                                        <xsl:with-param name="relFromDate"
                                            select="
                                                if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:fromDate))
                                                
                                                "/>
                                        <xsl:with-param name="relToDate"
                                            select="
                                                
                                                if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:toDate))
                                                
                                                
                                                
                                                
                                                "/>
                                        <xsl:with-param name="relDate"
                                            select="
                                                if (eac:date/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:date/@standardDate))
                                                else
                                                    (normalize-space(eac:date))"> </xsl:with-param>
                                        <!--  <!-\\-  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-\\->
                                    <xsl:with-param name="coll" select="$coll"/>-->
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="outputObjectPropertyForRelation">
                                        <xsl:with-param name="link"
                                            select="
                                                if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                                then
                                                    ('non')
                                                else
                                                    (normalize-space(@xlink:href))
                                                "/>
                                        <xsl:with-param name="recId" select="$theGoodRecId"/>
                                        <xsl:with-param name="relEntry"
                                            select="normalize-space(eac:relationEntry)"/>
                                        <xsl:with-param name="srcRelType" select="'family'"/>
                                        <xsl:with-param name="arcToRelName"
                                            select="'personHasFamilyRelation'"/>
                                        <xsl:with-param name="toAncRelArcName"
                                            select="'familyRelationConnects'"/>
                                        <xsl:with-param name="relName" select="'FamilyRelation'"/>
                                        <xsl:with-param name="uriRelName"
                                            >familyRelation</xsl:with-param>
                                        <xsl:with-param name="relSecondArcName"
                                            select="'familyRelationConnects'"/>
                                        <!--   <xsl:with-param name="shortcutRelName"
                                        select="'functionallyLinkedTo'"/>-->
                                        <xsl:with-param name="relFromDate"
                                            select="
                                                if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:fromDate))
                                                
                                                "/>
                                        <xsl:with-param name="relToDate"
                                            select="
                                                
                                                if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:toDate))
                                                
                                                
                                                
                                                
                                                "/>
                                        <!--      <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                                        <xsl:with-param name="relDate"
                                            select="
                                                if (eac:date/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:date/@standardDate))
                                                else
                                                    (normalize-space(eac:date))"
                                        > </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <!-- temporal-earlier -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'temporal-earlier']">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="srcRelType" select="'temporal-earlier'"/>
                                <xsl:with-param name="relName" select="'AgentTemporalRelation'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentIsTargetOfAgentTemporalRelation'"/>
                                <xsl:with-param name="toAncRelArcName"
                                    select="'agentTemporalRelationHasTarget'"/>

                                <xsl:with-param name="relSecondArcName"
                                    select="'agentTemporalRelationHasSource'"/>
                                <!--  <xsl:with-param name="shortcutRelName" select="'successorOf'"/>-->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!--   <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>
-->
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- temporal-later-->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'temporal-later']">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="srcRelType" select="'temporal-later'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentIsSourceOfAgentTemporalRelation'"/>
                                <xsl:with-param name="toAncRelArcName"
                                    select="'agentTemporalRelationHasSource'"/>
                                <xsl:with-param name="relName" select="'AgentTemporalRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'agentTemporalRelationHasTarget'"/>
                                <!--  <xsl:with-param name="shortcutRelName" select="'successorOf'"/>-->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!--   <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>
-->
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- hierarchical-child -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'hierarchical-child']">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="srcRelType" select="'hierarchical-child'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentIsSourceOfHierarchicalRelation'"/>
                                <xsl:with-param name="toAncRelArcName"
                                    select="'agentHierarchicalRelationHasSource'"/>
                                <xsl:with-param name="relName" select="'AgentHierarchicalRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'agentHierarchicalRelationHasTarget'"/>
                                <!--    <xsl:with-param name="shortcutRelName" select="'predecessorOf'"/>-->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!--  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- hierarchical-parent -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'hierarchical-parent']">
                            <xsl:call-template name="outputObjectPropertyForRelation">
                                <xsl:with-param name="link"
                                    select="
                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                        then
                                            ('non')
                                        else
                                            (normalize-space(@xlink:href))
                                        "/>
                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                <xsl:with-param name="relEntry"
                                    select="normalize-space(eac:relationEntry)"/>
                                <xsl:with-param name="srcRelType" select="'hierarchical-parent'"/>
                                <xsl:with-param name="arcToRelName"
                                    select="'agentIsTargetOfHierarchicalRelation'"/>
                                <xsl:with-param name="toAncRelArcName"
                                    select="'agentHierarchicalRelationHasTarget'"/>
                                <xsl:with-param name="relName" select="'AgentHierarchicalRelation'"/>
                                <xsl:with-param name="relSecondArcName"
                                    select="'agentHierarchicalRelationHasSource'"/>
                                <!--    <xsl:with-param name="shortcutRelName" select="'predecessorOf'"/>-->
                                <xsl:with-param name="relFromDate"
                                    select="
                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:fromDate))
                                        
                                        "/>
                                <xsl:with-param name="relToDate"
                                    select="
                                        
                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                        else
                                            (normalize-space(eac:dateRange/eac:toDate))
                                        
                                        
                                        
                                        
                                        "/>
                                <xsl:with-param name="relDate"
                                    select="
                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                        then
                                            (normalize-space(eac:date/@standardDate))
                                        else
                                            (normalize-space(eac:date))"> </xsl:with-param>
                                <!--  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                            </xsl:call-template>
                        </xsl:for-each>
                        <!-- associative-->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'associative']">
                            <xsl:choose>
                                <xsl:when
                                    test="contains(eac:descriptiveNote/eac:p, 'isDirectorOf') or contains(eac:descriptiveNote/eac:p, 'isDirected')">
                                    <!-- leadership relations-->

                                    <xsl:choose>
                                        <xsl:when test="$entType = 'person'">
                                            <xsl:call-template
                                                name="outputObjectPropertyForRelation">
                                                <xsl:with-param name="link"
                                                  select="
                                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                                        then
                                                            ('non')
                                                        else
                                                            (normalize-space(@xlink:href))
                                                        "/>
                                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                                <xsl:with-param name="relEntry"
                                                  select="normalize-space(eac:relationEntry)"/>
                                                <xsl:with-param name="srcRelType"
                                                  select="'associative'"/>
                                                <xsl:with-param name="arcToRelName"
                                                  select="'personIsSourceOfLeadershipRelation'"/>
                                                <xsl:with-param name="toAncRelArcName"
                                                  select="'leadershipRelationHasSource'"/>
                                                <xsl:with-param name="relName"
                                                  select="'LeadershipRelation'"/>
                                                <xsl:with-param name="relSecondArcName"
                                                  select="'leadershipRelationHasTarget'"/>
                                                <!--    <xsl:with-param name="shortcutRelName" select="'predecessorOf'"/>-->
                                                <xsl:with-param name="relFromDate"
                                                  select="
                                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                        else
                                                            (normalize-space(eac:dateRange/eac:fromDate))
                                                        
                                                        "/>
                                                <xsl:with-param name="relToDate"
                                                  select="
                                                        
                                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                        else
                                                            (normalize-space(eac:dateRange/eac:toDate))
                                                        
                                                        
                                                        
                                                        
                                                        "/>
                                                <xsl:with-param name="relDate"
                                                  select="
                                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:date/@standardDate))
                                                        else
                                                            (normalize-space(eac:date))"> </xsl:with-param>
                                                <!--  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$entType = 'corporateBody'">
                                            <xsl:call-template
                                                name="outputObjectPropertyForRelation">
                                                <xsl:with-param name="link"
                                                  select="
                                                        if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                                        then
                                                            ('non')
                                                        else
                                                            (normalize-space(@xlink:href))
                                                        "/>
                                                <xsl:with-param name="recId" select="$theGoodRecId"/>
                                                <xsl:with-param name="relEntry"
                                                  select="normalize-space(eac:relationEntry)"/>
                                                <xsl:with-param name="srcRelType"
                                                  select="'associative'"/>
                                                <xsl:with-param name="arcToRelName"
                                                  select="'groupIsTargetOfLeadershipRelation'"/>
                                                <xsl:with-param name="toAncRelArcName"
                                                  select="'leadershipRelationHasTarget'"/>
                                                <xsl:with-param name="relName"
                                                  select="'LeadershipRelation'"/>
                                                <xsl:with-param name="relSecondArcName"
                                                  select="'leadershipRelationHasSource'"/>

                                                <xsl:with-param name="relFromDate"
                                                  select="
                                                        if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                        else
                                                            (normalize-space(eac:dateRange/eac:fromDate))
                                                        
                                                        "/>
                                                <xsl:with-param name="relToDate"
                                                  select="
                                                        
                                                        if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                        else
                                                            (normalize-space(eac:dateRange/eac:toDate))
                                                        
                                                        
                                                        
                                                        
                                                        "/>
                                                <xsl:with-param name="relDate"
                                                  select="
                                                        if (eac:date/@standardDate[normalize-space(.) != ''])
                                                        then
                                                            (normalize-space(eac:date/@standardDate))
                                                        else
                                                            (normalize-space(eac:date))"> </xsl:with-param>
                                                <!--  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                                            </xsl:call-template>
                                        </xsl:when>
                                    </xsl:choose>





                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="outputObjectPropertyForRelation">
                                        <xsl:with-param name="link"
                                            select="
                                                if (normalize-space(@xlink:href) = '' or not(@xlink:href))
                                                then
                                                    ('non')
                                                else
                                                    (normalize-space(@xlink:href))
                                                "/>
                                        <xsl:with-param name="recId" select="$theGoodRecId"/>
                                        <xsl:with-param name="relEntry"
                                            select="normalize-space(eac:relationEntry)"/>
                                        <xsl:with-param name="srcRelType" select="'associative'"/>
                                        <xsl:with-param name="arcToRelName"
                                            select="'agentIsConnectedToAgentRelation'"/>
                                        <xsl:with-param name="toAncRelArcName"
                                            select="'agentRelationConnects'"/>
                                        <xsl:with-param name="relName" select="'AgentRelation'"/>
                                        <xsl:with-param name="relSecondArcName"
                                            select="'agentRelationConnects'"/>
                                        <!--    <xsl:with-param name="shortcutRelName" select="'predecessorOf'"/>-->
                                        <xsl:with-param name="relFromDate"
                                            select="
                                                if (eac:dateRange/eac:fromDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:fromDate))
                                                
                                                "/>
                                        <xsl:with-param name="relToDate"
                                            select="
                                                
                                                if (eac:dateRange/eac:toDate/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                else
                                                    (normalize-space(eac:dateRange/eac:toDate))
                                                
                                                
                                                
                                                
                                                "/>
                                        <xsl:with-param name="relDate"
                                            select="
                                                if (eac:date/@standardDate[normalize-space(.) != ''])
                                                then
                                                    (normalize-space(eac:date/@standardDate))
                                                else
                                                    (normalize-space(eac:date))"> </xsl:with-param>
                                        <!--  <xsl:with-param name="relNote"
                                        select="normalize-space(eac:descriptiveNote/eac:p)"/>-->
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>





                        </xsl:for-each>
                        <!-- PROVENANCE relations : the instance of the target OriginationRelation is generated below, in the same file. the target record sets are generated before (step 7) -->
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType = 'creatorOf']">
                            <xsl:choose>
                                <xsl:when test="normalize-space(@xlink:href) != ''">
                                    <RiC:thingIsTargetOfOriginationRelation>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat($baseURL, 'originationRelation/', substring-after(@xml:id, 'relation_'))"
                                            />
                                        </xsl:attribute>
                                    </RiC:thingIsTargetOfOriginationRelation>
                                </xsl:when>
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>
                        <!-- the metadata of the authority record (control element) -->
                        <RiC:describedBy>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'description/', $theGoodRecId)"/>
                            </xsl:attribute>
                        </RiC:describedBy>
                    </rdf:Description>


                    <!-- now, we process the "secondary" resources -->
                    <!-- Relations to activities -->



                    <xsl:if test="$entType = 'corporateBody'">
                        <xsl:for-each
                            select="eac:cpfDescription/eac:description/eac:functions/eac:function[normalize-space(eac:term) != '']">
                            <rdf:Description>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of
                                        select="concat($baseURL, 'activityRealizationRelation/', $theGoodRecId, substring-after(@xml:id, $theGoodRecId))"
                                    />
                                </xsl:attribute>
                                <rdf:type
                                    rdf:resource="http://www.ica.org/standards/RiC/ontology#ActivityRealizationRelation"/>

                                <xsl:if test="eac:dateRange/eac:fromDate">
                                    <RiC:beginningDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:fromDate/@standardDate"/>
                                            <xsl:with-param name="date" select="eac:fromDate"/>
                                        </xsl:call-template>


                                    </RiC:beginningDate>
                                </xsl:if>
                                <xsl:if test="eac:dateRange/eac:toDate">
                                    <RiC:endDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:toDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:dateRange/eac:toDate"/>
                                        </xsl:call-template>

                                    </RiC:endDate>
                                </xsl:if>
                                <!--do we keep this? the inverse triple is already there <RiC:activityRealizationRelationHasSource>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$URI"/>
                                    </xsl:attribute>
                                </RiC:activityRealizationRelationHasSource>-->
                                <RiC:activityRealizationRelationHasTarget>
                                    <!-- a blank node here-->
                                    <rdf:Description>
                                        <rdf:type
                                            rdf:resource="http://www.ica.org/standards/RiC/ontology#Activity"/>
                                        <xsl:if
                                            test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                            <RiC:description xml:lang="fr">
                                                <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                />
                                            </RiC:description>
                                        </xsl:if>
                                        <xsl:if
                                            test="eac:term[normalize-space(@vocabularySource) != '']">
                                            <xsl:variable name="vocSource"
                                                select="eac:term/@vocabularySource"/>
                                            <RiC:hasActivityType>
                                                <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$activityTypes/rdf:Description[substring-after(@rdf:about, 'FRAN_RI_011-') = $vocSource]/@rdf:about"
                                                  />
                                                </xsl:attribute>
                                            </RiC:hasActivityType>
                                        </xsl:if>
                                    </rdf:Description>
                                </RiC:activityRealizationRelationHasTarget>
                            </rdf:Description>

                        </xsl:for-each>
                    </xsl:if>
                    <!-- the relations to occupations -->
                    <xsl:if test="$entType = 'person'">
                        <xsl:for-each
                            select="eac:cpfDescription/eac:description/eac:occupations/eac:occupation[normalize-space(eac:term) != '']">
                            <rdf:Description>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of
                                        select="concat($baseURL, 'occupationRelation/', $theGoodRecId, substring-after(@xml:id, $theGoodRecId))"
                                    />
                                </xsl:attribute>
                                <rdf:type
                                    rdf:resource="http://www.ica.org/standards/RiC/ontology#OccupationRelation"/>
                                <!-- <xsl:if test="eac:descriptiveNote[normalize-space(eac:p)!='']">
                                    <RiC:description xml:lang="fr">
                                        <xsl:value-of
                                            select="normalize-space(eac:descriptiveNote/eac:p)"
                                        />
                                    </RiC:description>
                                </xsl:if>-->
                                <xsl:if test="eac:dateRange/eac:fromDate">
                                    <RiC:beginningDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:fromDate/@standardDate"/>
                                            <xsl:with-param name="date" select="eac:fromDate"/>
                                        </xsl:call-template>


                                    </RiC:beginningDate>
                                </xsl:if>
                                <xsl:if test="eac:dateRange/eac:toDate">
                                    <RiC:endDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:toDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:dateRange/eac:toDate"/>
                                        </xsl:call-template>

                                    </RiC:endDate>
                                </xsl:if>
                                <!--do we keep this ? <RiC:occupationRelationHasSource>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$URI"/>
                                    </xsl:attribute>
                                </RiC:occupationRelationHasSource>-->
                                <RiC:occupationRelationHasTarget>
                                    <!-- blank node -->
                                    <rdf:Description>
                                        <rdf:type
                                            rdf:resource="http://www.ica.org/standards/RiC/ontology#Occupation"/>
                                        <xsl:if
                                            test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                            <RiC:description xml:lang="fr">
                                                <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                />
                                            </RiC:description>
                                        </xsl:if>
                                        <xsl:if
                                            test="eac:term[normalize-space(@vocabularySource) != '']">
                                            <xsl:variable name="vocSource"
                                                select="eac:term/@vocabularySource"/>
                                            <RiC:hasOccupationType>
                                                <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$occupationTypes/rdf:Description[substring-after(@rdf:about, 'FRAN_RI_010-') = $vocSource]/@rdf:about"
                                                  />
                                                </xsl:attribute>
                                            </RiC:hasOccupationType>
                                        </xsl:if>
                                    </rdf:Description>
                                </RiC:occupationRelationHasTarget>
                            </rdf:Description>

                        </xsl:for-each>
                    </xsl:if>
                    <!-- provenance relations -->
                    <xsl:for-each
                        select="eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType = 'creatorOf']">
                        <xsl:variable name="link">
                            <xsl:choose>
                                <xsl:when test="@xlink:href[normalize-space(.) != '']">
                                    <xsl:value-of select="normalize-space(@xlink:href)"/>
                                </xsl:when>
                                <xsl:otherwise>non</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$link != 'non'">
                                <rdf:Description>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat($baseURL, 'originationRelation/', substring-after(@xml:id, 'relation_'))"
                                        />
                                    </xsl:attribute>
                                    <rdf:type
                                        rdf:resource="http://www.ica.org/standards/RiC/ontology#OriginationRelation"/>
                                    <rdfs:label xml:lang="fr">Relation de provenance entre l'agent "
                                            <xsl:value-of
                                            select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"/>
                                        <xsl:text> et l'ensemble de documents "</xsl:text>
                                        <xsl:value-of select="normalize-space(eac:relationEntry)"/>
                                        <xsl:text>"</xsl:text>
                                    </rdfs:label>

                                    <RiC:originationRelationHasSource>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:choose>

                                                <xsl:when test="contains($link, '#')">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'recordSet/', substring-before($link, '#'), '-', substring-after($link, '#'))"
                                                  />
                                                </xsl:when>

                                                <xsl:otherwise>

                                                  <xsl:value-of
                                                  select="concat($baseURL, 'recordSet/', substring-after($link, 'FRAN_IR_'), '-top')"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                    </RiC:originationRelationHasSource>
                                    <!--do we keep this ? <RiC:originationRelationHasTarget>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of select="$URI"/>
                                        </xsl:attribute>
                                    </RiC:originationelationHasTarget>-->

                                </rdf:Description>
                            </xsl:when>
                        </xsl:choose>


                    </xsl:for-each>

                    <!-- relations to appellations (agent names) -->

                    <xsl:for-each
                        select="eac:cpfDescription/eac:identity/eac:nameEntry[normalize-space(.) != '']">
                        <xsl:variable name="theName"
                            select="
                                if (count(eac:part) = 1)
                                then
                                    (normalize-space(eac:part))
                                else
                                    (
                                    )"/>
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat($baseURL, 'relationToAppellation/', $theGoodRecId, '_', generate-id())"/>

                            </xsl:attribute>
                            <rdf:type
                                rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToAppellation"/>
                            <xsl:if test="eac:useDates/eac:dateRange/eac:fromDate">

                                <RiC:beginningDate>
                                    <!--<xsl:value-of
                                            select="eac:useDates/eac:dateRange/eac:fromDate"/>-->
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:useDates/eac:dateRange/eac:fromDate/@standardDate"/>
                                        <xsl:with-param name="date"
                                            select="eac:useDates/eac:dateRange/eac:fromDate"/>
                                    </xsl:call-template>

                                </RiC:beginningDate>
                            </xsl:if>
                            <xsl:if test="eac:useDates/eac:dateRange/eac:toDate">
                                <RiC:endDate>
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:useDates/eac:dateRange/eac:toDate/@standardDate"/>
                                        <xsl:with-param name="date"
                                            select="eac:useDates/eac:dateRange/eac:toDate"/>
                                    </xsl:call-template>


                                </RiC:endDate>

                            </xsl:if>
                            <RiC:certainty xml:lang="fr">certain</RiC:certainty>
                            <!--do we keep this ? <RiC:relationToAppellationHasSource>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$URI"/>
                                </xsl:attribute>
                            </RiC:relationToAppellationHasSource>-->
                            <RiC:relationToAppellationHasTarget>
                                <xsl:choose>
                                    <xsl:when
                                        test="$agent-names/rdf:Description[rdfs:label = $theName]">
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="$agent-names/rdf:Description[rdfs:label = $theName]/@rdf:about"
                                            />
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- <xsl:attribute name="xml:lang">fr</xsl:attribute>-->
                                        <xsl:comment>pas de nom trouvé dans le fichier des noms pour la valeur  <xsl:value-of select="normalize-space(eac:part)"/></xsl:comment>


                                    </xsl:otherwise>
                                </xsl:choose>




                            </RiC:relationToAppellationHasTarget>
                        </rdf:Description>

                    </xsl:for-each>


                    <!-- relations to legal statuses -->


                    <!--<xsl:for-each
                        select="eac:cpfDescription/eac:description/descendant::eac:legalStatus">
                        <xsl:variable name="lsName" select="normalize-space(eac:term)"/>


                        <!-\- <xsl:if test="$legalsts/skos:Concept[skos:prefLabel = $lsName]">-\->
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:text>http://piaaf.demo.logilab.fr/resource/FRAN_TypeRelation_</xsl:text>
                                <xsl:value-of select="$theGoodRecId"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="generate-id()"/>
                            </xsl:attribute>
                            <rdf:type
                                rdf:resource="http://www.ica.org/standards/RiC/ontology#TypeRelation"/>
                            <RiC:hasType>
                                <xsl:choose>
                                    <xsl:when
                                        test="$legalsts/skos:Concept[skos:prefLabel = $lsName]">
                                        <xsl:attribute name="rdf:resource">

                                            <xsl:value-of
                                                select="$legalsts/skos:Concept[skos:prefLabel = $lsName]/@rdf:about"/>




                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="xml:lang">fr</xsl:attribute>
                                        <xsl:value-of select="normalize-space(eac:term)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </RiC:hasType>
                            <RiC:categorizationOf>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$URI"/>
                                </xsl:attribute>
                            </RiC:categorizationOf>
                            <xsl:if test="eac:dateRange/eac:fromDate">
                                <RiC:beginningDate>
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:dateRange/eac:fromDate/@standardDate"/>
                                        <xsl:with-param name="date"
                                            select="eac:dateRange/eac:fromDate"/>
                                    </xsl:call-template>
                                    <!-\- <xsl:choose>
                                                
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=4">
                                                    <xsl:attribute name="rdf:datatype"> <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text></xsl:attribute>
                                                    
                                                </xsl:when>
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=7">
                                                    <xsl:attribute name="rdf:datatype">
                                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:when>
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=10">
                                                    <xsl:attribute name="rdf:datatype">
                                                        <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                            
                                            <xsl:value-of select="
                                                if (normalize-space(eac:dateRange/eac:fromDate/@standardDate)!='')
                                                then (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                else(
                                                if (normalize-space(eac:dateRange/eac:fromDate)!='')
                                                then (normalize-space(eac:dateRange/eac:fromDate))
                                                else()
                                                )
                                                "/>
                                            -\->

                                </RiC:beginningDate>
                            </xsl:if>
                            <xsl:if test="eac:dateRange/eac:toDate">

                                <RiC:endDate>
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:dateRange/eac:toDate/@standardDate"/>
                                        <xsl:with-param name="date"
                                            select="eac:dateRange/eac:toDate"/>
                                    </xsl:call-template>
                                    <!-\-   <xsl:choose>
                                                    
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=4">
                                                        <xsl:attribute name="rdf:datatype"> <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text></xsl:attribute>
                                                        
                                                    </xsl:when>
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=7">
                                                        <xsl:attribute name="rdf:datatype">
                                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                                        </xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=10">
                                                        <xsl:attribute name="rdf:datatype">
                                                            <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                                        </xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:otherwise/>
                                                </xsl:choose>
                                                
                                                <!-\\-  <RiC:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">-\\->
                                                <xsl:value-of select="
                                                    if (normalize-space(eac:dateRange/eac:toDate/@standardDate)!='')
                                                    then (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                    else(
                                                    if (normalize-space(eac:dateRange/eac:toDate)!='')
                                                    then (normalize-space(eac:dateRange/eac:toDate))
                                                    else()
                                                    )
                                                    "/>-\->
                                </RiC:endDate>
                            </xsl:if>
                            <xsl:if test="eac:descriptiveNote">
                                <RiC:description xml:lang="fr">
                                    <xsl:value-of select="eac:descriptiveNote"/>
                                </RiC:description>
                            </xsl:if>
                        </rdf:Description>
                        <!-\-</xsl:if>-\->

                    </xsl:for-each>-->

                    <!--<xsl:for-each
                        select="eac:cpfDescription/eac:description/eac:places/eac:place[normalize-space(eac:placeEntry) != '']">

                        <xsl:variable name="placeName">
                            <xsl:choose>
                                <xsl:when test="eac:placeRole = 'Siège social'">
                                    <xsl:choose>
                                        <xsl:when
                                            test="parent::eac:places/eac:place[eac:placeRole = 'Siège']">
                                            <xsl:value-of
                                                select="concat(normalize-space(parent::eac:places/eac:place[eac:placeRole = 'Siège']/eac:placeEntry), '. ', normalize-space(eac:placeEntry))"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="normalize-space(eac:placeEntry)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="normalize-space(eac:placeEntry)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="$an-places/rdf:Description[rdfs:label = $placeName]">

                            <rdf:Description>
                                <xsl:attribute name="rdf:about">
                                    <xsl:text>http://piaaf.demo.logilab.fr/resource/FRAN_LocationRelation_</xsl:text>
                                    <xsl:value-of select="$theGoodRecId"/>
                                    <xsl:text>_</xsl:text>
                                    <xsl:value-of select="generate-id()"/>
                                </xsl:attribute>
                                <rdf:type
                                    rdf:resource="http://www.ica.org/standards/RiC/ontology#LocationRelation"/>
                                <RiC:hasLocation>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$an-places/rdf:Description[rdfs:label = $placeName]/@rdf:about"
                                        />
                                    </xsl:attribute>
                                </RiC:hasLocation>
                                <RiC:locationOf>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$URI"/>
                                    </xsl:attribute>
                                </RiC:locationOf>
                                <xsl:if test="eac:dateRange/eac:fromDate">
                                    <RiC:beginningDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:fromDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:dateRange/eac:fromDate"/>
                                        </xsl:call-template>
                                        <!-\- <xsl:choose>
                                                
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=4">
                                                    <xsl:attribute name="rdf:datatype"> <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text></xsl:attribute>
                                                    
                                                </xsl:when>
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=7">
                                                    <xsl:attribute name="rdf:datatype">
                                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:when>
                                                <xsl:when test="string-length(eac:dateRange/eac:fromDate/@standardDate)=10">
                                                    <xsl:attribute name="rdf:datatype">
                                                        <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                            
                                            <xsl:value-of select="
                                                if (normalize-space(eac:dateRange/eac:fromDate/@standardDate)!='')
                                                then (normalize-space(eac:dateRange/eac:fromDate/@standardDate))
                                                else(
                                                if (normalize-space(eac:dateRange/eac:fromDate)!='')
                                                then (normalize-space(eac:dateRange/eac:fromDate))
                                                else()
                                                )
                                                "/>
                                            -\->

                                    </RiC:beginningDate>
                                </xsl:if>
                                <xsl:if test="eac:dateRange/eac:toDate">

                                    <RiC:endDate>
                                        <xsl:call-template name="outputDate">
                                            <xsl:with-param name="stdDate"
                                                select="eac:dateRange/eac:toDate/@standardDate"/>
                                            <xsl:with-param name="date"
                                                select="eac:dateRange/eac:toDate"/>
                                        </xsl:call-template>
                                        <!-\-   <xsl:choose>
                                                    
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=4">
                                                        <xsl:attribute name="rdf:datatype"> <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text></xsl:attribute>
                                                        
                                                    </xsl:when>
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=7">
                                                        <xsl:attribute name="rdf:datatype">
                                                            <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                                        </xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:when test="string-length(eac:dateRange/eac:toDate/@standardDate)=10">
                                                        <xsl:attribute name="rdf:datatype">
                                                            <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                                        </xsl:attribute>
                                                    </xsl:when>
                                                    <xsl:otherwise/>
                                                </xsl:choose>
                                                
                                                <!-\\-  <RiC:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">-\\->
                                                <xsl:value-of select="
                                                    if (normalize-space(eac:dateRange/eac:toDate/@standardDate)!='')
                                                    then (normalize-space(eac:dateRange/eac:toDate/@standardDate))
                                                    else(
                                                    if (normalize-space(eac:dateRange/eac:toDate)!='')
                                                    then (normalize-space(eac:dateRange/eac:toDate))
                                                    else()
                                                    )
                                                    "/>-\->
                                    </RiC:endDate>
                                </xsl:if>
                                <xsl:if test="eac:descriptiveNote[normalize-space() != '']">
                                    <RiC:description xml:lang="fr">
                                        <xsl:value-of select="eac:descriptiveNote"/>
                                    </RiC:description>
                                </xsl:if>
                            </rdf:Description>

                        </xsl:if>
                    </xsl:for-each>-->

                    <!-- relations to places -->



                    <xsl:for-each
                        select="eac:cpfDescription/eac:description/eac:places/eac:place[normalize-space(.) != '']">
                        <xsl:variable name="role" select="eac:placeRole"/>
                        <xsl:variable name="nomLieu">
                            <xsl:choose>
                                <xsl:when
                                    test="eac:placeEntry[@localType = 'nomLieu' and normalize-space(.) != '']">
                                    <xsl:value-of
                                        select="normalize-space(eac:placeEntry[@localType = 'nomLieu' and normalize-space(.) != ''])"
                                    />
                                </xsl:when>
                                <xsl:otherwise>rien</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:choose>
                            <xsl:when test="$role = 'Lieu de Paris'">

                                <xsl:choose>
                                    <!-- 1. If the place has no name -->
                                    <xsl:when test="$nomLieu = 'rien'">


                                        <xsl:choose>
                                            <!-- If it is related to one entry in the gazetter -->
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 1">

                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>
                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if
                                                  test="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != ''][@vocabularySource]">
                                                      <xsl:variable name="vocabSrc" select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']/@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                      select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>




                                                  <xsl:if
                                                  test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                                  <RiC:description xml:lang="fr">
                                                  <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                  />
                                                  </RiC:description>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:fromDate">
                                                  <RiC:beginningDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:fromDate/@standardDate"/>
                                                  <xsl:with-param name="date" select="eac:fromDate"
                                                  />
                                                  </xsl:call-template>


                                                  </RiC:beginningDate>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:toDate">
                                                  <RiC:endDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:toDate/@standardDate"/>
                                                  <xsl:with-param name="date"
                                                  select="eac:dateRange/eac:toDate"/>
                                                  </xsl:call-template>

                                                  </RiC:endDate>
                                                  </xsl:if>

                                                </rdf:Description>






                                            </xsl:when>
                                            <!-- if the place is related to 2 entries in the gazeteer: partially treated-->
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 2">

                                                <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']">
                                                  <!-- <xsl:value-of
                                                                    select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                                />-->
                                                  <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>
                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if test="@vocabularySource">
                                                      <xsl:variable name="vocabSrc" select="@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>






                                                  </rdf:Description>




                                                  </xsl:for-each>
                                                </xsl:if>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <!-- 2. the place has no address -->
                                    <xsl:when
                                        test="$nomLieu = 'adresse indéterminée' or $nomLieu = 'indéterminée' or $nomLieu = 'indeterminée'">
                                        <xsl:choose>
                                            <xsl:when
                                                test="not(eac:placeEntry[@localType != 'nomLieu'])"> </xsl:when>
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) = 1">


                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']/@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>
                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if
                                                  test="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != ''][@vocabularySource]">
                                                      <xsl:variable name="vocabSrc" select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']/@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                      select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>




                                                  <xsl:if
                                                  test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                                  <RiC:description xml:lang="fr">
                                                  <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                  />
                                                  </RiC:description>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:fromDate">
                                                  <RiC:beginningDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:fromDate/@standardDate"/>
                                                  <xsl:with-param name="date" select="eac:fromDate"
                                                  />
                                                  </xsl:call-template>


                                                  </RiC:beginningDate>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:toDate">
                                                  <RiC:endDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:toDate/@standardDate"/>
                                                  <xsl:with-param name="date"
                                                  select="eac:dateRange/eac:toDate"/>
                                                  </xsl:call-template>

                                                  </RiC:endDate>
                                                  </xsl:if>

                                                </rdf:Description>
                                            </xsl:when>
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 2">

                                                <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']">
                                                  <!-- <xsl:value-of
                                                                    select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                                />-->
                                                  <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>
                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if test="@vocabularySource">
                                                      <xsl:variable name="vocabSrc" select="@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                      select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>






                                                  </rdf:Description>




                                                  </xsl:for-each>
                                                </xsl:if>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <!-- 3. if the place has a name -->
                                    <xsl:otherwise>

                                        <xsl:choose>
                                            <!-- if it has no link to an entry in the gazetteer -->
                                            <xsl:when
                                                test="not(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != ''])">
                                                <!--   <RiC:thingIsSourceOfLocationRelation>
                                                    <xsl:attribute name="rdf:resource">
                                                        <xsl:value-of
                                                            select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"
                                                        />
                                                    </xsl:attribute>
                                                </RiC:thingIsSourceOfLocationRelation>-->

                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"/>

                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>


                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if
                                                  test="$FRAN-places-Paris/rdf:Description[rdfs:label = $nomLieu]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$FRAN-places-Paris/rdf:Description[rdfs:label = $nomLieu]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>

                                                  <xsl:if
                                                  test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                                  <RiC:description xml:lang="fr">
                                                  <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                  />
                                                  </RiC:description>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:fromDate">
                                                  <RiC:beginningDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:fromDate/@standardDate"/>
                                                  <xsl:with-param name="date" select="eac:fromDate"
                                                  />
                                                  </xsl:call-template>


                                                  </RiC:beginningDate>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:toDate">
                                                  <RiC:endDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:toDate/@standardDate"/>
                                                  <xsl:with-param name="date"
                                                  select="eac:dateRange/eac:toDate"/>
                                                  </xsl:call-template>

                                                  </RiC:endDate>
                                                  </xsl:if>
                                                </rdf:Description>



                                            </xsl:when>
                                            <!-- if linked to the gazetteer once or more-->
                                            <xsl:when
                                                test="
                                                    count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) = 1 or (count(eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']) &gt; 1 and not(contains(eac:placeEntry[@localType = 'nomLieu'], ','))
                                                    
                                                    )">


                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"/>

                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>

                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>


                                                  <xsl:if
                                                  test="$FRAN-places-Paris/rdf:Description[rdfs:label = $nomLieu]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$FRAN-places-Paris/rdf:Description[rdfs:label = $nomLieu]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>




                                                </rdf:Description>

                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:when>

                            <xsl:otherwise>
                                <!-- role='Lieu général'-->


                                <xsl:choose>
                                    <xsl:when test="$nomLieu = 'rien'">
                                        <!-- the place has no name -->
                                        <xsl:choose>
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) = 1">
                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationtoPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType != 'nomLieu']/@xml:id, $theGoodRecId))"/>

                                                  </xsl:attribute>

                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>

                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>
                                                  <xsl:if
                                                  test="eac:placeEntry[@localType != 'nomLieu']/@vocabularySource">
                                                      <xsl:variable name="vocabSrc" select="eac:placeEntry[@localType != 'nomLieu']/@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>



                                                  <xsl:if
                                                  test="eac:descriptiveNote[normalize-space(eac:p) != '']">
                                                  <RiC:description xml:lang="fr">
                                                  <xsl:value-of
                                                  select="normalize-space(eac:descriptiveNote/eac:p)"
                                                  />
                                                  </RiC:description>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:fromDate">
                                                  <RiC:beginningDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:fromDate/@standardDate"/>
                                                  <xsl:with-param name="date" select="eac:fromDate"
                                                  />
                                                  </xsl:call-template>


                                                  </RiC:beginningDate>
                                                  </xsl:if>
                                                  <xsl:if test="eac:dateRange/eac:toDate">
                                                  <RiC:endDate>
                                                  <xsl:call-template name="outputDate">
                                                  <xsl:with-param name="stdDate"
                                                  select="eac:dateRange/eac:toDate/@standardDate"/>
                                                  <xsl:with-param name="date"
                                                  select="eac:dateRange/eac:toDate"/>
                                                  </xsl:call-template>

                                                  </RiC:endDate>
                                                  </xsl:if>

                                                </rdf:Description>
                                            </xsl:when>
                                            <xsl:when
                                                test="count(eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']) &gt; 1">

                                                <xsl:if
                                                  test="not(eac:dateRange) and not(eac:descriptiveNote)">
                                                  <xsl:for-each
                                                  select="eac:placeEntry[@localType != 'nomLieu' and normalize-space() != '']">

                                                  <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(@xml:id, $theGoodRecId))"
                                                  />
                                                  </xsl:attribute>
                                                  <!--<rdf:Description>-->
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>


                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>

                                                  <xsl:if test="@vocabularySource">
                                                      <xsl:variable name="vocabSrc" select="@vocabularySource"/>
                                                  <xsl:if
                                                  test="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$collection-places-rdf/rdf:Description[ends-with(@rdf:about, concat('-', $vocabSrc))]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>
                                                  </xsl:if>




                                                  </rdf:Description>
                                                  </xsl:for-each>
                                                </xsl:if>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>

                                    <xsl:otherwise>


                                        <xsl:choose>
                                            <xsl:when
                                                test="eac:placeEntry[@localType != 'nomLieu' and normalize-space(.) != '']">


                                                <rdf:Description>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="concat($baseURL, 'relationToPlace/', $theGoodRecId, '-', substring-after(eac:placeEntry[@localType = 'nomLieu']/@xml:id, $theGoodRecId))"/>

                                                  </xsl:attribute>
                                                  <rdf:type
                                                  rdf:resource="http://www.ica.org/standards/RiC/ontology#RelationToPlace"/>

                                                  <rdfs:label xml:lang="fr">
                                                  <xsl:text>Relation de localisation concernant l'entité "</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(ancestor::eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part)"
                                                  />
                                                      <xsl:text>"</xsl:text>
                                                  </rdfs:label>

                                                  <xsl:if
                                                  test="$FRAN-places-general/rdf:Description[rdfs:label = $nomLieu]">

                                                  <RiC:relationToPlaceHasTarget>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="$FRAN-places-general/rdf:Description[rdfs:label = $nomLieu]/@rdf:about"
                                                  />
                                                  </xsl:attribute>
                                                  </RiC:relationToPlaceHasTarget>
                                                  </xsl:if>


                                                </rdf:Description>



                                            </xsl:when>

                                        </xsl:choose>



                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:for-each>




                    <rdf:Description>
                        <!-- control element, to be converted into an instance of the Description class -->
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat($baseURL, 'description/', $theGoodRecId)"/>
                        </xsl:attribute>

                        <rdf:type
                            rdf:resource="http://www.ica.org/standards/RiC/ontology#Description"/>
                        <RiC:describes>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$URI"/>
                            </xsl:attribute>
                        </RiC:describes>
                        <xsl:choose>
                            <xsl:when
                                test="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'created']">
                                <RiC:creationDate>
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime/@standardDateTime"/>
                                        <xsl:with-param name="date"
                                            select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'created']/eac:eventDateTime"
                                        />
                                    </xsl:call-template>

                                </RiC:creationDate>
                            </xsl:when>
                            <xsl:when
                                test="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'derived']">
                                <RiC:creationDate>
                                    <xsl:call-template name="outputDate">
                                        <xsl:with-param name="stdDate"
                                            select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime/@standardDateTime"/>
                                        <xsl:with-param name="date"
                                            select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'derived'][1]/eac:eventDateTime"
                                        />
                                    </xsl:call-template>

                                </RiC:creationDate>
                            </xsl:when>
                        </xsl:choose>


                        <xsl:if
                            test="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'updated']">
                            <RiC:lastUpdateDate>

                                <xsl:call-template name="outputDate">
                                    <xsl:with-param name="stdDate"
                                        select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'updated'][last()]/eac:eventDateTime/@standardDateTime"/>
                                    <xsl:with-param name="date"
                                        select="eac:control/eac:maintenanceHistory/eac:maintenanceEvent[eac:eventType = 'updated'][last()]/eac:eventDateTime"
                                    />
                                </xsl:call-template>


                            </RiC:lastUpdateDate>
                        </xsl:if>
                        <RiC:identifier>
                            <xsl:value-of select="eac:control/eac:recordId"/>
                        </RiC:identifier>

                        <RiC:authoredBy>
                            <!-- in RiC-O authoredBy has domain RecordResource. TO BE FIXED (may be by considering Description as a subclass of Record -->
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="concat($baseURL, 'corporateBody/005601')"/>
                            </xsl:attribute>
                        </RiC:authoredBy>

                        <xsl:for-each
                            select="eac:control/eac:sources/eac:source[normalize-space(eac:sourceEntry) != '']">
                            <RiC:source xml:lang="fr">
                                <xsl:value-of select="normalize-space(eac:sourceEntry)"/>
                                <xsl:if test="@xlink:href[normalize-space(.) != '']">
                                    <xsl:value-of
                                        select="concat(' (', normalize-space(@xlink:href), ')')"/>
                                </xsl:if>
                            </RiC:source>
                        </xsl:for-each>

                        <RiC:isRegulatedBy
                            rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl003"/>
                        <RiC:isRegulatedBy
                            rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl004"/>
                        <xsl:choose>
                            <xsl:when test="$entType = 'corporateBody' or $entType = 'family'">
                                <RiC:isRegulatedBy
                                    rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl001"
                                />
                            </xsl:when>
                            <xsl:when test="$entType = 'person'">
                                <RiC:isRegulatedBy
                                    rdf:resource="http://data.archives-nationales.culture.gouv.fr/rule/rl002"
                                />
                            </xsl:when>
                        </xsl:choose>
                        <!--  entityId (when it contains an  ISNI). Has to be checked, as since a few months the SIA has added a @localType attribute to entityId ; in this case, the content of the element may not begin by 'ISNI'. Another question is: since we already process ISNI for the agent, do we have to process it again there? -->

                        <xsl:if
                            test="eac:cpfDescription/eac:identity/eac:entityId[starts-with(normalize-space(.), 'ISNI')]">
                            <xsl:variable name="ISNIValue"
                                select="normalize-space(eac:cpfDescription/eac:identity/eac:entityId[starts-with(normalize-space(.), 'ISNI')])"/>
                            <xsl:variable name="ISNIId">
                                <xsl:choose>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI:')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI:'), ' ', '')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI :')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI :'), ' ', '')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="starts-with($ISNIValue, 'ISNI')">
                                        <xsl:value-of
                                            select="replace(substring-after($ISNIValue, 'ISNI'), ' ', '')"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <!-- http://isni.org/isni/0000000121032683-->
                            <rdfs:seeAlso>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="concat('http://isni.org/isni/', $ISNIId)"
                                    />
                                </xsl:attribute>
                            </rdfs:seeAlso>


                        </xsl:if>

                        <rdfs:seeAlso>
                            <xsl:attribute name="rdf:resource">
                                <!-- https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/-->
                                <xsl:value-of
                                    select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/', $recId)"
                                />
                            </xsl:attribute>
                        </rdfs:seeAlso>
                        <xsl:for-each
                            select="eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType = 'identity']">

                            <xsl:variable name="lnk" select="normalize-space(@xlink:href)"/>
                            <xsl:if test="$lnk != ''">
                                <rdfs:seeAlso>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:if test="contains($lnk, 'bnf.fr')">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and contains($lnk, '/PUBLIC')">
                                                  <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                                                  <xsl:value-of
                                                  select="substring-before(substring-after($lnk, '12148/'), '/PUBLIC')"/>

                                                </xsl:when>
                                                <xsl:when
                                                  test="contains($lnk, 'catalogue.bnf.fr/ark:/12148/') and not(contains($lnk, '/PUBLIC'))">
                                                  <xsl:text>http://data.bnf.fr/ark:/12148/</xsl:text>
                                                  <xsl:value-of
                                                  select="substring-after($lnk, '12148/')"/>

                                                </xsl:when>
                                                <xsl:when
                                                  test="contains($lnk, 'http://data.bnf.fr/ark:/12148/')">
                                                  <xsl:value-of select="$lnk"/>

                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>

                                        <!-- exemple : http://fr.dbpedia.org/page/Henri_Labrouste, https://fr.wikipedia.org/wiki/Henri_Labrouste -->
                                        <xsl:if test="contains($lnk, 'wikipedia.org')">

                                            <xsl:value-of select="$lnk"/>
                                        </xsl:if>

                                    </xsl:attribute>
                                </rdfs:seeAlso>
                            </xsl:if>
                        </xsl:for-each>
                    </rdf:Description>

                </rdf:RDF>
            </xsl:result-document>
        </xsl:for-each>







    </xsl:template>
    <xsl:template name="outputObjectPropertyForRelation">
        <xsl:param name="recId"/>
        <xsl:param name="link"/>
        <xsl:param name="relType"/>
        <xsl:param name="arcToRelName"/>
        <xsl:param name="relName"/>
        <xsl:param name="relSecondArcName"/>
        <xsl:param name="srcRelType"/>

        <xsl:param name="relFromDate"/>
        <xsl:param name="relToDate"/>
        <xsl:param name="relDate"/>

        <xsl:param name="relEntry"/>
        <xsl:param name="toAncRelArcName"/>
        <xsl:param name="uriRelName"/>
       
      
       <!-- <xsl:variable name="relFile">
            <xsl:choose>
                <xsl:when test="$relName = 'FamilyRelation'">
                    <xsl:value-of select="$fam-relations"/>
                </xsl:when>
                <xsl:when test="$relName = 'AgentRelation'">
                    <xsl:value-of select="$assoc-rels"/>
                </xsl:when>
                <xsl:when test="$relName = 'AgentTemporalRelation'">
                    <xsl:value-of select="$temp-rels"/>
                </xsl:when>
                <xsl:when test="$relName = 'AgentHierarchicalRelation'">
                    <xsl:value-of select="$hier-rels"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
-->


        <!-- several cases -->

        <xsl:choose>
            <!-- the case 1 : no target, just the name of the target entity. Within the SIA, this should never happen so we don't take it into account here-->
            <xsl:when test="$link != 'non'">

                <xsl:choose>
                    <!-- symmetric relations -->

                    <xsl:when test="$relName = 'FamilyRelation'">

                        <xsl:for-each
                            select="
                                $fam-relations/rdf:Description[RiC:familyRelationConnects[ends-with(@rdf:resource, concat('/', $recId))] and RiC:familyRelationConnects[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))]]">
                            <!--  <xsl:variable name="theTargetRel" select="."/>-->
                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>







                    </xsl:when>
                    <xsl:when test="$relName = 'AgentRelation'">

                        <xsl:for-each
                            select="
                                $assoc-rels/rdf:Description[RiC:agentRelationConnects[ends-with(@rdf:resource, concat('/', $recId))] and RiC:agentRelationConnects[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>





                        </xsl:for-each>







                    </xsl:when>



                    <!-- temporal relations -->

                    <xsl:when
                        test="$relName = 'AgentTemporalRelation' and $srcRelType = 'temporal-later'">
                        <!--  <xsl:comment>Pour l'instant le lien vers cette relation ne figure pas dans le fichier relatif à l'agent. Voir le fichier RDF des relations chronologiques où on trouvera l'information (la relation chronologique est représentée par une instance de la classe AgentTemporalRelation, qui est reliée aux deux agents concernés, dont celiu décrit dans ce fichier).</xsl:comment>-->
                        <xsl:for-each
                            select="
                                $temp-rels/rdf:Description[RiC:agentTemporalRelationHasTarget[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))] and RiC:agentTemporalRelationHasSource[ends-with(@rdf:resource, concat('/', $recId))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when
                        test="$relName = 'AgentTemporalRelation' and $srcRelType = 'temporal-earlier'">

                        <xsl:for-each
                            select="
                                $temp-rels/rdf:Description[RiC:agentTemporalRelationHasSource[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))] and RiC:agentTemporalRelationHasTarget[ends-with(@rdf:resource, concat('/', $recId))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>








                    </xsl:when>




                    <!-- hierarchical relations-->

                    <xsl:when
                        test="$relName = 'AgentHierarchicalRelation' and $srcRelType = 'hierarchical-parent'">

                        <xsl:for-each
                            select="
                                $hier-rels/rdf:Description[RiC:hierarchicalRelationHasSource[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))] and RiC:hierarchicalRelationHasTarget[ends-with(@rdf:resource, concat('/', $recId))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>







                    </xsl:when>
                    <xsl:when
                        test="$relName = 'AgentHierarchicalRelation' and $srcRelType = 'hierarchical-child'">

                        <xsl:for-each
                            select="
                                $hier-rels/rdf:Description[RiC:hierarchicalRelationHasSource[ends-with(@rdf:resource, concat('/', $recId))] and RiC:hierarchicalRelationHasTarget[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>







                    </xsl:when>
                    <!-- leadership relations-->
                    <xsl:when
                        test="$relName = 'LeadershipRelation' and $srcRelType = 'associative' and $arcToRelName = 'personIsSourceOfLeadershipRelation'">

                        <xsl:for-each
                            select="
                                $hier-rels/rdf:Description[RiC:leadershipRelationHasSource[ends-with(@rdf:resource, concat('/', $recId))] and RiC:leadershipRelationHasTarget[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>







                    </xsl:when>
                    <xsl:when
                        test="$relName = 'LeadershipRelation' and $srcRelType = 'associative' and $arcToRelName = 'groupIsTargetOfLeadershipRelation'">

                        <xsl:for-each
                            select="
                                $hier-rels/rdf:Description[RiC:leadershipRelationHasTarget[ends-with(@rdf:resource, concat('/', $recId))] and RiC:leadershipRelationHasSource[ends-with(@rdf:resource, concat('/', substring-after($link, 'FRAN_NP_')))]]">

                            <xsl:choose>
                                <xsl:when test="$relFromDate != '' and $relToDate = ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and not(RiC:endDate)">

                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate != ''">
                                    <xsl:if
                                        test="not(RiC:beginningDate) and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate != '' and $relToDate != ''">
                                    <xsl:if
                                        test="normalize-space(RiC:beginningDate) = $relFromDate and normalize-space(RiC:endDate) = $relToDate">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relFromDate = '' and $relToDate = ''">
                                    <xsl:if test="not(RiC:beginningDate) and not(RiC:endDate)">
                                        <xsl:element name="RiC:{$arcToRelName}">

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="@rdf:about"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$relDate != ''">
                                    <xsl:if test="normalize-space(RiC:date) = $relDate">
                                        <xsl:value-of select="@rdf:about"/>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise><xsl:comment>NO OUTPUT FOR $link=
            <xsl:value-of select="$link"/></xsl:comment></xsl:otherwise>
                            </xsl:choose>

                        </xsl:for-each>







                    </xsl:when>
                </xsl:choose>





            </xsl:when>
        </xsl:choose>



    </xsl:template>


    <xsl:template name="outputDate">
        <xsl:param name="date"/>
        <xsl:param name="stdDate"/>

        <xsl:choose>

            <xsl:when test="string-length($stdDate) = 4">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                </xsl:attribute>

            </xsl:when>
            <xsl:when test="string-length($stdDate) = 7">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="string-length($stdDate) = 10">
                <xsl:attribute name="rdf:datatype">
                    <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

        <xsl:value-of
            select="
                if (normalize-space($stdDate) != '')
                then
                    (normalize-space($stdDate))
                else
                    (
                    if (normalize-space($date) != '')
                    then
                        (normalize-space($date))
                    else
                        ()
                    )
                "/>




    </xsl:template>
</xsl:stylesheet>
