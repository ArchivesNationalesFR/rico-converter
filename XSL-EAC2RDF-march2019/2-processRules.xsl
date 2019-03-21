<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:eac="urn:isbn:1-931666-33-4" xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    
    xmlns:iso-thes="http://purl.org/iso25964/skos-thes#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:xl="http://www.w3.org/2008/05/skos-xl#"
    xmlns:ginco="http://data.culture.fr/thesaurus/ginco/ns/"
    exclude-result-prefixes="xs xd eac iso-thes foaf dct xl dc ginco xlink skos"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> July, 3 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Florence Clavaud</xd:p>
            <xd:p>Revised on March 11, 2019</xd:p>
            
            <xd:p>Step 2 : generating an RDF file for handling rules, after having simply grouped them by their description (this can probably be enhanced).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="document('params.xml')/params"/>
    
    <xsl:variable name="baseURL" select="$params/baseURL"/>
 
    <xsl:variable name="chemin-EAC-AN">
        <xsl:value-of
            select="concat('src-2/', '?select=*.xml;recurse=yes;on-error=warning')"
        />
    </xsl:variable>
    <xsl:variable name="collection-EAC-AN" select="collection($chemin-EAC-AN)"/>
    <xsl:template match="/vide">
        
        
       
            <xsl:result-document href="rdf/rules/FRAN_rules.rdf" method="xml" encoding="utf-8" indent="yes">
                <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/"
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:owl="http://www.w3.org/2002/07/owl#"
                    xmlns:RiC="http://www.ica.org/standards/RiC/ontology#"
                   
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                   
                    xmlns:skos="http://www.w3.org/2004/02/skos/core#">
                   
                    <!--<xsl:for-each-group
                        select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/descendant::eac:mandate"
                        group-by="
                        
                         if (contains(eac:citation, '('))
                         then (if (starts-with(normalize-space(eac:citation), '-'))
                         then (normalize-space(substring-before(substring-after(eac:citation, '-'), '(')))
                         else(
                         
                         normalize-space(substring-before(eac:citation, '('))
                         )
                         
                         )
                         else(
                          if (contains(eac:citation, ':'))
                          
                          then (if (starts-with(normalize-space(eac:citation), '-'))
                          then (normalize-space(substring-before(substring-after(eac:citation, '-'), ':')))
                          else(
                          
                          normalize-space(substring-before(eac:citation, ':'))
                          ))
                          else(
                          if (starts-with(normalize-space(eac:citation), '-'))
                          then (normalize-space(substring-after(eac:citation, '-')))
                          else(
                          
                          if (ends-with(normalize-space(eac:citation), ';'))
                          then (normalize-space(substring(normalize-space(eac:citation), 1, string-length(normalize-space(eac:citation)) -1)))
                          else(
                          
                          if (ends-with(normalize-space(eac:citation), '.'))
                          then (normalize-space(substring(normalize-space(eac:citation), 1, string-length(normalize-space(eac:citation)) -1)))
                          else(
                          
                          normalize-space(eac:citation)
                          )
                          
                          )
                          
                          )
                          )
                         )
                        ">
                        <xsl:sort select="current-grouping-key()"/>
                       <!-\- <xsl:variable name="num" select="format-number(number(position()), '#000')"/>-\->
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:text>http://piaaf.demo.logilab.fr/resource/FRAN_mandate_</xsl:text>
                                <!-\-<xsl:value-of select="$num"/>-\->
                                <xsl:value-of select="substring-after(current-group()[1]/@xml:id, 'ma_')"/>
                            </xsl:attribute>
                            <rdf:type
                                rdf:resource="http://www.ica.org/standards/RiC/ontology#Mandate"/>
                            
                            <rdfs:label xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </rdfs:label>
                            
                            <xsl:for-each-group select="current-group()" group-by=" if (starts-with(normalize-space(eac:citation), '-'))
                                then (normalize-space(substring-after(eac:citation, '-')))
                                else(
                                
                                if (ends-with(normalize-space(eac:citation), ';'))
                                then (normalize-space(substring(normalize-space(eac:citation), 1, string-length(normalize-space(eac:citation)) -1)))
                                else(
                                
                                if (ends-with(normalize-space(eac:citation), '.'))
                                then (normalize-space(substring(normalize-space(eac:citation), 1, string-length(normalize-space(eac:citation)) -1)))
                                else(
                                
                                normalize-space(eac:citation)
                                )
                                
                                )
                                
                                )">
                                <xsl:sort select="current-grouping-key()"></xsl:sort>
                                <RiC:hasTitle xml:lang="fr">
                                    <!-\-<xsl:value-of select="normalize-space(eac:citation)"/>-\->
                                    <!-\-    <xsl:value-of select="current-grouping-key()"/>-\->
                                    <xsl:value-of select="current-grouping-key()"/>
                                </RiC:hasTitle>
                                <xsl:if test="eac:descriptiveNote">
                                    <RiC:description xml:lang="fr">
                                        <xsl:value-of select="normalize-space(eac:descriptiveNote)"/>
                                    </RiC:description>
                                </xsl:if>
                            </xsl:for-each-group>
                       
                        </rdf:Description>
                    
                    </xsl:for-each-group>
                   -->
                    <xsl:for-each-group select="$collection-EAC-AN/eac:eac-cpf/eac:cpfDescription/eac:description/descendant::eac:mandate/eac:descriptiveNote/eac:p[starts-with(normalize-space(.), '- Arrêté') or starts-with(normalize-space(.), '- Circulaire') or starts-with(normalize-space(.), '- Code') or starts-with(normalize-space(.), '- Convention') or starts-with(normalize-space(.), '- Décision') or starts-with(normalize-space(.), '- Déclaration') or starts-with(normalize-space(.), '- Décret') or starts-with(normalize-space(.), '- Loi') or starts-with(normalize-space(.), '- Ordonnance') or starts-with(normalize-space(.), '- arrêté') or starts-with(normalize-space(.), '- circulaire') or starts-with(normalize-space(.), '- décret') or starts-with(normalize-space(.), '- instruction') or starts-with(normalize-space(.), '- loi') or starts-with(normalize-space(.), '- ordonnance') or starts-with(normalize-space(.), 'Acte') or starts-with(normalize-space(.), 'Arch. nat.') or starts-with(normalize-space(.), 'Archives nationales') or starts-with(normalize-space(.), 'Arrêté') or starts-with(normalize-space(.), 'Avenant') or starts-with(normalize-space(.), 'BB/10/') or starts-with(normalize-space(.), 'Circulaire') or starts-with(normalize-space(.), 'Code') or starts-with(normalize-space(.), 'Constitution') or starts-with(normalize-space(.), 'Convention') or starts-with(normalize-space(.), 'Créé') or starts-with(normalize-space(.), 'Décision') or starts-with(normalize-space(.), 'Déclaration') or starts-with(normalize-space(.), 'Décret') or starts-with(normalize-space(.), 'JORF') or starts-with(normalize-space(.), 'LOI') or starts-with(normalize-space(.), 'Lettre de provision') or starts-with(normalize-space(.), 'Lettres de provision') or starts-with(normalize-space(.), 'Loi') or starts-with(normalize-space(.), 'Ordonnance') or starts-with(normalize-space(.), 'Règlement') or starts-with(normalize-space(.), 'Statuts') or starts-with(normalize-space(.), 'V/1/') or starts-with(normalize-space(.), 'décret') or starts-with(normalize-space(.), 'loi') or starts-with(normalize-space(.), 'ordonnance') or starts-with(normalize-space(.), '- Arrêté')]"
                        group-by="
                        if (starts-with(normalize-space(.), '- '))                      
                        
                        then (
                        
                        concat(upper-case(substring(normalize-space(substring-after(., '- ')), 1, 1)), substring(normalize-space(substring-after(., '- ')), 2))
                        
                        )
                        else (
                        concat(upper-case(substring(normalize-space(.), 1, 1)), substring(normalize-space(.), 2))
                        
                        )
                        ">
                        <xsl:sort select="current-grouping-key()"/>
                        
                        <rdf:Description>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="concat($baseURL, 'rule/', substring-after(current-group()[1]/@xml:id, '_rule_'))"/>
                              
                            </xsl:attribute>
                            <rdf:type
                                rdf:resource="http://www.ica.org/standards/RiC/ontology#Rule"/>
                            <RiC:title xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </RiC:title>
                            
                            <rdfs:label xml:lang="fr">
                                <xsl:value-of select="current-grouping-key()"/>
                            </rdfs:label>
                            
                           
                            
                           <!-- <xsl:for-each select="current-group()">
                                <xsl:variable name="recId" select="substring-after(ancestor::eac:eac-cpf/eac:control/eac:recordId, 'FRAN_NP_')"/>
                                <xsl:variable name="recType" select="ancestor::eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType"/>
                                <RiC:regulates>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="concat($baseURL, $recType,'/', $recId)"/>
                                    </xsl:attribute>
                                </RiC:regulates>
                            </xsl:for-each>-->
                        </rdf:Description>
                    </xsl:for-each-group>
                  
                    <rdf:Description rdf:about="http://data.archives-nationales.culture.gouv.fr/rule/rl001">
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Rule"/>
                        <rdfs:label xml:lang="fr">AFNOR Z44-060</rdfs:label>
                        <RiC:identifier xml:lang="fr">AFNOR Z44-060</RiC:identifier>
                        <RiC:title xml:lang="fr">AFNOR NF Z 44-060, décembre 1996. Documentation - Catalogue d'auteurs et d’anonymes - Forme et structure des vedettes de collectivités-auteurs</RiC:title>
                    </rdf:Description>
                    <rdf:Description rdf:about="http://data.archives-nationales.culture.gouv.fr/rule/rl002">
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Rule"/>
                        <rdfs:label xml:lang="fr">AFNOR Z44-061</rdfs:label>
                        <RiC:identifier xml:lang="fr">AFNOR Z44-061</RiC:identifier>
                        <RiC:title xml:lang="fr">AFNOR NF Z44-061 Juin 1986 Documentation - Catalogage - Forme et structure des vedettes noms de personnes, des vedettes titres, des rubriques de classement et des titres forgés</RiC:title>
                    </rdf:Description>
                   
                  
                    <rdf:Description rdf:about="http://data.archives-nationales.culture.gouv.fr/rule/rl003">
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Rule"/>
                        <rdfs:label xml:lang="fr">ICA ISAAR(CPF)</rdfs:label>
                        <RiC:identifier xml:lang="fr">ICA ISAAR(CPF)</RiC:identifier>
                        <RiC:title xml:lang="fr">Norme internationale pour les notices d’autorité archivistiques (Collectivités, personnes, familles) du Conseil international des archives, 2ème édition, 1996</RiC:title>
                    </rdf:Description>
                    <rdf:Description rdf:about="http://data.archives-nationales.culture.gouv.fr/rule/rl004">
                        <rdf:type rdf:resource="http://www.ica.org/standards/RiC/ontology#Rule"/>
                        <rdfs:label xml:lang="fr">ISO 8601</rdfs:label>
                        <RiC:identifier xml:lang="fr">ISO 8601</RiC:identifier>
                        <RiC:title xml:lang="fr">Norme ISO 8601:2004 Éléments de données et formats d’échange -- Échange d’information -- Représentation de la date et de l’heure</RiC:title>
                    </rdf:Description>
                </rdf:RDF>
                
            </xsl:result-document>
        
    </xsl:template>

</xsl:stylesheet>
