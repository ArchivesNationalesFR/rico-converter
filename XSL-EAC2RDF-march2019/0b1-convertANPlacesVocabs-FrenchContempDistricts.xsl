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
            <xd:p>Revised on March 8, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Generating RDF files from the XML files created by the Archives nationales de
                France, and describing places : processing the branches on French contemporary
                districts in the main file, FRAN_RI_005.xml. Step 1 : simple conversion +
                equivalences to INSEE and IGN datasets. </xd:p>
            <xd:p>Main reference ontology : RiC-O</xd:p>

            <xd:p>Nota bene: for French regions, the RDF file has been created manually. For the
                other branches, use another XSL. </xd:p>
        </xd:desc>
    </xd:doc>


    <xsl:variable name="params" select="document('params.xml')/params"/>

    <xsl:variable name="baseURL" select="$params/baseURL"/>
    <!-- l'identifiant du référentiel AN source -->
    <xsl:param name="ANVocabId">FRAN_RI_005</xsl:param>
    <xsl:param name="folder">rdf-AN</xsl:param>

    <xsl:variable name="insee-arrs"
        select="document('src/RI/places/sparql-datalift-arrondissementsINSEE-4.xml')/sparql:sparql"/>
    <xsl:variable name="insee-cants"
        select="document('src/RI/places/sparql-datalift-cantonsINSEE-4.xml')/sparql:sparql"/>

    <xsl:variable name="chemin-places-step1">
        <xsl:value-of select="'../../../rdf/places-step1/'"/>
    </xsl:variable>

    <xsl:template match="/r">
        <xsl:variable name="regions" select="d[@id = 'd3ntb5mh8b-1fnd49o0ydjbz']"/>
        <xsl:variable name="communes" select="d[@id = 'd3m08zhht0k--tkyaw3csd7xn']"/>
        <xsl:variable name="departs" select="d[@id = 'd3ntb6zxjb--1k1thm4e2xtmv']"/>
        <xsl:variable name="cants" select="d[@id = 'd3ntbd9c24--1cmjjmalqgjhj']"/>
        <xsl:variable name="arrts" select="d[@id = 'd3ntb92k9q-14xg06bqna7w3']"/>

        <!-- 1.  départements -->
        <!-- Nota : à ce jour manquent les départements anciens d'Algérie, des éléments historiques rédigés et les relations follows | precedes, les indications de géométrie + indication des chefs-lieux (à récupérer de data.ign.fr). See the second XSL.-->
        <!-- TODO : corriger/compléter les indications d'appartenance aux régions !! -->
        <xsl:result-document method="xml" encoding="utf-8" indent="yes"
            href="{$chemin-places-step1}FRAN_departements.rdf">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                xmlns:geofla="http://data.ign.fr/def/geofla#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                <xsl:for-each select="$departs/d">
                    <xsl:sort select="terme"/>
                    <xsl:variable name="id" select="@id"/>

                    <xsl:variable name="INSEEId"
                        select="
                            if (interdits/i[matches(., '\d+')])
                            then
                                interdits/i[matches(., '\d+')]
                            else
                                ('non')
                            
                            "> </xsl:variable>
                    <!-- <terme>Haut-Rhin (Alsace , département)</terme>-->
                    <!-- <terme>Golo (France , département , 1793-1811)</terme>-->
                    <!--  <terme>Guyane (département)</terme>-->
                    <!--  <terme>Essonne (Ile-de-France , département)</terme>-->
                    <!-- <terme>Saint-Barthélémy (pays et territoires d'outre-mer)</terme>-->
                    <!--<xsl:variable name="regionName" select="normalize-space(substring-before(substring-after (terme, '('), ','))"/>-->
                    <xsl:variable name="regionName">
                        <xsl:choose>
                            <xsl:when test="contains(terme, '(France')">
                                <xsl:text>non</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(terme, '(département)')">
                                <xsl:text>non</xsl:text>
                            </xsl:when>
                            <xsl:when test="contains(terme, 'outre-mer')">
                                <xsl:text>non</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="normalize-space(substring-before(substring-after(terme, '('), ','))"
                                />
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:variable>

                    <xsl:variable name="regionId">
                        <xsl:choose>
                            <xsl:when test="$regionName != 'non'">
                                <xsl:value-of
                                    select="$regions/d[normalize-space(substring-before(terme, '(')) = $regionName]/@id"
                                />
                            </xsl:when>
                            <xsl:otherwise>non</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>


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
                        <xsl:if
                            test="(not(contains(terme, 'Saint-Pierre-et-Miquelon')) and $INSEEId != 'non' and $regionName != 'non') or contains(terme, '(département)')">
                            <rdf:type rdf:resource="http://data.ign.fr/def/geofla#Departement"/>
                        </xsl:if>
                        <!--  <RiC:hasPlaceName>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
                                    select="concat($baseURL, 'place-name/', $ANVocabId, '-', $id)"/>

                            </xsl:attribute>
                        </RiC:hasPlaceName>-->
                        <!-- date de création : 1790, par défaut. A vérifier dépt par dépt via données INSEE-->
                        <!-- <terme>Golo (France , département , 1793-1811)</terme>-->
                        <RiC:beginningDate>
                            <xsl:attribute name="rdf:datatype">
                                <xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="contains(terme, '(France')">
                                    <xsl:variable name="date">
                                        <xsl:value-of
                                            select="substring-before(normalize-space(substring-after(terme, 'département ,')), ')')"
                                        />
                                    </xsl:variable>

                                    <xsl:value-of select="substring-before($date, '-')"/>

                                </xsl:when>
                                <xsl:when
                                    test="contains(terme, 'Guadeloupe') or contains(terme, 'Martinique') or contains(terme, 'Réunion') or contains(terme, 'Guyane')">
                                    <xsl:text>1946</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(terme, 'Tarn-et-Garonne')">
                                    <xsl:text>1808</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(terme, 'Mayotte')">
                                    <xsl:text>2011</xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="contains(terme, 'Corse-du-Sud') or contains(terme, 'Haute-Corse') or contains(terme, 'Saint-Pierre-et-Miquelon')">
                                    <xsl:text>1976</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(terme, 'Territoire-de-Belfort')">
                                    <xsl:text>1922</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains(terme, 'Meurthe-et-Moselle')">
                                    <xsl:text>1871</xsl:text>
                                </xsl:when>
                                <!-- Yvelines, Essonne, Hauts-de-Seine, Seine-Saint-Denis, Val-de-Marne et Val-d'Oise-->
                                <xsl:when
                                    test="contains(terme, 'Yvelines') or contains(terme, 'Essonne') or contains(terme, 'Val-de-Marne') or contains(terme, 'Hauts-de-Seine') or contains(terme, 'Seine-Saint-Denis') or (contains(terme, 'Val-d') and contains(terme, 'Oise'))">
                                    <xsl:text>1968</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>

                                    <xsl:text>1790</xsl:text>
                                </xsl:otherwise>
                                <!-- <http://id.insee.fr/geo/collectiviteDOutreMer/975>
        a                 igeo:CollectiviteDOutreMer ;
        igeo:chefLieu     <http://id.insee.fr/geo/commune/97502> ;
        igeo:codeINSEE    "975"^^xsd:token ;
        igeo:nom          "Saint-Pierre-Et-Miquelon"@fr ;
        igeo:subdivision  <http://id.insee.fr/geo/commune/97502> , <http://id.insee.fr/geo/commune/97501> ;
        igeo:vivant       true .-->
                            </xsl:choose>

                        </RiC:beginningDate>
                        <xsl:if test="contains(terme, '(France')">
                            <RiC:endDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
                                <xsl:variable name="date">
                                    <xsl:value-of
                                        select="substring-before(normalize-space(substring-after(terme, 'département ,')), ')')"
                                    />
                                </xsl:variable>

                                <xsl:value-of select="substring-after($date, '-')"/>




                            </RiC:endDate>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when
                                test="contains(terme, 'Guadeloupe') or contains(terme, 'Martinique') or contains(terme, 'Réunion') or contains(terme, 'Guyane') or contains(terme, 'Mayotte')">
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('http://id.insee.fr/geo/departement/', $INSEEId)"
                                        />
                                    </xsl:attribute>
                                </owl:sameAs>
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('http://data.ign.fr/id/geofla/departement/', $INSEEId)"
                                        />
                                    </xsl:attribute>
                                </owl:sameAs>
                                <insee-geo:CodeDepartement>
                                    <xsl:value-of select="$INSEEId"/>
                                </insee-geo:CodeDepartement>
                            </xsl:when>
                            <xsl:when test="contains(terme, 'Saint-Pierre-et-Miquelon')">
                                <owl:sameAs
                                    rdf:resource="http://id.insee.fr/geo/collectiviteDOutreMer/975"
                                />
                            </xsl:when>
                            <xsl:when test="$INSEEId != 'non' and $regionName != 'non'">
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('http://id.insee.fr/geo/departement/', $INSEEId)"
                                        />
                                    </xsl:attribute>
                                </owl:sameAs>
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('http://data.ign.fr/id/geofla/departement/', $INSEEId)"
                                        />
                                    </xsl:attribute>
                                </owl:sameAs>
                                <insee-geo:CodeDepartement>
                                    <xsl:value-of select="$INSEEId"/>
                                </insee-geo:CodeDepartement>
                            </xsl:when>
                        </xsl:choose>


                        <RiC:identifier>
                            <xsl:value-of
                                select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', $id)"
                            />
                        </RiC:identifier>
                        <xsl:if test="$regionId != 'non'">
                            <RiC:isPartOf>
                                <xsl:attribute name="rdf:resource">

                                    <xsl:value-of
                                        select="concat($baseURL, 'place/', $ANVocabId, '-', $regionId)"
                                    />
                                </xsl:attribute>
                            </RiC:isPartOf>
                            <geofla:region>
                                <xsl:attribute name="rdf:resource">

                                    <xsl:value-of
                                        select="concat($baseURL, 'place/', $ANVocabId, '-', $regionId)"
                                    />
                                </xsl:attribute>
                            </geofla:region>
                            <!-- <geofla:region>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat('http://data.ign.fr/id/geofla/region/', $regionId)"
                                    />
                                </xsl:attribute>
                            </geofla:region>-->
                        </xsl:if>
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
                <rdf:Description
                    rdf:about="http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-bis">
                    <rdfs:label xml:lang="fr">Paris (Ile-de-France, département)</rdfs:label>
                    <skos:prefLabel xml:lang="fr">Paris (Ile-de-France,
                        département)</skos:prefLabel>

                    <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                    <rdf:type rdf:resource="http://data.ign.fr/def/geofla#Departement"/>
                    <RiC:beginningDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear"
                        >1968</RiC:beginningDate>
                    <owl:sameAs rdf:resource="http://id.insee.fr/geo/departement/75"/>
                    <owl:sameAs rdf:resource="http://data.ign.fr/id/geofla/departement/75"/>
                    <RiC:followsInTime
                        rdf:resource="http://data.archives-nationales.culture.gouv.fr/place/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g"/>
                    <!--  <RiC:hasPlaceName
                        rdf:resource="http://data.archives-nationales.culture.gouv.fr/placeame/FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-bis"
                    />-->
                </rdf:Description>

            </rdf:RDF>
        </xsl:result-document>
        <!-- 2 : les communes -->
        <!-- point de départ :
            
            <d id="d3m08zhht0k-tkyaw3csd7xn">
  <terme>Communes françaises</terme>
  <d id="d3ntcnfgcw-pvic5jinawzd">
   <terme>L'Abergement-Clémenciat (Ain)</terme>
   <noticel>
    <forms>
     <f>L'Abergement-Clémenciat</f>
    </forms>
    <geo>C01-101#001-0001#N01-1</geo>
    <reg>Rhône-Alpes</reg>
    <dpt>Ain</dpt>
    <arr>12</arr>
    <canton>Châtillon-sur-Chalaronne</canton>
    <insee>01001</insee>
   </noticel>
  </d>
            
            -->
        <!-- pour l'instant on localise les communes uniquement aux départemets et régions ; pour les cantons on n'a que le nom donc il faudra trouver l'identifiant du canton dans le RI du SIA via son nom, puis passer par le référentiel INSEE pour apparier nom et numéro de canton.
        POur les arrondissements, idem, sauf qu'on a le numéro et pas le nom. On ira chercher le nom dans le référentiel INSEE puis on retrouvera l'identifiant dans le RI du SIA via le nom.
        -->
        <!-- TODO : ajouter les communes créées après 2013 !! Contrôler les identifiants INSEE/IGN pour les communes fusionnées/déléguées. Contrôler les appartenances aux départements -->

        <xsl:for-each-group select="$communes/d" group-by="noticel/dpt">
            <xsl:sort select="current-grouping-key()"/>
            <!--<xsl:variable name="dept" select="current-grouping-key()"/>-->
            <xsl:variable name="SIAdept"
                select="
                    
                    if (normalize-space(terme) = 'Paris (France)')
                    then
                        '75'
                    else
                        (
                        
                        $departs/d[starts-with(terme, concat(current-grouping-key(), ' ('))])"/>

            <xsl:variable name="SIAdeptId"
                select="
                    if (normalize-space(terme) = 'Paris (France)')
                    then
                        'FRAN_RI_005-d5bdp7f563-3i98jv8c3b0g-bis'
                    
                    else
                        (
                        $SIAdept/@id)"/>
            <xsl:variable name="INSEEdeptId"
                select="
                    
                    if (normalize-space(terme) = 'Paris (France)')
                    then
                        '75'
                    
                    else
                        (
                        
                        
                        $SIAdept/interdits/i[matches(., '\d+')])"/>
            <xsl:result-document method="xml" encoding="utf-8" indent="yes"
                href="{$chemin-places-step1}FRAN_communes_{$INSEEdeptId}.rdf">
                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                    <xsl:for-each select="current-group()">
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', @id)"/>

                            </xsl:attribute>
                            <rdfs:label xml:lang="fr">
                                <xsl:value-of select="normalize-space(terme)"/>
                            </rdfs:label>
                            <skos:prefLabel xml:lang="fr">
                                <xsl:value-of select="normalize-space(terme)"/>
                            </skos:prefLabel>
                            <xsl:for-each select="noticel/forms/f">
                                <skos:altLabel xml:lang="fr">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </skos:altLabel>
                            </xsl:for-each>
                            <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                            <rdf:type rdf:resource="http://data.ign.fr/def/geofla#Commune"/>
                            <RiC:identifier xml:lang="fr">
                                <xsl:value-of
                                    select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', @id)"
                                />
                            </RiC:identifier>
                            <owl:sameAs>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat('http://id.insee.fr/geo/commune/', noticel/insee)"
                                    />
                                </xsl:attribute>


                            </owl:sameAs>
                            <owl:sameAs>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat('http://data.ign.fr/id/geofla/commune/', noticel/insee)"
                                    />
                                </xsl:attribute>


                            </owl:sameAs>
                            <insee-geo:codeCommune>
                                <xsl:value-of select="noticel/insee"/>
                            </insee-geo:codeCommune>
                            <RiC:isPartOf>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                    />
                                </xsl:attribute>

                            </RiC:isPartOf>
                            <geofla:dpt>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                    />
                                </xsl:attribute>
                            </geofla:dpt>
                            <!-- on garde pour l'instant le contenu des éléments arr et canton en note-->
                            <xsl:if test="noticel/arr[normalize-space(.) != '']">
                                <RiC:note xml:lang="fr">
                                    <xsl:value-of select="concat('arrondissement : ', noticel/arr)"
                                    />
                                </RiC:note>
                            </xsl:if>
                            <xsl:if test="noticel/canton[normalize-space(.) != '']">
                                <RiC:note xml:lang="fr">
                                    <xsl:value-of select="concat('canton : ', noticel/canton)"/>
                                </RiC:note>
                            </xsl:if>


                        </rdf:Description>
                    </xsl:for-each>

                </rdf:RDF>


            </xsl:result-document>
        </xsl:for-each-group>
        <!-- 3. Les arrondissements -->
        <!-- fichier INSEE :
            <result>
			<binding name='nomDpt'>
				<literal xml:lang='fr'>Ain</literal>
			</binding>
			<binding name='arr'>
				<uri>http://id.insee.fr/geo/arrondissement/012</uri>
			</binding>
			<binding name='nom'>
				<literal xml:lang='fr'>Bourg-en-Bresse</literal>
			</binding>
			<binding name='numINSEE'>
				<literal datatype='http://www.w3.org/2001/XMLSchema#token'>012</literal>
			</binding>
			<binding name='dept'>
				<uri>http://id.insee.fr/geo/departement/01</uri>
			</binding>
		</result>-->
        <!-- AN : 
                 <d id="d3ntb9s85p-14c38t0elliz2">
   <terme>Bourg-en-Bresse (Ain , arrondissement)</terme>
   
   il y a aussi des : circonscription teritoriale, district administratif, subdivision administrative (16)
  </d>-->
        <xsl:for-each-group select="$arrts/d"
            group-by="
                if (starts-with(terme, 'Château-Chinon (Ville)'))
                then
                    'Nièvre'
                
                else
                    (
                    
                    
                    normalize-space(replace(substring-before(substring-after(terme, '('), ', arrondissement'), '&#xa0;', '')))">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:variable name="groupId" select="generate-id()"/>
            <!--<xsl:variable name="dept" select="current-grouping-key()"/>-->
            <xsl:variable name="SIAdept"
                select="
                    
                    if ($departs/d[starts-with(terme, concat(current-grouping-key(), ' ('))])
                    then
                        $departs/d[starts-with(terme, concat(current-grouping-key(), ' ('))]
                    else
                        ('non')
                    
                    "/>

            <xsl:variable name="SIAdeptId"
                select="
                    if ($SIAdept != 'non')
                    then
                        $SIAdept/@id
                    
                    else
                        ('non')"/>
            <xsl:variable name="INSEEdeptId"
                select="
                    
                    if ($SIAdept != 'non')
                    then
                        $SIAdept/interdits/i[matches(., '\d+')]
                    
                    else
                        (concat('non', current-grouping-key()))"/>
            <!-- <xsl:if test="$INSEEdeptId!='non'">-->
            <xsl:result-document method="xml" encoding="utf-8" indent="yes"
                href="{$chemin-places-step1}FRAN_arrondissements_{$INSEEdeptId}.rdf">
                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                    <xsl:for-each select="current-group()">
                        <xsl:variable name="stdLabelEntry">
                            <xsl:value-of
                                select="
                                    if (starts-with(terme, 'Château-Chinon (Ville)'))
                                    then
                                        'Château-Chinon (Ville)'
                                    
                                    else
                                        (
                                        
                                        
                                        
                                        normalize-space(translate(substring-before(terme, '('), '&#xa0;', '')))"
                            />
                        </xsl:variable>
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', @id)"/>

                            </xsl:attribute>

                            <rdfs:label xml:lang="fr">
                                <!-- <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>-->
                                <xsl:value-of
                                    select="concat($stdLabelEntry, ' (', current-grouping-key(), ', arrondissement)')"
                                />
                            </rdfs:label>
                            <skos:prefLabel xml:lang="fr">
                                <xsl:value-of
                                    select="concat($stdLabelEntry, ' (', current-grouping-key(), ', arrondissement)')"
                                />
                            </skos:prefLabel>

                            <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                            <rdf:type rdf:resource="http://data.ign.fr/def/geofla#Arrondissement"/>
                            <RiC:identifier xml:lang="fr">
                                <xsl:value-of
                                    select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', @id)"
                                />
                            </RiC:identifier>

                            <xsl:if
                                test="$insee-arrs/sparql:results/sparql:result[sparql:binding[@name = 'nomDpt' and normalize-space(sparql:literal) = current-grouping-key()] and sparql:binding[@name = 'nom' and normalize-space(sparql:literal) = $stdLabelEntry]]">
                                <xsl:variable name="sparqlINSEE-node"
                                    select="$insee-arrs/sparql:results/sparql:result[sparql:binding[@name = 'nomDpt' and normalize-space(sparql:literal) = current-grouping-key()] and sparql:binding[@name = 'nom' and normalize-space(sparql:literal) = $stdLabelEntry]]"/>
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$sparqlINSEE-node/sparql:binding[@name = 'arr']/sparql:uri"
                                        />
                                    </xsl:attribute>


                                </owl:sameAs>

                                <owl:sameAs>
                                    <!--<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat('http://data.ign.fr/id/geofla/arrondissement/', $sparqlINSEE-node/sparql:binding[@name = 'numINSEE']/sparql:literal)"
                                        />
                                    </xsl:attribute>

-->
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$sparqlINSEE-node/sparql:binding[@name = 'geoflaArr']/sparql:uri"
                                        />
                                    </xsl:attribute>

                                </owl:sameAs>
                                <insee-geo:codeArrondissement>
                                    <xsl:value-of
                                        select="$sparqlINSEE-node/sparql:binding[@name = 'numINSEE']/sparql:literal"
                                    />
                                </insee-geo:codeArrondissement>
                                <xsl:if
                                    test="$sparqlINSEE-node/sparql:binding[@name = 'vivant' and sparql:literal = 'false']">
                                    <RiC:state xml:lang="fr">disparu</RiC:state>
                                </xsl:if>
                                <xsl:if test="$sparqlINSEE-node/sparql:binding[@name = 'chefLieu']">
                                    <insee-geo:chefLieu>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="$sparqlINSEE-node/sparql:binding[@name = 'chefLieu']/sparql:uri"
                                            />
                                        </xsl:attribute>
                                    </insee-geo:chefLieu>
                                </xsl:if>
                            </xsl:if>
                            <xsl:if test="$SIAdeptId != 'non'">
                                <RiC:isPartOf>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                        />
                                    </xsl:attribute>

                                </RiC:isPartOf>
                                <geofla:dpt>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                        />
                                    </xsl:attribute>
                                </geofla:dpt>
                            </xsl:if>


                        </rdf:Description>
                    </xsl:for-each>

                </rdf:RDF>


            </xsl:result-document>
            <!--</xsl:if>-->
        </xsl:for-each-group>

        <!-- LES CANTONS -->
        <!-- <d id="d3ntbd9ozq-sc33f9ott8w6">
   <terme>Abbeville-Nord (Somme , canton)</terme>
  </d>-->
        <xsl:for-each-group select="$cants/d"
            group-by="normalize-space(replace(substring-before(substring-after(terme, '('), ', canton'), '&#xa0;', ''))">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:variable name="groupId" select="generate-id()"/>
            <!--<xsl:variable name="dept" select="current-grouping-key()"/>-->
            <xsl:variable name="SIAdept"
                select="
                    
                    if ($departs/d[starts-with(terme, concat(current-grouping-key(), ' ('))])
                    then
                        $departs/d[starts-with(terme, concat(current-grouping-key(), ' ('))]
                    else
                        ('non')
                    
                    "/>

            <xsl:variable name="SIAdeptId"
                select="
                    if ($SIAdept != 'non')
                    then
                        $SIAdept/@id
                    
                    else
                        ('non')"/>
            <xsl:variable name="INSEEdeptId"
                select="
                    
                    if ($SIAdept != 'non')
                    then
                        $SIAdept/interdits/i[matches(., '\d+')]
                    
                    else
                        (concat('non', current-grouping-key()))"/>
            <!-- <xsl:if test="$INSEEdeptId!='non'">-->
            <xsl:result-document method="xml" encoding="utf-8" indent="yes"
                href="{$chemin-places-step1}FRAN_cantons_{$INSEEdeptId}.rdf">
                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:insee-geo="http://rdf.insee.fr/def/geo#"
                    xmlns:geofla="http://data.ign.fr/def/geofla#"
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">

                    <xsl:for-each select="current-group()">
                        <xsl:variable name="stdLabelEntry">
                            <xsl:value-of
                                select="normalize-space(translate(substring-before(terme, '('), '&#xa0;', ''))"
                            />
                        </xsl:variable>
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat($baseURL, 'place/', $ANVocabId, '-', @id)"/>

                            </xsl:attribute>

                            <rdfs:label xml:lang="fr">
                                <!-- <xsl:value-of select="normalize-space(replace(terme, '&#x20;,', ','))"/>-->
                                <xsl:value-of
                                    select="concat($stdLabelEntry, ' (', current-grouping-key(), ', canton)')"
                                />
                            </rdfs:label>
                            <skos:prefLabel xml:lang="fr">
                                <xsl:value-of
                                    select="concat($stdLabelEntry, ' (', current-grouping-key(), ', canton)')"
                                />
                            </skos:prefLabel>

                            <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Place"/>
                            <rdf:type rdf:resource="http://data.ign.fr/def/geofla#Canton"/>
                            <RiC:identifier xml:lang="fr">
                                <xsl:value-of
                                    select="concat('Ancien identifiant SIA : ', $ANVocabId, '.xml#', @id)"
                                />
                            </RiC:identifier>
                            <xsl:if
                                test="$insee-cants/sparql:results/sparql:result[sparql:binding[@name = 'nomDpt' and normalize-space(sparql:literal) = current-grouping-key()] and sparql:binding[@name = 'nom' and normalize-space(sparql:literal) = $stdLabelEntry] and sparql:binding[@name = 'cant' and contains(sparql:uri, '/canton/')]]">
                                <xsl:variable name="sparqlINSEE-node"
                                    select="$insee-cants/sparql:results/sparql:result[sparql:binding[@name = 'nomDpt' and normalize-space(sparql:literal) = current-grouping-key()] and sparql:binding[@name = 'nom' and normalize-space(sparql:literal) = $stdLabelEntry] and sparql:binding[@name = 'cant' and contains(sparql:uri, '/canton/')]]"/>
                                <owl:sameAs>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="$sparqlINSEE-node/sparql:binding[@name = 'cant']/sparql:uri"
                                        />
                                    </xsl:attribute>


                                </owl:sameAs>
                                <xsl:choose>
                                    <xsl:when
                                        test="$sparqlINSEE-node/sparql:binding[@name = 'geoflaCant']">
                                        <owl:sameAs>
                                            <xsl:attribute name="rdf:resource">

                                                <xsl:value-of
                                                  select="$sparqlINSEE-node/sparql:binding[@name = 'geoflaCant']/sparql:uri"
                                                />
                                            </xsl:attribute>
                                        </owl:sameAs>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- cas où dans les données INSEE, le canton est une instance de canton2015-->
                                        <alert>pas de correspondance canton IGN</alert>
                                        <owl:sameAs>

                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                  select="concat('http://data.ign.fr/id/geofla/canton/', $sparqlINSEE-node/sparql:binding[@name = 'numINSEE']/sparql:literal)"
                                                />
                                            </xsl:attribute>


                                        </owl:sameAs>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="$sparqlINSEE-node/sparql:binding[@name = 'arr']">
                                    <RiC:isPartOf>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="$sparqlINSEE-node/sparql:binding[@name = 'arr']/sparql:uri"
                                            />
                                        </xsl:attribute>
                                    </RiC:isPartOf>
                                    <geofla:arr>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="$sparqlINSEE-node/sparql:binding[@name = 'arr']/sparql:uri"
                                            />
                                        </xsl:attribute>
                                    </geofla:arr>
                                </xsl:if>

                                <insee-geo:codeCanton>
                                    <xsl:value-of
                                        select="$sparqlINSEE-node/sparql:binding[@name = 'numINSEE']/sparql:literal"
                                    />
                                </insee-geo:codeCanton>
                                <!--<xsl:if test="$sparqlINSEE-node/sparql:binding[@name = 'vivant' and sparql:literal='false']">
                                    <RiC:state xml:lang="fr">disparu</RiC:state>
                                </xsl:if>-->
                                <xsl:if test="$sparqlINSEE-node/sparql:binding[@name = 'chefLieu']">
                                    <insee-geo:chefLieu>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="$sparqlINSEE-node/sparql:binding[@name = 'chefLieu']/sparql:uri"
                                            />
                                        </xsl:attribute>
                                    </insee-geo:chefLieu>
                                </xsl:if>
                            </xsl:if>


                            <xsl:if test="$SIAdeptId != 'non'">
                                <RiC:isPartOf>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                        />
                                    </xsl:attribute>

                                </RiC:isPartOf>
                                <geofla:dpt>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of
                                            select="concat($baseURL, 'place/', $ANVocabId, '-', $SIAdeptId)"
                                        />
                                    </xsl:attribute>
                                </geofla:dpt>
                            </xsl:if>


                        </rdf:Description>
                    </xsl:for-each>

                </rdf:RDF>


            </xsl:result-document>
            <!--</xsl:if>-->
        </xsl:for-each-group>








    </xsl:template>
</xsl:stylesheet>
