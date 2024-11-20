# relationHasTarget
find -type f -exec sed -i 's/rico:agentHierarchicalRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:groupSubdivisionRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:agentControlRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:leadershipRelationHasTarget/rico:relationHasTarget/g' {} +
find -type f -exec sed -i 's/rico:membershipRelationHasTarget/rico:relationHasTarget/g' {} +
# relationHasSource
find -type f -exec sed -i 's/rico:agentHierarchicalRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:groupSubdivisionRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:agentControlRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:leadershipRelationHasSource/rico:relationHasSource/g' {} +
find -type f -exec sed -i 's/rico:membershipRelationHasSource/rico:relationHasSource/g' {} +
# relationConnects
find -type f -exec sed -i 's/rico:agentRelationConnects/rico:relationConnects/g' {} +
find -type f -exec sed -i 's/rico:workRelationConnects/rico:relationConnects/g' {} +
find -type f -exec sed -i 's/rico:familyRelationConnects/rico:relationConnects/g' {} +
# thingIsTargetOfRelation
find -type f -exec sed -i 's/rico:agentIsTargetOfAgentHierarchicalRelation/rico:thingIsTargetOfRelation/g' {} +
find -type f -exec sed -i 's/rico:groupIsTargetOfGroupSubdivisionRelation/rico:thingIsTargetOfRelation/g' {} +
find -type f -exec sed -i 's/rico:agentIsTargetOfAgentControlRelation/rico:thingIsTargetOfRelation/g' {} +
find -type f -exec sed -i 's/rico:groupIsTargetOfLeadershipRelation/rico:thingIsTargetOfRelation/g' {} +
find -type f -exec sed -i 's/rico:personIsTargetOfMembershipRelation/rico:thingIsTargetOfRelation/g' {} +
# thingIsSourceOfRelation
find -type f -exec sed -i 's/rico:agentIsSourceOfAgentHierarchicalRelation/rico:thingIsSourceOfRelation/g' {} +
find -type f -exec sed -i 's/rico:groupIsSourceOfGroupSubdivisionRelation/rico:thingIsSourceOfRelation/g' {} +
find -type f -exec sed -i 's/rico:agentIsSourceOfAgentControlRelation/rico:thingIsSourceOfRelation/g' {} +
find -type f -exec sed -i 's/rico:personIsSourceOfLeadershipRelation/rico:thingIsSourceOfRelation/g' {} +
find -type f -exec sed -i 's/rico:groupIsSourceOfMembershipRelation/rico:thingIsSourceOfRelation/g' {} +
# thingIsConnectedToRelation
find -type f -exec sed -i 's/rico:agentIsConnectedToAgentRelation/rico:thingIsConnectedToRelation/g' {} +
find -type f -exec sed -i 's/rico:agentHasWorkRelation/rico:thingIsConnectedToRelation/g' {} +
find -type f -exec sed -i 's/rico:personHasFamilyRelation/rico:thingIsConnectedToRelation/g' {} +