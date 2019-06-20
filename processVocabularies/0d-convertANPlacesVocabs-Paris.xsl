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
                France, and describing places : processing the files that describe Parisian places</xd:p>
            <xd:p>Main reference ontology : RiC-O</xd:p>
           
        </xd:desc>
    </xd:doc>
    <!-- Des paramètres dont on pourra ensuite modifier directement la valeur, ou dont on pourra passer la valeur via une interface web ou en ligne de commande -->
    <!-- URL de base pour le RDF des AN (ou ALEGORIA ?) -->
   <!-- <xsl:param name="baseURL">http://data.alegoria.fr/</xsl:param>-->
    <xsl:variable name="params" select="document('params.xml')/params"/>
    
    <xsl:variable name="baseURL" select="$params/baseURL"/>
 
    <xsl:variable name="P-arr-anciens" select="document('src/places/FRAN_RI_021_lieuxParisArrondissementsAnciens.xml')/r"/>
    <xsl:variable name="P-com-rattachs" select="document('src/places/FRAN_RI_020_lieuxParisCommunesRattachees.xml')/r"/>
    <xsl:variable name="P-arr-actuels" select="document('src/places/FRAN_RI_022_lieuxParisArrondissementsActuels.xml')/r"/>
    <xsl:variable name="P-quartiers" select="document('src/places/FRAN_RI_023_lieuxParisQuartiers.xml')/r"/>
    <xsl:variable name="P-paroisses" select="document('src/places/FRAN_RI_024_lieuxParisParoisses.xml')/r"/>
    <xsl:variable name="P-voies" select="document('src/places/FRAN_RI_025_lieuxParisVoies.xml')/r"/>
    <xsl:variable name="P-edifices" select="document('src/places/FRAN_RI_026_lieuxParisEdifices.xml')/r"/>
    <xsl:variable name="lieux-general" select="document('src/places/FRAN_RI_005_22-05-2019.xml')/r"/>
    
    <xsl:template match="/vide">
        
        
        
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_arrondissementsAnciens.rdf">
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
                <xsl:for-each select="$P-arr-anciens/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                  <!--  <d id="d3nyv5jo07-\-11vv6ggdeixfq">
                        <terme>01e arrondissement</terme>
                    </d>
                    -->
                    <rdf:Description>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_021-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(terme), ' (Paris ; 1795-1860)')"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(terme), ' (Paris ; 1795-1860)')"/>
                        </skos:prefLabel>
                        <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1795</rico:beginningDate>
                        <rico:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1860</rico:endDate>
                      
                        <rico:hasPlaceType rdf:resource="placeType/arrondissement%20municipal"/>
                        <rico:state xml:lang="fr">disparu</rico:state>
                        <rico:isPartOf rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_021.xml#', $id)"
                            />
                        </rico:identifier>
                        
                    </rdf:Description>
                  
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_arrondissementsActuels.rdf">
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
                <xsl:for-each select="$P-arr-actuels/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    
               
                    
                    <!--  <d id="d3nyv5jo07-\-11vv6ggdeixfq">
                        <terme>01e arrondissement</terme>
                    </d>
                    -->
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_022-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(terme), ' (Paris ; 1860-....)')"/>
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(terme), ' (Paris ; 1860-....)')"/>
                        </skos:prefLabel>
                        
                        
                     
                        <rico:hasPlaceType rdf:resource="placeType/arrondissement%20municipal"/>
                       
                        <rico:isPartOf rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                        <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1860</rico:beginningDate>
                        
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_022.xml#', $id)"
                            />
                        </rico:identifier>
                           </rico:Place>
                        
              
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_communesRattachees.rdf">
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
                
                <xsl:for-each select="$P-com-rattachs/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    <!-- http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-->
                    
                    
                    <!--   <terme>Bagnolet (ancienne commune)</terme>
                    -->
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_020-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Seine ; commune)')"/>
                          
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Seine ; commune)')"/>
                        </skos:prefLabel>
                        <skos:altLabel xml:lang="fr">
                          <xsl:value-of select="normalize-space(terme)"/>
                        </skos:altLabel>
                        
                        <rico:hasPlaceType rdf:resource="placeType/ancienne%20commune"/>
                        <rico:history xml:lang="fr">commune rattachée en totalité ou partiellement à Paris</rico:history>
                        <rico:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1860</rico:endDate>
                        <rico:state xml:lang="fr">disparue</rico:state>
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_020.xml#', $id)"
                            />
                        </rico:identifier>
                        <rico:isPartOf rdf:resource="place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g"/>
                    </rico:Place>
                    
                    
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_quartiers.rdf">
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
                
                
                <xsl:for-each select="$P-quartiers/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    <!-- http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-->
                    
                    
                <!--    <terme>Grève (quartier)</terme>-->
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_023-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Paris ; quartier)')"/>
                            
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Paris ; quartier)')"/>
                        </skos:prefLabel>
                        <skos:altLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(terme)"/>
                        </skos:altLabel>
                        <xsl:for-each select="interdits/i">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>
                        <rico:hasPlaceType rdf:resource="placeType/quartier"/>
                       
                        <rico:type xml:lang="fr">quartier de Paris, de la fin du XVIIIe siècle à nos jours</rico:type>
                      <xsl:if test="def[normalize-space()!='']">
                          <rico:history xml:lang="fr">
                              <xsl:value-of select="def"/>
                          </rico:history>
                      </xsl:if>
                        <xsl:choose>
                            <xsl:when test="contains(def, 'créé en 1860.')">
                                <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1860</rico:beginningDate></xsl:when>
                            <xsl:when test="contains(def, 'créé en 1811.')">
                                <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1811</rico:beginningDate>
                            </xsl:when>
                            <xsl:when test="contains(def, 'ayant existé de 1701 à 1790.')">
                                <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1701</rico:beginningDate>
                                <rico:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1790</rico:endDate>
                            </xsl:when>
                            <xsl:when test="contains(def, 'ayant existé de 1811 à 1860.')">
                                <rico:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1811</rico:beginningDate>
                                <rico:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">1860</rico:endDate>
                            </xsl:when>
                        </xsl:choose>
                        
                        
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_023.xml#', $id)"
                            />
                        </rico:identifier>
                        <rico:isPartOf rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                    </rico:Place>
                    
                    
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_paroisses.rdf">
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
                
                <xsl:for-each select="$P-paroisses/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                 
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_024-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Paris ; paroisse)')"/>
                            
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="concat(normalize-space(substring-before(terme, '(')), ' (Paris ; paroisse)')"/>
                        </skos:prefLabel>
                        <skos:altLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(terme)"/>
                        </skos:altLabel>
                        <xsl:for-each select="interdits/i">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>
                        <rico:hasPlaceType rdf:resource="placeType/paroisse"/>
                          <rico:type xml:lang="fr">paroisse de Paris avant 1789</rico:type>
                        <xsl:if test="def[normalize-space()!='']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_024.xml#', $id)"
                            />
                        </rico:identifier>
                        <rico:isPartOf rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                    </rico:Place>
                    
                    
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_voies.rdf">
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
                <xsl:for-each select="$P-voies/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    <!-- http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-->
                    
                    
                    <!--    <terme>Grève (quartier)</terme>-->
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_025-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            
                          <xsl:value-of select="normalize-space(terme)"/>
                            
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(terme)"/>
                            
                        </skos:prefLabel>
                    
                        <xsl:for-each select="interdits/i">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>
                        
                        <rico:hasPlaceType rdf:resource="placeType/voie%20urbaine"/>
                        <rico:type xml:lang="fr">voie de Paris</rico:type>
                        <xsl:if test="def[normalize-space()!='']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="contains(def, 'Voie supprimée.')">
                                <rico:state xml:lang="fr">voie disparue</rico:state>
                            </xsl:when>
                            <xsl:when test="contains(def, 'Voie actuelle.')">
                                <rico:state xml:lang="fr">voie actuelle</rico:state>
                            </xsl:when>
                        </xsl:choose>
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_025.xml#', $id)"
                            />
                        </rico:identifier>
                        <rico:isWithin rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                    </rico:Place>
                    
                    
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="rdf/places/FRAN_Paris_edifices.rdf">
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
                <xsl:for-each select="$P-edifices/d">
                    
                    <xsl:variable name="id" select="@id"/>
                    
                    <!-- http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-->
                    
                    
                    <!--    <terme>Grève (quartier)</terme>-->
                    <rico:Place>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="concat('place/FRAN_RI_026-',  $id)"/>
                            
                        </xsl:attribute>
                        <rdfs:label xml:lang="fr">
                            
                            <xsl:value-of select="normalize-space(terme)"/>
                            
                        </rdfs:label>
                        <skos:prefLabel xml:lang="fr">
                            <xsl:value-of select="normalize-space(terme)"/>
                            
                        </skos:prefLabel>
                        
                        <xsl:for-each select="interdits/i">
                            <skos:altLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(.)"/>
                            </skos:altLabel>
                        </xsl:for-each>
                        
                        <rico:hasPlaceType rdf:resource="placeType/am%C3%A9nagement%20ou%20construction"/>
                        <rico:type xml:lang="fr">édifice dans les limites actuelles de Paris</rico:type>
                        <xsl:if test="def[normalize-space()!='']">
                            <rico:history xml:lang="fr">
                                <xsl:value-of select="def"/>
                            </rico:history>
                        </xsl:if>
                        <rico:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : FRAN_RI_026.xml#', $id)"
                            />
                        </rico:identifier>
                        <rico:isWithin rdf:resource="place/FRAN_RI_005-d5bdppt147--176wwvjcctrx0"/>
                    </rico:Place>
                    
                    
                    
                </xsl:for-each>
                
                
            </rdf:RDF>
        </xsl:result-document>
    </xsl:template>
   
  
    
</xsl:stylesheet>
