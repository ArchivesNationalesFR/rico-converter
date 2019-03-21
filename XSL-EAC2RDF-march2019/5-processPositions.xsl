<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:eac="urn:isbn:1-931666-33-4" xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:piaaf="http://www.piaaf.net" xmlns:piaaf-onto="http://piaaf.demo.logilab.fr/ontology#"
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:xl="http://www.w3.org/2008/05/skos-xl#"
    exclude-result-prefixes="piaaf-onto xs xd eac iso-thes rdf dct xl piaaf xlink" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July 3, 2017</xd:p>

            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>

            <xd:p>Step 5 : generating an RDF file for handling the positions occupied by the persons
                described. Could probably be enhanced</xd:p>
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



        <xsl:result-document href="rdf/positions/FRAN_positions.rdf" method="xml" encoding="utf-8"
            indent="yes">

            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">

                <xsl:for-each-group
                    select="$collection-EAC-AN/eac:eac-cpf[eac:cpfDescription/eac:identity/eac:entityType[normalize-space(.) = 'person']]/eac:cpfDescription/eac:relations/eac:cpfRelation[contains(eac:descriptiveNote/eac:p, 'isDirectorOf') or contains(eac:descriptiveNote/eac:p, 'isDirected')]"
                    group-by="
                        concat(normalize-space(@xlink:href), ' : ', normalize-space(eac:relationEntry))
                        
                        
                        
                        ">
                    <xsl:sort select="current-grouping-key()"/>

                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of
                                select="concat($baseURL, 'position/', substring-after(current-group()[1]/@xml:id, 'relation_'))"/>


                        </xsl:attribute>
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Position"/>


                        <rdfs:label xml:lang="fr">
                            <xsl:value-of
                                select="concat('Poste de dirigeant au sein de l', $apos, 'entité : ', eac:relationEntry)"/>
                            <!--<xsl:choose>-->
                            <!--  <xsl:when test="contains(current-grouping-key(), 'FR78422804100033_000000369') or contains(eac:relationEntry, 'Direction régionale des affaires')">
                                            <!-\- DRAC -\->
                                            <xsl:value-of select="concat(eac:relationEntry, '. Directeur')"/>
                                        </xsl:when>
                                        <xsl:when test="contains(current-grouping-key(), 'FR78422804100033_000000371') or contains(eac:relationEntry, 'Archives départementales')">
                                            <!-\- AD -\->
                                            <xsl:value-of select="concat(eac:relationEntry, '. Directeur')"/>
                                        </xsl:when>-->
                            <!-- <xsl:when test="contains(current-grouping-key(), 'NP_005419') or contains(current-grouping-key(), 'NP_000283') or contains(current-grouping-key(), 'NP_051355')  or contains(current-grouping-key(), 'NP_000237')  or contains(current-grouping-key(), 'NP_009266')  or contains(current-grouping-key(), 'NP_051284')">
                                        <xsl:value-of select="concat(eac:relationEntry, '. Président')"/>
                                    </xsl:when>
                                    <xsl:when test="contains(current-grouping-key(), 'NP_005430') or contains(current-grouping-key(), 'NP_005424')">
                                        <xsl:value-of select="concat(eac:relationEntry, '. Administrateur')"/>
                                    </xsl:when>
                                    <xsl:when test="contains(current-grouping-key(), 'NP_005061') or contains(current-grouping-key(), 'NP_005073')  or contains(current-grouping-key(), 'NP_051158')  or contains(current-grouping-key(), 'NP_005205')  or contains(current-grouping-key(), 'NP_050981')">
                                        <xsl:value-of select="concat(eac:relationEntry, '. Directeur')"/>
                                    </xsl:when>
                                    <xsl:when test="contains(current-grouping-key(), 'NP_051161')">
                                        <xsl:value-of select="concat(eac:relationEntry, '. Ministre')"/>
                                    </xsl:when>
                                    <xsl:when test="contains(current-grouping-key(), 'NP_007800')">
                                        <xsl:value-of select="concat(eac:relationEntry, '. Secrétaire d',$apos,'État')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('Poste de dirigeant au sein de l', $apos, 'entité suivante : ', eac:relationEntry)"/>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                        </rdfs:label>

                        <RiC:positionExistsIn>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'corporateBody/', substring-after(substring-before(current-grouping-key(), ' :'), 'FRAN_NP_'))"
                                />
                            </xsl:attribute>

                            <!--  <xsl:choose>
                                    <xsl:when test="$collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId=substring-before(current-grouping-key(), ' :')]">
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of select="concat($baseURL, 'corporateBody/', substring-after(substring-before(current-grouping-key(), ' :'), 'FRAN_NP_'))"/>
                                        </xsl:attribute>
                                    </xsl:when>-->
                            <!-- entité d'affiliation non décrite dans le corpus ; on la traite quand même. Deux cas : pas de lien, ou lien -->
                            <!-- <xsl:attribute name="xml:lang">fr</xsl:attribute>
                                           <xsl:value-of select="substring-after(current-grouping-key(), ': ')"/></xsl:otherwise>-->
                            <!-- <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="normalize-space(substring-before(current-grouping-key(), ':'))=''">
                                            <xsl:attribute name="xml:lang">fr</xsl:attribute>
                                            <xsl:value-of select="substring-after(current-grouping-key(), ': ')"/>
                                        </xsl:when>
                                        <xsl:when test="normalize-space(substring-before(current-grouping-key(), ':'))!=''">
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="concat($baseURL, 'corporateBody/', substring-after(substring-before(current-grouping-key(), ' :'), 'FRAN_NP_'))"/>
                                            </xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    </xsl:otherwise>-->
                            <!-- <xsl:otherwise>
                                        <xsl:attribute name="rdf:nodeID">
                                            <xsl:value-of select="concat('FRAN_bnode_pos_', substring-after(substring-before(current-grouping-key(), ' :'), 'FRAN_NP_'))"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>-->

                            <!--      <xsl:otherwise><xsl:value-of select="substring-after(current-grouping-key(), ': ')"/></xsl:otherwise>-->
                            <!-- </xsl:choose>-->

                        </RiC:positionExistsIn>

                        <xsl:for-each-group select="current-group()"
                            group-by="ancestor::eac:eac-cpf/eac:control/eac:recordId">
                            <RiC:occupiedBy>
                                <xsl:attribute name="rdf:resource">


                                    <xsl:value-of
                                        select="concat($baseURL, 'person/', substring-after(current-grouping-key(), 'FRAN_NP_'))"/>

                                </xsl:attribute>
                            </RiC:occupiedBy>
                        </xsl:for-each-group>



                    </rdf:Description>
                    <!--  <xsl:if test="not($collection-EAC-AN/eac:eac-cpf[eac:control/eac:recordId=substring-before(current-grouping-key(), ' :')])">
                            <rdf:Description>
                                <xsl:attribute name="rdf:nodeID">
                                    <xsl:value-of select="concat('FRAN_bnode_pos_', substring-after(substring-before(current-grouping-key(), ' :'), 'FRAN_NP_'))"/>
                                </xsl:attribute>
                                <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#CorporateBody"/>
                                <rdfs:label xml:lang="fr">
                                    <xsl:value-of select="substring-after(current-grouping-key(), ': ')"/>
                                </rdfs:label>
                                <RiC:mainSubjectOf>
                                    <!-\-  <!-\\\\- https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/FRAN_NP_005439-\\\\->-\->
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat('https://www.siv.archives-nationales.culture.gouv.fr/siv/NP/', substring-before(current-grouping-key(), ' :'))"/>
                                    </xsl:attribute>
                                </RiC:mainSubjectOf>
                            </rdf:Description>
                        </xsl:if>-->
                </xsl:for-each-group>

            </rdf:RDF>




        </xsl:result-document>

    </xsl:template>

</xsl:stylesheet>
