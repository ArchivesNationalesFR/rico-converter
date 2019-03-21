<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4"
    xmlns="urn:isbn:1-931666-33-4" exclude-result-prefixes="xs xd eac xlink" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b>June 23, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>

            <xd:p>Step 1 : if necessary (here it's necessary, since a great number of "objects"
                described in the EAC files have no identifiers yet within the ANF Information
                system), the XSL generates unique identifiers (using @xml:id for storing them) for
                these objects. Of course this method is definitely NOT the good one: if we
                regenerate the RDF (after having modified then exported the EAC files from the ANF
                SIA), then regenerate the identifiers, these identifiers will not be the same as the
                ones generated before; in other words they are not persistent...</xd:p>

        </xd:desc>
    </xd:doc>
    <xsl:variable name="chemin-EAC">
        <xsl:value-of select="concat('src/NP/', '?select=*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC)"/>
    <xsl:variable name="chemin-EAC-2">
        <xsl:value-of select="'src-2/'"/>
    </xsl:variable>
    <xsl:template match="/vide">


        <xsl:for-each select="$collection-EAC-AN">
            <xsl:variable name="myId" select="/eac:eac-cpf/eac:control/eac:recordId"/>
            <xsl:result-document href="{$chemin-EAC-2}{$myId}.xml" method="xml" encoding="utf-8"
                indent="yes">
                <xsl:apply-templates/>
            </xsl:result-document>


        </xsl:for-each>
    </xsl:template>

    <xsl:template match="* | text() | @* | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="* | text() | @* | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <!-- agent names -->
    <xsl:template match="eac:identity/eac:nameEntry">
        <nameEntry>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">agent-name</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </nameEntry>
    </xsl:template>
    <!-- events in the history of the entity. For now, chronItem is never used at the ANF. But I leave it here just in case for the future-->
    <!--<xsl:template match="eac:chronItem[ancestor::eac:description]">
       
        <chronItem>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">event</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                          <!-\-  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-\->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                           <!-\- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>
-\->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </chronItem>

    </xsl:template>-->
    <!-- mandates. For now, the SIA stores each mandate in a p element, descendant of a mandate element (there may be several p in this unique mandate element...). This should be fixed, so that this template should be updated -->
    <xsl:template match="eac:mandate/eac:descriptiveNote/eac:p">
        <p>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">rule</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!--   <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>
-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </p>

    </xsl:template>
    <!-- <xsl:template match="eac:mandate/eac:citation">
        <citation>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">record</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">FRAN</xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"/>
                            </xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/> 
            
        </citation>
    </xsl:template>-->
    <!--<xsl:template match="eac:control/eac:conventionDeclaration">
        <conventionDeclaration>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">rule</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">FRAN</xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"/>
                            </xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/> 
            
        </conventionDeclaration>
        
    </xsl:template>-->


    <!-- places. First, an identifier assigned to each place element. May be useful in some cases -->
    <xsl:template match="eac:description/eac:places/eac:place">
        <place>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">place</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!--   <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--   <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </place>
    </xsl:template>

    <!-- an identifier assigned to each placeEntry element, when it has a @localType whose value is 'nomLieu' (at the ANF, means a specific place which has its own appellation)-->
    <xsl:template
        match="eac:description/eac:places/eac:place/eac:placeEntry[@localType = 'nomLieu']">
        <placeEntry>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">placeEntry</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--   <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">
                        <xsl:text>no</xsl:text>
                    </xsl:with-param>

                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </placeEntry>
    </xsl:template>

    <!-- an identifier assigned to each placeEntry element, when it has a @localType whose value is not 'nomLieu' (at the ANF, means a place that is described in one if the gazetteers. If used, the @xml:id may be used for identifying the relation to this place) -->
    <xsl:template
        match="eac:description/eac:places/eac:place/eac:placeEntry[@localType != 'nomLieu']">
        <placeEntry>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">stdPlaceEntry</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">
                        <xsl:choose>
                            <xsl:when test="@vocabularySource != ''">
                                <xsl:value-of select="normalize-space(@vocabularySource)"/>
                            </xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>

                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </placeEntry>
    </xsl:template>

    <!-- relations with other agents -->
    <xsl:template match="eac:relations/eac:cpfRelation">
        <cpfRelation>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">relation</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!--  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </cpfRelation>
    </xsl:template>

    <!-- relations with archival resources-->
    <xsl:template match="eac:relations/eac:resourceRelation">
        <resourceRelation>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">relation</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">no</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </resourceRelation>
    </xsl:template>
    <!--<xsl:template match="eac:legalStatus[ancestor::eac:description]">
        <legalStatus>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                
                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">legal-status</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">FRAN</xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"/>
                            </xsl:when>
                            <xsl:when test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource">
                        <xsl:choose>
                            <xsl:when test="eac:term/@vocabularySource!=''">
                                <xsl:value-of select="normalize-space(eac:term/@vocabularySource)"/>
                            </xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/> 
            
        </legalStatus>
    </xsl:template>-->


    <!-- functions of corporate bodies-->
    <xsl:template match="eac:description/descendant::eac:function">
        <function>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">

                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">activity</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!--  <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!--   <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource"
                        ><!-- <xsl:choose>
                        <xsl:when test="eac:term/@vocabularySource!=''">
                            <xsl:value-of select="normalize-space(eac:term/@vocabularySource)"/>
                        </xsl:when>
                        <xsl:otherwise>-->no<!--</xsl:otherwise>
                    </xsl:choose>--></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </function>
    </xsl:template>


    <!-- occupations of persons -->
    <xsl:template match="eac:description/descendant::eac:occupation">
        <occupation>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">

                <xsl:call-template name="generate-identifier">
                    <xsl:with-param name="resource">occupation</xsl:with-param>
                    <xsl:with-param name="prov">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"
                                >FRAN</xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')"
                                >FRBNF</xsl:when>
                            <xsl:otherwise>FRSIAF</xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="recNumber">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_'))"
                                />
                            </xsl:when>
                            <!-- <xsl:when
                                test="starts-with(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRBNF_NP_protoLD_')">
                                <xsl:value-of
                                    select="normalize-space(substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'DGEARC_'))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(ancestor::eac:eac-cpf/eac:control/eac:recordId)"
                                />
                            </xsl:otherwise>-->

                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vocabSource"
                        ><!-- <xsl:choose>
                        <xsl:when test="eac:term/@vocabularySource!=''">
                            <xsl:value-of select="normalize-space(eac:term/@vocabularySource)"/>
                        </xsl:when>
                        <xsl:otherwise>-->no<!--</xsl:otherwise>
                    </xsl:choose>--></xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>

        </occupation>
    </xsl:template>
    <xsl:template name="generate-identifier">
        <xsl:param name="resource"/>
        <xsl:param name="prov"/>
        <xsl:param name="recNumber"/>
        <xsl:param name="vocabSource"/>
        <xsl:variable name="resourceCode">
            <xsl:choose>
                <xsl:when test="$resource = 'agent-name'">agentName</xsl:when>
                <xsl:when test="$resource = 'event'">event</xsl:when>
                <xsl:when test="$resource = 'rule'">rule</xsl:when>
                <xsl:when test="$resource = 'activity'">activity</xsl:when>
                <!-- <xsl:when test="$resource='place'">pl</xsl:when>-->
                <xsl:when test="$resource = 'relation'">relation</xsl:when>
                <!-- <xsl:when test="$resource='legal-status'">le</xsl:when>-->
                <xsl:when test="$resource = 'occupation'">occupation</xsl:when>
                <xsl:when test="$resource = 'record'">record</xsl:when>
                <xsl:when test="$resource = 'stdPlaceEntry'">stdPlaceEntry</xsl:when>
                <xsl:when test="$resource = 'placeEntry'">placeEntry</xsl:when>
                <xsl:when test="$resource = 'place'">place</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$vocabSource != 'no'">
                <xsl:value-of
                    select="concat($prov, '_', $resourceCode, '_', $recNumber, '-', $vocabSource, generate-id())"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat($prov, '_', $resourceCode, '_', $recNumber, '-', generate-id())"
                />
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>
</xsl:stylesheet>
