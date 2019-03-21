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
    exclude-result-prefixes="xs xd eac iso-thes rdf dct xl  xlink  skos isni foaf ginco dc an"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 4, 2017, checked and updated Dec. 8, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>

            <xd:p>Step 6 : generating RDF files for handling the relations between agents. These
                relations are n-ary ones (each one is an instance of a class defined in the RiC-O
                system of classes). </xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>
    <xsl:variable name="apos" select="'&#x2bc;'"/>


    <xsl:variable name="FRAN-positions"
        select="document('rdf/positions/FRAN_positions.rdf')/rdf:RDF"/>


    <!-- Step 1 : generates a list of the relations -->
    <xsl:variable name="ANAgentsRelList">

        <an:relations>

            <xsl:for-each
                select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:relations/eac:cpfRelation[@cpfRelationType != 'identity']">

                <an:rel type="{@cpfRelationType}" xml:id="{@xml:id}">

                    <an:fromAgent>
                        <xsl:value-of select="ancestor::eac:eac-cpf/eac:control/eac:recordId"/>
                    </an:fromAgent>
                    <an:fromAgentName>
                        <xsl:value-of
                            select="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'autorisée']/eac:part"
                        />
                    </an:fromAgentName>
                    <an:ancAgentType>
                        <xsl:value-of
                            select="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType"
                        />
                    </an:ancAgentType>
                    <xsl:if test="normalize-space(@xlink:href) != ''">
                        <an:targetEntity>

                            <xsl:value-of select="normalize-space(@xlink:href)"/>
                        </an:targetEntity>
                    </xsl:if>


                    <an:targetName>
                        <xsl:value-of select="normalize-space(eac:relationEntry)"/>
                    </an:targetName>

                    <xsl:if
                        test="eac:date[(@standardDate and normalize-space(@standardDate) != '') or normalize-space(.) != '']">
                        <an:date>

                            <xsl:choose>
                                <xsl:when test="eac:date[normalize-space(@standardDate) != '']">
                                    <xsl:attribute name="type">iso8601</xsl:attribute>
                                    <xsl:value-of select="normalize-space(eac:date/@standardDate)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="normalize-space(eac:date)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </an:date>
                    </xsl:if>
                    <xsl:if test="eac:dateRange">
                        <an:dateRange>
                            <xsl:if
                                test="eac:dateRange/eac:fromDate[@standardDate[normalize-space(.) != ''] or normalize-space(.) != '']">
                                <xsl:choose>
                                    <xsl:when
                                        test="eac:dateRange/eac:fromDate[normalize-space(@standardDate) != '']">
                                        <an:fromDate type="iso8601">
                                            <xsl:value-of
                                                select="eac:dateRange/eac:fromDate/@standardDate"/>
                                        </an:fromDate>
                                    </xsl:when>
                                    <xsl:when
                                        test="eac:dateRange/eac:fromDate[normalize-space(.) != '']">
                                        <an:fromDate>
                                            <xsl:value-of
                                                select="normalize-space(eac:dateRange/eac:fromDate)"
                                            />
                                        </an:fromDate>
                                    </xsl:when>
                                </xsl:choose>

                            </xsl:if>
                            <xsl:if
                                test="eac:dateRange/eac:toDate[@standardDate[normalize-space(.) != ''] or normalize-space(.) != '']">
                                <xsl:choose>
                                    <xsl:when
                                        test="eac:dateRange/eac:toDate[normalize-space(@standardDate) != '']">
                                        <an:toDate type="iso8601">
                                            <xsl:value-of
                                                select="eac:dateRange/eac:toDate/@standardDate"/>
                                        </an:toDate>
                                    </xsl:when>
                                    <xsl:when
                                        test="eac:dateRange/eac:toDate[normalize-space(.) != '']">
                                        <an:toDate>
                                            <xsl:value-of
                                                select="normalize-space(eac:dateRange/eac:toDate)"/>
                                        </an:toDate>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:if>
                        </an:dateRange>
                    </xsl:if>
                    <xsl:if test="eac:descriptiveNote[normalize-space(.) != '']">
                        <an:note>
                            <xsl:for-each
                                select="eac:descriptiveNote[normalize-space(.) != '']/eac:p[normalize-space(.) != '']">
                                <an:p>
                                    <xsl:copy-of select="node()"/>
                                </an:p>
                            </xsl:for-each>
                        </an:note>
                    </xsl:if>
                </an:rel>
            </xsl:for-each>
        </an:relations>

    </xsl:variable>

    <!-- steps 2  and 3: merge these relations -->
    <xsl:variable name="ANAgentsRelList_reduced">
        <an:relations>
            <xsl:for-each select="$ANAgentsRelList/an:relations/an:rel">
                <xsl:call-template name="mergeRelationsInFirstList">
                    <xsl:with-param name="anc" select="an:fromAgent"/>
                    <xsl:with-param name="targ" select="an:targetEntity"/>
                    <xsl:with-param name="tName" select="an:targetName"/>
                    <xsl:with-param name="date" select="an:date"/>
                    <xsl:with-param name="fdate" select="an:dateRange/an:fromDate"/>
                    <xsl:with-param name="tdate" select="an:dateRange/an:toDate"/>
                    <xsl:with-param name="note" select="an:note"/>

                    <xsl:with-param name="theRelId" select="@xml:id"/>
                </xsl:call-template>



            </xsl:for-each>
        </an:relations>
    </xsl:variable>



    <xsl:variable name="ANAgentsRelList_final">
        <an:relations>
            <xsl:for-each select="$ANAgentsRelList_reduced/an:relations/an:rel">
                <xsl:variable name="myId" select="@xml:id"/>
                <xsl:if test="not(preceding::an:rel[@xml:id = $myId])">
                    <an:rel>
                        <xsl:copy-of select="attribute::*"/>
                        <xsl:copy-of select="node()[not(self::an:note)]"/>
                        <xsl:choose>
                            <xsl:when test="an:note">
                                <an:note>
                                    <xsl:copy-of select="an:note/node()"/>
                                    <xsl:if
                                        test="$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel = $myId]">
                                        <an:p
                                            fromRel="{$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel=$myId]/@fromRel}">
                                            <xsl:copy-of
                                                select="$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel = $myId]/an:p/node()"
                                            />
                                        </an:p>
                                    </xsl:if>
                                </an:note>
                            </xsl:when>
                            <xsl:when test="not(an:note)">
                                <xsl:if
                                    test="$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel = $myId]">
                                    <an:note
                                        fromRel="{$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel=$myId]/@fromRel}">
                                        <xsl:copy-of
                                            select="$ANAgentsRelList_reduced/an:relations/an:specialNote[@toBeMovedToRel = $myId]/node()"
                                        />
                                    </an:note>

                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>

                    </an:rel>
                </xsl:if>
            </xsl:for-each>

        </an:relations>
    </xsl:variable>

    <xsl:template match="/vide">

      <!--  <xsl:result-document href="temp/ANAgentsRelTable.xml" indent="yes">

            <xsl:copy-of select="$ANAgentsRelList/*"/>

        </xsl:result-document>
        <xsl:result-document href="temp/ANAgentsRelTable_reduced.xml" indent="yes">
            <xsl:copy-of select="$ANAgentsRelList_reduced/*"/>
        </xsl:result-document>
        <xsl:result-document href="temp/ANAgentsRelTable_final.xml" indent="yes">
            <xsl:copy-of select="$ANAgentsRelList_final/*"/>
        </xsl:result-document>
-->
        <!-- the final output. See PIAAF project XSls for much more specific processing rules (using arcrole)-->

        <xsl:result-document href="rdf/relations/FRAN_familyRelations.rdf" method="xml"
            encoding="utf-8" indent="yes">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">




                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'family' and not(contains(an:fromAgentName, 'famille')) and not(contains(an:targetName, 'famille'))]">
                    <xsl:call-template name="output-relations-between-agents">

                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="'family'"/>
                    </xsl:call-template>

                </xsl:for-each>



            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document href="rdf/relations/FRAN_agentRelations.rdf" method="xml"
            encoding="utf-8" indent="yes">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">

                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'family' and (contains(an:fromAgentName, 'famille') or contains(an:targetName, 'famille'))]">
                    <xsl:call-template name="output-relations-between-agents">

                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="'associative'"/>
                    </xsl:call-template>
                </xsl:for-each>


                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'associative' and not(contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))]">
                    <xsl:call-template name="output-relations-between-agents">

                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="'associative'"/>
                    </xsl:call-template>

                </xsl:for-each>



            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document href="rdf/relations/FRAN_agentHierarchicalRelations.rdf" method="xml"
            encoding="utf-8" indent="yes">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">

                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'associative' and (contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))]">
                    <xsl:call-template name="output-relations-between-agents">
                        
                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="'associative'"/>
                    </xsl:call-template>
                    
                </xsl:for-each>


                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'hierarchical-child' or @type = 'hierarchical-parent']">
                    <xsl:call-template name="output-relations-between-agents">
                        <!--<xsl:with-param name="coll">FRAN</xsl:with-param>-->
                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="@type"/>

                    </xsl:call-template>

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document href="rdf/relations/FRAN_agentTemporalRelations.rdf" method="xml"
            encoding="utf-8" indent="yes">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">




                <xsl:for-each
                    select="$ANAgentsRelList_final/an:relations/an:rel[@type = 'temporal-earlier' or @type = 'temporal-later']">
                    <xsl:call-template name="output-relations-between-agents">
                        <!--<xsl:with-param name="coll">FRAN</xsl:with-param>-->
                        <xsl:with-param name="fromAgent" select="an:fromAgent"/>
                        <xsl:with-param name="fromAgentName" select="an:fromAgentName"/>
                        <xsl:with-param name="ancAgentType" select="an:ancAgentType"/>
                        <xsl:with-param name="tEntity" select="an:targetEntity"/>
                        <xsl:with-param name="tName" select="an:targetName"/>
                        <xsl:with-param name="relType" select="@type"/>

                    </xsl:call-template>

                </xsl:for-each>


            </rdf:RDF>
        </xsl:result-document>

    </xsl:template>

    <!-- template pour fusionner les relations qui doivent l'être -->
    <xsl:template name="mergeRelationsInFirstList">
        <xsl:param name="anc"/>
        <xsl:param name="date"/>
        <xsl:param name="fdate"/>
        <xsl:param name="tdate"/>
        <xsl:param name="note"/>
        <xsl:param name="tName"/>
        <xsl:param name="targ"/>
        <xsl:param name="theRelId"/>

        <xsl:choose>

            <xsl:when test="boolean($targ) = false()">

                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when
                test="boolean($targ) and not($collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId = $targ])">

                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="$collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId = $targ]">


                <!-- principle: if the relation is not symmetric, we keep only one of the two oriented relations that possibly exist in the list -->
                <xsl:choose>
                    <!-- we comment, and leave there, the first 'whens': in the future, if we use arcrole, they may be very useful -->
                    <!--  <xsl:when test="@arcrole = 'knows'">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="@arcrole = 'isAssociatedWithForItsControl'">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="@arcrole = 'isControlledBy'">
                        <xsl:copy-of select="."/>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'controls'">
                        <xsl:choose>
                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@arcrole = 'isControlledBy' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">
                                <xsl:variable name="theInvRel"
                                    select="parent::an:relations/an:rel[@arcrole = 'isControlledBy' and an:fromAgent = $targ and an:targetEntity = $anc]"/>

                                <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                <xsl:choose>
                                    <xsl:when test="boolean($date)">
                                        <xsl:if test="$theInvRel/an:date = $date">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) and boolean($tdate)">
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) and boolean($tdate) = false()">

                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) = false() and boolean($tdate)">
                                        <xsl:if
                                            test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when
                                        test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                        <xsl:choose>
                                            <xsl:when test="boolean($note)">
                                                <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                </xsl:if>
                                                <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                </xsl:if>
                                            </xsl:when>
                                            <xsl:when test="boolean($note) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'isDirectorOf'">
                        <xsl:copy-of select="."/>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'isDirectedBy'">
                        <xsl:choose>

                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@arcrole = 'isDirectorOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">
                                <xsl:for-each
                                    select="
                                        parent::an:relations/an:rel[@arcrole = 'isDirectorOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                        ">
                                    <xsl:variable name="theInvRel" select="."/>

                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                    <xsl:choose>
                                        <xsl:when test="boolean($date)">
                                            <xsl:if test="$theInvRel/an:date = $date">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="boolean($fdate) and boolean($tdate)">
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) and boolean($tdate) = false()">

                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) = false() and boolean($tdate)">
                                            <xsl:if
                                                test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:copy-of select="."/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>


                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'isPartOf'">
                        <xsl:copy-of select="."/>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'hasPart'">
                        <xsl:choose>
                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@arcrole = 'isPartOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">

                                <xsl:variable name="theInvRel"
                                    select="parent::an:relations/an:rel[@arcrole = 'isPartOf' and an:fromAgent = $targ and an:targetEntity = $anc]"/>

                                <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                <xsl:choose>
                                    <xsl:when test="boolean($date)">
                                        <xsl:if test="$theInvRel/an:date = $date">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) and boolean($tdate)">
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) and boolean($tdate) = false()">

                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="boolean($fdate) = false() and boolean($tdate)">
                                        <xsl:if
                                            test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:if
                                            test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                            <xsl:copy-of select="."/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when
                                        test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                        <xsl:choose>
                                            <xsl:when test="boolean($note)">
                                                <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                </xsl:if>
                                                <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                </xsl:if>
                                            </xsl:when>
                                            <xsl:when test="boolean($note) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>-->
                    <xsl:when test="@type = 'temporal-later'">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="@type = 'temporal-earlier'">
                        <xsl:choose>
                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@type = 'temporal-later' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">
                                <xsl:for-each
                                    select="parent::an:relations/an:rel[@type = 'temporal-later' and an:fromAgent = $targ and an:targetEntity = $anc]">





                                    <xsl:variable name="theInvRel" select="."/>
                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                    <xsl:call-template name="compareRels">
                                        <xsl:with-param name="anc" select="$anc"/>
                                        <xsl:with-param name="date" select="$date"/>
                                        <xsl:with-param name="fdate" select="$fdate"/>
                                        <xsl:with-param name="tdate" select="$tdate"/>
                                        <xsl:with-param name="note" select="$note"/>
                                        <xsl:with-param name="tName" select="$tName"/>
                                        <xsl:with-param name="targ" select="$targ"/>
                                        <xsl:with-param name="theRelId" select="$theRelId"/>
                                        <xsl:with-param name="theInvRel" select="$theInvRel"/>
                                        <xsl:with-param name="theInvRelId" select="$theInvRelId"/>
                                    </xsl:call-template>


                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!--<xsl:when test="@arcrole = 'isFunctionallyLinkedTo'">

                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::an:rel[@arcrole = 'isFunctionallyLinkedTo' and an:fromAgent = $targ and an:targetEntity = $anc] | preceding-sibling::an:rel[@arcrole = 'isFunctionallyLinkedTo' and an:fromAgent = $anc and an:targetEntity = $targ]">

                                <xsl:for-each
                                    select="preceding-sibling::an:rel[@type = 'isFunctionallyLinkedTo' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $targ and an:targetEntity = $anc] | preceding-sibling::an:rel[@type = 'isFunctionallyLinkedTo' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $anc and an:targetEntity = $targ]">


                                    <xsl:variable name="theInvRel" select="."/>

                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>
                                    <!-\-  <xsl:comment> voir relation </xsl:comment>
                                       <xsl:value-of select="$theInvRelId"/>-\->
                                    <xsl:choose>

                                        <xsl:when test="boolean($date)">
                                            <xsl:if test="$theInvRel/an:date = $date">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="boolean($fdate) and boolean($tdate)">
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) and boolean($tdate) = false()">

                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) = false() and boolean($tdate)">
                                            <xsl:if
                                                test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:copy-of select="."/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>-->
                    <xsl:when test="@type = 'family'">
                        <!-- this is a symmetric relation; we look 'before' the relation that is being processed -->
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::an:rel[@type = 'family' and an:fromAgent = $targ and an:targetEntity = $anc]">
                                <xsl:for-each
                                    select="preceding-sibling::an:rel[@type = 'family' and an:fromAgent = $targ and an:targetEntity = $anc]">
                                    <xsl:variable name="theInvRel" select="."/>


                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>
                                    <xsl:call-template name="compareRels">
                                        <xsl:with-param name="anc" select="$anc"/>
                                        <xsl:with-param name="date" select="$date"/>
                                        <xsl:with-param name="fdate" select="$fdate"/>
                                        <xsl:with-param name="tdate" select="$tdate"/>
                                        <xsl:with-param name="note" select="$note"/>
                                        <xsl:with-param name="tName" select="$tName"/>
                                        <xsl:with-param name="targ" select="$targ"/>
                                        <xsl:with-param name="theRelId" select="$theRelId"/>
                                        <xsl:with-param name="theInvRel" select="$theInvRel"/>
                                        <xsl:with-param name="theInvRelId" select="$theInvRelId"/>
                                    </xsl:call-template>
                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!--<xsl:when test="@arcrole = 'isMemberOf'">
                        <xsl:copy-of select="."/>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'hasMember'">
                        <xsl:choose>

                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@arcrole = 'isMemberOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">
                                <xsl:for-each
                                    select="
                                        parent::an:relations/an:rel[@arcrole = 'isMemberOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                        ">
                                    <xsl:variable name="theInvRel" select="."/>

                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                    <xsl:choose>
                                        <xsl:when test="boolean($date)">
                                            <xsl:if test="$theInvRel/an:date = $date">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="boolean($fdate) and boolean($tdate)">
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) and boolean($tdate) = false()">

                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) = false() and boolean($tdate)">
                                            <xsl:if
                                                test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:copy-of select="."/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>


                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'isEmployeeOf'">
                        <xsl:copy-of select="."/>
                    </xsl:when>-->
                    <!--<xsl:when test="@arcrole = 'hasEmployee'">
                        <xsl:choose>

                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@arcrole = 'isEmployeeOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">
                                <xsl:for-each
                                    select="
                                        parent::an:relations/an:rel[@arcrole = 'isEmployeeOf' and an:fromAgent = $targ and an:targetEntity = $anc]
                                        ">
                                    <xsl:variable name="theInvRel" select="."/>

                                    <xsl:variable select="$theInvRel/@xml:id" name="theInvRelId"/>

                                    <xsl:choose>
                                        <xsl:when test="boolean($date)">
                                            <xsl:if test="$theInvRel/an:date = $date">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRelId"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="boolean($fdate) and boolean($tdate)">
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) and boolean($tdate) = false()">

                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="boolean($fdate) = false() and boolean($tdate)">
                                            <xsl:if
                                                test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                                                <xsl:choose>
                                                  <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>
                                                  <an:specialNote>
                                                  <xsl:attribute name="fromRel">
                                                  <xsl:value-of select="@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="toBeMovedToRel">
                                                  <xsl:value-of select="$theInvRel/@xml:id"/>
                                                  </xsl:attribute>
                                                  <xsl:copy-of select="$note/node()"/>
                                                  </an:specialNote>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:when test="boolean($note) = false()">
                                                  <xsl:if test="not($theInvRel/an:note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if test="$theInvRel/an:note">

                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:if
                                                test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                                                <xsl:copy-of select="."/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                                            <xsl:choose>
                                                <xsl:when test="boolean($note)">
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                                  <an:removedRel relId="{$theRelId}"/>
                                                  </xsl:if>
                                                  <xsl:if
                                                  test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                                  <xsl:comment>notes différentes</xsl:comment>

                                                  <xsl:copy-of select="."/>
                                                  </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="boolean($note) = false()">
                                                  <xsl:copy-of select="."/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>


                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:when>-->
                    <xsl:when test="@type = 'associative' and (not(@arcrole) or @arcrole = '')">
                        <!-- this is a symmetric relation; we look 'before' the relation that is being processed -->
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::an:rel[@type = 'associative' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $targ and an:targetEntity = $anc]">
                                <xsl:for-each
                                    select="preceding-sibling::an:rel[@type = 'associative' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $targ and an:targetEntity = $anc]">
                                    <xsl:variable name="theInvRel" select="."/>
                                    <xsl:variable name="theInvRelId" select="$theInvRel/@xml:id"/>
                                    <xsl:call-template name="compareRels">
                                        <xsl:with-param name="anc" select="$anc"/>
                                        <xsl:with-param name="date" select="$date"/>
                                        <xsl:with-param name="fdate" select="$fdate"/>
                                        <xsl:with-param name="tdate" select="$tdate"/>
                                        <xsl:with-param name="note" select="$note"/>
                                        <xsl:with-param name="tName" select="$tName"/>
                                        <xsl:with-param name="targ" select="$targ"/>
                                        <xsl:with-param name="theRelId" select="$theRelId"/>
                                        <xsl:with-param name="theInvRel" select="$theInvRel"/>
                                        <xsl:with-param name="theInvRelId" select="$theInvRelId"/>
                                    </xsl:call-template>

                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:when>
                    <xsl:when
                        test="@type = 'hierarchical-parent' and (not(@arcrole) or @arcrole = '')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when
                        test="@type = 'hierarchical-child' and (not(@arcrole) or @arcrole = '')">
                        <xsl:choose>
                            <xsl:when
                                test="
                                    parent::an:relations/an:rel[@type = 'hierarchical-parent' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $targ and an:targetEntity = $anc]
                                    ">

                                <xsl:for-each
                                    select="parent::an:relations/an:rel[@type = 'hierarchical-parent' and (not(@arcrole) or @arcrole = '') and an:fromAgent = $targ and an:targetEntity = $anc]">
                                    <xsl:variable name="theInvRel" select="."/>
                                    <xsl:variable name="theInvRelId" select="$theInvRel/@xml:id"/>



                                    <xsl:call-template name="compareRels">
                                        <xsl:with-param name="anc" select="$anc"/>
                                        <xsl:with-param name="date" select="$date"/>
                                        <xsl:with-param name="fdate" select="$fdate"/>
                                        <xsl:with-param name="tdate" select="$tdate"/>
                                        <xsl:with-param name="note" select="$note"/>
                                        <xsl:with-param name="tName" select="$tName"/>
                                        <xsl:with-param name="targ" select="$targ"/>
                                        <xsl:with-param name="theRelId" select="$theRelId"/>
                                        <xsl:with-param name="theInvRel" select="$theInvRel"/>
                                        <xsl:with-param name="theInvRelId" select="$theInvRelId"/>
                                    </xsl:call-template>

                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

        </xsl:choose>
    </xsl:template>

    <xsl:template name="compareRels">
        <xsl:param name="theRelId"/>
        <xsl:param name="theInvRel"/>
        <xsl:param name="theInvRelId"/>
        <xsl:param name="anc"/>
        <xsl:param name="date"/>
        <xsl:param name="fdate"/>
        <xsl:param name="tdate"/>
        <xsl:param name="note"/>
        <xsl:param name="tName"/>
        <xsl:param name="targ"/>

        <xsl:choose>
            <xsl:when test="boolean($date)">
                <xsl:if test="$theInvRel/an:date = $date">
                    <xsl:choose>
                        <xsl:when test="boolean($note)">
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                <xsl:comment>notes différentes</xsl:comment>
                                <an:specialNote>
                                    <xsl:attribute name="fromRel">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="toBeMovedToRel">
                                        <xsl:value-of select="$theInvRelId"/>
                                    </xsl:attribute>
                                    <xsl:copy-of select="$note/node()"/>
                                </an:specialNote>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="boolean($note) = false()">
                            <xsl:if test="not($theInvRel/an:note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if test="$theInvRel/an:note">

                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="$theInvRel/an:date != $date or boolean($theInvRel/an:date) = false()">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="boolean($fdate) and boolean($tdate)">
                <xsl:if
                    test="$theInvRel/an:dateRange/an:fromDate = $fdate and $theInvRel/an:dateRange/an:toDate = $tdate">
                    <xsl:choose>
                        <xsl:when test="boolean($note)">
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                <xsl:comment>notes différentes</xsl:comment>
                                <an:specialNote>
                                    <xsl:attribute name="fromRel">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="toBeMovedToRel">
                                        <xsl:value-of select="$theInvRel/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:copy-of select="$note/node()"/>
                                </an:specialNote>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="boolean($note) = false()">
                            <xsl:if test="not($theInvRel/an:note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if test="$theInvRel/an:note">

                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if
                    test="$theInvRel/an:dateRange/an:fromDate != $fdate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="boolean($fdate) and boolean($tdate) = false()">

                <xsl:if
                    test="$theInvRel/an:dateRange/an:fromDate = $fdate and not($theInvRel/an:dateRange/an:toDate)">
                    <xsl:choose>
                        <xsl:when test="boolean($note)">
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                <xsl:comment>notes différentes</xsl:comment>
                                <an:specialNote>
                                    <xsl:attribute name="fromRel">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="toBeMovedToRel">
                                        <xsl:value-of select="$theInvRel/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:copy-of select="$note/node()"/>
                                </an:specialNote>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="boolean($note) = false()">
                            <xsl:if test="not($theInvRel/an:note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if test="$theInvRel/an:note">

                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if
                    test="$theInvRel/an:dateRange/an:fromDate != $fdate or boolean($theInvRel/an:dateRange/an:fromDate) = false() or $theInvRel/an:dateRange/an:toDate">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="boolean($fdate) = false() and boolean($tdate)">
                <xsl:if
                    test="not($theInvRel/an:dateRange/an:fromDate) and $theInvRel/an:dateRange/an:toDate = $tdate">
                    <xsl:choose>
                        <xsl:when test="boolean($note)">
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if
                                test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                                <xsl:comment>notes différentes</xsl:comment>
                                <an:specialNote>
                                    <xsl:attribute name="fromRel">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="toBeMovedToRel">
                                        <xsl:value-of select="$theInvRel/@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:copy-of select="$note/node()"/>
                                </an:specialNote>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="boolean($note) = false()">
                            <xsl:if test="not($theInvRel/an:note)">
                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                            <xsl:if test="$theInvRel/an:note">

                                <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:if
                    test="$theInvRel/an:dateRange/an:fromDate or $theInvRel/an:dateRange/an:toDate != $tdate or boolean($theInvRel/an:dateRange/an:toDate) = false()">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:when>
            <xsl:when
                test="(boolean($fdate) = false() and boolean($tdate) = false()) or boolean($date) = false()">
                <xsl:choose>
                    <xsl:when test="boolean($note)">
                        <xsl:if test="normalize-space($theInvRel/an:note) = normalize-space($note)">
                            <an:removedRel relId="{$theRelId}" sameAs="{$theInvRelId}"/>
                        </xsl:if>
                        <xsl:if test="normalize-space($theInvRel/an:note) != normalize-space($note)">
                            <xsl:comment>notes différentes</xsl:comment>

                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="boolean($note) = false()">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>


    </xsl:template>



    <xsl:template name="output-relations-between-agents">
        <xsl:param name="tName"/>
        <xsl:param name="fromAgent"/>
        <xsl:param name="fromAgentName"/>
        <xsl:param name="ancAgentType"/>
        <!-- <xsl:param name="coll"/>-->
        <xsl:param name="tEntity"/>
        <xsl:param name="relType"/>
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$baseURL"/>
                <xsl:choose>
                    <xsl:when test="$relType = 'family'">
                        <xsl:text>familyRelation/</xsl:text>
                    </xsl:when>
                    <xsl:when test="$relType = 'temporal-earlier' or $relType = 'temporal-later'">
                        <xsl:text>agentTemporalRelation/</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="$relType = 'hierarchical-child' or $relType = 'hierarchical-parent'">
                        <xsl:text>agentHierarchicalRelation/</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="$relType = 'associative' and (contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))"
                        >leadershipRelation</xsl:when>
                    <xsl:when test="$relType = 'associative' and not(contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))">
                        <xsl:text>agentRelation/</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="substring-after(@xml:id, 'relation_')"/>


            </xsl:attribute>
            <rdf:type>
                <xsl:attribute name="rdf:resource">
                    <xsl:text>http://www.ica.org/standards/RiC/ontology#</xsl:text>
                    <xsl:choose>
                        <!-- <xsl:when test="@arcrole = 'isFunctionallyLinkedTo'"
                            >BusinessRelation</xsl:when>
                        <xsl:when test="@arcrole = 'isControlledBy' or @arcrole = 'controls'"
                            >AgentControlRelation</xsl:when>
                        <xsl:when test="@arcrole = 'hasPart'">AgentWholePartRelation</xsl:when>
                        <xsl:when test="@arcrole = 'isPartOf'">AgentWholePartRelation</xsl:when>-->
                        <xsl:when test="@type = 'temporal-earlier' or @type = 'temporal-later'"
                            >AgentTemporalRelation</xsl:when>
                        <!-- <xsl:when test="@arcrole = 'isDirectorOf' or @arcrole = 'isDirectedBy'"
                            >AgentLeadershipRelation</xsl:when>
                        <xsl:when test="@arcrole = 'knows'">SocialRelation</xsl:when>
                        <xsl:when test="@arcrole = 'isMemberOf'">AgentMembershipRelation</xsl:when>
                        <xsl:when test="@arcrole = 'hasMember'">AgentMembershipRelation</xsl:when>
                        <xsl:when test="@arcrole = 'hasEmployee'">AgentMembershipRelation</xsl:when>
                        <xsl:when test="@arcrole = 'isEmployeeOf'"
                            >AgentMembershipRelation</xsl:when>
                        <xsl:when test="@arcrole = 'isAssociatedWithForItsControl'"
                            >AgentControlRelation</xsl:when>-\->-->
                        <xsl:when test="$relType = 'family'">FamilyRelation</xsl:when>
                        <xsl:when
                            test="$relType = 'associative' and (contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))"
                            >LeadershipRelation</xsl:when>
                        <xsl:when
                            test="$relType = 'associative' and (not(@arcrole) or @arcrole = '')"
                            >AgentRelation</xsl:when>
                        <xsl:when
                            test="@type = 'hierarchical-parent' and (not(@arcrole) or @arcrole = '')">
                            <!-- nombreux cas a priori pour les AN et le SIAF au moins -->
                            <xsl:text>AgentHierarchicalRelation</xsl:text>
                        </xsl:when>
                        <xsl:when
                            test="@type = 'hierarchical-child' and (not(@arcrole) or @arcrole = '')">
                            <!-- nombreux cas a priori pour les AN et le SIAF au moins -->
                            <xsl:text>AgentHierarchicalRelation</xsl:text>
                        </xsl:when>
                    </xsl:choose>

                </xsl:attribute>
            </rdf:type>
            <rdfs:label xml:lang="fr">
                <xsl:choose>
                    <!-- <xsl:when test="@arcrole = 'isFunctionallyLinkedTo'">Relation fonctionnelle de
                        travail entre</xsl:when>
                    <xsl:when
                        test="@arcrole = 'isControlledBy' or @arcrole = 'controls' or @arcrole = 'isAssociatedWithForItsControl'"
                        >Relation de contrôle ou de tutelle entre</xsl:when>
                    <xsl:when test="@arcrole = 'hasPart'">Relation du tout à une partie
                        entre</xsl:when>
                    <xsl:when test="@arcrole = 'isPartOf'">Relation du tout à une partie
                        entre</xsl:when>-->
                    <xsl:when test="@type = 'temporal-earlier' or @type = 'temporal-later'">Relation
                        chronologique entre</xsl:when>
                    <!--<xsl:when test="@arcrole = 'isDirectorOf' or @arcrole = 'isDirectedBy'">Relation
                        de "leadership" ou de direction entre</xsl:when>
                    <xsl:when
                        test="@arcrole = 'isMemberOf' or @arcrole = 'hasMember' or @arcrole = 'isEmployeeOf' or @arcrole = 'hasEmployee'"
                        >Relation d'affiliation, ou de salarié à employeur, entre</xsl:when>-->
                    <xsl:when test="$relType = 'family'">Relation familiale entre</xsl:when>
                    <xsl:when
                        test="$relType = 'associative' and (contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected'))"
                        > Relation de 'leadership" ou de direction entre </xsl:when>
                    <xsl:when
                        test="($relType = 'associative' and (not(@arcrole) or @arcrole = '')) or @arcrole = 'knows'">
                        <xsl:choose>
                            <xsl:when
                                test="contains($fromAgentName, 'famille') or contains($tEntity, 'famille')">
                                <xsl:text>Relation familiale entre</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Relation sociale entre</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:when>
                    <xsl:when
                        test="@type = 'hierarchical-parent' and (not(@arcrole) or @arcrole = '')">
                        <!-- nombreux cas a priori pour les AN et le SIAF au moins -->
                        <xsl:text>Relation hiérarchique entre</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="@type = 'hierarchical-child' and (not(@arcrole) or @arcrole = '')">
                        <!-- nombreux cas a priori pour les AN et le SIAF au moins -->
                        <xsl:text>Relation hiérarchique entre</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:text> les agents "</xsl:text>

                <!-- <xsl:when test="$coll = 'FRSIAF'">
                        <xsl:value-of
                            select="$collection-EAC-SIAF/eac:eac-cpf[eac:control/eac:recordId = $fromAgent]/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'preferredFormForProject']/eac:part"
                        />
                    </xsl:when>-->

                <xsl:value-of select="$fromAgentName"/>

                <!-- <xsl:when test="$coll = 'FRBNF'">
                        <xsl:value-of
                            select="$collection-EAC-BnF/eac:eac-cpf[eac:control/eac:recordId = $fromAgent]/eac:cpfDescription/eac:identity/eac:nameEntry[@localType = 'preferredFormForProject']/eac:part"
                        />
                    </xsl:when>-->


                <xsl:text>" et "</xsl:text>
                <xsl:value-of select="$tName"/>
                <xsl:text>"</xsl:text>
            </rdfs:label>
            <xsl:if test="an:note">
                <RiC:description xml:lang="fr">
                    <xsl:for-each select="an:note/an:p">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </RiC:description>
            </xsl:if>

            <xsl:if test="an:date">
                <RiC:date>
                    <xsl:choose>
                        <xsl:when test="not(an:date/@type)">
                            <xsl:value-of select="an:date"/>
                        </xsl:when>
                        <xsl:when test="an:date/@type = 'iso8601'">
                            <xsl:attribute name="rdf:datatype">
                                <xsl:choose>
                                    <xsl:when test="string-length(an:date) = 4">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:date) = 7">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:date) = 10">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="an:date"/>
                        </xsl:when>
                    </xsl:choose>
                </RiC:date>
            </xsl:if>
            <xsl:if test="an:dateRange/an:fromDate">
                <RiC:beginningDate>
                    <xsl:choose>
                        <xsl:when test="not(an:dateRange/an:fromDate/@type)">
                            <xsl:value-of select="an:dateRange/an:fromDate"/>
                        </xsl:when>
                        <xsl:when test="an:dateRange/an:fromDate/@type = 'iso8601'">
                            <xsl:attribute name="rdf:datatype">
                                <xsl:choose>
                                    <xsl:when test="string-length(an:dateRange/an:fromDate) = 4">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:dateRange/an:fromDate) = 7">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:dateRange/an:fromDate) = 10">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="an:dateRange/an:fromDate"/>
                        </xsl:when>
                    </xsl:choose>

                </RiC:beginningDate>
            </xsl:if>
            <xsl:if test="an:dateRange/an:toDate">

                <RiC:endDate>
                    <xsl:choose>
                        <xsl:when test="not(an:dateRange/an:toDate/@type)">
                            <xsl:value-of select="an:dateRange/an:toDate"/>
                        </xsl:when>
                        <xsl:when test="an:dateRange/an:toDate/@type = 'iso8601'">
                            <xsl:attribute name="rdf:datatype">
                                <xsl:choose>
                                    <xsl:when test="string-length(an:dateRange/an:toDate) = 4">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:dateRange/an:toDate) = 7">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="string-length(an:dateRange/an:toDate) = 10">
                                        <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="an:dateRange/an:toDate"/>
                        </xsl:when>
                    </xsl:choose>
                </RiC:endDate>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="$relType = 'family'">
                    <RiC:familyRelationConnects>
                        <xsl:call-template name="outputObjectPropertyToAnc">


                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                            <xsl:with-param name="ancAgentType" select="$ancAgentType"/>

                        </xsl:call-template>

                    </RiC:familyRelationConnects>


                    <RiC:familyRelationConnects>
                        <xsl:call-template name="outputObjectPropertyToTarg">

                            <xsl:with-param name="tEntity" select="$tEntity"/>
                            <xsl:with-param name="relType" select="$relType"/>
                        </xsl:call-template>

                    </RiC:familyRelationConnects>

                </xsl:when>
                <xsl:when test="$relType = 'associative'">
                    <xsl:choose>
                        <xsl:when
                            test="contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected')">
                            <xsl:choose>
                                <xsl:when test="$ancAgentType = 'person'">
                                    <RiC:leadershipRelationHasSource>
                                        <xsl:call-template name="outputObjectPropertyToAnc">


                                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                                            <xsl:with-param name="ancAgentType"
                                                select="$ancAgentType"/>

                                        </xsl:call-template>
                                    </RiC:leadershipRelationHasSource>
                                    <RiC:leadershipRelationHasTarget>
                                        <xsl:call-template name="outputObjectPropertyToTarg">


                                            <xsl:with-param name="tEntity" select="$tEntity"/>
                                            <xsl:with-param name="relType" select="$relType"/>
                                        </xsl:call-template>
                                    </RiC:leadershipRelationHasTarget>
                                </xsl:when>
                                <xsl:when test="$ancAgentType = 'corporateBody'">
                                    <RiC:leadershipRelationHasSource>
                                        <xsl:call-template name="outputObjectPropertyToTarg">


                                            <xsl:with-param name="tEntity" select="$tEntity"/>
                                            <xsl:with-param name="relType" select="$relType"/>
                                        </xsl:call-template>
                                    </RiC:leadershipRelationHasSource>
                                    <RiC:leadershipRelationHasTarget>
                                        <xsl:call-template name="outputObjectPropertyToAnc">


                                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                                            <xsl:with-param name="ancAgentType"
                                                select="$ancAgentType"/>

                                        </xsl:call-template>
                                    </RiC:leadershipRelationHasTarget>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if
                                test="
                                $FRAN-positions/rdf:Description[
                                (RiC:occupiedBy[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]
                                and
                                RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]
                                
                                    )
                                    or
                                    (RiC:occupiedBy[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]
                                    and
                                    RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]
                                    )
                                    ]">
                                <RiC:leadershipWithPosition>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="
                                                
                                                if ($FRAN-positions/rdf:Description[
                                                RiC:occupiedBy[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]
                                                and
                                                RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]
                                                ])
                                                then
                                                $FRAN-positions/rdf:Description[RiC:occupiedBy[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]
                                                and
                                                RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]]/@rdf:about
                                                else
                                                    (
                                                    if (
                                                    $FRAN-positions/rdf:Description[
                                                    RiC:occupiedBy[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]
                                                    and
                                                    RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]
                                                    ]
                                                    )
                                                    
                                                    then
                                                    $FRAN-positions/rdf:Description[
                                                    RiC:occupiedBy[ends-with(@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))]
                                                    and
                                                    RiC:positionExistsIn[ends-with(@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))]]/@rdf:about
                                                    
                                                    else
                                                        ()
                                                    
                                                    
                                                    )
                                                
                                                
                                                
                                                "
                                        />
                                    </xsl:attribute>
                                </RiC:leadershipWithPosition>
                            </xsl:if>
                        </xsl:when>



                        <xsl:otherwise>
                            <RiC:agentRelationConnects>
                                <xsl:call-template name="outputObjectPropertyToAnc">


                                    <xsl:with-param name="fromAgent" select="$fromAgent"/>
                                    <xsl:with-param name="ancAgentType" select="$ancAgentType"/>

                                </xsl:call-template>

                            </RiC:agentRelationConnects>


                            <RiC:agentRelationConnects>
                                <xsl:call-template name="outputObjectPropertyToTarg">


                                    <xsl:with-param name="tEntity" select="$tEntity"/>
                                    <xsl:with-param name="relType" select="$relType"/>
                                </xsl:call-template>

                            </RiC:agentRelationConnects>
                        </xsl:otherwise>
                    </xsl:choose>




                    <!-- A REPRENDRE : devrait donner un LeadershipRelation <xsl:if test="contains(an:note/an:p, 'isDirectorOf') or contains(an:note/an:p, 'isDirected')">
                    <xsl:if
                        test="
                        $FRAN-positions/rdf:Description[
                        (ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                        and
                        ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                        )
                        or 
                        ( ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                        and
                        ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                        )
                        ]">
                        <RiC:leadershipWithPosition>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="
                                    
                                    if ($FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    ])
                                    then $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    ]/@rdf:about
                                    else (
                                    if(
                                    $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    ]
                                    )
                                    
                                    then $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    ]/@rdf:about
                                    
                                    else()
                                    
                                    
                                    )
                                    
                                    
                                    
                                   "
                                />
                            </xsl:attribute>
                        </RiC:leadershipWithPosition>
                    </xsl:if>
                     </xsl:if>-->

                </xsl:when>
                <xsl:when test="$relType = 'temporal-earlier'">
                    <!-- A a pour prédécesseur / suit / follows B-->
                    <!-- la relation doit avoir pour source le prédécesseur: A precedesInTime B-->

                    <RiC:agentTemporalRelationHasTarget>
                        <!-- A -->
                        <xsl:call-template name="outputObjectPropertyToAnc">

                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                            <xsl:with-param name="ancAgentType" select="$ancAgentType"/>

                        </xsl:call-template>
                    </RiC:agentTemporalRelationHasTarget>
                    <RiC:agentTemporalRelationHasSource>
                        <!-- B-->
                        <xsl:call-template name="outputObjectPropertyToTarg">

                            <!-- <xsl:with-param name="fromAgent" select="$fromAgent"/>
                <xsl:with-param name="ancAgentType" select="$ancAgentType"/>-->
                            <xsl:with-param name="tEntity" select="$tEntity"/>
                            <xsl:with-param name="relType" select="$relType"/>

                        </xsl:call-template>
                    </RiC:agentTemporalRelationHasSource>
                </xsl:when>
                <xsl:when test="$relType = 'temporal-later'">

                    <!-- A a pour successeur B-->
                    <!-- la relation doit avoir pour source le prédécesseur: A precedesInTime B-->
                    <RiC:agentTemporalRelationHasSource>
                        <!-- A-->
                        <xsl:call-template name="outputObjectPropertyToAnc">

                            <!--<xsl:with-param name="coll" select="$coll"/>-->
                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                            <xsl:with-param name="ancAgentType" select="$ancAgentType"/>
                            <!--<xsl:with-param name="tEntity" select="$tEntity"/>-->
                        </xsl:call-template>
                    </RiC:agentTemporalRelationHasSource>
                    <RiC:agentTemporalRelationHasTarget>
                        <xsl:call-template name="outputObjectPropertyToTarg">
                            <!--<xsl:with-param name="coll" select="$coll"/>-->
                            <!-- <xsl:with-param name="fromAgent" select="$fromAgent"/>
                    <xsl:with-param name="ancAgentType" select="$ancAgentType"/>-->
                            <xsl:with-param name="tEntity" select="$tEntity"/>
                            <xsl:with-param name="relType" select="$relType"/>
                            <!-- <xsl:with-param name="arcrole" select="@arcrole"/>-->
                        </xsl:call-template>
                    </RiC:agentTemporalRelationHasTarget>



                </xsl:when>
                <xsl:when test="$relType = 'hierarchical-child'">

                    <!-- relation RiC : A est supérieur à B -->
                    <RiC:hierarchicalRelationHasSource>
                        <xsl:call-template name="outputObjectPropertyToAnc">
                            <!-- 
                            <xsl:with-param name="coll" select="$coll"/>-->
                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                            <xsl:with-param name="ancAgentType" select="$ancAgentType"/>

                        </xsl:call-template>
                    </RiC:hierarchicalRelationHasSource>
                    <RiC:hierarchicalRelationHasTarget>
                        <xsl:call-template name="outputObjectPropertyToTarg">

                            <xsl:with-param name="tEntity" select="$tEntity"/>
                            <xsl:with-param name="relType" select="$relType"/>

                        </xsl:call-template>
                    </RiC:hierarchicalRelationHasTarget>



                </xsl:when>
                <xsl:when test="$relType = 'hierarchical-parent'">

                    <!-- A est inférieur à B -->
                    <RiC:hierarchicalRelationHasTarget>
                        <!-- A-->
                        <xsl:call-template name="outputObjectPropertyToAnc">

                            <!--   <xsl:with-param name="coll" select="$coll"/>-->
                            <xsl:with-param name="fromAgent" select="$fromAgent"/>
                            <xsl:with-param name="ancAgentType" select="$ancAgentType"/>

                        </xsl:call-template>
                    </RiC:hierarchicalRelationHasTarget>
                    <RiC:hierarchicalRelationHasSource>
                        <xsl:call-template name="outputObjectPropertyToTarg">
                            <!-- <xsl:with-param name="coll" select="$coll"/>-->

                            <xsl:with-param name="tEntity" select="$tEntity"/>

                            <xsl:with-param name="relType" select="$relType"/>
                        </xsl:call-template>
                    </RiC:hierarchicalRelationHasSource>



                </xsl:when>
            </xsl:choose>


            <!-- <xsl:if test="@arcrole = 'knows' or (@type = 'associative' and (not(@arcrole) or @arcrole = '')) and not(@type = 'family')">
                <RiC:relationConnects>
                    <xsl:call-template name="outputObjectPropertyToAnc">
                        
                        
                        <xsl:with-param name="fromAgent" select="$fromAgent"/>
                        <xsl:with-param name="ancAgentType" select="$ancAgentType"/>
                        
                    </xsl:call-template>
                    
                </RiC:relationConnects>
                
                
                <RiC:relationConnects>
                    <xsl:call-template name="outputObjectPropertyToTarg">
                        
                        
                        <xsl:with-param name="tEntity" select="$tEntity"/>
                        
                    </xsl:call-template>
                    
                </RiC:relationConnects>-->
            <!-- <xsl:if test="contains(eac:descriptiveNote/eac:p, 'isDirectorOf') or contains(eac:descriptiveNote/eac:p, 'isDirected')">
                    <xsl:if
                        test="
                        $FRAN-positions/rdf:Description[
                        (ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                        and
                        ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                        )
                        or 
                        ( ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                        and
                        ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                        )
                        ]">
                        <RiC:leadershipWithPosition>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="
                                    
                                    if ($FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    ])
                                    then $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    ]/@rdf:about
                                    else (
                                    if(
                                    $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    ]
                                    )
                                    
                                    then $FRAN-positions/rdf:Description[
                                    ends-with(RiC:occupiedBy/@rdf:resource, substring-after($tEntity, 'FRAN_NP_'))
                                    and
                                    ends-with(RiC:positionExistsIn/@rdf:resource, substring-after($fromAgent, 'FRAN_NP_'))
                                    ]/@rdf:about
                                    
                                    else()
                                    
                                    
                                    )
                                    
                                    
                                    
                                   "
                                />
                            </xsl:attribute>
                        </RiC:leadershipWithPosition>
                    </xsl:if>
                    -->
            <!--  </xsl:if>-->







        </rdf:Description>

    </xsl:template>
    <!--<xsl:template name="outputPositionInRel">
        <xsl:param name="tName"/>
        <xsl:param name="tEntity"/>
        <xsl:param name="fromAgent"/>
        <xsl:param name="coll"/>

        <xsl:choose>
            <xsl:when test="$coll = 'FRSIAF'">
                <xsl:comment>coll='FRSIAF'</xsl:comment>
                <xsl:if
                    test="
                        $FRSIAF-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                        and
                        RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_person_', $fromAgent)
                        and
                        (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_corporate-body_', $tEntity)
                        or
                        RiC:positionIn = $tName
                        
                        )]">
                    <xsl:comment>condition réalisée</xsl:comment>
                    <RiC:leadershipWithPosition>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of
                                select="
                                    $FRSIAF-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                                    and
                                    RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_person_', $fromAgent)
                                    and
                                    (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_corporate-body_', $tEntity)
                                    or
                                    RiC:positionIn = $tName
                                    
                                    )]/@rdf:about"
                            />
                        </xsl:attribute>
                    </RiC:leadershipWithPosition>
                </xsl:if>

            </xsl:when>
            <xsl:when test="$coll = 'FRAN'">
                <xsl:comment>coll='FRAN'</xsl:comment>
                <xsl:if
                    test="
                        $FRAN-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                        and
                        RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRAN_person_', substring-after($fromAgent, 'FRAN_NP_'))
                        and
                        (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRAN_corporate-body_', substring-after($tEntity, 'FRAN_NP_'))
                        or
                        RiC:positionIn = $tName
                        or
                        ends-with(RiC:positionIn/@rdf:nodeID, substring-after($tEntity, 'FRAN_NP_'))
                        )]">
                    <RiC:leadershipWithPosition>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of
                                select="
                                    $FRAN-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                                    and
                                    RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRAN_person_', substring-after($fromAgent, 'FRAN_NP_'))
                                    and
                                    (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRAN_corporate-body_', substring-after($tEntity, 'FRAN_NP_'))
                                    or
                                    RiC:positionIn = $tName
                                    or
                                    ends-with(RiC:positionIn/@rdf:nodeID, substring-after($tEntity, 'FRAN_NP_'))
                                    )]/@rdf:about"
                            />
                        </xsl:attribute>
                    </RiC:leadershipWithPosition>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$coll = 'FRBNF'">
                <xsl:if
                    test="
                        $FRBNF-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                        and
                        RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRBNF_person_', substring-after($fromAgent, 'DGEARC_'))
                        and
                        (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRBNF_corporate-body_', substring-after($tEntity, 'DGEARC'))
                        or
                        RiC:positionIn = $tName
                        
                        )]">
                    <RiC:leadershipWithPosition>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of
                                select="
                                    $FRBNF-positions/rdf:Description[rdf:type/@rdf:resource = 'http://www.ica.org/standards/RiC/ontology#Position'
                                    and
                                    RiC:occupiedBy/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRBNF_person_', substring-after($fromAgent, 'DGEARC_'))
                                    and
                                    (RiC:positionIn/@rdf:resource = concat('http://piaaf.demo.logilab.fr/resource/FRBNF_corporate-body_', substring-after($tEntity, 'DGEARC'))
                                    or
                                    RiC:positionIn = $tName
                                    
                                    )]/@rdf:about"
                            />
                        </xsl:attribute>
                    </RiC:leadershipWithPosition>
                </xsl:if>
            </xsl:when>
        </xsl:choose>

    </xsl:template>-->
    <xsl:template name="outputObjectPropertyToAnc">

        <xsl:param name="fromAgent"/>
       
        <xsl:param name="ancAgentType"/>
        <xsl:attribute name="rdf:resource">
         
            <xsl:value-of select="$baseURL"/>

            <xsl:choose>
                <xsl:when test="$ancAgentType = 'person'">person/</xsl:when>
                <xsl:when test="$ancAgentType = 'corporateBody'">corporateBody/</xsl:when>
                <xsl:when test="$ancAgentType = 'family'">family/</xsl:when>
            </xsl:choose>
            <xsl:value-of
                select="
                    substring-after($fromAgent, 'FRAN_NP_')
                    
                    "
            />
        </xsl:attribute>
    </xsl:template>
    <xsl:template name="outputObjectPropertyToTarg">



        <xsl:param name="tEntity"/>

        <xsl:param name="relType"/>

        <xsl:if test="normalize-space($tEntity) != ''">

            <xsl:choose>

                <xsl:when test="$collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId = $tEntity]">
                    <xsl:variable name="targetEntityType"
                        select="
                            
                            $collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId = $tEntity]/eac:cpfDescription/eac:identity/eac:entityType
                            
                            
                            "/>
                   
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat($baseURL, $targetEntityType, '/')"/>

                    
                        <xsl:value-of select="substring-after($tEntity, 'FRAN_NP_')"/>



                    </xsl:attribute>



                </xsl:when>
                <xsl:otherwise>

                    <!--    <xsl:attribute name="rdf:nodeID">
                        <xsl:value-of
                            select="concat('FRAN_bnode_', substring-after($tEntity, 'FRAN_NP_'), '_', generate-id())"
                        />
                    </xsl:attribute>-->

                    <xsl:variable name="targEntityType">
                        <xsl:choose>
                            <!-- relation hiérarchique : entre 2 cbodies -->
                            <!--  <xsl:when test="starts-with($cpfRel, 'hierarchical')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>-->
                            <!-- <xsl:when test="contains($arcrole, 'isDirectedBy')">
                                <xsl:text>person</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'isDirectorOf')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'isAssociatedWithForItsControl')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'controls') or contains($arcrole, 'isControlledBy') or contains($arcrole, 'isPartOf') or contains($arcrole, 'hasPart')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="contains($arcrole, 'hasMember') or contains($arcrole, 'hasEmployee')">
                                <xsl:text>person</xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="contains($arcrole, 'isMemberOf') or contains($arcrole, 'isEmployeeOf')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>-->
                            <xsl:when
                                test="$relType = 'hierarchical-child' or $relType = 'hierarchical-parent'">
                                <xsl:text>corporateBody</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>agent</xsl:text>
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:variable>





                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of
                            select="concat($baseURL, $targEntityType, '/', substring-after($tEntity, 'FRAN_NP_'))"
                        />
                    </xsl:attribute>

                </xsl:otherwise>
                <!-- <xsl:when test="starts-with($tEntity, 'FR784')">
                   <!-\- <xsl:attribute name="rdf:nodeID">
                        <xsl:value-of select="concat('FRSIAF_bnode_', $tEntity, '_', generate-id())"
                        />
                    </xsl:attribute>-\->
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_group-type_', $tEntity)"/>
                    </xsl:attribute>
                </xsl:when>-->
                <!--  <xsl:when test="starts-with($tEntity, 'FRAD')">

                 <!-\-   <xsl:attribute name="rdf:nodeID">
                        <xsl:value-of select="concat('FRSIAF_bnode_', $tEntity, '_', generate-id())"
                        />
                    </xsl:attribute>-\->
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat('http://piaaf.demo.logilab.fr/resource/FRSIAF_corporate-body_', $tEntity)"/>
                    </xsl:attribute>
                </xsl:when>-->
                <!--<xsl:when test="starts-with($tEntity, 'FRBNF')">
                    <!-\-<xsl:attribute name="rdf:nodeID">
                        <xsl:value-of
                            select="concat('FRBNF_bnode_', substring-after($tEntity, 'DGEARC_'), '_', generate-id())"
                        />
                    </xsl:attribute>-\->
                    
                    <xsl:variable name="targEntityType">
                        <xsl:choose>
                            <!-\- relation hiérarchique : entre 2 cbodies -\->
                            <!-\-  <xsl:when test="starts-with($cpfRel, 'hierarchical')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>-\->
                            <xsl:when test="contains($arcrole, 'isDirectedBy')">
                                <xsl:text>person</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'isDirectorOf')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'isAssociatedWithForItsControl')">
                                <xsl:text>corporate-body</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains($arcrole, 'controls') or contains($arcrole, 'isControlledBy') or contains($arcrole, 'isPartOf') or contains($arcrole, 'hasPart')">
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
                    </xsl:variable>
                    
                    
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat('http://piaaf.demo.logilab.fr/resource/FRBNF_', $targEntityType, '_', substring-after($tEntity, 'DGEARC_'))"/>
                    </xsl:attribute>
                   <!-\- <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat('http://www.piaaf.net/agents/FRBNF_agent_', substring-after($tEntity, 'DGEARC_'))"/>
                    </xsl:attribute>-\->
                </xsl:when>-->
                <!--<xsl:when test="starts-with($tEntity, 'http://data.bnf.fr/ark:/12148/')">
                    <!-\- cas de la relation NNF d138e498-\->
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat($tEntity, '#Organization')"/>
                    </xsl:attribute>
                </xsl:when>-->

            </xsl:choose>

        </xsl:if>
        <xsl:if test="normalize-space($tEntity) = ''">
            <xsl:attribute name="xml:lang">fr</xsl:attribute>
            <xsl:value-of select="an:targetName"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
