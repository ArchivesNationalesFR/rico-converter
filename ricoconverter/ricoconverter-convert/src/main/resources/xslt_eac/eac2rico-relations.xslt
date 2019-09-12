<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="http://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="http://data.archives-nationales.culture.gouv.fr/eac2rico/"
	xmlns:isni="http://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
>

	<!-- Configuration of the types and properties for the possible types of hierarchical relations -->
	<xsl:variable name="HIERARCHICAL_RELATION_CONFIG">
		<AgentHierarchicalRelation>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:agentHierarchicalRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentHierarchicalRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:agentIsTargetOfAgentHierarchicalRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsSourceOfAgentHierarchicalRelation</isSourceOfProperty>
			<label>Relation hiérarchique</label>
		</AgentHierarchicalRelation>
		<GroupSubdivisionRelation>
			<extraType>http://www.ica.org/standards/RiC/ontology#GroupSubdivisionRelation</extraType>
			<targetProperty>rico:groupSubdivisionRelationHasTarget</targetProperty>
			<sourceProperty>rico:groupSubdivisionRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfGroupSubdivisionRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:groupIsSourceOfGroupSubdivisionRelation</isSourceOfProperty>
			<label>Relation de subdivision</label>
		</GroupSubdivisionRelation>
		<AgentControlRelation>
			<extraType>http://www.ica.org/standards/RiC/ontology#AgentControlRelation</extraType>
			<targetProperty>rico:agentControlRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentControlRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:agentIsTargetOfAgentControlRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsSourceOfAgentControlRelation</isSourceOfProperty>
			<label>Relation de contrôle</label>
		</AgentControlRelation>
	</xsl:variable>
	
	<!-- Determine the type of a hierarchicalRelation; the type corresponds to the possible types in $HIERARCHICAL_RELATION_CONFIG -->
	<xsl:template name="hierarchicalRelationType" as="xs:string">
		<xsl:param name="relation"  as="element()?"/>
		<xsl:choose>
	       	<xsl:when test="eac2rico:specifiesGroupSubdivisionRelation(@xlink:arcrole)">GroupSubdivisionRelation</xsl:when>
	       	<xsl:when test="eac2rico:specifiesAgentControlRelation(@xlink:arcrole)">AgentControlRelation</xsl:when>
	       	<!-- If we are processing a "Service d'Administration Centrale"... -->
	       	<xsl:when test="eac2rico:isServiceCentral(/eac:eac-cpf)">
	       		<!-- ...read the description of the referenced entity... -->
	       		<xsl:variable name="externalEntityDescription" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	       		<!-- ...and if it is _also_ a "Service d'Administration Central", then add an extra type to the relation -->
	       		<xsl:choose>
	       			<xsl:when test="eac2rico:isServiceCentral($externalEntityDescription/eac:eac-cpf)">GroupSubdivisionRelation</xsl:when>
	       			<xsl:when test="eac2rico:isMinistere($externalEntityDescription/eac:eac-cpf) and $relation/@cpfRelationType='hierarchical-parent'">GroupSubdivisionRelation</xsl:when>
	       			<xsl:otherwise>AgentHierarchicalRelation</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<!-- If we are processing a "Ministère"... -->
	       	<xsl:when test="eac2rico:isMinistere(/eac:eac-cpf)">
	       		<!-- ...read the description of the referenced entity... -->
	       		<xsl:variable name="externalEntityDescription" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	       		<xsl:choose>
	       			<xsl:when test="eac2rico:isServiceCentral($externalEntityDescription/eac:eac-cpf) and $relation/@cpfRelationType='hierarchical-child'">GroupSubdivisionRelation</xsl:when>
	       			<xsl:when test="eac2rico:isCabinetMinisteriel($externalEntityDescription/eac:eac-cpf) and $relation/@cpfRelationType='hierarchical-child'">GroupSubdivisionRelation</xsl:when>
	       			<xsl:otherwise>AgentHierarchicalRelation</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:when test="eac2rico:denotesAgentControlRelation(eac:descriptiveNote)">AgentControlRelation</xsl:when>
	       	
	       	<xsl:otherwise>AgentHierarchicalRelation</xsl:otherwise>
      	</xsl:choose>		
	</xsl:template>
	
	<xsl:variable name="ASSOCIATIVE_RELATION_CONFIG">
		<AgentRelation>
			<baseType>rico:AgentRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:agentRelationConnects</targetProperty>
			<sourceProperty>rico:agentRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:agentIsConnectedToAgentRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsConnectedToAgentRelation</isSourceOfProperty>
			<label>Relation associative</label>
		</AgentRelation>
		<LeadershipRelation>
			<baseType>rico:AgentHierarchicalRelation</baseType>
			<extraType>http://www.ica.org/standards/RiC/ontology#LeadershipRelation</extraType>
			<targetProperty>rico:leadershipRelationHasTarget</targetProperty>
			<sourceProperty>rico:leadershipRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfLeadershipRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfLeadershipRelation</isSourceOfProperty>
			<label>Relation de direction (leadership)</label>
		</LeadershipRelation>
		<AgentSubordinationRelation>
			<baseType>rico:AgentHierarchicalRelation</baseType>
			<extraType>http://www.ica.org/standards/RiC/ontology#AgentSubordinationRelation</extraType>
			<targetProperty>rico:agentSubordinationRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentSubordinationRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:personIsTargetOfAgentSubordinationRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfAgentSubordinationRelation</isSourceOfProperty>
			<label>Relation hiérarchique (de subordination)</label>
		</AgentSubordinationRelation>
		<AgentMembershipRelation>
			<baseType>rico:AgentMembershipRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:agentMembershipRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentMembershipRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfAgentMembershipRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfAgentMembershipRelation</isSourceOfProperty>
			<label>Relation d'appartenance</label>
		</AgentMembershipRelation>
		<ProfessionalRelation>
			<baseType>rico:ProfessionalRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:professionalRelationConnects</targetProperty>
			<sourceProperty>rico:professionalRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:agentHasProfessionalRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentHasProfessionalRelation</isSourceOfProperty>
			<label>Relation professionnelle (de travail)</label>
		</ProfessionalRelation>
	</xsl:variable>
	
	<!-- Determine the type of an associativeRelation; the type corresponds to the possible types in $ASSOCIATIVE_RELATION_CONFIG -->
	<xsl:template name="associativeRelationType" as="xs:string">
		<xsl:param name="relation"  as="element()?"/>
		<xsl:choose>
			<xsl:when test="eac2rico:specifiesLeadershipRelation(@xlink:arcrole)">LeadershipRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesAgentSubordinationRelation(@xlink:arcrole)">AgentSubordinationRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesProfessionalRelation(@xlink:arcrole)">ProfessionalRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesAgentMembershipRelation(@xlink:arcrole)">AgentMembershipRelation</xsl:when>
	       	<!-- If we detect a specific keyword in the description... -->
	       	<xsl:when test="eac2rico:denotesLeadershipRelation(eac:descriptiveNote)">
	       		<!-- ...read the description of the referenced entity... -->
	       		<xsl:variable name="externalEntityDescription" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))" />
	       		<!-- ...and if one entity is a person and the other is the corporateBody, then this is a LeadershipRelation -->
	       		<xsl:choose>
	       			<xsl:when test="
	       				(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person' and $externalEntityDescription/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody')
	       				or
	       				(/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'corporateBody' and $externalEntityDescription/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person')
	       			">LeadershipRelation</xsl:when>
	       			<xsl:otherwise>AgentRelation</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:otherwise>AgentRelation</xsl:otherwise>
      	</xsl:choose>		
	</xsl:template>
	
	<!-- Determine source entity of an associative or family relation : 
		if this is a LeadershipRelation/AgentMembershipRelation, this is necessarily the person, otherwise this is the entity with the lowest ID -->
	<xsl:template name="associativeOrFamilyRelationSourceEntity">
		<xsl:param name="relation"  as="element()"/>
		<xsl:param name="type"  as="xs:string"/>
		
		<xsl:choose>
			<!-- If there is an @xlink:arcrole, it has priority to determine the orientation of the relation, if it is not unspecified -->
			<xsl:when test="$relation/@xlink:arcrole and $KEYWORDS/AgentRelation/*[local-name() = $type]/Arcroles/Arcrole[@currentEntityRole != 'unspecified']">
				<xsl:choose>
					<xsl:when test="$relation/@xlink:arcrole = $KEYWORDS/AgentRelation/*[local-name() = $type]/Arcroles/Arcrole[@currentEntityRole = 'source']">
			    		<xsl:value-of select="$agentUri" />
			    	</xsl:when>
			    	<xsl:otherwise>
			    		<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
			    	</xsl:otherwise>
		    	</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
		   			<xsl:when test="(normalize-space($type) = 'LeadershipRelation' or normalize-space($type) = 'AgentMembershipRelation')">
		   				<xsl:choose>
		   					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
		   						<xsl:value-of select="$agentUri" />
		   					</xsl:when>
		   					<xsl:otherwise>
		   						<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
		   					</xsl:otherwise>
		   				</xsl:choose>
		   			</xsl:when>
		   			<xsl:otherwise>
		   				<xsl:choose>
		   					<xsl:when test="@xlink:href &gt; /eac:eac-cpf/eac:control/eac:recordId">
		   						<xsl:value-of select="$agentUri" />
		   					</xsl:when>
		   					<xsl:otherwise>
		   						<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
		   					</xsl:otherwise>
		   				</xsl:choose>
		   			</xsl:otherwise>
		   		</xsl:choose>
			</xsl:otherwise>		
		</xsl:choose>
		

	</xsl:template>
	
	<!-- Determine target entity of an associative or family relation : 
		if this is a LeadershipRelation/AgentMembershipRelation, this is necessarily the corporateBody/family, otherwise this is the entity with the highest ID -->
	<xsl:template name="associativeOrFamilyRelationTargetEntity">
		<xsl:param name="relation"  as="element()"/>
		<xsl:param name="type"  as="xs:string"/>
	
		<xsl:choose>
			<!-- If there is an @xlink:arcrole, it has priority to determine the orientation of the relation if it is not unspecified -->
			<xsl:when test="$relation/@xlink:arcrole and $KEYWORDS/AgentRelation/*[local-name() = $type]/Arcroles/Arcrole[@currentEntityRole != 'unspecified']">
				<xsl:choose>
					<xsl:when test="$relation/@xlink:arcrole = $KEYWORDS/AgentRelation/*[local-name() = $type]/Arcroles/Arcrole[@currentEntityRole = 'target']">
			    		<xsl:value-of select="$agentUri" />
			    	</xsl:when>
			    	<xsl:otherwise>
			    		<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
			    	</xsl:otherwise>
			    </xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when
						test="(normalize-space($type) = 'LeadershipRelation' or normalize-space($type) = 'AgentMembershipRelation')">
						<xsl:choose>
							<xsl:when
								test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType != 'person'">
								<xsl:value-of select="$agentUri" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when
								test="@xlink:href &lt; /eac:eac-cpf/eac:control/eac:recordId">
								<xsl:value-of select="$agentUri" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	

	</xsl:template>

	<xsl:variable name="FAMILY_RELATION_CONFIG">
		<FamilyRelation>
			<type>rico:FamilyRelation</type>
			<targetProperty>rico:familyRelationConnects</targetProperty>
			<sourceProperty>rico:familyRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:personHasFamilyRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personHasFamilyRelation</isSourceOfProperty>
			<label>Relation familiale</label>
		</FamilyRelation>
		<AgentMembershipRelation>
			<type>rico:AgentMembershipRelation</type>
			<targetProperty>rico:agentMembershipRelationHasTarget</targetProperty>
			<sourceProperty>rico:agentMembershipRelationHasSource</sourceProperty>
			<isTargetOfProperty>rico:groupIsTargetOfAgentMembershipRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:personIsSourceOfAgentMembershipRelation</isSourceOfProperty>
			<label>Relation d'appartenance</label>
		</AgentMembershipRelation>
		<AgentRelation>
			<type>rico:AgentRelation</type>
			<targetProperty>rico:agentRelationConnects</targetProperty>
			<sourceProperty>rico:agentRelationConnects</sourceProperty>
			<isTargetOfProperty>rico:agentIsConnectedToAgentRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:agentIsConnectedToAgentRelation</isSourceOfProperty>
			<label>Relation</label>
		</AgentRelation>
	</xsl:variable>


	<!-- Determine the type of a family relation; the type corresponds to the possible types in $FAMILY_RELATION_CONFIG -->
	<xsl:template name="familyRelationType">
		<xsl:param name="relation"  as="element()?"/>

		<xsl:variable name="entityType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />		
		<xsl:variable name="externalEntityType" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />

		<xsl:choose>
			<xsl:when test="eac2rico:specifiesAgentMembershipRelation(@xlink:arcrole)">AgentMembershipRelation</xsl:when>
	       	<xsl:when test="$entityType = 'person'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">FamilyRelation</xsl:when>
					<xsl:when test="$externalEntityType = 'family'">AgentMembershipRelation</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning($recordId, 'UNEXPECTED_RELATED_ENTITY_TYPE', $externalEntityType)" />
						AgentRelation
					</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:when test="$entityType = 'family'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">AgentMembershipRelation</xsl:when>
					<xsl:when test="$externalEntityType = 'family'">AgentRelation</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning($recordId, 'UNEXPECTED_RELATED_ENTITY_TYPE', $externalEntityType)" />
						AgentRelation
					</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:otherwise>
	       		<xsl:value-of select="eac2rico:warning($recordId, 'UNEXPECTED_RELATED_ENTITY_TYPE', $externalEntityType)" />
				AgentRelation
	       	</xsl:otherwise>
      	</xsl:choose>			


		
	</xsl:template>	
	

	<!-- Tests if a legalStatus on the entity has the value 'Service d'administration centrale' -->
	<xsl:function name="eac2rico:isServiceCentral" as="xs:boolean">
		<xsl:param name="entityDescriptionRoot"  as="element()?"/>
		<xsl:sequence select="$entityDescriptionRoot/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:term/@vocabularySource='d5blonaxbw--1mt8t42bokzts'" />
	</xsl:function>
	<!-- Tests if a legalStatus on the entity has the value 'Ministère' -->
	<xsl:function name="eac2rico:isMinistere" as="xs:boolean">
		<xsl:param name="entityDescriptionRoot"  as="element()?"/>
		<xsl:sequence select="$entityDescriptionRoot/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:term/@vocabularySource='d5bloo2gwk-sgl3fc00gzgl'" />
	</xsl:function>
	<!-- Tests if a legalStatus on the entity has the value 'Cabinet ministériel' -->
	<xsl:function name="eac2rico:isCabinetMinisteriel" as="xs:boolean">
		<xsl:param name="entityDescriptionRoot"  as="element()?"/>
		<xsl:sequence select="$entityDescriptionRoot/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:term/@vocabularySource='d5blonb04s-1nqrprwwl75h0'" />
	</xsl:function>
	
	<!-- Tests if a relation descriptiveNote indicates an AgentControlRelation. We look if the descriptiveNote contains specific keywords -->
	<xsl:function name="eac2rico:denotesAgentControlRelation" as="xs:boolean">
		<xsl:param name="descriptiveNote"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/AgentControlRelation/Keywords/Keyword[contains(
			replace(normalize-unicode(lower-case($descriptiveNote),'NFKD'),'\P{IsBasicLatin}',''),
			replace(normalize-unicode(lower-case(text()),'NFKD'),'\P{IsBasicLatin}','')
		)] != ''" />
	</xsl:function>
	
	<!-- Tests if a relation descriptiveNote indicates a LeadershipRelation. We look if the descriptiveNote contains specific keywords -->
	<xsl:function name="eac2rico:denotesLeadershipRelation" as="xs:boolean">
		<xsl:param name="descriptiveNote"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/LeadershipRelation/Keywords/Keyword[contains(
			replace(normalize-unicode(lower-case($descriptiveNote),'NFKD'),'\P{IsBasicLatin}',''),
			replace(normalize-unicode(lower-case(text()),'NFKD'),'\P{IsBasicLatin}','')
		)] != ''" />
	</xsl:function>
	
	<!-- Tests if an xlink:arcrole attribute value indicates a GroupSubdivisionRelation -->
	<xsl:function name="eac2rico:specifiesGroupSubdivisionRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/GroupSubdivisionRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates a AgentControlRelation -->
	<xsl:function name="eac2rico:specifiesAgentControlRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/AgentControlRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates a LeadershipRelation -->
	<xsl:function name="eac2rico:specifiesLeadershipRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/LeadershipRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates a AgentSubordinationRelation -->
	<xsl:function name="eac2rico:specifiesAgentSubordinationRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/AgentSubordinationRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates a ProfessionalRelation -->
	<xsl:function name="eac2rico:specifiesProfessionalRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/ProfessionalRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates an AgentMembershopRelation -->
	<xsl:function name="eac2rico:specifiesAgentMembershipRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/AgentMembershipRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
		
</xsl:stylesheet>