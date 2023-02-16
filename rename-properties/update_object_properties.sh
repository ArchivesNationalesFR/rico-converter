## First extract property names with an xslt :
# java -jar ~/programs/saxon/SaxonHE11-4J/saxon-he-11.4.jar -s:updated-object-properties.xml -xsl:extract_properties.xslt -o:updated-object-properties-mapping.txt

# Enlever manuellement hasContentOfType, hasOrHadLanguage, hasOrHadLegalStatus, hasRecordState

## declare an array variable
declare -a arr=(
"accumulatedBy|hasAccumulator"
"accumulates|isAccumulatorOf"
"affectedBy|isOrWasAffectedBy"
"affects|affectsOrAffected"
"belongsToCategory|hasOrHadCategory"
"belongsToDemographicGroup|hasOrHadDemographicGroup"
"collectedBy|hasCollector"
"collects|isCollectorOf"
"containedBy|isOrWasContainedBy"
"contains|containsOrContained"
"controlledBy|hasOrHadController"
"controls|isOrWasControllerOf"
"createdBy|hasCreator"
"createdByMigrationFromInstantiation|migratedFrom"
"describedBy|isOrWasDescribedBy"
"describes|describesOrDescribed"
"enforcedBy|isOrWasEnforcedBy"
"existsIn|existsOrExistedIn"
"expressedBy|isOrWasExpressedBy"
"expresses|expressesOrExpressed"
"follows|followsOrFollowed"
"hasAgentName|hasOrHadAgentName"
"hasAppellation|hasOrHadAppellation"
"hasAuthorityOver|hasOrHadAuthorityOver"
"hasComponent|hasOrHadComponent"
"hasConstituent|hasOrHadConstituent"
"hasCoordinates|hasOrHadCoordinates"
"hasCorporateBodyType|hasOrHadCorporateBodyType"
"hasCorrespondent|hasOrHadCorrespondent"
"hasFamilyLinkWith|hasFamilyAssociationWith"
"hasIntellectualPropertyRightsOn|isOrWasHolderOfIntellectualPropertyRightsOf"
"hasJurisdiction|hasOrHadJurisdiction"
"hasLocation|hasOrHadLocation"
"hasMainSubject|hasOrHadMainSubject"
"hasMember|hasOrHadMember"
"hasName|hasOrHadName"
"hasOccupationOfType|hasOrHadOccupationOfType"
"hasParent|isChildOf"
"hasPart|hasOrHadPart"
"hasPhysicalLocation|hasOrHadPhysicalLocation"
"hasPlaceName|hasOrHadPlaceName"
"hasPlaceType|hasOrHadPlaceType"
"hasPosition|hasOrHadPosition"
"hasRuleType|hasOrHadRuleType"
"hasSpouse|hasOrHadSpouse"
"hasStudent|hasOrHadStudent"
"hasSubEvent|hasOrHadSubevent"
"hasSubdivision|hasOrHadSubdivision"
"hasSubject|hasOrHadSubject"
"hasTeacher|hasOrHadTeacher"
"hasTitle|hasOrHadTitle"
"heldBy|hasOrHadHolder"
"identifiedBy|hasOrHadIdentifier"
"identifies|isOrWasIdentifierOf"
"includedIn|isOrWasIncludedIn"
"includes|includesOrIncluded"
"instantiates|isInstantiationOf"
"intellectualPropertyRightsHeldBy|hasOrHadIntellectualPropertyRightsHolder"
"involvedIn|isOrWasParticipantIn"
"involves|hasOrHadParticipant"
"isAdjacentTo|isOrWasAdjacentTo"
"isAgentNameOf|isOrWasAgentNameOf"
"isAntecedentOf|hasSuccessor"
"isAppellationOf|isOrWasAppellationOf"
"isCategoryOf|isOrWasCategoryOf"
"isComponentOf|isOrWasComponentOf"
"isConstituentOf|isOrWasConstituentOf"
"isCoordinatesOf|isOrWasCoordinatesOf"
"isCorporateBodyTypeOf|isOrWasCorporateBodyTypeOf"
"isDemographicGroupOf|isOrWasDemographicGroupOf"
"isDocumentationOf|documents"
"isHierarchicallyInferiorTo|isOrWasSubordinateTo"
"isHierarchicallySuperiorTo|hasOrHadSubordinate"
"isHolderOf|isOrWasHolderOf"
"isJurisdictionOf|isOrWasJurisdictionOf"
"isLanguageOf|isOrWasLanguageOf"
"isLeaderOf|isOrWasLeaderOf"
"isLegalStatusOf|isOrWasLegalStatusOf"
"isLocationOf|isOrWasLocationOf"
"isMainSubjectOf|isOrWasMainSubjectOf"
"isManagerOf|isOrWasManagerOf"
"isMemberOf|isOrWasMemberOf"
"isMigratedIntoInstantiation|migratedInto"
"isNameOf|isOrWasNameOf"
"isOccupationTypeOf|isOrWasOccupationTypeOf"
"isOwnerOf|isOrWasOwnerOf"
"isPartOf|isOrWasPartOf"
"isPhysicalLocationOf|isOrWasPhysicalLocationOf"
"isPlaceNameOf|isOrWasPlaceNameOf"
"isPlaceTypeOf|isOrWasPlaceTypeOf"
"isRepliedToBy|hasReply"
"isResponsibleForEnforcing|isOrWasResponsibleForEnforcing"
"isRuleTypeOf|isOrWasRuleTypeOf"
"isSubEventOf|isOrWasSubeventOf"
"isSubdivisionOf|isOrWasSubdivisionOf"
"isSubjectOf|isOrWasSubjectOf"
"isTitleOf|isOrWasTitleOf"
"isUnderAuthorityOf|isOrWasUnderAuthorityOf"
"ledBy|hasOrHadLeader"
"managedBy|hasOrHadManager"
"occupiedBy|isOrWasOccupiedBy"
"occupies|occupiesOrOccupied"
"overlaps|overlapsOrOverlapped"
"ownedBy|hasOrHadOwner"
"performedBy|isOrWasPerformedBy"
"performs|performsOrPerformed"
"precedes|precedesOrPreceded"
"publishedBy|hasPublisher"
"publishes|isPublisherOf"
"receivedBy|hasReceiver"
"receives|isReceiverOf"
"regulatedBy|isOrWasRegulatedBy"
"regulates|regulatesOrRegulated"
"repliesTo|isReplyTo"
"resultsFrom|resultsOrResultedFrom"
"resultsIn|resultsOrResultedIn"
"hasWorkRelationWith|hasOrHadWorkRelationWith"
)

## now loop through the above array
for i in "${arr[@]}"
do
   echo " checking : $i"
   a=(${i//|/ })
   oldPropertyName=rico:${a[0]}
   newPropertyName=rico:${a[1]}
   # Pour faire un dry run : (rediriger vers un fichier de sortie)
   # grep -lre $oldPropertyName 20-Sources/rico-converter/ricoconverter/ricoconverter-convert/src/test/resources/ 20-Sources/rico-converter/ricoconverter/ricoconverter-convert/src/main/resources/ | xargs sed --quiet "s/$oldPropertyName/$newPropertyName/gp"
   grep -lre $oldPropertyName ../ricoconverter/ricoconverter-convert/src/test/resources/ ../ricoconverter/ricoconverter-convert/src/main/resources/ | xargs sed -i "s/$oldPropertyName/$newPropertyName/g"
done