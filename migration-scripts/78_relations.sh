# PerformanceRelation
find -type f -exec sed -i 's/rico:performanceRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:performanceRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:agentIsTargetOfPerformanceRelation/rico:thingIsTargetOfRelation/g' {} +
find -type f -exec sed -i 's/rico:activityIsSourceOfPerformanceRelation/rico:thingIsSourceOfRelation/g' {} +

# TypeRelation
find -type f -exec sed -i 's/rico:typeRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:typeRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:thingIsTargetOfTypeRelation/rico:thingIsTargetOfRelation/g' {} +

# AgentOriginationRelation renamed to OrganicProvenanceRelation
find -type f -exec sed -i 's/rico:AgentOriginationRelation/rico:OrganicProvenanceRelation/g' {} +
find -type f -exec sed -i 's/rico:agentOriginationRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:agentOriginationRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:agentIsTargetOfAgentOriginationRelation/rico:thingIsTargetOfRelation/g' {} +
# shortcut rename
find -type f -exec sed -i 's/rico:isProvenanceOf/rico:isOrganicProvenanceOf/g' {} +

# MandateRelation
find -type f -exec sed -i 's/rico:mandateRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:mandateRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:agentIsTargetOfMandateRelation/rico:thingIsTargetOfRelation/g' {} +

# PlaceRelation
find -type f -exec sed -i 's/rico:placeRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:placeRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:thingIsTargetOfPlaceRelation/rico:thingIsTargetOfRelation/g' {} +