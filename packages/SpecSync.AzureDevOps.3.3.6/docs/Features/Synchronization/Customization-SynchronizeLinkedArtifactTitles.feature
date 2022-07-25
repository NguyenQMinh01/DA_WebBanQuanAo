Feature: Customization: Synchronize linked artifact titles

Rule: The Work Item title should be added to the tag on linking

@tc:721
Scenario: The work item tag is removed from the scenario
	Given there is an Azure DevOps project with a Product Backlog Item "Sample requirement"
	And the synchronizer is configured as
		| setting                                                          | value |
		| synchronization/links[]/tagPrefix                                | pbi   |
		| customizations/synchronizeLinkedArtifactTitles/enabled           | true  |
		| customizations/synchronizeLinkedArtifactTitles/linkTagPrefixes[] | pbi   |
	And a @pbi tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the Test Case should be linked to the Product Backlog Item
	And a tag "@pbi:[id-of-pbi]:Sample_requirement" should have been added to the scenario in the local workspace

Rule: When the Work Item title is updated, the link tag should be updated when the scenario changes

@tc:722
Scenario: The work item tag is updated for a new title when the scenario is synchronized
	Given there is an Azure DevOps project with a Product Backlog Item "Sample requirement"
	And the synchronizer is configured as
		| setting                                                          | value |
		| synchronization/links[]/tagPrefix                                | pbi   |
		| customizations/synchronizeLinkedArtifactTitles/enabled           | true  |
		| customizations/synchronizeLinkedArtifactTitles/linkTagPrefixes[] | pbi   |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi]:Sample_requirement
		Scenario: Sample scenario
			When I do something
		"""
	And the Product Backlog Item title has been updated to "Updated requirement"
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi]:Sample_requirement
		Scenario: Updated sample scenario
			When I do something new
		"""
	Then the scenario tags should have been updated to contain "@pbi:[id-of-pbi]:Updated_requirement" in the local workspace
