<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rico="https://www.ica.org/standards/RiC/ontology#"
	xmlns:eac2rico="https://rdf.archives-nationales.culture.gouv.fr/eac2rico/"
	xmlns:isni="https://isni.org/ontology#"
	xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:html="http://www.w3.org/1999/xhtml"
>

	<!-- Configuration of the types and properties for the possible types of hierarchical relations -->
	<xsl:variable name="HIERARCHICAL_RELATION_CONFIG">
		<AgentHierarchicalRelation>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation hiérarchique</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasOrHadSubordinate</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isOrWasSubordinateTo</shortcutIfSubjectIsTargetOfRelation>
			<shortcutIfSubjectIsSourceOfRelation_current>rico:hasDirectSubordinate</shortcutIfSubjectIsSourceOfRelation_current>
			<shortcutIfSubjectIsTargetOfRelation_current>rico:isDirectSubordinateTo</shortcutIfSubjectIsTargetOfRelation_current>
			<shortcutIfSubjectIsSourceOfRelation_past>rico:hadSubordinate</shortcutIfSubjectIsSourceOfRelation_past>
			<shortcutIfSubjectIsTargetOfRelation_past>rico:wasSubordinateTo</shortcutIfSubjectIsTargetOfRelation_past>
		</AgentHierarchicalRelation>
		<GroupSubdivisionRelation>
			<extraType>https://www.ica.org/standards/RiC/ontology#GroupSubdivisionRelation</extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation de subdivision</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasOrHadSubdivision</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isOrWasSubdivisionOf</shortcutIfSubjectIsTargetOfRelation>
			<shortcutIfSubjectIsSourceOfRelation_current>rico:hasDirectSubdivision</shortcutIfSubjectIsSourceOfRelation_current>
			<shortcutIfSubjectIsTargetOfRelation_current>rico:isDirectSubdivisionOf</shortcutIfSubjectIsTargetOfRelation_current>
			<shortcutIfSubjectIsSourceOfRelation_past>rico:hadSubdivision</shortcutIfSubjectIsSourceOfRelation_past>
			<shortcutIfSubjectIsTargetOfRelation_past>rico:wasSubdivisionOf</shortcutIfSubjectIsTargetOfRelation_past>
		</GroupSubdivisionRelation>
		<AgentControlRelation>
			<extraType>https://www.ica.org/standards/RiC/ontology#AgentControlRelation</extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation de contrôle</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:isOrWasControllerOf</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:hasOrHadController</shortcutIfSubjectIsTargetOfRelation>
			<shortcutIfSubjectIsSourceOfRelation_current>rico:isOrWasControllerOf</shortcutIfSubjectIsSourceOfRelation_current>
			<shortcutIfSubjectIsTargetOfRelation_current>rico:hasOrHadController</shortcutIfSubjectIsTargetOfRelation_current>
			<shortcutIfSubjectIsSourceOfRelation_past>rico:isOrWasControllerOf</shortcutIfSubjectIsSourceOfRelation_past>
			<shortcutIfSubjectIsTargetOfRelation_past>rico:hasOrHadController</shortcutIfSubjectIsTargetOfRelation_past>
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
			<baseType>rico:AgentToAgentRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:relationConnects</targetProperty>
			<sourceProperty>rico:relationConnects</sourceProperty>
			<isTargetOfProperty>rico:thingIsConnectedToRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsConnectedToRelation</isSourceOfProperty>
			<label>Relation associative</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:isAgentAssociatedWithAgent</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isAgentAssociatedWithAgent</shortcutIfSubjectIsTargetOfRelation>
		</AgentRelation>
		<LeadershipRelation>
			<baseType>rico:AgentHierarchicalRelation</baseType>
			<extraType>https://www.ica.org/standards/RiC/ontology#LeadershipRelation</extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation de direction (leadership)</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:isOrWasLeaderOf</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:hasOrHadLeader</shortcutIfSubjectIsTargetOfRelation>
		</LeadershipRelation>
		<MembershipRelation>
			<baseType>rico:MembershipRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation d'appartenance</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasOrHadMember</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isOrWasMemberOf</shortcutIfSubjectIsTargetOfRelation>
		</MembershipRelation>
		<WorkRelation>
			<baseType>rico:WorkRelation</baseType>
			<!-- no extra type here -->
			<extraType></extraType>
			<targetProperty>rico:relationConnects</targetProperty>
			<sourceProperty>rico:relationConnects</sourceProperty>
			<isTargetOfProperty>rico:thingIsConnectedToRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsConnectedToRelation</isSourceOfProperty>
			<label>Relation professionnelle (de travail)</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasOrHadWorkRelationWith</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:hasOrHadWorkRelationWith</shortcutIfSubjectIsTargetOfRelation>
		</WorkRelation>
		<!-- Note how AgentControlRelation is present in both hierarchical and associative relation configs -->
		<AgentControlRelation>
			<baseType>rico:AgentHierarchicalRelation</baseType>
			<extraType>https://www.ica.org/standards/RiC/ontology#AgentControlRelation</extraType>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation de contrôle</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:isOrWasControllerOf</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:hasOrHadController</shortcutIfSubjectIsTargetOfRelation>
		</AgentControlRelation>
	</xsl:variable>
	
	<!-- Determine the type of an associativeRelation; the type corresponds to the possible types in $ASSOCIATIVE_RELATION_CONFIG -->
	<xsl:template name="associativeRelationType" as="xs:string">
		<xsl:param name="relation"  as="element()?"/>
		<xsl:choose>
			<xsl:when test="eac2rico:specifiesLeadershipRelation(@xlink:arcrole)">LeadershipRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesWorkRelation(@xlink:arcrole)">WorkRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesMembershipRelation(@xlink:arcrole)">MembershipRelation</xsl:when>
			<xsl:when test="eac2rico:specifiesAgentControlRelation(@xlink:arcrole)">AgentControlRelation</xsl:when>
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
		if this is a MembershipRelation, this is necessarily the corporateBody/family.
		if this is a LeadershipRelation, this is necessarily the person.
		otherwise this is the entity with the lowest ID
    -->
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
		   			<xsl:when test="(normalize-space($type) = 'MembershipRelation')">
		   				<xsl:choose>
		   					<xsl:when test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType != 'person'">
		   						<xsl:value-of select="$agentUri" />
		   					</xsl:when>
		   					<xsl:otherwise>
		   						<xsl:value-of select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
		   					</xsl:otherwise>
		   				</xsl:choose>
		   			</xsl:when>
		   			<xsl:when test="(normalize-space($type) = 'LeadershipRelation')">
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
	
	
	
	<!-- 
	    Determine target entity of an associative or family relation : 
		if this is a MembershipRelation, this is necessarily the person.
		if this is a LeadershipRelation, this is necessarily the corporateBody/family.
		otherwise this is the entity with the highest ID
	-->
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
						test="(normalize-space($type) = 'MembershipRelation')">
						<xsl:choose>
							<xsl:when
								test="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType = 'person'">
								<xsl:value-of select="$agentUri" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="eac2rico:URI-AgentExternal(@xlink:href, document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml')))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when
						test="(normalize-space($type) = 'LeadershipRelation')">
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
			<targetProperty>rico:relationConnects</targetProperty>
			<sourceProperty>rico:relationConnects</sourceProperty>
			<isTargetOfProperty>rico:thingIsConnectedToRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsConnectedToRelation</isSourceOfProperty>
			<label>Relation familiale</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasFamilyAssociationWith</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:hasFamilyAssociationWith</shortcutIfSubjectIsTargetOfRelation>
		</FamilyRelation>
		<MembershipRelation>
			<type>rico:MembershipRelation</type>
			<targetProperty>rico:relationHasTarget</targetProperty>
			<sourceProperty>rico:relationHasSource</sourceProperty>
			<isTargetOfProperty>rico:thingIsTargetOfRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsSourceOfRelation</isSourceOfProperty>
			<label>Relation d'appartenance</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:hasOrHadMember</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isOrWasMemberOf</shortcutIfSubjectIsTargetOfRelation>
		</MembershipRelation>
		<AgentRelation>
			<type>rico:AgentToAgentRelation</type>
			<targetProperty>rico:relationConnects</targetProperty>
			<sourceProperty>rico:relationConnects</sourceProperty>
			<isTargetOfProperty>rico:thingIsConnectedToRelation</isTargetOfProperty>
			<isSourceOfProperty>rico:thingIsConnectedToRelation</isSourceOfProperty>
			<label>Relation</label>
			<shortcutIfSubjectIsSourceOfRelation>rico:isAgentAssociatedWithAgent</shortcutIfSubjectIsSourceOfRelation>
			<shortcutIfSubjectIsTargetOfRelation>rico:isAgentAssociatedWithAgent</shortcutIfSubjectIsTargetOfRelation>
		</AgentRelation>
	</xsl:variable>


	<!-- Determine the type of a family relation; the type corresponds to the possible types in $FAMILY_RELATION_CONFIG -->
	<xsl:template name="familyRelationType">
		<xsl:param name="relation"  as="element()?"/>

		<xsl:variable name="entityType" select="/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />		
		<xsl:variable name="externalEntityType" select="document(concat($INPUT_FOLDER, '/', @xlink:href, '.xml'))/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType" />

		<xsl:choose>
			<xsl:when test="eac2rico:specifiesMembershipRelation(@xlink:arcrole)">MembershipRelation</xsl:when>
	       	<xsl:when test="$entityType = 'person'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">FamilyRelation</xsl:when>
					<xsl:when test="$externalEntityType = 'family'">MembershipRelation</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="eac2rico:warning($recordId, 'UNEXPECTED_RELATED_ENTITY_TYPE', $externalEntityType)" />
						AgentRelation
					</xsl:otherwise>
	       		</xsl:choose>
	       	</xsl:when>
	       	
	       	<xsl:when test="$entityType = 'family'">
	       		<xsl:choose>
	       			<xsl:when test="$externalEntityType = 'person'">MembershipRelation</xsl:when>
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
	<!-- Tests if an xlink:arcrole attribute value indicates a WorkRelation -->
	<xsl:function name="eac2rico:specifiesWorkRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/WorkRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
	<!-- Tests if an xlink:arcrole attribute value indicates an AgentMembershopRelation -->
	<xsl:function name="eac2rico:specifiesMembershipRelation" as="xs:boolean">
		<xsl:param name="arcrole"  as="xs:string?" />
		<xsl:sequence select="$KEYWORDS/AgentRelation/MembershipRelation/Arcroles/Arcrole[text() = $arcrole] != ''" />
	</xsl:function>
		
</xsl:stylesheet>